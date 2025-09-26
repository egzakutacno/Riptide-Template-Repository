# Riptide SDK Integration Guide

This guide explains how to integrate the Riptide SDK into your crypto node project using this template.

## Overview

The Riptide SDK provides a minimal, hook-based architecture for crypto node services. It handles:
- Health monitoring and heartbeat
- Status reporting
- Metrics collection
- Configuration validation
- Secret management

## Core Concepts

### 1. Hooks Architecture

Riptide uses a hooks-based system where you implement only the functionality you need:

```javascript
// hooks.js
module.exports = {
  heartbeat,    // Required: Periodic health updates
  status,       // Required: Status reporting
  ready,        // Optional: Readiness check
  probe,        // Optional: Liveness probe
  metrics,      // Optional: Performance metrics
  validate,     // Optional: Config validation
  installSecrets // Optional: Secret management
};
```

### 2. Configuration

Configuration is split between:
- `riptide.config.json` - Riptide SDK settings
- Environment variables - Service-specific settings

## Step-by-Step Integration

### Step 1: Basic Setup

1. Copy the template files to your project
2. Install dependencies: `npm install`
3. Configure environment: `cp env.example .env`

### Step 2: Implement Required Hooks

#### Heartbeat Hook
```javascript
const heartbeat = async (context) => {
  return {
    timestamp: new Date().toISOString(),
    status: 'healthy',
    uptime: process.uptime(),
    // Add your node-specific health data
  };
};
```

#### Status Hook
```javascript
const status = async (context) => {
  return {
    service: 'your-crypto-node',
    status: 'running',
    version: '1.0.0',
    // Add detailed status information
  };
};
```

### Step 3: Add Optional Hooks (As Needed)

#### Ready Hook (for Kubernetes readiness)
```javascript
const ready = async (context) => {
  const checks = {
    database: await checkDatabase(),
    network: await checkNetwork(),
    wallet: await checkWallet()
  };
  
  return {
    ready: Object.values(checks).every(check => check),
    checks
  };
};
```

#### Metrics Hook (for monitoring)
```javascript
const metrics = async (context) => {
  return {
    timestamp: new Date().toISOString(),
    node: {
      blocksProcessed: 1234567,
      transactionsProcessed: 9876543
    },
    system: {
      memory: process.memoryUsage(),
      cpu: process.cpuUsage()
    }
  };
};
```

### Step 4: Configure Your Service

Update `riptide.config.json`:
```json
{
  "service": {
    "name": "your-crypto-node",
    "version": "1.0.0",
    "port": 3000
  },
  "riptide": {
    "enabled": true,
    "heartbeatInterval": 30000,
    "metricsEnabled": true
  }
}
```

### Step 5: Initialize Riptide in Your App

```javascript
const { RiptideSDK } = require('@deeep-network/riptide');
const hooks = require('./hooks');
const config = require('./riptide.config.json');

const riptide = new RiptideSDK({
  config: config.riptide,
  hooks: hooks
});

// Initialize
await riptide.initialize();
```

## Common Patterns

### Health Check Pattern

```javascript
const heartbeat = async (context) => {
  try {
    const healthData = await performHealthChecks();
    return {
      timestamp: new Date().toISOString(),
      status: 'healthy',
      data: healthData
    };
  } catch (error) {
    return {
      timestamp: new Date().toISOString(),
      status: 'unhealthy',
      error: error.message
    };
  }
};
```

### Metrics Collection Pattern

```javascript
const metrics = async (context) => {
  const nodeMetrics = await collectNodeMetrics();
  const systemMetrics = {
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    uptime: process.uptime()
  };
  
  return {
    timestamp: new Date().toISOString(),
    node: nodeMetrics,
    system: systemMetrics
  };
};
```

### Configuration Validation Pattern

```javascript
const validate = async (context) => {
  const config = context.config;
  const errors = [];
  
  // Validate required fields
  if (!config.service?.name) {
    errors.push('Service name is required');
  }
  
  // Add more validation as needed
  
  return {
    valid: errors.length === 0,
    errors
  };
};
```

## Best Practices

### 1. Error Handling
Always wrap hook implementations in try-catch blocks:

```javascript
const myHook = async (context) => {
  try {
    // Your logic here
    return { success: true, data: result };
  } catch (error) {
    console.error('Hook error:', error);
    return { success: false, error: error.message };
  }
};
```

### 2. Performance
Keep hooks lightweight and fast:

```javascript
const heartbeat = async (context) => {
  // Use cached data when possible
  const cachedStatus = getCachedStatus();
  return {
    timestamp: new Date().toISOString(),
    status: cachedStatus
  };
};
```

### 3. Logging
Use structured logging:

```javascript
const status = async (context) => {
  console.log('Status check requested', {
    timestamp: new Date().toISOString(),
    service: 'crypto-node'
  });
  
  // Your logic here
};
```

### 4. Configuration
Use environment variables for sensitive data:

```javascript
const installSecrets = async (context) => {
  const secrets = {
    apiKey: process.env.API_KEY,
    privateKey: process.env.PRIVATE_KEY,
    databaseUrl: process.env.DATABASE_URL
  };
  
  // Install secrets
  return { success: true, installed: Object.keys(secrets) };
};
```

## Troubleshooting

### Common Issues

1. **Hook not being called**: Check if the hook is exported in `hooks.js`
2. **Configuration errors**: Validate your `riptide.config.json` syntax
3. **Environment variables**: Ensure `.env` file is loaded with `dotenv`
4. **Async/await**: Make sure all hooks are async functions

### Debug Mode

Enable debug logging:

```javascript
const riptide = new RiptideSDK({
  config: {
    ...config.riptide,
    debug: true
  },
  hooks: hooks
});
```

## Next Steps

1. Implement the hooks you need for your specific crypto node
2. Add your blockchain-specific logic
3. Configure monitoring and alerting
4. Set up deployment pipelines
5. Add comprehensive testing

For more examples, see the `hooks.js` file in this template.
