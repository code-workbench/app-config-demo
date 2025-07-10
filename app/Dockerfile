# Use the official .NET 8 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Use the .NET 8 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project file and restore dependencies
COPY ["AppConfigDemo.csproj", "."]
RUN dotnet restore "./AppConfigDemo.csproj"

# Copy source code and build
COPY . .
WORKDIR "/src/."
RUN dotnet build "./AppConfigDemo.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./AppConfigDemo.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage - runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY start.sh .

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
RUN chmod +x start.sh
USER appuser

# Set environment variables for ASP.NET Core
ENV ASPNETCORE_ENVIRONMENT=Production

RUN ls -la /app

ENTRYPOINT ["./start.sh"]