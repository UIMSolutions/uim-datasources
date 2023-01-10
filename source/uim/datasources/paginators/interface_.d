/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.paginators.interface_;

@safe:
import uim.datasources;

// This interface describes the methods for paginator instance.
interface IPaginator {
  // Handles pagination of datasource records.
  // aRepository / aQuery - The repository or query to paginate.
  // myParams Request params
  // settings The settings/configuration used for pagination.
  IDSResultSet paginate(IDSRepositoty aRepositry, STRINGAA myParams = [], STRINGAA settings): IResultSet;
  IDSResultSet paginate(IDSQuery aQuery, STRINGAA myParams = [], STRINGAA settings): IResultSet;

  // Get paging params after pagination operation.
  STRINGAA getPagingParams();
}
