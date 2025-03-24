FROM ghcr.io/backstage/backstage:latest

WORKDIR /app

# Switch to root for privileged operations
USER root

# Install the Kubernetes plugins with exact versions
RUN cd packages/backend && yarn add \
    @backstage/plugin-kubernetes@0.12.5 \
    @backstage/plugin-kubernetes-backend@0.19.4

# Create plugin directories with proper permissions
RUN mkdir -p /app/packages/backend/dist/plugins && \
    chown -R node:node /app/packages/backend/dist/plugins

# Switch to the node user for file operations
USER node

# Create kubernetes plugin file
RUN echo "const { createRouter } = require('@backstage/plugin-kubernetes-backend');" > /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "module.exports = async function createPlugin(env) {" >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "  return await createRouter({" >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "    logger: env.logger," >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "    config: env.config," >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "    discovery: env.discovery," >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "    permissions: env.permissions," >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "  });" >> /app/packages/backend/dist/plugins/kubernetes.js && \
    echo "};" >> /app/packages/backend/dist/plugins/kubernetes.js

# Patch the main backend file to load the plugin in a less invasive way
RUN sed -i '/const app = express/a const kubernetes = require("./plugins/kubernetes");' /app/packages/backend/dist/index.cjs.js && \
    sed -i '/apiRouter.use.*proxy/i \ \ apiRouter.use("/kubernetes", await kubernetes(middlewareEnv));' /app/packages/backend/dist/index.cjs.js

# Switch back to root for the final command
USER root

EXPOSE 7007

# Use the standard entry point, don't modify configs
CMD ["node", "packages/backend", "--config", "app-config.yaml"]