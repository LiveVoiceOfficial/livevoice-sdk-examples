const path = require('path');
const fs = require('fs');
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const projectRoot = __dirname;

/**
 * Local-development support for the LiveVoice wrapper.
 *
 * When `livevoice-sdk-react-native` is linked to a local checkout (e.g. `yarn link`, which adds a
 * Yarn `portal:` symlink), that checkout lives OUTSIDE this project, and Metro won't resolve/bundle
 * files outside its `watchFolders` — so add the linked package's real path when it points elsewhere.
 * For a normal npm install (a fresh clone) the package sits inside `node_modules`, so this stays
 * empty and the config is a no-op.
 */
const watchFolders = [];
const resolverConfig = {};
const serverConfig = {};
try {
  const linked = fs.realpathSync(path.join(projectRoot, 'node_modules', 'livevoice-sdk-react-native'));
  if (!linked.startsWith(projectRoot)) {
    watchFolders.push(linked);

    // Force a SINGLE copy of react / react-native. The linked wrapper ships its own
    // node_modules/react(+native), and Metro resolves those nested copies for imports
    // originating inside the wrapper. `extraNodeModules` is only a *fallback* (consulted
    // when a module isn't otherwise found), so it can't override the wrapper's nested
    // copies — you still get a duplicate React, which surfaces as
    // "Cannot read property 'useSyncExternalStore' of null" (or "Invalid hook call").
    // A resolveRequest redirect rewrites every react / react-native import — from any
    // file, wrapper included — to this app's copy, which also matches the native binary.
    const forced = {
      react: path.join(projectRoot, 'node_modules', 'react'),
      'react-native': path.join(projectRoot, 'node_modules', 'react-native'),
    };
    resolverConfig.extraNodeModules = forced;
    resolverConfig.resolveRequest = (context, moduleName, platform) => {
      // Order matters: test 'react-native' before 'react'. Match the bare package and its
      // subpaths only ('react', 'react/jsx-runtime', 'react-native/Libraries/…') — never
      // siblings like 'react-native-safe-area-context' or 'react-dom'.
      for (const pkg of ['react-native', 'react']) {
        if (moduleName === pkg || moduleName.startsWith(pkg + '/')) {
          const rest = moduleName.slice(pkg.length); // '' or '/subpath'
          return context.resolveRequest(context, forced[pkg] + rest, platform);
        }
      }
      return context.resolveRequest(context, moduleName, platform);
    };

    // The wrapper's images. A Debug app loads each image from this server, at an address made
    // from the file's path relative to the project: '/assets/../../livevoice-sdk-react-native/…'
    // for the linked checkout. Metro refuses that address. Android resolves the '..' segments
    // before sending, so its request arrives as '/livevoice-sdk-react-native/…'; iOS sends the
    // address as it is. Hand both forms to Metro's asset endpoint with the real relative path.
    const relative = path.relative(projectRoot, linked).split(path.sep).join('/');
    const prefixes = ['/assets/' + relative + '/', '/' + relative.replace(/^(\.\.\/)+/, '') + '/'];
    serverConfig.enhanceMiddleware = middleware => (req, res, next) => {
      const prefix = prefixes.find(candidate => req.url.startsWith(candidate));
      if (prefix != null) {
        const [pathname, query] = req.url.split('?');
        const file = relative + '/' + pathname.slice(prefix.length);
        req.url = '/assets/?unstable_path=' + encodeURIComponent(file) + (query ? '&' + query : '');
      }
      return middleware(req, res, next);
    };
  }
} catch {
  // Not installed / not linked — nothing to add.
}

/** @type {import('@react-native/metro-config').MetroConfig} */
const config = {
  watchFolders,
  resolver: resolverConfig,
  server: serverConfig,
};

module.exports = mergeConfig(getDefaultConfig(projectRoot), config);
