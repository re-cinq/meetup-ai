const { createBackendModule } = require('@backstage/backend-plugin-api');
const { kubernetesPlugin } = require('@backstage/plugin-kubernetes-backend');

module.exports.kubernetesModulePlugin = createBackendModule({
  pluginId: 'kubernetes',
  moduleId: 'kubernetes',
  register(env) {
    env.registerInit({
      deps: {
        discovery: 'discovery',
        logger: 'logger',
        config: 'config',
        permissions: 'permissions',
      },
      async init({ discovery, logger, config, permissions }) {
        return await kubernetesPlugin({
          discovery,
          logger,
          config,
          permissions,
        });
      },
    });
  },
});