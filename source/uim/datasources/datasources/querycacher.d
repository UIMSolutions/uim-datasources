module uim.cake.datasources;

import uim.cake;

@safe:

/**
 * Handles caching queries and loading results from the cache.
 *
 * Used by {@link \UIM\Datasource\QueryTrait} internally.
 *
 * @internal
 * @see \UIM\Datasource\QueryTrait.cache() for the interface.
 */
class QueryCacher {
    // The key or auto to generate a key
    protected Closure|string _key;

    // Config for cache engine.
    protected ICache|string _config;

    /**
     * Constructor.
     * Params:
     * \Closure|string aKey The key or auto to generate a key.
     * @param \Psr\SimpleCache\ICache|string configData The cache config name or cache engine instance.
     * @throws \RuntimeException
     */
    this(Closure|string aKey, ICache|string configData) {
       _key = aKey;
       _config = configData;
    }
    
    /**
     * Load the cached results from the cache or run the query.
     * Params:
     * object aQuery The query the cache read is for.
     */
    Json fetch(object aQuery) {
        aKey = _resolveKey(aQuery);
        storage = _resolveCacher();
        result = storage.get(aKey);
        if (isEmpty(result)) {
            return null;
        }
        return result;
    }
    
    /**
     * Store the result set into the cache.
     * Params:
     * object aQuery The query the cache read is for.
     * @param \Traversable results The result set to store.
     */
    bool store(object aQuery, Traversable results) {
        aKey = _resolveKey(aQuery);
        storage = _resolveCacher();

        return storage.set(aKey, results);
    }
    
    /**
     * Get/generate the cache key.
     * Params:
     * object aQuery The query to generate a key for.
     */
    protected string _resolveKey(object aQuery) {
        if (isString(_key)) {
            return _key;
        }
        func = _key;
        auto result = func(aQuery);
        if (!isString(result)) {
            string message = "Cache key functions must return a string. Got %s."
            .format(var_export(result, true));
            throw new UimException(message);
        }
        return result;
    }

    // Get the cache engine.
    protected ICache _resolveCacher() {
        if (isString(_config)) {
            return Cache.pool(_config);
        }
        return _config;
    }
}
