/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.exceptions.missingdatasource;

@safe:
import uim.datasources;

// Used when a datasource cannot be found.
class DDSOMissingDatasourceException : DDSOException {
  protected string _messageTemplate = "Datasource class %s could not be found. %s";
}
auto DSOMissingDatasourceException() { return new DDSOMissingDatasourceException(); }