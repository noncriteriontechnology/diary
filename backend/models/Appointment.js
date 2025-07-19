const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  clientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Client',
    required: true
  },
  title: {
    type: String,
    required: [true, 'Appointment title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters']
  },
  description: {
    type: String,
    maxlength: [1000, 'Description cannot exceed 1000 characters']
  },
  startDateTime: {
    type: Date,
    required: [true, 'Start date and time is required']
  },
  endDateTime: {
    type: Date,
    required: [true, 'End date and time is required']
  },
  location: {
    type: String,
    trim: true,
    maxlength: [200, 'Location cannot exceed 200 characters']
  },
  appointmentType: {
    type: String,
    enum: ['Consultation', 'Court Hearing', 'Client Meeting', 'Document Review', 'Mediation', 'Deposition', 'Other'],
    default: 'Consultation'
  },
  status: {
    type: String,
    enum: ['Scheduled', 'Confirmed', 'In Progress', 'Completed', 'Cancelled', 'Rescheduled'],
    default: 'Scheduled'
  },
  priority: {
    type: String,
    enum: ['Low', 'Medium', 'High', 'Urgent'],
    default: 'Medium'
  },
  reminderMinutes: {
    type: Number,
    default: 30,
    min: [0, 'Reminder minutes cannot be negative']
  },
  isRecurring: {
    type: Boolean,
    default: false
  },
  recurringPattern: {
    frequency: {
      type: String,
      enum: ['Daily', 'Weekly', 'Monthly', 'Yearly']
    },
    interval: {
      type: Number,
      min: 1
    },
    endDate: Date,
    daysOfWeek: [Number] // 0-6, Sunday to Saturday
  },
  attendees: [{
    name: String,
    email: String,
    phone: String,
    role: {
      type: String,
      enum: ['Client', 'Lawyer', 'Witness', 'Expert', 'Other'],
      default: 'Client'
    }
  }],
  notes: [{
    content: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  documents: [{
    name: String,
    path: String,
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  }],
  billableHours: {
    type: Number,
    min: [0, 'Billable hours cannot be negative'],
    default: 0
  },
  hourlyRate: {
    type: Number,
    min: [0, 'Hourly rate cannot be negative']
  },
  totalAmount: {
    type: Number,
    min: [0, 'Total amount cannot be negative'],
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
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

// Create compound indexes for efficient querying
appointmentSchema.index({ userId: 1, startDateTime: 1 });
appointmentSchema.index({ userId: 1, clientId: 1 });
appointmentSchema.index({ userId: 1, status: 1 });
appointmentSchema.index({ startDateTime: 1, endDateTime: 1 });

// Validation: End time must be after start time
appointmentSchema.pre('save', function(next) {
  if (this.endDateTime <= this.startDateTime) {
    return next(new Error('End time must be after start time'));
  }
  
  // Calculate total amount if billable hours and hourly rate are provided
  if (this.billableHours && this.hourlyRate) {
    this.totalAmount = this.billableHours * this.hourlyRate;
  }
  
  this.updatedAt = Date.now();
  next();
});

// Virtual for duration in minutes
appointmentSchema.virtual('durationMinutes').get(function() {
  return Math.round((this.endDateTime - this.startDateTime) / (1000 * 60));
});

// Virtual for formatted date range
appointmentSchema.virtual('dateRange').get(function() {
  const start = this.startDateTime.toLocaleDateString();
  const end = this.endDateTime.toLocaleDateString();
  return start === end ? start : `${start} - ${end}`;
});

module.exports = mongoose.model('Appointment', appointmentSchema);
