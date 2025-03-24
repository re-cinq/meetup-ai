// packages/backend/src/index.ts (modified)
import Router from 'express-promise-router';
import { createServiceBuilder } from '@backstage/backend-common';
// ... other imports ...
import proxy from './plugins/proxy';
import techdocs from './plugins/techdocs';
import search from './plugins/search';
// ADD THIS IMPORT:
import kubernetes from './plugins/kubernetes';

export default async function createPlugin() {
  // ... existing code ...
  const proxyEnv = useHotMemoize(module, () => createEnv('proxy'));
  // ADD THIS LINE:
  const kubernetesEnv = useHotMemoize(module, () => createEnv('kubernetes'));
  const searchEnv = useHotMemoize(module, () => createEnv('search'));
  const appEnv = useHotMemoize(module, () => createEnv('app'));

  const apiRouter = Router();
  apiRouter.use('/catalog', await catalog(catalogEnv));
  apiRouter.use('/scaffolder', await scaffolder(scaffolderEnv));
  apiRouter.use('/auth', await auth(authEnv));
  apiRouter.use('/techdocs', await techdocs(techdocsEnv));
  apiRouter.use('/proxy', await proxy(proxyEnv));
  apiRouter.use('/search', await search(searchEnv));
  // ADD THIS LINE:
  apiRouter.use('/kubernetes', await kubernetes(kubernetesEnv));

  // ... rest of the file ...
}