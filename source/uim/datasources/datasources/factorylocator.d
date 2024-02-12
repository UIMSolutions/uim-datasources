module uim.datasources;

import uim.datasources;

@safe:

class FactoryLocator {
    // A list of model factory functions.
    protected static ILocator[string] _modelFactories = [];

    /**
     * Register a locator to return repositories of a given type.
     * Params:
     * string atype The name of the repository type the factory bool is for.
     * @param \UIM\Datasource\Locator\ILocator factory The factory auto used to create instances.
     */
    static void add(string atype, ILocator factory) {
        _modelFactories[$type] = factory;
    }
    
    /**
     * Drop a model factory.
     * Params:
     * string atype The name of the repository type to drop the factory for.
     */
    static void drop(string typeName) {
        _modelFactories.remove(typeName);
    }
    
    /**
     * Get the factory for the specified repository type.
     * Params:
     * string atype The repository type to get the factory for.
     * @throws \InvalidArgumentException If the specified repository type has no factory.
     */
    static ILocator get(string atype) {
        if (isSet(_modelFactories[type])) {
            return _modelFactories[type];
        }
        throw new InvalidArgumentException(
            "Unknown repository type `%s`. Make sure you register a type before trying to use it."
            .format(type)
        ));
    }
}
