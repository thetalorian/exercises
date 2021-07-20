# Option 3 - Implement a web application that uses a fixed-sized LRU cache to efficiently serve up imagery

I'd like to see you build an app that exposes a web API. This API should accept two floats, the first in the range -90 to 90 (Lat) and the second in the range of -180 to 180 (Long), which are Mars coordinates. The app returns the URL of an image file of those coordinates on the Martian surface, or one of the standard HTTP error codes.

This app implements an LRU cache of fixed size (3000), keyed on Lat/Long pairs, which operates in O(1) to return the requested URL. New URLs are obtained using a library function GetImageURL(float, float), which returns instantaneously but at a high $ cost; implement a stub version of GetImageURL() that returns a random number as a string for purposes of this problem.
On a cache hit, the app returns the cached URL. On a cache miss, the app obtains a new URL and caches it, ejecting the oldest cached item if the cache is full. These operations must occur in O(1).

Bonus points for adding diagnostic API calls to get and clear cache hit and miss counters, and to track the execution time of each of the three main LRU cache behaviors (hit, miss when not full, miss when full).

# Implementation

Pending...
