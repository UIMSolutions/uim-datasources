module uim.datasources;

import uim.datasources;

@safe:

/**

/**
 * Manages and loads instances of Connection
 *
 * Provides an interface to loading and creating connection objects. Acts as
 * a registry for the connections defined in an application.
 *
 * Provides an interface for loading and enumerating connections defined in
 * config/app.d
 */
class ConnectionManager {
  	override bool initialize(IConfigData[string] configData = null) {
		if (!super.initialize(configData)) { return false; }
		
		return true;
	}

    use StaticConfigTemplate {
        setConfig as protected _setConfig;
        parseDsn as protected _parseDsn;
    }
    
    // A map of connection aliases.
    protected static STRINGAA _connectionAliases = [];

    // An array mapping url schemes to fully qualified driver class names
    protected static STRINGAA _dsnClassMap = [
        "mysql": Mysql.class,
        "postgres": Postgres.class,
        "sqlite": Sqlite.class,
        "sqlserver": Sqlserver.class,
    ];

    // The ConnectionRegistry used by the manager.
    protected static ConnectionRegistry _registry;

    /**
     * Configure a new connection object.
     *
     * The connection will not be constructed until it is first used.
     * Params:
     * Json[string]|string aKey The name of the connection config, or an array of multiple configs.
     * @param \UIM\Datasource\IConnection|\Closure|Json[string]|null configData An array of name: config data for adapter.
     * @throws \UIM\Core\Exception\UimException When trying to modify an existing config.
     * @see \UIM\Core\StaticConfigTrait.config()
     */
    static void setConfig(string[] aKey, IConnection|Closure|array|null configData = null) {
        if (isArray(configData)) {
            configData("name", aKey);
        }
        _setConfig(aKey, configData);
    }
    
    /**
     * Parses a DSN into a valid connection configuration
     *
     * This method allows setting a DSN using formatting similar to that used by PEAR.DB.
     * The following is an example of its usage:
     *
     * ```
     * dsn = "mysql://user:pass@localhost/database";
     * configData = ConnectionManager.parseDsn($dsn);
     *
     * dsn = "UIM\Database\Driver\Mysql://localhost:3306/database?className=UIM\Database\Connection";
     * configData = ConnectionManager.parseDsn($dsn);
     *
     * dsn = "UIM\Database\Connection://localhost:3306/database?driver=UIM\Database\Driver\Mysql";
     * configData = ConnectionManager.parseDsn($dsn);
     * ```
     *
     * For all classes, the value of `scheme` is set as the value of both the `className` and `driver`
     * unless they have been otherwise specified.
     *
     * Note that query-string arguments are also parsed and set as values in the returned configuration.
     * Params:
     * string adsn The DSN string to convert to a configuration array
     */
    static Json[string] parseDsn(string adsn) {
        configData = _parseDsn($dsn);

        if (configuration.hasKey("path") && configData("database").isEmpty) {
            configData("database", substr(configData("path"), 1);
        }
        if (configData("driver").isEmpty) {
            configData("driver", configData("className"));
            configData("className", Connection.classname);
        }
        unset(configData("path"]);

        return configData;
    }
    
    /**
     * Set one or more connection aliases.
     *
     * Connection aliases allow you to rename active connections without overwriting
     * the aliased connection. This is most useful in the test-suite for replacing
     * connections with their test variant.
     *
     * Defined aliases will take precedence over normal connection names. For example,
     * if you alias "default" to 'test", fetching "default" will always return the 'test'
     * connection as long as the alias is defined.
     *
     * You can remove aliases with ConnectionManager.dropAlias().
     *
     * ### Usage
     *
     * ```
     * // Make 'things' resolve to 'test_things' connection
     * ConnectionManager.alias("test_things", "things");
     * ```
     * Params:
     * string asource The existing connection to alias.
     * @param string aalias The alias name that resolves to `$source`.
     */
    static void alias(string asource, string connectionAlias) {
        _connectionAliases[connectionAlias] = source;
    }
    
    /**
     * Drop an alias.
     *
     * Removes an alias from ConnectionManager. Fetching the aliased
     * connection may fail if there is no other connection with that name.
     * Params:
     * string aalias The connection alias to drop
     */
    static void dropAlias(string aalias) {
        unset(_connectionAliases[$alias]);
    }
    
    // Returns the current connection aliases and what they alias.
    static STRINGAA aliases() {
        return _connectionAliases;
    }
    
    /**
     * Get a connection.
     *
     * If the connection has not been constructed an instance will be added
     * to the registry. This method will use any aliases that have been
     * defined. If you want the original unaliased connections pass `false`
     * as second parameter.
     * Params:
     * string connectionName The connection name.
     * @param bool useAliases Whether connection aliases are used
     */
    static IConnection get(string connectionName, bool useAliases = true) {
        if ($useAliases && isSet(_connectionAliases[connectionName])) {
            connectionName = _connectionAliases[connectionName];
        }
        if (!isSet(configuration.data(connectionName])) {
            throw new MissingDatasourceConfigException(["name": connectionName]);
        }

        _registry ? _registry : new ConnectionRegistry();
        return _registry.{connectionName} ?? _registry.load(connectionName, configuration.data(connectionName]);
    }
}
