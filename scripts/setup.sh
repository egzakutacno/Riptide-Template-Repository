#!/bin/bash

# Setup script for Riptide Crypto Node Template
# This script helps set up a new project from this template

set -e

echo "🚀 Setting up Riptide Crypto Node Template..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version $(node -v) detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created. Please update it with your configuration."
else
    echo "✅ .env file already exists"
fi

# Create logs directory
mkdir -p logs

# Set up git hooks (if .git exists)
if [ -d .git ]; then
    echo "🔧 Setting up git hooks..."
    # Add pre-commit hook for linting
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
npm run lint
EOF
    chmod +x .git/hooks/pre-commit
    echo "✅ Git hooks configured"
fi

# Run initial validation
echo "🔍 Running initial validation..."
npm run lint

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your configuration"
echo "2. Modify hooks.js for your specific needs"
echo "3. Update riptide.config.json"
echo "4. Run 'npm run dev' to start development"
echo ""
echo "For more information, see the documentation in the docs/ folder"
