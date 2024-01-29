module uim.datasources;

import uim.cake;

@safe:

/**
 * Describes the methods that any class representing a data storage should
 * comply with.
 */
interface IInvalidProperty {
    // Get a list of invalid fields and their data for errors upon validation/patching
    array getInvalid();

    /**
     * Set fields as invalid and not patchable into the entity.
     *
     * This is useful for batch operations when one needs to get the original value for an error message after patching.
     * This value could not be patched into the entity and is simply copied into the _invalid property for debugging
     * purposes or to be able to log it away.
     * Params:
     * Json[string] $fields The values to set.
     * @param bool $overwrite Whether to overwrite pre-existing values for $field.
     */
    auto setFieldsInvalid(array $fields, bool $overwrite = false);

    /**
     * Get a single value of an invalid field. Returns null if not set.
     * Params:
     * string afield The name of the field.
     */
    Json getInvalidField(string afield) ;

    /**
     * Sets a field as invalid and not patchable into the entity.
     * Params:
     * string afield The value to set.
     * @param Json aValue The invalid value to be set for $field.
     */
    auto setInvalidField(string afield, Json aValue);
}
