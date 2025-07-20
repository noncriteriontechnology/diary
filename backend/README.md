# Lawyer's Diary Backend

## Quick Start Guide

### 1. Install Dependencies
```bash
npm install
```

### 2. Start the Server
```bash
# Development mode (with auto-restart)
npm run dev

# Or production mode
npm start
```

### 3. Test the API
The server will start on http://localhost:5000

Test endpoints:
- GET http://localhost:5000/ - Server status
- POST http://localhost:5000/api/auth/register - User registration
- POST http://localhost:5000/api/auth/login - User login

### 4. Example API Usage

**Register a new user:**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "phone": "+1234567890",
    "barNumber": "BAR123",
    "specialization": "Criminal Law",
    "firmName": "Doe & Associates"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

## Environment Variables

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

## Database

Currently configured to use MongoDB Atlas (cloud database) for easy setup.
No local MongoDB installation required.

## File Structure

```
backend/
├── models/          # Database models
├── routes/          # API routes
├── middleware/      # Custom middleware
├── uploads/         # File uploads directory
├── server.js        # Main server file
├── package.json     # Dependencies
└── .env            # Environment variables
```
