# Riptide Systemd Integration Guide

## When to Use This
Use this when you have a crypto node application that **requires systemd as PID 1** in Docker, but you also need to integrate it with the NerdNode Riptide SDK for orchestration.

## The Problem
- Your crypto application needs systemd as PID 1 to function properly
- Riptide SDK typically expects to run as PID 1 for orchestration
- You need both to work together in a Docker container

## The Solution: Hybrid Architecture
Run systemd as PID 1 and Riptide as a systemd-managed service.

## Quick Integration Prompt

```
I need to integrate a crypto node application with the NerdNode Riptide SDK in a Docker container. Here are the requirements:

**Application Requirements:**
- [CRYPTO_APP_NAME] requires systemd as PID 1 to function properly
- The application should run continuously as a service
- [Add any specific requirements for your crypto app]

**Integration Goals:**
- Use systemd as PID 1 in Docker
- Run Riptide as a systemd-managed service (not PID 1)
- Implement Riptide hooks for orchestration
- Ensure proper service startup order

**Technical Architecture Needed:**
1. **Dockerfile with systemd as PID 1:**
   - Base image with systemd support
   - Install both crypto app and Riptide SDK
   - Configure systemd services

2. **Service Structure:**
   - [CRYPTO_APP_NAME]-service.service (main crypto app)
   - [CRYPTO_APP_NAME]-riptide-manager.service (Riptide orchestration)
   - Optional: Watcher service for startup coordination

3. **Riptide Integration:**
   - Implement hooks.js with all required hooks
   - Configure riptide.config.json
   - Set up proper service dependencies

**Key Files Needed:**
- Dockerfile (systemd as PID 1)
- src/hooks.js (Riptide hooks)
- [crypto_app]-riptide-manager.service (Riptide service)
- riptide.config.json (Riptide configuration)

**Critical Implementation Details:**
- Use systemd as PID 1 in Dockerfile
- Run Riptide as a systemd service (not PID 1)
- Create symlink for hooks.js: `ln -sf /root/src/hooks.js /root/hooks.js`
- Implement proper service dependencies and startup order

Please implement this architecture for [CRYPTO_APP_NAME] with the specific requirements above.
```

## Usage Instructions

1. **Replace Placeholders:**
   - `[CRYPTO_APP_NAME]` with your actual crypto application name
   - Add any specific requirements for your crypto app

2. **Customize Requirements:**
   - Add specific commands your app needs
   - Include any special configuration requirements
   - Mention any specific file formats or locations

3. **Use This Prompt:**
   - Copy the template above
   - Fill in your specific details
   - Send to AI assistant
   - Get complete implementation

## Key Benefits of This Architecture

✅ **Systemd as PID 1:** Apps that require systemd work properly  
✅ **Riptide Integration:** Full orchestration capabilities maintained  
✅ **Service Management:** Proper startup/shutdown order  
✅ **Production Ready:** Robust error handling and logging  
✅ **Reusable:** Template works for any crypto node project  

## Common Pitfalls to Avoid

❌ **Don't run Riptide as PID 1** when your app needs systemd  
❌ **Don't forget service dependencies** - ensures proper startup order  
❌ **Don't skip the symlink** - Riptide needs hooks.js in the right location  
❌ **Don't forget to disable Riptide by default** - prevents premature startup  

This template will save you hours of debugging and ensure a clean, production-ready integration every time.
