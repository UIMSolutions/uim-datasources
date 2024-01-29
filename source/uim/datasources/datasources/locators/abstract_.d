module uim.datasources.locators.abstract_;

import uim.cake;

@safe:

// Provides an abstract registry/factory for repository objects.
abstract class AbstractLocator : ILocator {
    // Instances that belong to the registry.
    protected IRepository[string]  anInstances = [];

    /**
     * Contains a list of options that were passed to get() method.
     */
    protected Json[string] options = null;

    /**
 Params:
     * string aalias The alias name you want to get.
     * @param Json[string] options The options you want to build the table with.
     */
    IRepository get(string aalias, Json[string] options = null) {
        storeOptions = options;
        unset($storeOptions["allowFallbackClass"]);

        if (isSet(this.instances[$alias])) {
            if (!empty($storeOptions) && isSet(this.options[$alias]) && this.options[$alias] != storeOptions) {
                throw new UimException(
                    "You cannot configure `%s`, it already exists in the registry.",
                    .format($alias)
                );
            }
            return this.instances[$alias];
        }
        this.options[$alias] = storeOptions;

        return this.instances[$alias] = this.createInstance($alias, options);
    }
    
    /**
     * Create an instance of a given classname.
     * Params:
     * string aalias Repository alias.
     * @param Json[string] options The options you want to build the instance with.
     */
    abstract protected IRepository createInstance(string aalias, Json[string] options = null);

 
    IRepository set(string aalias, IRepository repository) {
        return this.instances[$alias] = repository;
    }
 
    bool exists(string aalias) {
        return isSet(this.instances[$alias]);
    }
 
    void remove(string aalias) {
        unset(
            this.instances[$alias],
            this.options[$alias]
        );
    }
 
    void clear() {
        this.instances = [];
        this.options = [];
    }
}
