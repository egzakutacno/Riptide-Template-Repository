# Setup script for Riptide Crypto Node Template (PowerShell)
# This script helps set up a new project from this template

Write-Host "🚀 Setting up Riptide Crypto Node Template..." -ForegroundColor Blue

# Check if Node.js is installed
try {
    $nodeVersion = node -v
    Write-Host "✅ Node.js version $nodeVersion detected" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js 18+ first." -ForegroundColor Red
    exit 1
}

# Check Node.js version
$versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
if ($versionNumber -lt 18) {
    Write-Host "❌ Node.js version 18+ is required. Current version: $nodeVersion" -ForegroundColor Red
    exit 1
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
npm install

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item "env.example" ".env"
    Write-Host "✅ .env file created. Please update it with your configuration." -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Create logs directory
if (-not (Test-Path "logs")) {
    New-Item -ItemType Directory -Path "logs" | Out-Null
    Write-Host "✅ Logs directory created" -ForegroundColor Green
}

# Set up git hooks (if .git exists)
if (Test-Path ".git") {
    Write-Host "🔧 Setting up git hooks..." -ForegroundColor Yellow
    
    # Create .git/hooks directory if it doesn't exist
    if (-not (Test-Path ".git/hooks")) {
        New-Item -ItemType Directory -Path ".git/hooks" | Out-Null
    }
    
    # Add pre-commit hook for linting
    $preCommitHook = @"
#!/bin/bash
npm run lint
"@
    $preCommitHook | Out-File -FilePath ".git/hooks/pre-commit" -Encoding UTF8
    Write-Host "✅ Git hooks configured" -ForegroundColor Green
}

# Run initial validation
Write-Host "🔍 Running initial validation..." -ForegroundColor Yellow
npm run lint

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update .env with your configuration" -ForegroundColor White
Write-Host "2. Modify hooks.js for your specific needs" -ForegroundColor White
Write-Host "3. Update riptide.config.json" -ForegroundColor White
Write-Host "4. Run 'npm run dev' to start development" -ForegroundColor White
Write-Host ""
Write-Host "For more information, see the documentation in the docs/ folder" -ForegroundColor Cyan
