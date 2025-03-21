# Auth Service

Authentication and authorization service for the Microservices Deployment Framework.

## Features

- User authentication (login/logout)
- JWT token generation and validation
- Role-based access control
- Integration with identity providers (OAuth, OIDC)

## API Endpoints

- POST /auth/login - User login
- POST /auth/logout - User logout
- POST /auth/token - Get a new token
- GET /auth/me - Get current user information

## Integration with Other Services

This service is used by all other microservices for authentication and authorization through:

1. Token validation
2. Service-to-service authentication
3. User role and permission checks 