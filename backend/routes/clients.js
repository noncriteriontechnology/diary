const express = require('express');
const Client = require('../models/Client');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Apply authentication middleware to all routes
router.use(protect);

// @route   GET /api/clients
// @desc    Get all clients for the authenticated user
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 10, search, status, caseType, sortBy = 'createdAt', sortOrder = 'desc' } = req.query;

    // Build query
    const query = { userId: req.user.id, isActive: true };

    // Add search functionality
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
        { caseNumber: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    // Add filters
    if (status) query.status = status;
    if (caseType) query.caseType = caseType;

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query with pagination
    const clients = await Client.find(query)
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('-notes -documents'); // Exclude large fields for list view

    // Get total count for pagination
    const total = await Client.countDocuments(query);

    res.json({
      success: true,
      data: clients,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total,
        limit
      }
    });
  } catch (error) {
    console.error('Get clients error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching clients'
    });
  }
});

// @route   GET /api/clients/:id
// @desc    Get single client by ID
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const client = await Client.findOne({
      _id: req.params.id,
      userId: req.user.id,
      isActive: true
    });

    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client not found'
      });
    }

    res.json({
      success: true,
      data: client
    });
  } catch (error) {
    console.error('Get client error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching client'
    });
  }
});

// @route   POST /api/clients
// @desc    Create new client
// @access  Private
router.post('/', async (req, res) => {
  try {
    const clientData = {
      ...req.body,
      userId: req.user.id
    };

    const client = await Client.create(clientData);

    res.status(201).json({
      success: true,
      message: 'Client created successfully',
      data: client
    });
  } catch (error) {
    console.error('Create client error:', error);
    
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: messages
      });
    }

    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Client with this case number already exists'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error while creating client'
    });
  }
});

// @route   PUT /api/clients/:id
// @desc    Update client
// @access  Private
router.put('/:id', async (req, res) => {
  try {
    const client = await Client.findOneAndUpdate(
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
    );

    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client not found'
      });
    }

    res.json({
      success: true,
      message: 'Client updated successfully',
      data: client
    });
  } catch (error) {
    console.error('Update client error:', error);
    
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
      message: 'Server error while updating client'
    });
  }
});

// @route   DELETE /api/clients/:id
// @desc    Delete client (soft delete)
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const client = await Client.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        isActive: true
      },
      { isActive: false },
      { new: true }
    );

    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client not found'
      });
    }

    res.json({
      success: true,
      message: 'Client deleted successfully'
    });
  } catch (error) {
    console.error('Delete client error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting client'
    });
  }
});

// @route   POST /api/clients/:id/notes
// @desc    Add note to client
// @access  Private
router.post('/:id/notes', async (req, res) => {
  try {
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({
        success: false,
        message: 'Note content is required'
      });
    }

    const client = await Client.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        isActive: true
      },
      {
        $push: {
          notes: {
            content,
            createdAt: new Date()
          }
        }
      },
      { new: true }
    );

    if (!client) {
      return res.status(404).json({
        success: false,
        message: 'Client not found'
      });
    }

    res.json({
      success: true,
      message: 'Note added successfully',
      data: client.notes[client.notes.length - 1]
    });
  } catch (error) {
    console.error('Add client note error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding note'
    });
  }
});

// @route   GET /api/clients/search/suggestions
// @desc    Get search suggestions for clients
// @access  Private
router.get('/search/suggestions', async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.length < 2) {
      return res.json({
        success: true,
        data: []
      });
    }

    const clients = await Client.find({
      userId: req.user.id,
      isActive: true,
      $or: [
        { name: { $regex: q, $options: 'i' } },
        { phone: { $regex: q, $options: 'i' } },
        { caseNumber: { $regex: q, $options: 'i' } }
      ]
    })
    .select('name phone caseNumber')
    .limit(10);

    res.json({
      success: true,
      data: clients
    });
  } catch (error) {
    console.error('Search suggestions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching suggestions'
    });
  }
});

module.exports = router;
