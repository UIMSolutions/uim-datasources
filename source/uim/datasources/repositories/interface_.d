/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.repositories.interface_;

@safe:
import uim.datasources;

// Describes the methods that any class representing a data storage should comply with.
interface IRepository {
  // Sets the repository aliasName.
  IRepository aliasName(string aAliasName);

  // Returns the repository aliasName.
  string aliasName();

  //Sets the table registry key used to create this table instance.
  // registryAliasName - The key used to access this object.
  IRepository registryAlias(string registryAliasName);

  // Returns the table registry key used to create this table instance.
  string registryAlias();

  // Test to see if a Repository has a specific field/column.
  // v The field to check for.
  // True if the field exists, false if it does not.
  bool hasField(string fieldName);

  // Creates a new Query for this repository and applies some defaults based on the type of search that was selected.
  // myType the type of query to perform
  // array<string, mixed> myOptions An array that will be passed to Query::applyOptions()
  IQuery find(string myType = "all", STRINGAA someOptions = null);

  /**
    * Returns a single record after finding it by its primary key, if no record is
    * found this method throws an exception.
    *
    * ### Example:
    *
    * ```
    * $id = 10;
    * $article = $articles.get($id);
    *
    * $article = $articles.get($id, ["contain":["Comments]]);
    * ```
    *
    * @param mixed $primaryKey primary key value to find
    * @param array<string, mixed> myOptions options accepted by `Table::find()`
    * @throws \Cake\Datasource\Exception\RecordNotFoundException if the record with such id
    * could not be found
    */
  IEntity get(IValue[string] primaryKeys, STRINGAA someOptions);

  // Creates a new Query instance for this repository
  IQuery query();

  /**
    * Update all matching records.
    *
    * Sets the fieldNames to the provided values based on $conditions.
    * This method will *not* trigger beforeSave/afterSave events. If you need those
    * first load a collection of records and update them.
    *
    * @param \Cake\Database\Expression\QueryExpression|\Closure|array|string fieldNames A hash of field: new value.
    * @param mixed $conditions Conditions to be used, accepts anything Query::where()
    * can take.
    * @return int Count Returns the affected rows.
    */
  // int updateAll(fieldNames, $conditions);

  /**
    * Deletes all records matching the provided conditions.
    *
    * This method will *not* trigger beforeDelete/afterDelete events. If you
    * need those first load a collection of records and delete them.
    *
    * This method will *not* execute on associations" `cascade` attribute. You should
    * use database foreign keys + ON CASCADE rules if you need cascading deletes combined
    * with this method.
    *
    * @param mixed $conditions Conditions to be used, accepts anything Query::where()
    * can take.
    * @return int Returns the number of affected rows.
    * @see \Cake\Datasource\IRepository::delete()
    */
  // int deleteAll($conditions);

  /**
    * Returns true if there is any record in this repository matching the specified
    * conditions.
    *
    * @param array $conditions list of conditions to pass to the query
    */
  // bool exists($conditions);

  /**
    * Persists an entity based on the fields that are marked as dirty and
    * returns the same entity after a successful save or false in case
    * of any error.
    *
    * @param \Cake\Datasource\IEntity anEntity the entity to be saved
    * @param \ArrayAccess|array myOptions The options to use when saving.
    */
  IEntity save(IEntity anEntity, myOptions= null);

  /**
    * Delete a single entity.
    *
    * Deletes an entity and possibly related associations from the database
    * based on the "dependent" option used when defining the association.
    *
    * anEntity - The entity to remove.
    * someOptions - The options for the delete.
    * @return bool success
    */
  bool deleteEntity(IEntity anEntity, STRINGAA someOptions= null);

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
    * $article = this.Articles.newEntity(this.request.getData());
    * ```
    *
    * The hydrated entity will correctly do an insert/update based
    * on the primary key data existing in the database when the entity
    * is saved. Until the entity is saved, it will be a detached record.
    *
    * @param IValue[string] mergeData The data to build an entity with.
    * @param array<string, mixed> myOptions A list of options for the object hydration.
    */
  IEntity newEntity(IValue[string] mergeData, STRINGAA someOptions = null);

  /**
    * Create a list of entities + associated entities from an array.
    *
    * This is most useful when hydrating request data back into entities.
    * For example, in your controller code:
    *
    * ```
    * $articles = this.Articles.newEntities(this.request.getData());
    * ```
    *
    * The hydrated entities can then be iterated and saved.
    *
    * @param IValue[string] mergeData The data to build an entity with.
    * @param array<string, mixed> myOptions A list of options for the objects hydration.
    * returns An array of hydrated records.
    */
  IENtity[] newEntities(IValue[string] mergeData, STRINGAA someOptions = null);

  /**
    * Merges the passed `myData` into `$entity` respecting the accessible
    * fields configured on the entity. Returns the same entity after being
    * altered.
    *
    * This is most useful when editing an existing entity using request data:
    *
    * ```
    * $article = this.Articles.patchEntity($article, this.request.getData());
    * ```
    *
    * @param \Cake\Datasource\IEntity anEntity the entity that will get the
    * data merged in
    * @param IValue[string] mergeData key value list of fields to be merged into the entity
    * @param array<string, mixed> myOptions A list of options for the object hydration.
    * @return \Cake\Datasource\IEntity
    */
  IEntity patchEntity(IEntity anEntity, IValue[string] mergeData, STRINGAA someOptions = null);

  /**
    * Merges each of the elements passed in `myData` into the entities
    * found in `$entities` respecting the accessible fields configured on the entities.
    * Merging is done by matching the primary key in each of the elements in `myData`
    * and `$entities`.
    *
    * This is most useful when editing a list of existing entities using request data:
    *
    * ```
    * $article = this.Articles.patchEntities($articles, this.request.getData());
    * ```
    *
    * @param \Traversable|array<\Cake\Datasource\IEntity> $entities the entities that will get the
    * data merged in
    * @param IValue[string] mergeData list of arrays to be merged into the entities
    * @param array<string, mixed> myOptions A list of options for the objects hydration.
    */
  IEntity[] patchEntities(IEntity someEntities, IValue[string] mergeData, STRINGAA someOptions = null);
}
