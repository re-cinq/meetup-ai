// merge-configs.js
const fs = require('fs');
const yaml = require('js-yaml');

function mergeConfigs(baseConfigPath, overrideConfigPath, outputConfigPath) {
  try {
    let baseConfig = {};
    if (fs.existsSync(baseConfigPath)) {
      baseConfig = yaml.load(fs.readFileSync(baseConfigPath, 'utf8'));
    }

    let overrideConfig = {};
    if (fs.existsSync(overrideConfigPath)) {
      overrideConfig = yaml.load(fs.readFileSync(overrideConfigPath, 'utf8'));
    }

    function deepMerge(target, source) {
      for (const key in source) {
        if (source[key] && typeof source[key] === 'object') {
          target[key] = target[key] || {};
          deepMerge(target[key], source[key]);
        } else {
          target[key] = source[key];
        }
      }
      return target;
    }

    const mergedConfig = deepMerge(baseConfig, overrideConfig);
    fs.writeFileSync(outputConfigPath, yaml.dump(mergedConfig));
    console.log(`Merged config saved to ${outputConfigPath}`);

  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

// Merge app-config.yaml with app-config.kubernetes.yaml
mergeConfigs('/app/app-config.yaml', '/app/app-config.kubernetes.yaml', '/app/app-config.local.yaml');