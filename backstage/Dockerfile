FROM node:20-bookworm-slim AS build

# Install dependencies required for building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create a simple Backstage app
RUN npx --yes @backstage/create-app@latest --skip-install --no-interactive

# Set ownership to improve compatibility with Podman on macOS
# Podman on macOS can have different user ID handling than Docker
RUN chown -R node:node /app

# Switch to non-root user for better security and Podman compatibility
USER node

# Install dependencies
WORKDIR /app
RUN yarn install --frozen-lockfile

# Build the app
RUN yarn build

# Install ML platform specific plugins
RUN yarn add --cwd packages/app \
    @backstage/plugin-kubernetes \
    @backstage/plugin-catalog-graph \
    @backstage/plugin-tech-radar \
    @backstage/plugin-scaffolder \
    @backstage/plugin-search \
    @backstage/plugin-github-actions \
    @backstage/plugin-api-docs \
    @backstage/plugin-tech-insights

# Production stage
FROM node:20-bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    curl \
    ca-certificates \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy built files from previous stage
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json ./
COPY --from=build --chown=node:node /app/packages/backend/dist/ ./packages/backend/dist/
COPY --from=build --chown=node:node /app/packages/backend/package.json ./packages/backend/package.json

# Copy frontend assets
COPY --from=build --chown=node:node /app/packages/app/dist/ ./packages/app/dist/
COPY --from=build --chown=node:node /app/packages/app/package.json ./packages/app/package.json

# Copy configuration
COPY --from=build --chown=node:node /app/app-config*.yaml ./

# Install production dependencies
USER node
RUN yarn install --frozen-lockfile --production

# Set environment variables
ENV NODE_ENV production
ENV BACKSTAGE_APP_ENV production

# Expose port
EXPOSE 7007

# Use tini for proper process management
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start the backend
CMD ["node", "packages/backend"]