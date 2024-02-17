module uim.datasources.interfaces.repository;

import uim.datasources;

@safe:

/**
 * Describes the methods that any class representing a data storage should
 * comply with.
 */
interface IRepository {
    // Sets the repository alias.
    auto setAlias(string tableAlias);

    // Returns the repository alias.
    string getAlias();

    /**
     * Alias a field with the repository`s current alias.
     *
     * If field is already aliased it will result in no-op.
     */
    string aliasField(string fieldAlias);

    // Sets the table registry key used to create this table instance.
    void registryAlias(string registryAlias);

    // Returns the table registry key used to create this table instance.
    string registryAlias();

    // Test to see if a Repository has a specific field/column.
    bool hasField(string fieldName);

    /**
     * Creates a new Query for this repository and applies some defaults based on the
     * type of search that was selected.
     * Params:
     * string atype the type of query to perform
     * @param Json ...someArguments Arguments that match up to finder-specific parameters
     */
    IQuery find(string atype = "all", Json ...someArguments);

    /**
     * Returns a single record after finding it by its primary key, if no record is
     * found this method throws an exception.
     *
     * ### Example:
     *
     * ```
     *  anId = 10;
     * article = articles.get(anId);
     *
     * article = articles.get(anId, ["contain": ["Comments]]);
     * ```
     * Params:
     * Json $primaryKey primary key value to find
     * @param string[] afinder The finder to use. Passing an options array is deprecated.
     * @param \Psr\SimpleCache\ICache|string|null $cache The cache config to use.
     *  Defaults to `null`, i.e. no caching.
     * @param \Closure|string|null $cacheKey The cache key to use. If not provided
     *  one will be autogenerated if `$cache` is not null.
     * @throws \UIM\Datasource\Exception\RecordNotFoundException if the record with such id
     * could not be found
     */
    IEntity get(
        Json $primaryKey,
        string[] afinder = "all",
        ICache|string|null $cache = null,
        Closure|string|null $cacheKey = null,
        Json ...someArguments
    );

    // Creates a new Query instance for this repository
    IQuery query();

    /**
     * Update all matching records.
     *
     * Sets the fields to the provided values based on $conditions.
     * This method will *not* trigger beforeSave/afterSave events. If you need those
     * first load a collection of records and update them.
     * Params:
     * \Closure|string[] afields A hash of field: new value.
     * @param \Closure|string[]|null $conditions Conditions to be used, accepts anything Query.where()
     * can take.
     */
    int updateAll(Closure|string[] afields, Closure|string[]|null $conditions);

    /**
     * Deletes all records matching the provided conditions.
     *
     * This method will *not* trigger beforeDelete/afterDelete events. If you
     * need those first load a collection of records and delete them.
     *
     * This method will *not* execute on associations' `cascade` attribute. You should
     * use database foreign keys + ON CASCADE rules if you need cascading deletes combined
     * with this method.
     * Params:
     * \Closure|string[]|null $conditions Conditions to be used, accepts anything Query.where()
     * can take.
     */
    int deleteAll(Closure|string[]|null $conditions);

    /**
     * Returns true if there is any record in this repository matching the specified
     * conditions.
     * Params:
     * \Closure|string[]|null $conditions list of conditions to pass to the query
     */
   bool exists(Closure|string[]|null $conditions);

    /**
     * Persists an entity based on the fields that are marked as dirty and
     * returns the same entity after a successful save or false in case
     * of any error.
     * Params:
     * \UIM\Datasource\IEntity $entity the entity to be saved
     * @param IData[string] optionData The options to use when saving.
     */
    IEntity|false save(IEntity $entity, IData[string] optionData = null);

    /**
     * Delete a single entity.
     *
     * Deletes an entity and possibly related associations from the database
     * based on the 'dependent' option used when defining the association.
     * Params:
     * \UIM\Datasource\IEntity $entity The entity to remove.
     * @param IData[string] optionData The options for the delete.
         */
    bool delete(IEntity $entity, IData[string] optionData = null);

    /**
     * This creates a new entity object.
     *
     * Careful: This does not trigger any field validation.
     * This entity can be persisted without validation error as empty record.
     * Always patch in required fields before saving.
     */
    IEntity newEmptyEntity();

    /**
     * Create a new entity + associated entities from an array.
     *
     * This is most useful when hydrating request data back into entities.
     * For example, in your controller code:
     *
     * ```
     * article = this.Articles.newEntity(this.request.getData());
     * ```
     *
     * The hydrated entity will correctly do an insert/update based
     * on the primary key data existing in the database when the entity
     * is saved. Until the entity is saved, it will be a detached record.
     * Params:
     * array data The data to build an entity with.
     * @param IData[string] $options A list of options for the object hydration.
     */
    IEntity newEntity(array data, IData[string] optionData = null);

    /**
     * Create a list of entities + associated entities from an array.
     *
     * This is most useful when hydrating request data back into entities.
     * For example, in your controller code:
     *
     * ```
     * articles = this.Articles.newEntities(this.request.getData());
     * ```
     *
     * The hydrated entities can then be iterated and saved.
     */
    IEntity[] newEntities(array buildData, IData[string] optionDataForHydration = null);

    /**
     * Merges the passed `someData` into `$entity` respecting the accessible
     * fields configured on the entity. Returns the same entity after being
     * altered.
     *
     * This is most useful when editing an existing entity using request data:
     *
     * ```
     * article = this.Articles.patchEntity($article, this.request.getData());
     * ```
     * Params:
     * \UIM\Datasource\IEntity $entity the entity that will get the
     * data merged in
     * @param array data key value list of fields to be merged into the entity
     * @param IData[string] $options A list of options for the object hydration.
     */
    IEntity patchEntity(IEntity $entity, array data, IData[string] optionData = null);

    /**
     * Merges each of the elements passed in `someData` into the entities
     * found in `$entities` respecting the accessible fields configured on the entities.
     * Merging is done by matching the primary key in each of the elements in `someData`
     * and `$entities`.
     *
     * This is most useful when editing a list of existing entities using request data:
     *
     * ```
     * article = this.Articles.patchEntities($articles, this.request.getData());
     * ```
     * Params:
     * iterable<\UIM\Datasource\IEntity> $entities the entities that will get the
     * data merged in
     * @param array data list of arrays to be merged into the entities
     * @param IData[string] $options A list of options for the objects hydration.
     */
    IEntity[] patchEntities(iterable $entities, array data, IData[string] optionData = null);
}
