module uim.datasources\Paging;

import uim.datasources;

@safe:

/**
 * This class is used to handle automatic model data pagination.
 */
class NumericPaginator : IPaginator {
    use InstanceConfigTemplate();

    /**
     * Default pagination settings.
     *
     * When calling paginate() these settings will be merged with the configuration
     * you provide.
     *
     * - `maxLimit` - The maximum limit users can choose to view. Defaults to 100
     * - `limit` - The initial number of items per page. Defaults to 20.
     * - `page` - The starting page, defaults to 1.
     * - `allowedParameters` - A list of parameters users are allowed to set using request
     *  parameters. Modifying this list will allow users to have more influence
     *  over pagination, be careful with what you permit.
     * - `sortableFields` - A list of fields which can be used for sorting. By
     *  default all table columns can be used for sorting. You can use this option
     *  to restrict sorting only by particular fields. If you want to allow
     *  sorting on either associated columns or calculated fields then you will
     *  have to explicity specify them (along with other fields). Using an empty
     *  array will disable sorting alltogether.
     * - `finder` - The table finder to use. Defaults to `all`.
     * - `scope` - If specified this scope will be used to get the paging options
     *  from the query params passed to paginate(). Scopes allow namespacing the
     *  paging options and allows paginating multiple models in the same action.
     *  Default `null`.
     *
     */
    protected IData[string] _defaultConfigData = [
        "page": 1,
        "limit": 20,
        "maxLimit": 100,
        "allowedParameters": ["limit", "sort", "page", "direction"],
        "sortableFields": null,
        "finder": "all",
        "scope": null,
    ];

    // Calculated paging params.
    protected array pagingParams = [
        "limit": null,
        "count": null,
        "totalCount": null,
        "perPage": null,
        "pageCount": null,
        "currentPage": null,
        "requestedPage": null,
        "start": null,
        "end": null,
        "hasPrevPage": null,
        "hasNextPage": null,
        "sort": null,
        "sortDefault": null,
        "direction": null,
        "directionDefault": null,
        "completeSort": null,
        "alias": null,
        "scope": null,
    ];

    /**
     * Handles automatic pagination of model records.
     *
     * ### Configuring pagination
     *
     * When calling `paginate()` you can use the settings parameter to pass in
     * pagination settings. These settings are used to build the queries made
     * and control other pagination settings.
     *
     * If your settings contain a key with the current table`s alias. The data
     * inside that key will be used. Otherwise, the top level configuration will
     * be used.
     *
     * ```
     * settings = [
     *   'limit": 20,
     *   'maxLimit": 100
     * ];
     * results = paginator.paginate(aTable, settings);
     * ```
     *
     * The above settings will be used to paginate any repository. You can configure
     * repository specific settings by keying the settings with the repository alias.
     *
     * ```
     * settings = [
     *   'Articles": [
     *     'limit": 20,
     *     'maxLimit": 100
     *   ],
     *   'Comments": [... ]
     * ];
     * results = paginator.paginate(aTable, settings);
     * ```
     *
     * This would allow you to have different pagination settings for
     * `Articles` and `Comments` repositories.
     *
     * ### Controlling sort fields
     *
     * By default UIM will automatically allow sorting on any column on the
     * repository object being paginated. Often times you will want to allow
     * sorting on either associated columns or calculated fields. In these cases
     * you will need to define an allowed list of all the columns you wish to allow
     * sorting on. You can define the allowed sort fields in the `$settings` parameter:
     *
     * ```
     * settings = [
     *  'Articles": [
     *    'finder": 'custom",
     *    `sortableFields": ["title", "author_id", "comment_count"],
     *  ]
     * ];
     * ```
     *
     * Passing an empty array as sortableFields disallows sorting altogether.
     *
     * ### Paginating with custom finders
     *
     * You can paginate with any find type defined on your table using the
     * `finder` option.
     *
     * ```
     * settings = [
     *   'Articles": [
     *     'finder": 'popular'
     *   ]
     * ];
     * results = paginator.paginate(aTable, settings);
     * ```
     *
     * Would paginate using the `find("popular")` method.
     *
     * You can also pass an already created instance of a query to this method:
     *
     * ```
     * aQuery = this.Articles.find("popular").matching("Tags", auto ($q) {
     *  return q.where(["name": 'UIM"])
     * });
     * results = paginator.paginate(aQuery);
     * ```
     *
     * ### Scoping Request parameters
     *
     * By using request parameter scopes you can paginate multiple queries in
     * the same controller action:
     *
     * ```
     * articles = paginator.paginate($articlesQuery, ["scope": 'articles"]);
     * tags = paginator.paginate($tagsQuery, ["scope": "tags"]);
     * ```
     *
     * Each of the above queries will use different query string parameter sets
     * for pagination data. An example URL paginating both results would be:
     *
     * ```
     * /dashboard?articles[page]=1&tags[page]=2
     * ```
     * Params:
     * Json target The repository or query
     *  to paginate.
     * @param array requestParameters Request params
     * @param array settingsForPagination The settings/configuration used for pagination.
     */
    IPaginated paginate(
        Json target,
        array requestParameters = [],
        array settingsForPagination = []
    ) {
        aQuery = null;
        if (cast(IQuery)$target) {
            aQuery = target;
            target = aQuery.getRepository();
            if ($target.isNull) {
                throw new UimException("No repository set for query.");
            }
        }
        assert(
            cast(IRepository)$target ,
            'Pagination target must be an instance of `" ~ IQuery.classname
                ~ "` or `" ~ IRepository.classname ~ "`.'
        );

        someData = this.extractData($target, requestParameters, settingsForPagination);
        aQuery = this.getQuery($target, aQuery, someData);

         someItems = this.getItems(clone aQuery, someData);
        this.pagingParams["count"] = count(someItems);
        this.pagingParams["totalCount"] = this.getCount(aQuery, someData);

        pagingParams = this.buildParams(someData);
        if ($pagingParams["requestedPage"] > pagingParams["currentPage"]) {
            throw new PageOutOfBoundsException([
                "requestedPage": pagingParams["requestedPage"],
                "pagingParams": pagingParams,
            ]);
        }
        return this.buildPaginated(someItems, pagingParams);
    }
    
