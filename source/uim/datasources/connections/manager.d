/*********************************************************************************************************
*	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        *
*	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  *
*	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      *
**********************************************************************************************************/
module uim.datasources.connections.manager;

@safe:
import uim.datasources;

/**
 * Manages and loads instances of Connection
 *
 * Provides an interface to loading and creating connection objects. 
 * Acts as a registry for the connections defined in an application.
 *
 * Provides an interface for loading and enumerating connections 
 */
class DDTSConnectionManager {
  // #region internal fields
    // A map of connection aliases.
    protected static string[] _aliasMap;

    // An array mapping url schemes to fully qualified driver class names
    protected static STRINGAA $_dsnClassMap = [
        "mysql": Mysql::class,
        "postgres": Postgres::class,
        "sqlite": Sqlite::class,
        "sqlserver": Sqlserver::class,
    ];

    // The ConnectionRegistry used by the manager.
    protected static DDTSConnectionRegistry $_registry;
  // #endregion internal fields

  this() {
    initialize;
  }

  void initialize() {}
}
