FROM backstage/backstage:latest

WORKDIR /app

# Install the Kubernetes plugins
RUN yarn add @backstage/plugin-kubernetes @backstage/plugin-kubernetes-backend --cwd packages/backend

# Copy essential configuration files
COPY app-config.kubernetes.yaml /app/
COPY kubernetes.ts /app/packages/backend/src/plugins/
COPY index.ts /app/packages/backend/src/index.ts
COPY merge-configs.js /app/

# Merge configurations
RUN node /app/merge-configs.js

EXPOSE 7007

CMD ["node", "packages/backend", "--config", "app-config.local.yaml"]