    /**
     * Build paginated resultset.
     * Params:
     * \UIM\Datasource\IResultSet  someItems
     * @param array pagingParams
     */
    protected IPaginated buildPaginated(IResultSet  someItems, array pagingParams) {
        return new PaginatedResultSet(someItems, pagingParams);
    }
    
    /**
     * Get query for fetching paginated results.
     * Params:
     * \UIM\Datasource\IRepository object Repository instance.
     * @param \UIM\Datasource\IQuery|null aQuery Query Instance.
     * @param IData[string] someData Pagination data.
     */
    protected IQuery getQuery(IRepository object, ?IQuery aQuery, array data) {
        options = someData["options"];
        aQueryOptions = array_intersect_key(
            options,
            ["order": null, "page": null, "limit": null],
        );

        if (aQuery.isNull) {
            someArguments = [];
            type = !empty(options["finder"]) ? options["finder"] : "all";
            if (isArray($type)) {
                someArguments = (array)current($type);
                type = key($type);
            }
            aQuery = object.find($type, ...someArguments);
        }
        aQuery.applyOptions(aQueryOptions);

        return aQuery;
    }
    
    /**
     * Get paginated items.
     * Params:
     * \UIM\Datasource\IQuery aQuery Query to fetch items.
     * @param array data Paging data.
     */
    protected IResultSet getItems(IQuery aQuery, array data) {
        return aQuery.all();
    }
    
    /**
     * Get total count of records.
     * Params:
     * \UIM\Datasource\IQuery aQuery Query instance.
     * @param array data Pagination data.
     */
    protected int getCount(IQuery aQuery, array data) {
        return aQuery.count();
    }
    
    /**
     * Extract pagination data needed
     * Params:
     * \UIM\Datasource\IRepository object The repository object.
     * params Request params
     * settings The settings/configuration used for pagination.
     */
    protected array extractData(IRepository object, IData[string] requestParameters, IData[string] settingForPagination) {
        auto aliasObj = object.getAlias();
        auto defaults = this.getDefaults($aliasObj, settingForPagination);

        auto validSettings = _defaultConfigData.keys;
        validSettings ~= "order";
        auto extraSettings = array_diff_key($defaults, array_flip($validSettings));
        if ($extraSettings) {
            triggerWarning(
                "Passing query options as paginator settings is no longer supported." ~
                " Use a custom finder through the `finder` config or pass a SelectQuery instance to paginate()." ~
                " Extra keys found are: " ~ extraSettings.keys.join(",")
            );
        }
        options = this.mergeOptions(requestParameters, defaults);
        options = this.validateSort($object, options);
        options = this.checkLimit(options);

        options["page"] = max((int)options["page"], 1);

        return compact("defaults", "options", "alias");
    }
    
