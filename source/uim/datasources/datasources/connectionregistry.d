module uim.cake.datasources;

import uim.cake;

@safe:

/*
/**
 * A registry object for connection instances.
 *
 * @see \UIM\Datasource\ConnectionManager
 * @extends \UIM\Core\ObjectRegistry<\UIM\Datasource\IConnection>
 */
class ConnectionRegistry : ObjectRegistry {
    /**
     * Resolve a datasource classname.
     *
     * Part of the template method for UIM\Core\ObjectRegistry.load()
     */
    protected string _resolveClassName(string className) {
        /** @var class-string<\UIM\Datasource\IConnection>|null */
        return App.className(className, "Datasource");
    }
    
    /**
     * Throws an exception when a datasource is missing
     *
     * Part of the template method for UIM\Core\ObjectRegistry.load()
     * Params:
     * @param string plugin The plugin the datasource is missing in.
     */
    protected void _throwMissingClassError(string className, string aplugin) {
        throw new MissingDatasourceException([
            "class":  className,
            "plugin": plugin,
        ]);
    }
    
    /**
     * Create the connection object with the correct settings.
     *
     * Part of the template method for UIM\Core\ObjectRegistry.load()
     *
     * If a closure is passed as first argument, The returned value of this
     * auto will be the result from calling the closure.
     * Params:
     * \UIM\Datasource\IConnection|\Closure|class-string<\UIM\Datasource\IConnection>  className The classname or object to make.
     * @param string aalias The alias of the object.
     * @param IConfigData[string] configData An array of settings to use for the datasource.
     */
    protected IConnection _create(object|string className, string aalias, IConfigData[string] configData) {
        if (isString(className)) {
            unset(configData("className"]);

            return new className(configData);
        }
        if (cast(Closure)className) {
            return className($alias);
        }
        return className;
    }

    // Remove a single adapter from the registry.
    void unload(string adapterName) {
        unset(_loaded[adapterName]);
    }
}
