FROM backstage/backstage:latest

WORKDIR /app

# Temporarily switch to root for operations requiring elevated permissions
USER root

# Create base config with the critical backend.baseUrl setting
RUN echo 'backend:\n  baseUrl: http://localhost:7007' > /app/app-config.base.yaml

# Install the Kubernetes plugins
RUN cd packages/backend && yarn add \
    @backstage/plugin-kubernetes \
    @backstage/plugin-kubernetes-backend

# Copy Kubernetes configuration
COPY app-config.kubernetes.yaml /app/

# Merge configurations - this ensures the baseUrl setting is included in the final config
RUN cat /app/app-config.base.yaml > /app/app-config.yaml && \
    cat /app/app-config.kubernetes.yaml >> /app/app-config.yaml

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

EXPOSE 7007

# Also modify the CMD to load BOTH config files (fallback in case the mounted config doesn't have baseUrl)
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.base.yaml"]