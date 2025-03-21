# User Service

User management service for the Microservices Deployment Framework.

## Features

- User registration and profile management
- User preferences
- User notification settings
- User data management (GDPR compliance)

## API Endpoints

- GET /users - Get list of users
- GET /users/{id} - Get user by ID
- POST /users - Create a new user
- PUT /users/{id} - Update a user
- DELETE /users/{id} - Delete a user
- GET /users/me - Get current user profile

## Integration with Other Services

This service integrates with:

1. Auth Service for user authentication
2. Product Service for user-specific product recommendations
3. Notification Service for user communication preferences 