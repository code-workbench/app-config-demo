# App Config Demo

A .NET 8 web application that demonstrates reading environment variables and displaying them in a modern web UI. The application runs in a Docker container and exposes both a REST API and a web interface.

## Features

- 🔧 Reads `TEST_SETTING` and `TEST_SECRET` environment variables
- 🌐 Modern, responsive web UI
- 🔄 Real-time refresh capability
- 🐳 Docker containerized
- 📊 REST API endpoint for configuration data
- 🔒 Secure container configuration with non-root user

## Environment Variables

The application reads the following environment variables:

- `TEST_SETTING`: A general configuration setting
- `TEST_SECRET`: A secret configuration value

If these variables are not set, the application will display "Not set" for each.

## Quick Start

### Using Docker Compose (Recommended)

1. Build and run the application:
   ```bash
   docker-compose up --build
   ```

2. Open your browser and navigate to:
   - Web UI: http://localhost:8080
   - API endpoint: http://localhost:8080/api/config

### Using Docker directly

1. Build the Docker image:
   ```bash
   docker build -t app-config-demo .
   ```

2. Run the container with environment variables:
   ```bash
   docker run -p 8080:8080 \
     -e TEST_SETTING="My Test Setting" \
     -e TEST_SECRET="MySecretValue" \
     app-config-demo
   ```

### Local Development

1. Restore dependencies:
   ```bash
   dotnet restore
   ```

2. Set environment variables (Linux/macOS):
   ```bash
   export TEST_SETTING="Development Setting"
   export TEST_SECRET="DevSecret123"
   ```

   Or Windows (PowerShell):
   ```powershell
   $env:TEST_SETTING="Development Setting"
   $env:TEST_SECRET="DevSecret123"
   ```

3. Run the application:
   ```bash
   dotnet run
   ```

4. Navigate to http://localhost:5000 (or the port shown in the console)

## API Endpoints

### GET /api/config

Returns the current configuration values:

```json
{
  "testSetting": "Hello from Docker!",
  "testSecret": "MySecretValue123",
  "timestamp": "2025-07-09T10:30:00.000Z"
}
```

### GET /

Serves the web UI interface.

## Architecture

- **Backend**: ASP.NET Core 8 minimal API
- **Frontend**: Vanilla HTML/CSS/JavaScript with modern styling
- **Container**: Multi-stage Docker build with security best practices
- **Security**: Runs as non-root user, minimal attack surface

## Security Features

- Non-root container execution
- Minimal base image (aspnet runtime)
- Health checks included
- Environment variable injection (no hardcoded secrets)
- CORS configured for development

## Development Notes

The application uses:
- .NET 8 minimal APIs for lightweight and fast startup
- Embedded HTML to keep the deployment simple
- Modern CSS with gradients and animations
- Auto-refresh functionality every 30 seconds
- Error handling and loading states

## Production Considerations

For production deployment:
- Use Azure Key Vault or similar for secret management
- Configure proper CORS policies
- Set up proper logging and monitoring
- Use HTTPS/TLS termination
- Consider using Azure Container Apps or Azure App Service

## Building and Testing

The Docker image includes health checks and can be tested with:

```bash
# Check container health
docker ps

# View logs
docker-compose logs -f

# Test API directly
curl http://localhost:8080/api/config
```
