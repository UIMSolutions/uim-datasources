/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.queries.cacher;

use Closure;
use Psr\SimpleCache\ICache;
use RuntimeException;
use Traversable;

/**
 * Handles caching queries and loading results from the cache.
 *
 * Used by {@link uim.cake.Datasource\QueryTrait} internally.
 *
 * @internal
 * @see uim.datasources.QueryTrait::cache() for the interface.
 */
class QueryCacher
{
    /**
     * The key or function to generate a key.
     *
     * @var \Closure|string
     */
    protected _key;

    /**
     * Config for cache engine.
     *
     * @var \Psr\SimpleCache\ICache|string
     */
    protected _config;

    /**
     * Constructor.
     *
     * @param \Closure|string aKey The key or function to generate a key.
     * @param \Psr\SimpleCache\ICache|string aConfig The cache config name or cache engine instance.
     * @throws \RuntimeException
     */
    this(key, aConfig) {
        if (!is_string(key) && !(key instanceof Closure)) {
            throw new RuntimeException("Cache keys must be strings or callables.");
        }
        _key = key;

        if (!is_string(aConfig) && !(aConfig instanceof ICache)) {
            throw new RuntimeException("Cache configs must be strings or \Psr\SimpleCache\ICache instances.");
        }
        _config = aConfig;
    }

    /**
     * Load the cached results from the cache or run the query.
     *
     * @param object query The query the cache read is for.
     * @return mixed|null Either the cached results or null.
     */
    function fetch(object query) {
        key = _resolveKey(query);
        storage = _resolveCacher();
        result = storage.get(string aKey);
        if (empty(result)) {
            return null;
        }

        return result;
    }

    /**
     * Store the result set into the cache.
     *
     * @param object query The query the cache read is for.
     * @param \Traversable results The result set to store.
     * @return bool True if the data was successfully cached, false on failure
     */
    bool store(object query, Traversable results) {
        key = _resolveKey(query);
        storage = _resolveCacher();

        return storage.set(string aKey, results);
    }

    /**
     * Get/generate the cache key.
     *
     * @param object query The query to generate a key for.
     * @return string
     * @throws \RuntimeException
     */
    protected string _resolveKey(object query) {
        if (is_string(_key)) {
            return _key;
        }
        func = _key;
        key = func(query);
        if (!is_string(key)) {
            msg = sprintf("Cache key functions must return a string. Got %s.", var_export(key, true));
            throw new RuntimeException(msg);
        }

        return key;
    }

    /**
     * Get the cache engine.
     *
     * @return \Psr\SimpleCache\ICache
     */
    protected function _resolveCacher() {
        if (is_string(_config)) {
            return Cache::pool(_config);
        }

        return _config;
    }
}
