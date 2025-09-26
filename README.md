# Riptide Crypto Node Template

A professional template repository for crypto node projects using the [Riptide SDK](https://www.npmjs.com/package/@deeep-network/riptide). This template provides a minimal, production-ready foundation that follows industry best practices.

## 🚀 Quick Start

### 1. Clone the Template

```bash
git clone https://github.com/nerdnode/riptide-crypto-node-template.git your-crypto-project
cd your-crypto-project
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

```bash
cp env.example .env
# Edit .env with your specific configuration
```

### 4. Start Development

```bash
npm run dev
```

## 📁 Project Structure

```
riptide-crypto-node-template/
├── package.json              # Dependencies and scripts
├── riptide.config.json       # Riptide SDK configuration
├── hooks.js                  # Riptide hooks implementation
├── index.js                  # Main application entry point
├── env.example               # Environment variables template
├── .gitignore               # Git ignore rules
├── docs/                    # Documentation
├── scripts/                 # Development utilities
└── README.md                # This file
```

## 🔧 Configuration

### Riptide Configuration (`riptide.config.json`)

The Riptide SDK is configured through `riptide.config.json`. Key settings:

```json
{
  "service": {
    "name": "crypto-node-service",
    "version": "1.0.0",
    "port": 3000
  },
  "riptide": {
    "enabled": true,
    "heartbeatInterval": 30000,
    "statusCheckInterval": 60000,
    "metricsEnabled": true
  }
}
```

### Environment Variables

Copy `env.example` to `.env` and configure:

- **Service Settings**: Port, environment, service name
- **Node Configuration**: Network, node type, consensus mechanism
- **Database**: Connection settings (if needed)
- **API Keys**: External service credentials
- **Riptide Settings**: SDK-specific configuration

## 🎣 Hooks Implementation

The `hooks.js` file contains the Riptide SDK hooks. Only implement what you need:

### Minimal Required Hooks

- **`heartbeat`**: Periodic health updates (every 30s by default)
- **`status`**: Detailed status reporting via API

### Optional Hooks

- **`ready`**: Readiness check for traffic acceptance
- **`probe`**: Liveness probe for container orchestration
- **`metrics`**: Performance and operational metrics
- **`validate`**: Configuration validation
- **`installSecrets`**: Secret management

### Example: Custom Hook Implementation

```javascript
const heartbeat = async (context) => {
  const nodeStatus = await checkNodeHealth();
  return {
    timestamp: new Date().toISOString(),
    status: 'healthy',
    nodeStatus,
    uptime: process.uptime()
  };
};
```

## 🛠️ Development

### Available Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm test           # Run tests
npm run lint       # Run ESLint
npm run format     # Format code with Prettier
```

### API Endpoints

- `GET /` - Service information
- `GET /health` - Health check
- `GET /status` - Detailed status
- `GET /metrics` - Performance metrics

## 🏗️ Customization for Your Project

### 1. Update Package Information

Edit `package.json`:
- Change `name` to your project name
- Update `description` and `keywords`
- Modify `repository` URL

### 2. Configure Service Settings

Update `riptide.config.json`:
- Set your service name and version
- Configure port and environment
- Adjust Riptide settings

### 3. Implement Project-Specific Hooks

Modify `hooks.js`:
- Implement only the hooks you need
- Add your crypto node logic
- Customize health checks and metrics

### 4. Add Project Dependencies

Update `package.json` with your specific dependencies:
- Blockchain SDKs (Web3.js, ethers.js, etc.)
- Database drivers
- Authentication libraries
- Monitoring tools

## 🔒 Security Best Practices

1. **Environment Variables**: Never commit `.env` files
2. **Secrets Management**: Use the `installSecrets` hook for sensitive data
3. **Input Validation**: Validate all inputs in your hooks
4. **Error Handling**: Implement proper error handling and logging
5. **HTTPS**: Use HTTPS in production
6. **Rate Limiting**: Implement rate limiting for public endpoints

## 📊 Monitoring and Observability

The template includes built-in monitoring capabilities:

- **Health Checks**: Automatic health monitoring
- **Metrics Collection**: Performance and operational metrics
- **Status Reporting**: Detailed service status
- **Logging**: Structured logging with configurable levels

## 🚀 Deployment

### Docker Deployment

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

### Environment-Specific Configuration

- **Development**: Use local configuration
- **Staging**: Use staging environment variables
- **Production**: Use production secrets and configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📚 Documentation

- [Riptide SDK Documentation](https://www.npmjs.com/package/@deeep-network/riptide)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Express.js Security](https://expressjs.com/en/advanced/best-practice-security.html)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Support

- Create an issue for bugs or feature requests
- Check the documentation in the `docs/` folder
- Review the example implementations in `hooks.js`

---

**Made with ❤️ by NerdNode**

*This template follows industry best practices and is designed to scale with your crypto projects.*
