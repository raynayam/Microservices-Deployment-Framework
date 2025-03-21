const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const { createProxyMiddleware } = require('http-proxy-middleware');
const rateLimit = require('express-rate-limit');
const promClient = require('prom-client');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(helmet());
app.use(morgan('combined'));
app.use(compression());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDurationMicroseconds = new promClient.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['route', 'method', 'status'],
  buckets: [0.1, 5, 15, 50, 100, 500, 1000, 5000],
});
register.registerMetric(httpRequestDurationMicroseconds);

// Metrics middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    httpRequestDurationMicroseconds
      .labels(req.path, req.method, res.statusCode)
      .observe(duration);
  });
  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).send({ status: 'ok' });
});

app.get('/readiness', (req, res) => {
  res.status(200).send({ status: 'ready' });
});

// Service proxies
const authServiceUrl = process.env.AUTH_SERVICE_URL || 'http://auth-service:8080';
const userServiceUrl = process.env.USER_SERVICE_URL || 'http://user-service:8080';
const productServiceUrl = process.env.PRODUCT_SERVICE_URL || 'http://product-service:8080';

// Auth service proxy
app.use('/api/auth', createProxyMiddleware({
  target: authServiceUrl,
  pathRewrite: { '^/api/auth': '/auth' },
  changeOrigin: true,
  onProxyReq: (proxyReq, req, res) => {
    console.log(`Proxying request to auth service: ${req.method} ${req.path}`);
  }
}));

// User service proxy
app.use('/api/users', createProxyMiddleware({
  target: userServiceUrl,
  pathRewrite: { '^/api/users': '/users' },
  changeOrigin: true,
  onProxyReq: (proxyReq, req, res) => {
    console.log(`Proxying request to user service: ${req.method} ${req.path}`);
  }
}));

// Product service proxy
app.use('/api/products', createProxyMiddleware({
  target: productServiceUrl,
  pathRewrite: { '^/api/products': '/products' },
  changeOrigin: true,
  onProxyReq: (proxyReq, req, res) => {
    console.log(`Proxying request to product service: ${req.method} ${req.path}`);
  }
}));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'production' ? {} : err.message
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
}); 