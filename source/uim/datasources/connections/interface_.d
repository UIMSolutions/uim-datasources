module uim.datasources.connections.interface_;

@safe:
import uim.datasources;

// This interface defines the methods you can depend on in a connection.
interface IDSConnection : ILoggerAware {
  // Gets the current logger object.
  LoggerInterface getLogger();

  // Set a cacher.
  // auto setCacher(ICache newCacher);

  // Get a cacher.
  // ICache getCacher();

  // Get the configuration name for this connection.
  string configName();

  // Get the configuration data used to create the connection.
  STRINGAA config();

  /**
    * Executes a callable IDSConnection inside a transaction, if any exception occurs
    * while executing the passed callable, the transaction will be rolled back
    * If the result of the callable IDSConnection is `false`, the transaction will
    * also be rolled back. Otherwise the transaction is committed after executing
    * the callback.
    *
    * The callback will receive the connection instance as its first argument.
    */
  IDSConnection transactional(callable $callback);

  /**
    * Run an operation with constraints disabled.
    * Constraints should be re-enabled after the callback succeeds/fails.
    */
  IDSConnection disableConstraints(callable $callback);

  /**
    * Enable/disable query logging
    * enableLogging - Enable/disable query logging
    */
  // IDSConnection enableQueryLogging(bool enableLogging = true);

  // Disable query logging
  IDSConnection disableQueryLogging();

  // Check if query logging is enabled.
  bool isQueryLoggingEnabled();
}
