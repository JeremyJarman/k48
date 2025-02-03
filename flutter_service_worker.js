'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "bb3946e0569be11c849666a381987376",
"assets/AssetManifest.bin.json": "ad527520ea35255f06257ce080cbe8b6",
"assets/AssetManifest.json": "1c87151ed2fddb4239945ac70566c359",
"assets/assets/Adjectives.csv": "01cd060fc1c6db2cdcd5282df7238cb1",
"assets/assets/Aevone.jpg": "647369ffaa2057463d2d61a0e74bd976",
"assets/assets/ArticleNounPairs.csv": "1d857c78826de76b681fad16ffa95261",
"assets/assets/AssetManifest.bin": "f15a79f9b6cc34f007de3e346b7b8eb6",
"assets/assets/AssetManifest.bin.json": "49749ce9314754a5ac04ad355712f2b1",
"assets/assets/AssetManifest.json": "25fd29f53076eed93fa1c67d6b087084",
"assets/assets/d1.csv": "5d084e50a9481aed8c85548d396b7a8f",
"assets/assets/d10.csv": "9966b86ca759541bcfec53e2d14a241e",
"assets/assets/d11.csv": "c88fd628f59bc0518e5c38d4cd04a9b3",
"assets/assets/d12.csv": "81bc7a69c5184c89ed791e22a1e3c5ed",
"assets/assets/d13.csv": "c56cd7054d7713a7365d3dc9dcca4a54",
"assets/assets/d14.csv": "aaa9c0a5c74e01f1332fec5e67ad847a",
"assets/assets/d15.csv": "4ff408c6cdac88e9917795830e8949b4",
"assets/assets/d16.csv": "bf362403a90ff724962fef3ccc2e33cb",
"assets/assets/d17.csv": "c6bdd76d123149aecec4be72ffbf58cf",
"assets/assets/d18.csv": "d442e09a1acd80e01061cda4a72de659",
"assets/assets/d2.csv": "00dea1e3c98bda8632b9ab1fa10c343b",
"assets/assets/d3.csv": "4ee04253759c0de2472a17cde649d289",
"assets/assets/d4.csv": "dfc1ac9ffcc9bd1d60c931bb4d170da0",
"assets/assets/d5.csv": "db8823e3aa35979e09d100f7d433a044",
"assets/assets/d6.csv": "8e429741a45baa62b9a9cf980043fb4a",
"assets/assets/d7.csv": "bb2e15e076720dee228939ae965a31aa",
"assets/assets/d8.csv": "c5a6dcedb3149adca801f8df92d23266",
"assets/assets/d9.csv": "e9b82b46215d33aa2c2d2cf0edf98959",
"assets/assets/FontManifest.json": "cf3c681641169319e61b61bd0277378f",
"assets/assets/galaxy.jpg": "17960eb843d6739f59b0ccae282147d6",
"assets/assets/GameOverFrame.svg": "0ec320fe10fdaadd5ea4c4aa99b46295",
"assets/assets/manifest.json": "69ba61cc3cd6255ea3447bb6eafa3b5c",
"assets/assets/Nexar2.jpg": "7c482b0f32da67b5c113b4ebff55e2f4",
"assets/assets/NOTICES": "471d250a3afc8e9867d01ce1f700f925",
"assets/assets/ranks/Explorer1.svg": "86bf7d96aa74f523669d83cacc77dadb",
"assets/assets/ranks/Explorer2.svg": "52a9ced6dcf7a73a81cc70fd155f4be8",
"assets/assets/ranks/Explorer3.svg": "3bce989a8e9ff28bfb5c43a0f2e8a499",
"assets/assets/ranks/Intern1.svg": "25ddb5a7a5624bda953c2bd9642198a6",
"assets/assets/ranks/Intern2.svg": "9595442666c35deda9367145bac80914",
"assets/assets/ranks/Intern3.svg": "1c5dc223b4d75db5e09ee0114636f2af",
"assets/assets/ranks/Legend1.svg": "a9f4f84c1a6b32d376236357d7fc18de",
"assets/assets/ranks/Legend2.svg": "79ef69a03c838326180bcb06bc34a0d2",
"assets/assets/ranks/Legend3.svg": "63aafe4f27ec3acd832ebc00ef014675",
"assets/assets/ranks/Navigator1.svg": "19cc215bc78cfdcb7a310d82f0ab80a5",
"assets/assets/ranks/Navigator2.svg": "5582e5e6d7db9ad6f9826c67aa6184aa",
"assets/assets/ranks/Navigator3.svg": "2d77f2127a01fd6a07b4324946c00616",
"assets/assets/ranks/Pilot1.svg": "923b37afaaf68b816b7f4d5ec9b1925a",
"assets/assets/ranks/Pilot2.svg": "19891ef6ff18714cc86c6f7f68f6f9cb",
"assets/assets/ranks/Pilot3.svg": "0bb6fede85b328279c9ac67667eed23d",
"assets/assets/ranks/Pioneer1.svg": "9aea8bb108e9af1fd7b5a0c3dc129c30",
"assets/assets/ranks/Pioneer2.svg": "5f28a0d59a03258ff0dc422a9a2901de",
"assets/assets/ranks/Pioneer3.svg": "07bc3f02e010a2ccdd56aa837e915a14",
"assets/assets/ranks/Scholar1.svg": "6a45edd39d42a2630ea6da81f67fa00e",
"assets/assets/ranks/Scholar2.svg": "201de47ca47b8c03df3062889b941799",
"assets/assets/ranks/Scholar3.svg": "0fdc87617a84e575938ceb08de7420b1",
"assets/assets/ranks/Voyager1.svg": "f6802c739c25db83cddaa7fe8b69a334",
"assets/assets/ranks/Voyager2.svg": "df616d77736035347d3eb9b3550da430",
"assets/assets/ranks/Voyager3.svg": "3d5720129a7b0d675effd35092bd9577",
"assets/assets/Stars.csv": "59e06b0f7251bb58a99124c735dee3f8",
"assets/assets/stars.jpg": "45f07017660f5d9522141fe412cb757a",
"assets/assets/WarpFrame.png": "c850e812f6c4d0fce7431d88b74368e5",
"assets/assets/WelcomeText.txt": "42e696d9c942a5c701105675ed3eb2d2",
"assets/assets/WordLists_01.csv": "303d49f8746cd6aca4f7f0167067796f",
"assets/assets/WordLists_02.csv": "b62bcd7c47f4e690fcacb114b03a60d4",
"assets/assets/WordLists_03.csv": "8b04fcfa1371b7e0d5accc593f03b6c5",
"assets/assets/WordLists_04.csv": "cb4c9f503d5afd403c2a6b8fe556aa3c",
"assets/FontManifest.json": "1b1e7812d9eb9f666db8444d7dde1b20",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "3718be74ca3552bc238dc456d4c21170",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/material_design_icons_flutter/lib/fonts/materialdesignicons-webfont.ttf": "e9f2f143310604845f8aa26c42ad5f55",
"assets/ranks/Explorer1.svg": "86bf7d96aa74f523669d83cacc77dadb",
"assets/ranks/Explorer2.svg": "52a9ced6dcf7a73a81cc70fd155f4be8",
"assets/ranks/Explorer3.svg": "3bce989a8e9ff28bfb5c43a0f2e8a499",
"assets/ranks/Intern1.svg": "25ddb5a7a5624bda953c2bd9642198a6",
"assets/ranks/Intern2.svg": "9595442666c35deda9367145bac80914",
"assets/ranks/Intern3.svg": "1c5dc223b4d75db5e09ee0114636f2af",
"assets/ranks/Legend1.svg": "a9f4f84c1a6b32d376236357d7fc18de",
"assets/ranks/Legend2.svg": "79ef69a03c838326180bcb06bc34a0d2",
"assets/ranks/Legend3.svg": "63aafe4f27ec3acd832ebc00ef014675",
"assets/ranks/Navigator1.svg": "19cc215bc78cfdcb7a310d82f0ab80a5",
"assets/ranks/Navigator2.svg": "5582e5e6d7db9ad6f9826c67aa6184aa",
"assets/ranks/Navigator3.svg": "2d77f2127a01fd6a07b4324946c00616",
"assets/ranks/Pilot1.svg": "923b37afaaf68b816b7f4d5ec9b1925a",
"assets/ranks/Pilot2.svg": "19891ef6ff18714cc86c6f7f68f6f9cb",
"assets/ranks/Pilot3.svg": "0bb6fede85b328279c9ac67667eed23d",
"assets/ranks/Pioneer1.svg": "9aea8bb108e9af1fd7b5a0c3dc129c30",
"assets/ranks/Pioneer2.svg": "5f28a0d59a03258ff0dc422a9a2901de",
"assets/ranks/Pioneer3.svg": "07bc3f02e010a2ccdd56aa837e915a14",
"assets/ranks/Scholar1.svg": "6a45edd39d42a2630ea6da81f67fa00e",
"assets/ranks/Scholar2.svg": "201de47ca47b8c03df3062889b941799",
"assets/ranks/Scholar3.svg": "0fdc87617a84e575938ceb08de7420b1",
"assets/ranks/Voyager1.svg": "f6802c739c25db83cddaa7fe8b69a334",
"assets/ranks/Voyager2.svg": "df616d77736035347d3eb9b3550da430",
"assets/ranks/Voyager3.svg": "3d5720129a7b0d675effd35092bd9577",
"assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"canvaskit/canvaskit.js": "4a9bf79219d86ed807ac1ea2c30e01dd",
"canvaskit/canvaskit.js.symbols": "7591a27e90a9f47b73104b5beea5f732",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "067d1b778b913719f905e9eba6d9f2d4",
"canvaskit/chromium/canvaskit.js.symbols": "5e3724af47d205af948bfc9946c80dc4",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "9e94c7112288ea6e16844d9879ce08dc",
"canvaskit/skwasm.js.symbols": "601a3adb24ac6b21b8e89735a27416f3",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "b31cd002f2ed6e6d27aed1fa7658efae",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "cba20c120ae4ddb4032083938b14d54a",
"flutter_bootstrap.js": "be7e2478cca4a032a3fe4ec5e6953765",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "1ddbf44347ab5319ff6c8d2c09ea24fe",
"/": "1ddbf44347ab5319ff6c8d2c09ea24fe",
"main.dart.js": "a384c54859d94af02975f286312334d8",
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
