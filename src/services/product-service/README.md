# Product Service

Product management service for the Microservices Deployment Framework.

## Features

- Product catalog management
- Product search and filtering
- Product categories and tags
- Product recommendations
- Inventory management

## API Endpoints

- GET /products - Get list of products
- GET /products/{id} - Get product by ID
- POST /products - Create a new product
- PUT /products/{id} - Update a product
- DELETE /products/{id} - Delete a product
- GET /products/categories - Get product categories
- GET /products/recommendations - Get product recommendations

## Integration with Other Services

This service integrates with:

1. Auth Service for authentication
2. User Service for user-specific recommendations
3. Inventory Service for stock management
4. Pricing Service for dynamic pricing 