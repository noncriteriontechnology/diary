const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  clientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    required: false // Notes can be general or client-specific
  },
  appointmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Appointment',
    required: false // Notes can be appointment-specific
  },
  title: {
    type: String,
    required: [true, 'Note title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters']
  },
  content: {
    type: String,
    required: [true, 'Note content is required'],
    maxlength: [10000, 'Content cannot exceed 10000 characters']
  },
  noteType: {
    type: String,
    enum: ['General', 'Client Meeting', 'Court Hearing', 'Research', 'Case Strategy', 'Follow-up', 'Other'],
    default: 'General'
  },
  priority: {
    type: String,
    enum: ['Low', 'Medium', 'High', 'Urgent'],
    default: 'Medium'
  },
  tags: [{
    type: String,
    trim: true,
    maxlength: [50, 'Tag cannot exceed 50 characters']
  }],
  voiceRecording: {
    filename: String,
    path: String,
    duration: Number, // in seconds
    size: Number, // in bytes
    uploadedAt: Date
  },
  attachments: [{
    name: String,
    path: String,
    size: Number,
    mimeType: String,
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  }],
  isPrivate: {
    type: Boolean,
    default: false
  },
  isFavorite: {
    type: Boolean,
    default: false
  },
  reminderDate: {
    type: Date
  },
  status: {
    type: String,
    enum: ['Active', 'Archived', 'Deleted'],
    default: 'Active'
  },
  lastAccessedAt: {
    type: Date,
    default: Date.now
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Create indexes for efficient searching
noteSchema.index({ userId: 1, createdAt: -1 });
noteSchema.index({ userId: 1, clientId: 1 });
noteSchema.index({ userId: 1, appointmentId: 1 });
noteSchema.index({ userId: 1, tags: 1 });
noteSchema.index({ userId: 1, noteType: 1 });
noteSchema.index({ userId: 1, status: 1 });

// Text search index for title and content
noteSchema.index({ 
  title: 'text', 
  content: 'text', 
  tags: 'text' 
});

// Update updatedAt field before saving
noteSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Method to update last accessed time
noteSchema.methods.updateLastAccessed = function() {
  this.lastAccessedAt = new Date();
  return this.save();
};

// Virtual for word count
noteSchema.virtual('wordCount').get(function() {
  return this.content ? this.content.split(/\s+/).length : 0;
});

// Virtual for reading time estimate (assuming 200 words per minute)
noteSchema.virtual('readingTimeMinutes').get(function() {
  const wordCount = this.wordCount;
  return Math.ceil(wordCount / 200);
});

module.exports = mongoose.model('Note', noteSchema);
