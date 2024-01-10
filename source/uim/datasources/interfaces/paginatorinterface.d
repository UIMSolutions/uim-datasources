module uim.cake.datasources\Paging;

import uim.cake;

@safe:

// This interface describes the methods for paginator instance.
interface IPaginator {
    /**
     * Handles pagination of data.
     * Params:
     * Json $target Anything that needs to be paginated.
     * @param array $params Request params.
     * @param array $settings The settings/configuration used for pagination.
     */
    IPaginated paginate(
        Json $target,
        array $params = [],
        array $settings = []
    );
}
