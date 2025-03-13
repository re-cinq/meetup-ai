FROM ghcr.io/backstage/backstage:latest

# Add custom configuration
COPY app-config.yaml /app/app-config.custom.yaml

# Set environment variables
ENV NODE_ENV=production
ENV BACKSTAGE_APP_ENV=production

# Start with custom configuration
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.custom.yaml"]