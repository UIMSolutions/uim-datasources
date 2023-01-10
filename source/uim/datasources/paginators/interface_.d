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
