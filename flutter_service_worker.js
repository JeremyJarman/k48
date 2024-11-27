'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "f15a79f9b6cc34f007de3e346b7b8eb6",
"assets/AssetManifest.bin.json": "49749ce9314754a5ac04ad355712f2b1",
"assets/AssetManifest.json": "25fd29f53076eed93fa1c67d6b087084",
"assets/assets/Adjectives.csv": "01cd060fc1c6db2cdcd5282df7238cb1",
"assets/assets/Aevone.jpg": "647369ffaa2057463d2d61a0e74bd976",
"assets/assets/ArticleNounPairs.csv": "1d857c78826de76b681fad16ffa95261",
"assets/assets/galaxy.jpg": "7987200c4c09707989caf1ddb4fa9051",
"assets/assets/GameOverFrame.svg": "fe7a83e95c326a0883839aca958d5867",
"assets/assets/Nexar2.jpg": "7c482b0f32da67b5c113b4ebff55e2f4",
"assets/assets/ranks/Explorer1.svg": "0e49ef748bd0daa29002cc789758fc97",
"assets/assets/ranks/Explorer2.svg": "6ff22bb624d415c6db12564f8cac47c2",
"assets/assets/ranks/Explorer3.svg": "e36580e17e4b7bceb06dba166b0552b9",
"assets/assets/ranks/Intern1.svg": "423c39cbaa1cb7904cbcdc8771296daa",
"assets/assets/ranks/Intern2.svg": "be1be67ae4609fb40b7c5c771ff4cd55",
"assets/assets/ranks/Intern3.svg": "132b413e8298635968b891219a7dde71",
"assets/assets/ranks/Legend1.svg": "0449c7b0f564aaeed4d7045a7d033878",
"assets/assets/ranks/Legend2.svg": "a933f091529631ef39c9a458dc3cab49",
"assets/assets/ranks/Legend3.svg": "9406752a363767e5f6ed236bdd03660b",
"assets/assets/ranks/Navigator1.svg": "1a0191beb0fa92487c01363ba40e0a11",
"assets/assets/ranks/Navigator2.svg": "025dd5a52f5638f0f60956add4d7b582",
"assets/assets/ranks/Navigator3.svg": "40c68dbddc26300d1c874c6a23e80716",
"assets/assets/ranks/Pilot1.svg": "50907d0a9e9ea9096ced7892afe6f2df",
"assets/assets/ranks/Pilot2.svg": "2f9ae2aa35c19ce4796bfc37d36b7e9a",
"assets/assets/ranks/Pilot3.svg": "6032aa3618ebfe5ad7ae644e9b974713",
"assets/assets/ranks/Pioneer1.svg": "e5b21c5c57565abf7e01bc296924bfa9",
"assets/assets/ranks/Pioneer2.svg": "3427808c9fb9224f38985462a01c60a6",
"assets/assets/ranks/Pioneer3.svg": "aed8247ca098ec526be621fadde3b1b0",
"assets/assets/ranks/Scholar1.svg": "c122c3cd223f736848cdc4553e954833",
"assets/assets/ranks/Scholar2.svg": "54af533aa6714b3038b6b7cc992aff73",
"assets/assets/ranks/Scholar3.svg": "8e4c6e2e1d363ccb55ac5c86560b7e9f",
"assets/assets/ranks/Voyager1.svg": "80f7baaa70889abc9cc4df5616bef72d",
"assets/assets/ranks/Voyager2.svg": "2d747800bb5b0b72a77b36908141f240",
"assets/assets/ranks/Voyager3.svg": "3f71874b22fba204bcc40f68111540be",
"assets/assets/stars.jpg": "bb7ed80e11aa2dfdad81042ae6674fe9",
"assets/assets/WarpFrame.png": "c850e812f6c4d0fce7431d88b74368e5",
"assets/assets/WelcomeText.txt": "42e696d9c942a5c701105675ed3eb2d2",
"assets/FontManifest.json": "cf3c681641169319e61b61bd0277378f",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "59da487e6756dd5a21828b0f002bf6ff",
"assets/packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf": "e9f2f143310604845f8aa26c42ad5f55",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "38f68e323a11da1b2bea0b8939ef9013",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "48a6825b0d38c68d2874e9174433d4c3",
"/": "48a6825b0d38c68d2874e9174433d4c3",
"main.dart.js": "26391c76d72b5e027c07c34d5eb10aeb",
"manifest.json": "69ba61cc3cd6255ea3447bb6eafa3b5c",
"version.json": "d4f7a4e38cf8c2166ca63e5ff6352955"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
