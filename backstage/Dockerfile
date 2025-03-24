FROM ghcr.io/backstage/backstage:latest

WORKDIR /app

# Switch to root for privileged operations
USER root

# Create essential config with backend.baseUrl 
RUN echo 'backend:\n  baseUrl: http://localhost:7007' > /app/app-config.base.yaml

# Install the Kubernetes plugins with exact versions that are compatible
RUN cd packages/backend && yarn add \
    @backstage/plugin-kubernetes@0.12.5 \
    @backstage/plugin-kubernetes-backend@0.19.4

# Copy Kubernetes configuration
COPY app-config.kubernetes.yaml /app/

# Merge configurations into app-config.yaml
RUN cat /app/app-config.base.yaml > /app/app-config.default.yaml && \
    cat /app/app-config.kubernetes.yaml >> /app/app-config.default.yaml

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

# Patch the main backend file to load the plugin
RUN sed -i 's/const app = express()/const app = express();\\nconst kubernetes = require(".\/plugins\/kubernetes");/' /app/packages/backend/dist/index.cjs.js && \
    sed -i 's/apiRouter.use("\/proxy"/apiRouter.use("\/kubernetes", await kubernetes(middlewareEnv));\\n  apiRouter.use("\/proxy"/' /app/packages/backend/dist/index.cjs.js

# Create a startup script to ensure we always have baseUrl
USER root
RUN echo '#!/bin/bash\n\
if grep -q "backend:" /app/app-config.yaml && ! grep -q "baseUrl:" /app/app-config.yaml; then\n\
  echo "Adding backend.baseUrl to app-config.yaml"\n\
  echo "backend:\\n  baseUrl: http://localhost:7007" >> /app/app-config.yaml\n\
fi\n\
exec node packages/backend --config app-config.yaml --config app-config.default.yaml\n' > /app/start.sh && \
chmod +x /app/start.sh

EXPOSE 7007

# Use our startup script instead of calling node directly
CMD ["/app/start.sh"]