/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.cake.satasources;

@safe:
import uim.datasources;

// use InvalidArgumentException;

class FactoryLocator {
    /**
     * A list of model factory functions.
     *
     * @var array<callable|uim.cake.Datasource\Locator\ILocator>
     */
    protected static _modelFactories = null;

    /**
     * Register a callable to generate repositories of a given type.
     *
     * @param string $type The name of the repository type the factory bool is for.
     * @param uim.cake.Datasource\Locator\ILocator|callable $factory The factory function used to create instances.
     */
    static void add(string $type, $factory) {
        if ($factory instanceof ILocator) {
            static::_modelFactories[$type] = $factory;

            return;
        }

        if (is_callable($factory)) {
            deprecationWarning(
                "Using a callable as a locator has been deprecated."
                ~ " Use an instance of Cake\Datasource\Locator\ILocatorinstead."
            );

            static::_modelFactories[$type] = $factory;

            return;
        }

        throw new InvalidArgumentException(sprintf(
            "`$factory` must be an instance of Cake\Datasource\Locator\ILocatoror a callable."
            ~ " Got type `%s` instead.",
            getTypeName($factory)
        ));
    }

    /**
     * Drop a model factory.
     * aRepositoryTypeName - The name of the repository type to drop the factory for.
     */
    static void drop(string aRepositoryTypeName) {
        static::_modelFactories.remove(aRepositoryTypeName));
    }

    /**
     * Get the factory for the specified repository type.
     *
     * @param string $type The repository type to get the factory for.
     * @throws \InvalidArgumentException If the specified repository type has no factory.
     * @return uim.cake.Datasource\Locator\ILocator|callable The factory for the repository type.
     */
    static function get(string $type) {
        if ("Table"  !in static::_modelFactories)) {
            static::_modelFactories["Table"] = new TableLocator();
        }

        if (!isset(static::_modelFactories[$type])) {
            throw new InvalidArgumentException(sprintf(
                "Unknown repository type '%s'. Make sure you register a type before trying to use it.",
                $type
            ));
        }

        return static::_modelFactories[$type];
    }
}
