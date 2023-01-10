module uim.datasources.entities.interface_;

@safe:
import uim.datasources;

/**
 * Describes the methods that any class representing a data storage should
 * comply with.
 *
 * @property mixed $id Alias for commonly used primary key.
 * @method bool[] getAccessible() Accessible configuration for this entity.
 */
interface IEntity : ArrayAccess, JsonSerializable {
    /**
     * Sets hidden fields.
     *
     * fieldNames - An array of fields to hide from array exports.
     * shouldMerge - Should merge the new fields with the existing. By default false.
     */
    IEntity hiddenFields(string[] fieldNames, bool shouldMerge = false);

    // Gets the hidden fields.
    string[] hiddenFields();

    /**
     * Sets the virtual fields on this entity.
     *
     * fieldNames - An array of fields to treat as virtual.
     * houldMerge - Should merge the new fields with the existing. By default false.
     */
    IEntity virtualFields(string[] fieldNames, bool shouldMerge = false);

    // Gets the virtual fields on this entity.aaa
    string[] virtualFields();

    /**
     * Sets the Changed status of a single field.
     *
     * fieldName - the field to set or check status for
     * @param bool $isChanged true means the field was changed, false means it was not changed. Default true.
     * @return this
     */
    IEntity setChanged(string fieldName, bool isChanged = true);

    /**
     * Checks if the entity is Changed or if a single field of it is Changed.
     *
     * fieldName - The field to check the status for. Null for the whole entity.
     * returns whether the field was changed or not
     */
    bool isChanged(string fieldName = null);

    // Gets the Changed fields.
    string[] getChanged();

    /**
     * Returns whether this entity has errors.
     *
     * shouldIncludeNested - true will check nested entities for hasErrors()
     */
    bool hasErrors(bool shouldIncludeNested = true);

    // Returns all validation errors.
    // array getErrors();

    /**
     * Returns validation errors of a field
     *
     * @param string fieldName Field name to get the errors from
     */
    // array getError(string fieldName);

    /**
     * Sets error messages to the entity
     *
     * @param array myErrors The array of errors to set.
     * @param bool $overwrite Whether to overwrite pre-existing errors for fieldNames
     * @return this
     */
    // auto setErrors(array myErrors, bool $overwrite = false);

    /**
     * Sets errors for a single field
     *
     * @param string fieldName The field to get errors for, or the array of errors to set.
     * @param array|string myErrors The errors to be set for myField
     * @param bool $overwrite Whether to overwrite pre-existing errors for myField
     * @return this
     */
    // auto setError(string fieldName, myErrors, bool $overwrite = false);

    /**
     * Stores whether a field value can be changed or set in this entity.
     *
     * @param array<string>|string fieldName single or list of fields to change its accessibility
     * @param bool $set true marks the field as accessible, false will
     * mark it as protected.
     */
    IEntity setAccess(string[] fieldNames, bool setAccessible);
    IEntity setAccess(string fieldName, bool setAccessible);

    /**
     * Checks if a field is accessible
     *
     * fieldName - Field name to check
     */
    bool isAccessible(string fieldName);

    /**
     * Sets the source alias
     * anAliasName - the alias of the repository
     */
    IEntity setSource(string anAliasName);

    // Returns the alias of the repository from which this entity came from.
    string getSource();

    /**
     * Returns an array with the requested original fields
     * stored in this entity, indexed by field name.
     *
     * fieldNames - List of fields to be returned
     */
    IValue[string] extractOriginal(string[] fieldNames);

    /**
     * Returns an array with only the original fields stored in this entity, indexed by field name.
     *
     * fieldNames - st of fields to be returned
     */
    array extractOriginalChanged(string[] fieldNames);

    /**
     * Sets one or multiple fields to the specified value
     *
     * @param array<string, mixed>|string fieldName the name of field to set or a list of
     * fields with their respective values
     * @param mixed myValue The value to set to the field or an array if the
     * first argument is also an array, in which case will be treated as myOptions
     * @param array<string, mixed> myOptions Options to be used for setting the field. Allowed option
     * keys are `setter` and `guard`
     * @return this
     */
    IEntity set(IValue[string] fieldValues, STRINGAA someOptions = null);
    IEntity set(string fieldName, IValue aValue, STRINGAA someOptions = null);

    /**
     * Returns the value of a field by name
     *
     * fieldName - the name of the field to retrieve
     */
    IValue get(string fieldName);

    /**
     * Returns the original value of a field.
     *
     * fieldName - The name of the field.
     */
    IValue getOriginal(string myFfieldNameeld);

    // Gets all original values of the entity.
    array getOriginalValues();

    /**
     * Returns whether this entity contains a field named myField regardless of if it is empty.
     * array<string>|string fieldName The field to check.
     */
    bool has(string[] fieldNames);
    bool has(string[] fieldNames...);

    /**
     * Removes a field or list of fields from this entity
     *
     * fieldNames - The fields to unset.
     */
    IEntity unset(this O)(string[] fieldNames);
    IEntity unset(this O)(string[] fieldNames...);

    /**
     * Get the list of visible fields.
     * @return A list of fields that are "visible" in all representations.
     */
    string[] getVisible();

    /**
     * Returns an array with all the visible fields set in this entity.
     *
     * *Note* hidden fields are not visible, and will not be output
     * by toArray().
     */
    string[] toArray();

    /**
     * Returns an array with the requested fields stored in this entity, indexed by field name
     *
     * @param fieldNames list of fields to be returned
     * onlyChangedFields - Return the requested field only if it is Changed
     * @return array
     */
    string[] extract(string[] fieldNames, bool onlyChangedFields = false);

    /**
     * Sets the entire entity as clean, which means that it will appear as
     * no fields being modified or added at all. This is an useful call
     * for an initial object hydration
     */
    void clean();

    /**
     * Set the status of this entity.
     *
     * Using `true` means that the entity has not been persisted in the database,
     * `false` indicates that the entity has been persisted.
     *
     * isNew - Indicate whether this entity has been persisted.
     */
    IEntity setNew(bool isNew);

    /**
     * Returns whether this entity has already been persisted.
     * returns whether the entity has been persisted.
     */
    bool isNew();
}
