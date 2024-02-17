/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.locators.locator;

@safe:
import uim.datasources;

// use RuntimeException;

// Provides an abstract registry/factory for repository objects.
abstract class AbstractLocator : ILocator {
    /**
     * Instances that belong to the registry.
     *
     * @var array<string, uim.cake.Datasource\>
     */
    protected IRepository[string] instances;

    // Contains a list of options that were passed to get() method.
    protected array[string] $options = null;

    /**
     * {@inheritDoc}
     *
     * @param string alias The alias name you want to get.
     * @param array<string, mixed> $options The options you want to build the table with.
     */
    IRepository get(string alias, STRINGAA someOptions = null) {
        auto storeOptions = $options;
        storeOptions.remove("allowFallbackClass");

        if (this.instances.isSet($alias)) {
            if (!empty($storeOptions) && isset(this.options[$alias]) && this.options[$alias] != $storeOptions) {
                throw new RuntimeException(sprintf(
                    "You cannot configure '%s', it already exists in the registry.",
                    alias
                ));
            }

            return this.instances[$alias];
        }

        this.options[$alias] = storeOptions;

        return this.instances[$alias] = this.createInstance($alias, $options);
    }

    /**
     * Create an instance of a given classname.
     *
     * @param string alias Repository alias.
     * @param array<string, mixed> $options The options you want to build the instance with.
     * @return uim.cake.Datasource\
     */
    abstract protected IRepository createInstance(string alias, STRINGAA someOptions);


    function set(string alias, IRepository $repository) {
        return this.instances[$alias] = $repository;
    }


    bool exists(string alias) {
        return isset(this.instances[$alias]);
    }


    void remove(string alias) {
        unset(
            this.instances[$alias],
            this.options[$alias]
        );
    }


    void clear() {
        this.instances = null;
        this.options = null;
    }
}
