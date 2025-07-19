# Lawyer's Diary Backend API

A comprehensive Node.js backend API for the Lawyer's Diary mobile application, built with Express.js and MongoDB.

## Features

- **User Authentication**: Secure JWT-based authentication with registration and login
- **Client Management**: Complete CRUD operations for client records
- **Appointment Scheduling**: Calendar-based appointment management with conflict detection
- **Notes System**: Text and voice note recording with file attachments
- **Search Functionality**: Advanced search across clients, appointments, and notes
- **File Upload**: Support for voice recordings and document attachments
- **Security**: Rate limiting, input validation, and secure password hashing

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **File Upload**: Multer
- **Security**: Helmet, bcryptjs, express-rate-limit
- **Validation**: Mongoose validation + validator.js

## Installation

### Prerequisites

- Node.js (v14 or higher)
- MongoDB (local installation or MongoDB Atlas)
- npm or yarn

### Setup Steps

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   ```
   Edit the `.env` file with your configuration:
   - Set your MongoDB connection string
   - Generate a secure JWT secret
   - Configure other environment variables as needed

3. **Create Upload Directory**
   ```bash
   mkdir uploads
   ```

4. **Start the Server**
   ```bash
   # Development mode with auto-restart
   npm run dev
   
   # Production mode
   npm start
   ```

## API Endpoints

### Authentication Routes (`/api/auth`)

- `POST /register` - Register new user
- `POST /login` - User login
- `GET /me` - Get current user profile
- `PUT /profile` - Update user profile
- `PUT /change-password` - Change password

### Client Routes (`/api/clients`)

- `GET /` - Get all clients (with pagination and search)
- `GET /:id` - Get single client
- `POST /` - Create new client
- `PUT /:id` - Update client
- `DELETE /:id` - Delete client (soft delete)
- `POST /:id/notes` - Add note to client
- `GET /search/suggestions` - Get search suggestions

### Appointment Routes (`/api/appointments`)

- `GET /` - Get all appointments (with filters)
- `GET /calendar` - Get appointments for calendar view
- `GET /:id` - Get single appointment
- `POST /` - Create new appointment
- `PUT /:id` - Update appointment
- `DELETE /:id` - Delete appointment
- `PUT /:id/status` - Update appointment status

### Notes Routes (`/api/notes`)

- `GET /` - Get all notes (with search and filters)
- `GET /:id` - Get single note
- `POST /` - Create new note
- `PUT /:id` - Update note
- `DELETE /:id` - Delete note
- `POST /:id/voice` - Upload voice recording
- `POST /:id/attachments` - Upload attachment
- `PUT /:id/favorite` - Toggle favorite status
- `GET /search/tags` - Get all tags

## Database Schema

### User Model
- Personal information (name, email, phone)
- Professional details (bar number, firm, specialization)
- Authentication data (hashed password)
- Account status and timestamps

### Client Model
- Contact information
- Case details (type, number, description)
- Status and priority
- Billing information
- Notes and documents

### Appointment Model
- Date and time scheduling
- Client association
- Location and type
- Status tracking
- Recurring appointment support
- Billing integration

### Note Model
- Text content with rich formatting
- Voice recording support
- File attachments
- Tagging system
- Client/appointment association

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt with salt rounds
- **Rate Limiting**: Prevents brute force attacks
- **Input Validation**: Comprehensive data validation
- **CORS Protection**: Configurable cross-origin requests
- **Helmet Security**: Security headers and protection

## File Upload

- **Voice Recordings**: MP3, WAV, M4A, AAC formats
- **Documents**: PDF, DOC, DOCX, TXT, images
- **Size Limit**: 10MB per file
- **Storage**: Local file system (configurable)

## Error Handling

- Comprehensive error responses
- Validation error details
- Development vs production error modes
- Logging for debugging

## Development

### Running Tests
```bash
npm test
```

### Code Structure
```
backend/
├── models/          # Mongoose models
├── routes/          # API route handlers
├── middleware/      # Custom middleware
├── uploads/         # File upload directory
├── server.js        # Main server file
└── package.json     # Dependencies and scripts
```

## Deployment

1. Set `NODE_ENV=production` in environment
2. Use a process manager like PM2
3. Set up reverse proxy (nginx)
4. Configure MongoDB Atlas for cloud database
5. Set up file storage (AWS S3, etc.)

## API Usage Examples

### Register User
```javascript
POST /api/auth/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword",
  "phone": "+1234567890",
  "barNumber": "BAR123456",
  "firm": "Doe & Associates",
  "specialization": ["Criminal Law", "Civil Law"]
}
```

### Create Client
```javascript
POST /api/clients
Authorization: Bearer <token>
{
  "name": "Jane Smith",
  "phone": "+1987654321",
  "email": "jane@example.com",
  "caseType": "Family",
  "caseDescription": "Divorce proceedings",
  "status": "Active"
}
```

### Schedule Appointment
```javascript
POST /api/appointments
Authorization: Bearer <token>
{
  "clientId": "client_id_here",
  "title": "Initial Consultation",
  "startDateTime": "2024-01-15T10:00:00Z",
  "endDateTime": "2024-01-15T11:00:00Z",
  "appointmentType": "Consultation",
  "location": "Office"
}
```

## Support

For issues and questions, please refer to the project documentation or contact the development team.
