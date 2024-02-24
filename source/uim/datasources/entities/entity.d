/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.entities.entity;

@safe:
import uim.datasources;

/**
 * An entity represents a single result row from a repository. It exposes the
 * methods for retrieving and storing properties associated in this row.
 */
class Entity : IEntity, InvalidPropertyInterface {
    // use EntityTrait;

    // Holds all fields and their values for this entity.
    protected IValue[string] _fields;

    // Holds all fields that have been changed and their original values for this entity.
    protected IValue[string] _original;

    // List of field names that should not be included in JSON or Array representations of this Entity.
    protected string[] _hidden;

    // Indicates whether this entity is yet to be persisted.
    // Entities default to assuming they are new. You can use Table::persisted()
    // to set the new flag on an entity based on records in the database.
    protected bool _new = true;

    /*
     * List of computed or virtual fields that should be included in JSON or array
     * representations of this Entity. If a field is present in both _hidden and _virtual
     * the field will not be in the array/JSON versions of the entity. */
    protected string[] _virtual = null;

    // Holds a list of the fields that were modified or added after this object was originally created.
    protected bool[] _changed;

    /**
     * Initializes the internal properties of this entity out of the
     * keys in an array. The following list of options can be used:
     *
     * - useSetters: whether use internal setters for properties or not
     * - markClean: whether to mark all properties as clean after setting them
     * - markNew: whether this instance has not yet been persisted
     * - guard: whether to prevent inaccessible properties from being set (default: false)
     * - source: A string representing the alias of the repository this entity came from
     *
     * ### Example:
     *
     * ```
     *  $entity = new Entity(["id": 1, "name": "Andrew"])
     * ```
     *
     * @param array<string, mixed> $properties hash of properties to set in this entity
     * @param array<string, mixed> options list of options to use when creating this entity
     */
    /* this(array $properties = null, STRINGAA someOptions = null) {
        options += [
            "useSetters": true,
            "markClean": false,
            "markNew": null,
            "guard": false,
            "source": null,
        ];

        if (!empty(options["source"])) {
            this.setSource(options["source"]);
        }

        if (options["markNew"] != null) {
            this.setNew(options["markNew"]);
        }

        if (!empty($properties) && options["markClean"] && !options["useSetters"]) {
            _fields = $properties;

            return;
        }

        if (!empty($properties)) {
            this.set($properties, [
                "setter": options["useSetters"],
                "guard": options["guard"],
            ]);
        }

        if (options["markClean"]) {
            this.clean();
        }
    } */
}
