const mongoose = require('mongoose');
const validator = require('validator');

const clientSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Client name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  email: {
    type: String,
    lowercase: true,
    validate: [validator.isEmail, 'Please provide a valid email'],
    sparse: true // Allows multiple null values
  },
  phone: {
    type: String,
    required: [true, 'Phone number is required'],
    validate: {
      validator: function(v) {
        return /^\+?[\d\s\-\(\)]{10,}$/.test(v);
      },
      message: 'Please provide a valid phone number'
    }
  },
  alternatePhone: {
    type: String,
    validate: {
      validator: function(v) {
        return !v || /^\+?[\d\s\-\(\)]{10,}$/.test(v);
      },
      message: 'Please provide a valid alternate phone number'
    }
  },
  address: {
    street: String,
    city: String,
    state: String,
    zipCode: String,
    country: {
      type: String,
      default: 'India'
    }
  },
  caseType: {
    type: String,
    required: [true, 'Case type is required'],
    enum: ['Criminal', 'Civil', 'Corporate', 'Family', 'Property', 'Tax', 'Labor', 'Constitutional', 'Other']
  },
  caseNumber: {
    type: String,
    trim: true,
    sparse: true // Allows multiple null values but unique non-null values
  },
  caseDescription: {
    type: String,
    maxlength: [1000, 'Case description cannot exceed 1000 characters']
  },
  status: {
    type: String,
    enum: ['Active', 'Closed', 'On Hold', 'Pending'],
    default: 'Active'
  },
  priority: {
    type: String,
    enum: ['Low', 'Medium', 'High', 'Urgent'],
    default: 'Medium'
  },
  retainerFee: {
    type: Number,
    min: [0, 'Retainer fee cannot be negative']
  },
  hourlyRate: {
    type: Number,
    min: [0, 'Hourly rate cannot be negative']
  },
  totalBilled: {
    type: Number,
    default: 0,
    min: [0, 'Total billed cannot be negative']
  },
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

// Create compound index for efficient searching
clientSchema.index({ userId: 1, name: 1 });
clientSchema.index({ userId: 1, phone: 1 });
clientSchema.index({ userId: 1, caseNumber: 1 });
clientSchema.index({ userId: 1, status: 1 });

// Update updatedAt field before saving
clientSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Virtual for full address
clientSchema.virtual('fullAddress').get(function() {
  const addr = this.address;
  if (!addr) return '';
  
  const parts = [addr.street, addr.city, addr.state, addr.zipCode, addr.country].filter(Boolean);
  return parts.join(', ');
});

module.exports = mongoose.model('Client', clientSchema);
