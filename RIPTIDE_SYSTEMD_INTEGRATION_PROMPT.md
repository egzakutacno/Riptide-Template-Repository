# Riptide Systemd Integration Prompt Template

## When to Use This Prompt
Use this prompt when you have a crypto node application that **requires systemd as PID 1** in Docker, but you also need to integrate it with the NerdNode Riptide SDK for orchestration.

## The Problem
- Your crypto application needs systemd as PID 1 to function properly
- Riptide SDK typically expects to run as PID 1 for orchestration
- You need both to work together in a Docker container

## The Solution: Hybrid Architecture
Run systemd as PID 1 and Riptide as a systemd-managed service.

## Complete Integration Prompt

```
I need to integrate a crypto node application with the NerdNode Riptide SDK in a Docker container. Here are the requirements:

**Application Requirements:**
- [CRYPTO_APP_NAME] requires systemd as PID 1 to function properly
- The application is interactive and needs automated CLI interaction
- It creates wallet files that need to be sent to the orchestrator
- The application should run continuously as a service

**Integration Goals:**
- Use systemd as PID 1 in Docker
- Run Riptide as a systemd-managed service (not PID 1)
- Implement all Riptide hooks (start, stop, health, status, heartbeat, ready, probe, metrics, validate, installSecrets)
- Send wallet keys to orchestrator only once on first heartbeat
- Ensure proper service startup order (crypto app first, then Riptide)

**Technical Architecture Needed:**
1. **Dockerfile with systemd as PID 1:**
   - Base image with systemd support
   - Install both crypto app and Riptide SDK
   - Configure systemd services

2. **Service Dependencies:**
   - [CRYPTO_APP_NAME]-service.service (main crypto app)
   - [CRYPTO_APP_NAME]-riptide-manager.service (Riptide orchestration)
   - [CRYPTO_APP_NAME]-wallet-watcher.service (waits for wallet creation)

3. **Wallet Watcher Pattern:**
   - Service that monitors for wallet file creation
   - Only starts Riptide after wallet is ready
   - Prevents premature heartbeats without wallet data

4. **Riptide Hooks Implementation:**
   - All standard hooks with proper error handling
   - Heartbeat hook with wallet key transmission (once only)
   - Service status monitoring and health checks

5. **CLI Automation:**
   - Python script using Typer for interactive CLI handling
   - Automated wallet creation and key extraction
   - Clean exit from interactive sessions

**Key Files Needed:**
- Dockerfile (systemd as PID 1)
- [crypto_app]_automation.py (CLI automation)
- src/hooks.js (Riptide hooks)
- [crypto_app]-riptide-manager.service (Riptide service)
- [crypto_app]-wallet-watcher.service (wallet watcher)
- start-riptide-after-wallet.sh (wallet detection script)
- riptide.config.json (Riptide configuration)

**Critical Implementation Details:**
- Use `Type=oneshot` for wallet watcher (runs once, exits)
- Disable Riptide service by default in Dockerfile
- Create symlink for hooks.js: `ln -sf /root/src/hooks.js /root/hooks.js`
- Implement flag file for wallet key transmission control
- Use proper service dependencies and startup order

**Expected Outcome:**
- Crypto app runs with systemd as PID 1
- Riptide runs as managed service after wallet creation
- All Riptide hooks work properly
- Wallet keys sent to orchestrator once on first heartbeat
- Clean service lifecycle management

Please implement this architecture for [CRYPTO_APP_NAME] with the specific requirements above.
```

## Usage Instructions

1. **Replace Placeholders:**
   - `[CRYPTO_APP_NAME]` with your actual crypto application name
   - Add any specific requirements for your crypto app

2. **Customize Requirements:**
   - Add specific CLI commands your app needs
   - Include any special configuration requirements
   - Mention specific wallet file formats or locations

3. **Use This Prompt:**
   - Copy the template above
   - Fill in your specific details
   - Send to AI assistant
   - Get complete implementation

## Key Benefits of This Architecture

✅ **Systemd as PID 1:** Crypto apps that require systemd work properly  
✅ **Riptide Integration:** Full orchestration capabilities maintained  
✅ **Service Management:** Proper startup/shutdown order  
✅ **Wallet Security:** Keys sent only once, securely  
✅ **Production Ready:** Robust error handling and logging  
✅ **Reusable:** Template works for any crypto node project  

## Common Pitfalls to Avoid

❌ **Don't run Riptide as PID 1** when crypto app needs systemd  
❌ **Don't skip the wallet watcher** - prevents premature heartbeats  
❌ **Don't forget service dependencies** - ensures proper startup order  
❌ **Don't send wallet keys repeatedly** - use flag file control  
❌ **Don't use Type=simple for watcher** - use Type=oneshot  

This template will save you hours of debugging and ensure a clean, production-ready integration every time.
