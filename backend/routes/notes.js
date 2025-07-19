const express = require('express');
const multer = require('multer');
const path = require('path');
const Note = require('../models/Note');
const Client = require('../models/Client');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  },
  fileFilter: function (req, file, cb) {
    // Allow audio files for voice recordings and common document types
    const allowedTypes = /jpeg|jpg|png|pdf|doc|docx|txt|mp3|wav|m4a|aac/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only audio, image, and document files are allowed'));
    }
  }
});

// Apply authentication middleware to all routes
router.use(protect);

// @route   GET /api/notes
// @desc    Get all notes for the authenticated user
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      clientId, 
      appointmentId,
      noteType,
      priority,
      tags,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    // Build query
    const query = { userId: req.user.id, status: 'Active' };

    // Add search functionality
    if (search) {
      query.$text = { $search: search };
    }

    // Add filters
    if (clientId) query.clientId = clientId;
    if (appointmentId) query.appointmentId = appointmentId;
    if (noteType) query.noteType = noteType;
    if (priority) query.priority = priority;
    if (tags) {
      const tagArray = tags.split(',').map(tag => tag.trim());
      query.tags = { $in: tagArray };
    }

    // Build sort object
    const sort = {};
    if (search) {
      sort.score = { $meta: 'textScore' };
    }
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query with pagination and populate references
    const notes = await Note.find(query)
      .populate('clientId', 'name phone')
      .populate('appointmentId', 'title startDateTime')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('-attachments'); // Exclude attachments for list view

    // Get total count for pagination
    const total = await Note.countDocuments(query);

    res.json({
      success: true,
      data: notes,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total,
        limit
      }
    });
  } catch (error) {
    console.error('Get notes error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching notes'
    });
  }
});

// @route   GET /api/notes/:id
// @desc    Get single note by ID
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const note = await Note.findOne({
      _id: req.params.id,
      userId: req.user.id,
      status: 'Active'
    })
    .populate('clientId', 'name phone email')
    .populate('appointmentId', 'title startDateTime endDateTime');

    if (!note) {
      return res.status(404).json({
        success: false,
        message: 'Note not found'
      });
    }

    // Update last accessed time
    await note.updateLastAccessed();

    res.json({
      success: true,
      data: note
    });
  } catch (error) {
    console.error('Get note error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching note'
    });
  }
});

// @route   POST /api/notes
// @desc    Create new note
// @access  Private
router.post('/', async (req, res) => {
  try {
    const noteData = {
      ...req.body,
      userId: req.user.id
    };

    // Validate client exists if clientId is provided
    if (noteData.clientId) {
      const client = await Client.findOne({
        _id: noteData.clientId,
        userId: req.user.id,
        isActive: true
      });

      if (!client) {
        return res.status(400).json({
          success: false,
          message: 'Invalid client ID or client not found'
        });
      }
    }

    const note = await Note.create(noteData);
    
    // Populate references for response
    await note.populate('clientId', 'name phone');

    res.status(201).json({
      success: true,
      message: 'Note created successfully',
      data: note
    });
  } catch (error) {
    console.error('Create note error:', error);
    
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
      message: 'Server error while creating note'
    });
  }
});

// @route   PUT /api/notes/:id
// @desc    Update note
// @access  Private
router.put('/:id', async (req, res) => {
  try {
    const note = await Note.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        status: 'Active'
      },
      req.body,
      {
        new: true,
        runValidators: true
      }
    )
    .populate('clientId', 'name phone')
    .populate('appointmentId', 'title startDateTime');

    if (!note) {
      return res.status(404).json({
        success: false,
        message: 'Note not found'
      });
    }

    res.json({
      success: true,
      message: 'Note updated successfully',
      data: note
    });
  } catch (error) {
    console.error('Update note error:', error);
    
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
      message: 'Server error while updating note'
    });
  }
});

// @route   DELETE /api/notes/:id
// @desc    Delete note (soft delete)
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const note = await Note.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        status: 'Active'
      },
      { status: 'Deleted' },
      { new: true }
    );

    if (!note) {
      return res.status(404).json({
        success: false,
        message: 'Note not found'
      });
    }

    res.json({
      success: true,
      message: 'Note deleted successfully'
    });
  } catch (error) {
    console.error('Delete note error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting note'
    });
  }
});

// @route   POST /api/notes/:id/voice
// @desc    Upload voice recording for note
// @access  Private
router.post('/:id/voice', upload.single('voiceRecording'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Voice recording file is required'
      });
    }

    const note = await Note.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        status: 'Active'
      },
      {
        voiceRecording: {
          filename: req.file.filename,
          path: req.file.path,
          size: req.file.size,
          uploadedAt: new Date()
        }
      },
      { new: true }
    );

    if (!note) {
      return res.status(404).json({
        success: false,
        message: 'Note not found'
      });
    }

    res.json({
      success: true,
      message: 'Voice recording uploaded successfully',
      data: note.voiceRecording
    });
  } catch (error) {
    console.error('Upload voice recording error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while uploading voice recording'
    });
  }
});

// @route   POST /api/notes/:id/attachments
// @desc    Upload attachment for note
// @access  Private
router.post('/:id/attachments', upload.single('attachment'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Attachment file is required'
      });
    }

    const note = await Note.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.user.id,
        status: 'Active'
      },
      {
        $push: {
          attachments: {
            name: req.file.originalname,
            path: req.file.path,
            size: req.file.size,
            mimeType: req.file.mimetype,
            uploadedAt: new Date()
          }
        }
      },
      { new: true }
    );

    if (!note) {
      return res.status(404).json({
        success: false,
        message: 'Note not found'
      });
    }

    const newAttachment = note.attachments[note.attachments.length - 1];

    res.json({
      success: true,
      message: 'Attachment uploaded successfully',
      data: newAttachment
    });
  } catch (error) {
    console.error('Upload attachment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while uploading attachment'
    });
  }
});

// @route   PUT /api/notes/:id/favorite
// @desc    Toggle favorite status of note
// @access  Private
router.put('/:id/favorite', async (req, res) => {
  try {
    const note = await Note.findOne({
      _id: req.params.id,
      userId: req.user.id,
      status: 'Active'
    });

    if (!note) {
      return res.status(404).json({
        success: false,
        message: 'Note not found'
      });
    }

    note.isFavorite = !note.isFavorite;
    await note.save();

    res.json({
      success: true,
      message: `Note ${note.isFavorite ? 'added to' : 'removed from'} favorites`,
      data: { isFavorite: note.isFavorite }
    });
  } catch (error) {
    console.error('Toggle favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating favorite status'
    });
  }
});

// @route   GET /api/notes/search/tags
// @desc    Get all unique tags for user's notes
// @access  Private
router.get('/search/tags', async (req, res) => {
  try {
    const tags = await Note.distinct('tags', {
      userId: req.user.id,
      status: 'Active'
    });

    res.json({
      success: true,
      data: tags.sort()
    });
  } catch (error) {
    console.error('Get tags error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching tags'
    });
  }
});

module.exports = router;
