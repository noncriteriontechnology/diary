const express = require('express');
const Appointment = require('../models/Appointment');
const Client = require('../models/Client');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Apply authentication middleware to all routes
router.use(protect);

// @route   GET /api/appointments
// @desc    Get all appointments for the authenticated user
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      startDate, 
      endDate, 
      status, 
      clientId, 
      appointmentType,
      sortBy = 'startDateTime',
      sortOrder = 'asc'
    } = req.query;

    // Build query
    const query = { userId: req.user.id, isActive: true };

    // Date range filter
    if (startDate || endDate) {
      query.startDateTime = {};
      if (startDate) query.startDateTime.$gte = new Date(startDate);
      if (endDate) query.startDateTime.$lte = new Date(endDate);
    }

    // Add filters
    if (status) query.status = status;
    if (clientId) query.clientId = clientId;
    if (appointmentType) query.appointmentType = appointmentType;

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query with pagination and populate client info
    const appointments = await Appointment.find(query)
      .populate('clientId', 'name phone email')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('-notes -documents'); // Exclude large fields for list view

    // Get total count for pagination
    const total = await Appointment.countDocuments(query);

    res.json({
      success: true,
      data: appointments,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total,
        limit
      }
    });
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointments'
    });
  }
});

// @route   GET /api/appointments/calendar
// @desc    Get appointments for calendar view
// @access  Private
router.get('/calendar', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date and end date are required for calendar view'
      });
    }

    const appointments = await Appointment.find({
      userId: req.user.id,
      isActive: true,
      startDateTime: {
        $gte: new Date(startDate),
        $lte: new Date(endDate)
      }
    })
    .populate('clientId', 'name phone')
    .select('title startDateTime endDateTime status priority appointmentType clientId location')
    .sort({ startDateTime: 1 });

    res.json({
      success: true,
      data: appointments
    });
  } catch (error) {
    console.error('Get calendar appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching calendar appointments'
    });
  }
});

// @route   GET /api/appointments/:id
// @desc    Get single appointment by ID
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const appointment = await Appointment.findOne({
      _id: req.params.id,
      userId: req.user.id,
      isActive: true
    }).populate('clientId', 'name phone email address');

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    res.json({
      success: true,
      data: appointment
    });
  } catch (error) {
    console.error('Get appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointment'
    });
  }
});

// @route   POST /api/appointments
// @desc    Create new appointment
// @access  Private
router.post('/', async (req, res) => {
  try {
    const appointmentData = {
      ...req.body,
      userId: req.user.id
    };

    // Validate client exists and belongs to user
    const client = await Client.findOne({
      _id: appointmentData.clientId,
      userId: req.user.id,
      isActive: true
    });

    if (!client) {
      return res.status(400).json({
        success: false,
        message: 'Invalid client ID or client not found'
      });
    }

    // Check for scheduling conflicts
    const conflictingAppointment = await Appointment.findOne({
      userId: req.user.id,
      isActive: true,
      status: { $nin: ['Cancelled', 'Completed'] },
      $or: [
        {
          startDateTime: {
            $lt: new Date(appointmentData.endDateTime),
            $gte: new Date(appointmentData.startDateTime)
          }
        },
        {
          endDateTime: {
            $gt: new Date(appointmentData.startDateTime),
            $lte: new Date(appointmentData.endDateTime)
          }
        },
        {
          startDateTime: { $lte: new Date(appointmentData.startDateTime) },
          endDateTime: { $gte: new Date(appointmentData.endDateTime) }
        }
      ]
    });

    if (conflictingAppointment) {
      return res.status(400).json({
        success: false,
        message: 'Time slot conflicts with existing appointment',
        conflictingAppointment: {
          id: conflictingAppointment._id,
          title: conflictingAppointment.title,
          startDateTime: conflictingAppointment.startDateTime,
          endDateTime: conflictingAppointment.endDateTime
        }
      });
    }

    const appointment = await Appointment.create(appointmentData);
    
    // Populate client info for response
    await appointment.populate('clientId', 'name phone email');

    res.status(201).json({
      success: true,
      message: 'Appointment created successfully',
      data: appointment
    });
  } catch (error) {
    console.error('Create appointment error:', error);
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: messages
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while creating appointment'
    });
  }
});

// @route   PUT /api/appointments/:id
// @desc    Update appointment
// @access  Private
router.put('/:id', async (req, res) => {
  try {
    // If updating time, check for conflicts
    if (req.body.startDateTime || req.body.endDateTime) {
      const existingAppointment = await Appointment.findOne({
        _id: req.params.id,
        userId: req.user.id,
        isActive: true
      });

      if (!existingAppointment) {
        return res.status(404).json({
          success: false,
          message: 'Appointment not found'
        });
      }

      const startDateTime = req.body.startDateTime || existingAppointment.startDateTime;
      const endDateTime = req.body.endDateTime || existingAppointment.endDateTime;

      // Check for scheduling conflicts (excluding current appointment)
      const conflictingAppointment = await Appointment.findOne({
        _id: { $ne: req.params.id },
        userId: req.user.id,
        isActive: true,
        status: { $nin: ['Cancelled', 'Completed'] },
        $or: [
          {
            startDateTime: {
              $lt: new Date(endDateTime),
              $gte: new Date(startDateTime)
            }
          },
          {
            endDateTime: {
              $gt: new Date(startDateTime),
              $lte: new Date(endDateTime)
            }
          },
          {
            startDateTime: { $lte: new Date(startDateTime) },
            endDateTime: { $gte: new Date(endDateTime) }
          }
        ]
      });

      if (conflictingAppointment) {
        return res.status(400).json({
          success: false,
          message: 'Time slot conflicts with existing appointment',
          conflictingAppointment: {
            id: conflictingAppointment._id,
            title: conflictingAppointment.title,
            startDateTime: conflictingAppointment.startDateTime,
            endDateTime: conflictingAppointment.endDateTime
          }
        });
      }
    }

    const appointment = await Appointment.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        isActive: true
      },
      req.body,
      {
        new: true,
        runValidators: true
      }
    ).populate('clientId', 'name phone email');

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    res.json({
      success: true,
      message: 'Appointment updated successfully',
      data: appointment
    });
  } catch (error) {
    console.error('Update appointment error:', error);
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: messages
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while updating appointment'
    });
  }
});

// @route   DELETE /api/appointments/:id
// @desc    Delete appointment (soft delete)
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const appointment = await Appointment.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        isActive: true
      },
      { isActive: false },
      { new: true }
    );

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    res.json({
      success: true,
      message: 'Appointment deleted successfully'
    });
  } catch (error) {
    console.error('Delete appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting appointment'
    });
  }
});

// @route   PUT /api/appointments/:id/status
// @desc    Update appointment status
// @access  Private
router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Status is required'
      });
    }

    const appointment = await Appointment.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        isActive: true
      },
      { status },
      {
        new: true,
        runValidators: true
      }
    ).populate('clientId', 'name phone email');

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    res.json({
      success: true,
      message: 'Appointment status updated successfully',
      data: appointment
    });
  } catch (error) {
    console.error('Update appointment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating appointment status'
    });
  }
});

module.exports = router;
