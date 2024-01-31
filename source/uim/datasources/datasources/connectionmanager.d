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


    use StaticConfigTemplate {
        setConfig as protected _setConfig;
        parseDsn as protected _parseDsn;
    }
    



    
