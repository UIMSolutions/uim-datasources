module uim.datasources\Paging;

import uim.cake;

@safe:

/**
 * Simplified paginator which avoids potentially expensives queries
 * to get the total count of records.
 *
 * When using a simple paginator you will not be able to generate page numbers.
 * Instead use only the prev/next pagination controls.
 */
class SimplePaginator : NumericPaginator {
    /**
     * Get paginated items.
     *
     * Get one additional record than the limit. This helps deduce if next page exits.
     * Params:
     * \UIM\Datasource\IQuery aQuery Query to fetch items.
     * @param array data Paging data.
     */
    protected IResultSet getItems(IQuery aQuery, array data) {
        return aQuery.limit(someData["options"]["limit"] + 1).all();
    }
 
    protected array buildParams(array data) {
        hasNextPage = false;
        if (this.pagingParams["count"] > someData["options"]["limit"]) {
            hasNextPage = true;
            this.pagingParams["count"] -= 1;
        }
        super.buildParams(someData);

        this.pagingParams["hasNextPage"] = hasNextPage;

        return this.pagingParams;
    }
    
    /**
     * Build paginated resultset.
     *
     * Since the query fetches an extra record, drop the last record if records
     * fetched exceeds the limit/per page.
     * Params:
     * \UIM\Datasource\IResultSet  someItems
     * @param array pagingParams
     */
    protected IPaginated buildPaginated(IResultSet  someItems, array pagingParams) {
        if (count(someItems) > this.pagingParams["perPage"]) {
             someItems =  someItems.take(this.pagingParams["perPage"]);
        }
        return new PaginatedResultSet(someItems, pagingParams);
    }
    
    /**
     * Simple pagination does not perform any count query, so this method returns `null`.
     * Params:
     * \UIM\Datasource\IQuery aQuery Query instance.
     * @param array data Pagination data.
     */
    protected int getCount(IQuery aQuery, array data) {
        return null;
    }
}