    /**
     * Build pagination params.
     * Params:
     * IData[string] someData Paginator data containing keys 'options",
     * 'defaults", "alias'.
     */
    protected IData[string] buildParams(array data) {
        this.pagingParams = [
            "perPage": someData["options"]["limit"],
            "requestedPage": someData["options"]["page"],
            "alias": someData["alias"],
            "scope": someData["options"]["scope"],
        ] + this.pagingParams;

        this.addPageCountParams(someData);
        this.addStartEndParams(someData);
        this.addPrevNextParams(someData);
        this.addSortingParams(someData);

        this.pagingParams["limit"] = someData["defaults"]["limit"] != someData["options"]["limit"]
            ? someData["options"]["limit"]
            : null;

        return this.pagingParams;
    }
    
    /**
     * Add "currentPage" and "pageCount" params.
     * Params:
     * array data Paginator data.
     */
    protected void addPageCountParams(array data) {
        page = someData["options"]["page"];
        pageCount = null;

        if (this.pagingParams["totalCount"] !isNull) {
            pageCount = max((int)ceil(this.pagingParams["totalCount"] / this.pagingParams["perPage"]), 1);
            page = min($page, pageCount);
        } else if (this.pagingParams["count"] == 0 && this.pagingParams["requestedPage"] > 1) {
            page = 1;
        }
        this.pagingParams["currentPage"] = page;
        this.pagingParams["pageCount"] = pageCount;
    }
    
    /**
     * Add "start" and "end" params.
     * Params:
     * array data Paginator data.
     */
    protected void addStartEndParams(array data) {
        start = end = 0;

        if (this.pagingParams["count"] > 0) {
            start = ((this.pagingParams["currentPage"] - 1) * this.pagingParams["perPage"]) + 1;
            end = start + this.pagingParams["count"] - 1;
        }
        this.pagingParams["start"] = start;
        this.pagingParams["end"] = end;
    }
    
    /**
     * Add "prevPage" and "nextPage" params.
     * Params:
     * array data Paging data.
     */
    protected void addPrevNextParams(array data) {
        this.pagingParams["hasPrevPage"] = this.pagingParams["currentPage"] > 1;
        if (this.pagingParams["totalCount"].isNull) {
            this.pagingParams["hasNextPage"] = true;
        } else {
            this.pagingParams["hasNextPage"] = this.pagingParams["totalCount"]
                > this.pagingParams["currentPage"] * this.pagingParams["perPage"];
        }
    }
    
    /**
     * Add sorting / ordering params.
     * Params:
     * array data Paging data.
     */
    protected void addSortingParams(array data) {
        defaults = someData["defaults"];
        order = (array)someData["options"]["order"];
        sortDefault = directionDefault = false;

        if (!empty($defaults["order"]) && count($defaults["order"]) >= 1) {
            sortDefault = key($defaults["order"]);
            directionDefault = current($defaults["order"]);
        }
        this.pagingParams = [
            `sort": someData["options"]["sort"],
            'direction": isSet(someData["options"]["sort"]) && count($order) ? current($order): null,
            `sortDefault": sortDefault,
            'directionDefault": directionDefault,
            'completeSort": order,
        ] + this.pagingParams;
    }
    
    /**
     * Merges the various options that Paginator uses.
     * Pulls settings together from the following places:
     *
     * - General pagination settings
     * - Model specific settings.
     * - Request parameters
     *
     * The result of this method is the aggregate of all the option sets
     * combined together. You can change config value `allowedParameters` to modify
     * which options/values can be set using request parameters.
     * Params:
     * @param array settings The settings to merge with the request data.
     */
    protected IData[string] mergeOptions(IData[string] requestParameters, array settings) {
        if (!empty($settings["scope"])) {
            scope = settings["scope"];
            requestParameters = !empty(requestParameters[$scope]) ? (array)requestParameters[$scope] : [];
        }
        requestParameters = array_intersect_key(requestParameters, array_flip(_configData.isSet("allowedParameters")));

        return chain($settings, requestParameters);
    }
    
    /**
     * Get the settings for a model. If there are no settings for a specific
     * repository, the general settings will be used.
     * Params:
     * string aalias Model name to get settings for.
     */
    protected IData[string] getDefaults(string aalias, IData[string] settings) {
        if (isSet($settings[$alias])) {
            settings = settings[$alias];
        }
        defaults = this.getConfig();

        maxLimit = settings["maxLimit"] ?? defaults["maxLimit"];
        aLimit = settings.get("limit", defaults["limit"]);

        if (aLimit > maxLimit) {
            aLimit = maxLimit;
        }
        settings["maxLimit"] = maxLimit;
        settings["limit"] = aLimit;

        return settings + defaults;
    }
    
