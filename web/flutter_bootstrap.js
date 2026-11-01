{{flutter_js}}
{{flutter_build_config}}

// Keep the renderer local so the catalog does not depend on an external CDN.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
}).catch(function (error) {
  console.error('Flutter initialization failed', error);
  window.showStartupError();
});
