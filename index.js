/**
 * Main Entry Point for Riptide Crypto Node Template
 * 
 * This is a minimal example of how to integrate the Riptide SDK
 * into your crypto node project.
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { RiptideSDK } = require('@deeep-network/riptide');
const hooks = require('./hooks');
const config = require('./riptide.config.json');

const app = express();
const PORT = process.env.PORT || config.service.port || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Initialize Riptide SDK
const riptide = new RiptideSDK({
  config: config.riptide,
  hooks: hooks
});

// Basic health check endpoint
app.get('/health', async (req, res) => {
  try {
    const status = await hooks.status();
    res.json(status);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  try {
    if (hooks.metrics) {
      const metrics = await hooks.metrics();
      res.json(metrics);
    } else {
      res.json({ message: 'Metrics hook not implemented' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Status endpoint
app.get('/status', async (req, res) => {
  try {
    const status = await hooks.status();
    res.json(status);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Basic info endpoint
app.get('/', (req, res) => {
  res.json({
    service: config.service.name,
    version: config.service.version,
    description: config.service.description,
    status: 'running',
    timestamp: new Date().toISOString()
  });
});

// Start the server
async function startServer() {
  try {
    // Initialize Riptide SDK
    await riptide.initialize();
    console.log('✅ Riptide SDK initialized successfully');
    
    // Start Express server
    app.listen(PORT, () => {
      console.log(`🚀 Crypto Node Service running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
      console.log(`📈 Metrics: http://localhost:${PORT}/metrics`);
      console.log(`ℹ️  Status: http://localhost:${PORT}/status`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Received SIGTERM, shutting down gracefully...');
  await riptide.shutdown();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Received SIGINT, shutting down gracefully...');
  await riptide.shutdown();
  process.exit(0);
});

// Start the application
startServer();
