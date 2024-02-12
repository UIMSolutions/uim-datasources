/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.paginators.paginator;

@safe:
import uim.datasources;

// This class is used to handle automatic model data pagination.
class Paginator : IPaginator {
    // use InstanceConfigTrait;

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
     *   parameters. Modifying this list will allow users to have more influence
     *   over pagination, be careful with what you permit.
     *
     * @var array<string, mixed>
     * /
    protected STRINGAA _defaultConfig = [
        "page":1,
        "limit":20,
        "maxLimit":100,
        "allowedParameters":["limit", "sort", "page", "direction"],
    ];

    // Paging params after pagination operation is done.
    protected STRINGAA _pagingParams= null;

    /**
     * Handles automatic pagination of model records.
     *
     * ### Configuring pagination
     *
     * When calling `paginate()` you can use the settings parameter to pass in
     * pagination settings. These settings are used to build the queries made
     * and control other pagination settings.
     *
     * If your settings contain a key with the current table"s alias. The data
     * inside that key will be used. Otherwise the top level configuration will
     * be used.
     *
     * ```
     *  settings = [
     *    "limit":20,
     *    "maxLimit":100
     *  ];
     *  myResults = paginator.paginate(myTable, settings);
     * ```
     *
     * The above settings will be used to paginate any repository. You can configure
     * repository specific settings by keying the settings with the repository alias.
     *
     * ```
     *  settings = [
     *    "Articles":[
     *      "limit":20,
     *      "maxLimit":100
     *    ],
     *    "Comments":[ ... ]
     *  ];
     *  myResults = paginator.paginate(myTable, settings);
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
     * sorting on. You can define the allowed sort fields in the `settings` parameter:
     *
     * ```
     * settings = [
     *   "Articles":[
     *     "finder":"custom",
     *     "sortableFields":["title", "author_id", "comment_count"],
     *   ]
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
     *  settings = [
     *    "Articles":[
     *      "finder":"popular"
     *    ]
     *  ];
     *  myResults = paginator.paginate(myTable, settings);
     * ```
     *
     * Would paginate using the `find("popular")` method.
     *
     * You can also pass an already created instance of a query to this method:
     *
     * ```
     * myQuery = this.Articles.find("popular").matching("Tags", function (q) {
     *   return q.where(["name":"CakePHP"])
     * });
     * myResults = paginator.paginate(myQuery);
     * ```
     *
     * ### Scoping Request parameters
     *
     * By using request parameter scopes you can paginate multiple queries in
     * the same controller action:
     *
     * ```
     * articles = paginator.paginate(articlesQuery, ["scope":"articles"]);
     * tags = paginator.paginate(tagsQuery, ["scope":"tags"]);
     * ```
     *
     * Each of the above queries will use different query string parameter sets
     * for pagination data. An example URL paginating both results would be:
     *
     * ```
     use Cake\ORM\Entity;dashboard?articles[page]=1&tags[page]=2
     * ```
     *
     * @param \Cake\Datasource\IRepository|\Cake\Datasource\IQuery object The repository or query
     *   to paginate.
     * @param array myParams Request params
     * @param array settings The settings/configuration used for pagination.
     * @return \Cake\Datasource\IResultSet Query results
     * @throws \Cake\Datasource\Exception\PageOutOfBoundsException
     * /
    IDSResultSet paginate(object object, array myParams= null, array settings= null) {
        myQuery = null;
        if (object instanceof IQuery) {
            myQuery = object;
            object = myQuery.getRepository();
            if (object == null) {
                throw new CakeException("No repository set for query.");
            }
        }

        myData = this.extractData(object, myParams, settings);
        myQuery = this.getQuery(object, myQuery, myData);

        cleanQuery = clone myQuery;
        myResults = myQuery.all();
        myData["numResults"] = count(myResults);
        myData["count"] = this.getCount(cleanQuery, myData);

        pagingParams = this.buildParams(myData);
        myAlias = object.getAlias();
        _pagingParams = [myAlias: pagingParams];
        if (pagingParams["requestedPage"] > pagingParams["page"]) {
            throw new PageOutOfBoundsException([
                "requestedPage":pagingParams["requestedPage"],
                "pagingParams":_pagingParams,
            ]);
        }

        return myResults;
    }

    // Get query for fetching paginated results.
    // \Cake\Datasource\IRepository object Repository instance.
    // \Cake\Datasource\IQuery|null myQuery Query Instance.
    //  array<string, mixed> myData Pagination data.
    protected IDSQuery getQuery(IRepository object, ?IQuery myQuery, array myData) {
        if (myQuery == null) {
            myQuery = object.find(myData["finder"], myData["options"]);
        } else {
            myQuery.applyOptions(myData["options"]);
        }

        return myQuery;
    }

    /**
     * Get total count of records.
     *
     * @param \Cake\Datasource\IQuery myQuery Query instance.
     * @param array myData Pagination data.
     * @return int|null
     * /
    protected Nullable!int getCount(IQuery myQuery, array myData) {
        return myQuery.count();
    }

    /**
     * Extract pagination data needed
     *
     * @param \Cake\Datasource\IRepository object The repository object.
     * @param array<string, mixed> myParams Request params
     * @param array<string, mixed> settings The settings/configuration used for pagination.
     * @return array Array with keys "defaults", "options" and "finder"
     * /
    protected auto extractData(IRepository anRepository, array myParams, array settings): array
    {
        myAlias = object.getAlias();
        defaults = this.getDefaults(myAlias, settings);
        options = this.mergeOptions(myParams, defaults);
        options = this.validateSort(anRepository, options);
        options = this.checkLimit(options);

        options += ["page":1, "scope":null];
        options["page"] = (int)options["page"] < 1 ? 1 : (int)options["page"];
        [myFinder, options] = _extractFinder(options);

        return compact("defaults", "options", "finder");
    }

    /**
     * Build pagination params.
     *
     * @param array<string, mixed> myData Paginator data containing keys "options",
     *   "count", "defaults", "finder", "numResults".
     * @return array<string, mixed> Paging params.
     * /
    protected auto buildParams(array myData): array
    {
        limit = myData["options"]["limit"];

        paging = [
            "count":myData["count"],
            "current":myData["numResults"],
            "perPage":limit,
            "page":myData["options"]["page"],
            "requestedPage":myData["options"]["page"],
        ];

        paging = this.addPageCountParams(paging, myData);
        paging = this.addStartEndParams(paging, myData);
        paging = this.addPrevNextParams(paging, myData);
        paging = this.addSortingParams(paging, myData);

        paging += [
            "limit":myData["defaults"]["limit"] != limit ? limit : null,
            "scope":myData["options"]["scope"],
            "finder":myData["finder"],
        ];

        return paging;
    }

    /**
     * Add "page" and "pageCount" params.
     *
     * @param array<string, mixed> myParams Paging params.
     * @param array myData Paginator data.
     * @return array<string, mixed> Updated params.
     * /
    protected auto addPageCountParams(array myParams, array myData): array
    {
        page = myParams["page"];
        pageCount = 0;

        if (myParams["count"] !== null) {
            pageCount = max((int)ceil(myParams["count"] / myParams["perPage"]), 1);
            page = min(page, pageCount);
        } elseif (myParams["current"] == 0 && myParams["requestedPage"] > 1) {
            page = 1;
        }

        myParams["page"] = page;
        myParams["pageCount"] = pageCount;

        return myParams;
    }

    /**
     * Add "start" and "end" params.
     *
     * @param array<string, mixed> myParams Paging params.
     * @param array myData Paginator data.
     * @return array<string, mixed> Updated params.
     * /
    protected auto addStartEndParams(array myParams, array myData): array
    {
        start = end = 0;

        if (myParams["current"] > 0) {
            start = ((myParams["page"] - 1) * myParams["perPage"]) + 1;
            end = start + myParams["current"] - 1;
        }

        myParams["start"] = start;
        myParams["end"] = end;

        return myParams;
    }

    /**
     * Add "prevPage" and "nextPage" params.
     *
     * @param array<string, mixed> myParams Paginator params.
     * @param array myData Paging data.
     * @return array<string, mixed> Updated params.
     * /
    protected auto addPrevNextParams(array myParams, array myData): array
    {
        myParams["prevPage"] = myParams["page"] > 1;
        if (myParams["count"] == null) {
            myParams["nextPage"] = true;
        } else {
            myParams["nextPage"] = myParams["count"] > myParams["page"] * myParams["perPage"];
        }

        return myParams;
    }

    /**
     * Add sorting / ordering params.
     *
     * @param array<string, mixed> myParams Paginator params.
     * @param array myData Paging data.
     * @return array<string, mixed> Updated params.
     * /
    protected auto addSortingParams(array myParams, array myData): array
    {
        defaults = myData["defaults"];
        order = (array)myData["options"]["order"];
        sortDefault = directionDefault = false;

        if (!empty(defaults["order"]) && count(defaults["order"]) == 1) {
            sortDefault = key(defaults["order"]);
            directionDefault = current(defaults["order"]);
        }

        myParams += [
            "sort":myData["options"]["sort"],
            "direction":isset(myData["options"]["sort"]) && count(order) ? current(order) : null,
            "sortDefault":sortDefault,
            "directionDefault":directionDefault,
            "completeSort":order,
        ];

        return myParams;
    }

    /**
     * Extracts the finder name and options out of the provided pagination options.
     *
     * @param array<string, mixed> options the pagination options.
     * @return array An array containing in the first position the finder name
     *   and in the second the options to be passed to it.
     * /
    protected auto _extractFinder(IData[string] options): array
    {
        myType = !empty(options["finder"]) ? options["finder"] : "all";
        unset(options["finder"], options["maxLimit"]);

        if (is_array(myType)) {
            options = (array)current(myType) + options;
            myType = key(myType);
        }

        return [myType, options];
    }

    /**
     * Get paging params after pagination operation.
     *
     * @return array
     * /
    auto getPagingParams(): array
    {
        return _pagingParams;
    }

    /**
     * Shim method for reading the deprecated whitelist or allowedParameters options
     * /
    protected string[] getAllowedParameters() {
        allowed = this.getConfig("allowedParameters");
        if (!allowed) {
            allowed= null;
        }
        whitelist = this.getConfig("whitelist");
        if (whitelist) {
            deprecationWarning("The `whitelist` option is deprecated. Use the `allowedParameters` option instead.");

            return array_merge(allowed, whitelist);
        }

        return allowed;
    }

    /**
     * Shim method for reading the deprecated sortWhitelist or sortableFields options.
     * @param array<string, mixed> myConfig The configuration data to coalesce and emit warnings on.
     * /
    protected string[] getSortableFields(array myConfig) {
        allowed = myConfig["sortableFields"] ?? null;
        if (allowed !== null) {
            return allowed;
        }
        deprecated = myConfig["sortWhitelist"] ?? null;
        if (deprecated !== null) {
            deprecationWarning("The `sortWhitelist` option is deprecated. Use `sortableFields` instead.");
        }

        return deprecated;
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
     *
     * @param array<string, mixed> myParams Request params.
     * @param array settings The settings to merge with the request data.
     * @return array<string, mixed> Array of merged options.
     * /
    function mergeOptions(array myParams, array settings): array
    {
        if (!empty(settings["scope"])) {
            scope = settings["scope"];
            myParams = !empty(myParams[scope]) ? (array)myParams[scope] : [];
        }

        allowed = this.getAllowedParameters();
        myParams = array_intersect_key(myParams, array_flip(allowed));

        return array_merge(settings, myParams);
    }

    /**
     * Get the settings for a myModel. If there are no settings for a specific
     * repository, the general settings will be used.
     *
     * @param string aliasName Model name to get settings for.
     * @param array<string, mixed> settings The settings which is used for combining.
     * @return array<string, mixed> An array of pagination settings for a model,
     *   or the general settings.
     * /
    auto getDefaults(string aliasName, array settings): array
    {
        if (isset(settings[myAlias])) {
            settings = settings[myAlias];
        }

        defaults = this.getConfig();
        defaults["whitelist"] = defaults["allowedParameters"] = this.getAllowedParameters();

        maxLimit = settings["maxLimit"] ?? defaults["maxLimit"];
        limit = settings["limit"] ?? defaults["limit"];

        if (limit > maxLimit) {
            limit = maxLimit;
        }

        settings["maxLimit"] = maxLimit;
        settings["limit"] = limit;

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
     * The default order options provided to paginate() will be merged with the user"s
     * requested sorting field/direction.
     *
     * @param \Cake\Datasource\IRepository object Repository object.
     * @param array<string, mixed> options The pagination options being used for this request.
     * @return array<string, mixed> An array of options with sort + direction removed and
     *   replaced with order if possible.
     * /
    function validateSort(IRepository object, IData[string] options): array
    {
        if (isset(options["sort"])) {
            direction = null;
            if (isset(options["direction"])) {
                direction = strtolower(options["direction"]);
            }
            if (!in_array(direction, ["asc", "desc"], true)) {
                direction = "asc";
            }

            order = isset(options["order"]) && is_array(options["order"]) ? options["order"] : [];
            if (order && options["sort"] && indexOf(options["sort"], ".") == false) {
                order = _removeAliases(order, object.getAlias());
            }

            options["order"] = [options["sort"]: direction] + order;
        } else {
            options["sort"] = null;
        }
        unset(options["direction"]);

        if (empty(options["order"])) {
            options["order"]= null;
        }
        if (!is_array(options["order"])) {
            return options;
        }

        sortAllowed = false;
        allowed = this.getSortableFields(options);
        if (allowed !== null) {
            options["sortableFields"] = options["sortWhitelist"] = allowed;

            myField = key(options["order"]);
            sortAllowed = in_array(myField, allowed, true);
            if (!sortAllowed) {
                options["order"]= null;
                options["sort"] = null;

                return options;
            }
        }

        if (
            options["sort"] == null
            && count(options["order"]) == 1
            && !is_numeric(key(options["order"]))
        ) {
            options["sort"] = key(options["order"]);
        }

        options["order"] = _prefix(object, options["order"], sortAllowed);

        return options;
    }

    /**
     * Remove alias if needed.
     *
     * @param array<string, mixed> fieldNames Current fields
     * @param string myModel Current model alias
     * @return array<string, mixed> fieldNames Unaliased fields where applicable
     * /
    protected auto _removeAliases(array fieldNames, string myModel): array
    {
        myResult= null;
        foreach (fieldNames as myField: sort) {
            if (indexOf(myField, ".") == false) {
                myResult[myField] = sort;
                continue;
            }

            [myAlias, currentField] = explode(".", myField);

            if (myAlias == myModel) {
                myResult[currentField] = sort;
                continue;
            }

            myResult[myField] = sort;
        }

        return myResult;
    }

    /**
     * Prefixes the field with the table alias if possible.
     *
     * @param \Cake\Datasource\IRepository object Repository object.
     * @param array order Order array.
     * @param bool allowed Whether the field was allowed.
     * @return array Final order array.
     * /
    protected auto _prefix(IRepository object, array order, bool allowed = false): array
    {
        myTableAlias = object.getAlias();
        myTableOrder= null;
        foreach (order as myKey: myValue) {
            if (is_numeric(myKey)) {
                myTableOrder[] = myValue;
                continue;
            }
            myField = myKey;
            myAlias = myTableAlias;

            if (indexOf(myKey, ".") !== false) {
                [myAlias, myField] = explode(".", myKey);
            }
            correctAlias = (myTableAlias == myAlias);

            if (correctAlias && allowed) {
                // Disambiguate fields in schema. As id is quite common.
                if (object.hasField(myField)) {
                    myField = myAlias . "." . myField;
                }
                myTableOrder[myField] = myValue;
            } elseif (correctAlias && object.hasField(myField)) {
                myTableOrder[myTableAlias . "." . myField] = myValue;
            } elseif (!correctAlias && allowed) {
                myTableOrder[myAlias . "." . myField] = myValue;
            }
        }

        return myTableOrder;
    }

    /**
     * Check the limit parameter and ensure it"s within the maxLimit bounds.
     *
     * @param array<string, mixed> options An array of options with a limit key to be checked.
     * @return array<string, mixed> An array of options for pagination.
     * /
    function checkLimit(IData[string] options): array
    {
        options["limit"] = (int)options["limit"];
        if (options["limit"] < 1) {
            options["limit"] = 1;
        }
        options["limit"] = max(min(options["limit"], options["maxLimit"]), 1);

        return options;
    }*/
}