    /**
     * Validate that the desired sorting can be performed on the object.
     *
     * Only fields or virtualFields can be sorted on. The direction param will
     * also be sanitized. Lastly sort + direction keys will be converted into
     * the model friendly order key.
     *
     * You can use the allowedParameters option to control which columns/fields are
     * available for sorting via URL parameters. This helps prevent users from ordering large
     * result sets on un-indexed values.
     *
     * If you need to sort on associated columns or synthetic properties you
     * will need to use the `sortableFields` option.
     *
     * Any columns listed in the allowed sort fields will be implicitly trusted.
     * You can use this to sort on synthetic columns, or columns added in custom
     * find operations that may not exist in the schema.
     *
     * The default order options provided to paginate() will be merged with the user`s
     * requested sorting field/direction.
     * Params:
     * \UIM\Datasource\IRepository object Repository object.
     * @param IData[string] optionData The pagination options being used for this request.
     */
    protected IData[string] validateSort(IRepository repository, IData[string] optionData = null) {
        if (isSet(options["sort"])) {
            string direction;
            if (isSet(options["direction"])) {
                direction = options["direction"].toLower;
            }
            if (!in_array($direction, ["asc", "desc"], true)) {
                direction = "asc";
            }
            order = isSet(options["order"]) && isArray(options["order"]) ? options["order"] : [];
            if ($order && options["sort"] && !options["sort"].has(".")) {
                order = _removeAliases($order, repository.getAlias());
            }
            options["order"] = [options["sort"]: direction] + order;
        } else {
            options["sort"] = null;
        }
        unset(options["direction"]);

        if (isEmpty(options["order"])) {
            options["order"] = [];
        }
        if (!isArray(options["order"])) {
            return options;
        }
        sortAllowed = false;
        if (isSet(options["sortableFields"])) {
            field = key(options["order"]);
            sortAllowed = in_array(field, options["sortableFields"], true);
            if (!$sortAllowed) {
                options["order"] = [];
                options["sort"] = null;

                return options;
            }
        }
        if (
            options["sort"].isNull
            && count(options["order"]) >= 1
            && !isNumeric(key(options["order"]))
        ) {
            options["sort"] = key(options["order"]);
        }
        options["order"] = _prefix(repository, options["order"], sortAllowed);

        return options;
    }
    
    /**
     * Remove alias if needed.
     * Params:
     * IData[string] fields Current fields
     * @param string amodel Current model alias
     */
    protected IData[string] _removeAliases(IData[string] fields, string amodel) {
        auto result;
        foreach (field: sort; fields) {
            if (isInt(field)) {
                throw new UimException(
                    "The `order` config must be an associative array. Found invalid value with numeric key: `%s`".format(
                    sort
                ));
            }
            if (!field.has(".")) {
                result[field] = sort;
                continue;
            }
            [$alias, currentField] = split(".", field);

            if ($alias == model) {
                result[$currentField] = sort;
                continue;
            }
            result[field] = sort;
        }
        return result;
    }
    
    /**
     * Prefixes the field with the table alias if possible.
     * Params:
     * \UIM\Datasource\IRepository object Repository object.
     * @param array order Order array.
     * @param bool allowed Whether the field was allowed.
     */
    protected array _prefix(IRepository object, array order, bool allowed = false) {
        aTableAlias = object.getAlias();
        aTableOrder = [];
        foreach ($order as aKey: aValue) {
            if (isNumeric(aKey)) {
                aTableOrder ~= aValue;
                continue;
            }
            field = aKey;
            alias = aTableAlias;

            if (aKey.has(".")) {
                [$alias, field] = split(".", aKey);
            }
            correctAlias = (aTableAlias == alias);

            if ($correctAlias && allowed) {
                // Disambiguate fields in schema. As id is quite common.
                if ($object.hasField(field)) {
                    field = alias ~ "." ~ field;
                }
                aTableOrder[field] = aValue;
            } else if ($correctAlias && object.hasField(field)) {
                aTableOrder[aTableAlias ~ "." ~ field] = aValue;
            } else if (!$correctAlias && allowed) {
                aTableOrder[$alias ~ "." ~ field] = aValue;
            }
        }
        return aTableOrder;
    }
    
    /**
     * Check the limit parameter and ensure it`s within the maxLimit bounds.
     * Params:
     * IData[string] optionData An array of options with a limit key to be checked.
     */
    protected IData[string] checkLimit(IData[string] optionData = null) {
        options["limit"] = (int)options["limit"];
        if (options["limit"] < 1) {
            options["limit"] = 1;
        }
        options["limit"] = max(min(options["limit"], options["maxLimit"]), 1);

        return options;
    }
}
