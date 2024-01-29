module source.uim.datasources.mixins.entitytrait;

import uim.datasources;

@safe:

/**
 * An entity represents a single result row from a repository. It exposes the
 * methods for retrieving and storing fields associated in this row.
 */
mixin EntityTemplate {
  /**
     * Holds all fields and their values for this entity.
     */
  protected Json[string] _fields = [];

  // Holds all fields that have been changed and their original values for this entity.
  protected Json _original = [];

  // Holds all fields that have been initially set on instantiation, or after marking as clean
  protected string[] _originalFields = [];

  /**
     * List of field names that should **not** be included in JSON or Array
     * representations of this Entity.
     */
  protected string[] _hidden = [];

  /**
     * List of computed or virtual fields that **should** be included in JSON or array
     * representations of this Entity. If a field is present in both _hidden and _virtual
     * the field will **not** be in the array/JSON versions of the entity.
     */
  protected string[] _virtual = [];

  /**
     * Holds a list of the fields that were modified or added after this object
     * was originally created.
     */
  protected bool[] _dirty = [];

  /**
     * Holds a cached list of getters/setters per class
     *
     * @var array<string, array<string, STRINGAA>>
     */
  protected static array _accessors = [];

  /**
     * Indicates whether this entity is yet to be persisted.
     * Entities default to assuming they are new. You can use Table.persisted()
     * to set the new flag on an entity based on records in the database.
     */
  protected bool _new = true;

  /**
     * List of errors per field as stored in this object.
     */
  protected Json[string] _errors = [];

  // List of invalid fields and their data for errors upon validation/patching.
  protected Json[string] _invalid = [];

  /**
     * Map of fields in this entity that can be safely mass assigned, each
     * field name points to a boolean indicating its status. An empty array
     * means no fields are accessible for mass assigment.
     *
     * The special field '\*' can also be mapped, meaning that any other field
     * not defined in the map will take its value. For example, `'*": true`
     * means that any field not defined in the map will be accessible for mass
     * assignment by default.
     */
  protected bool[string] _accessible = ["*": true];

  /**
     * The alias of the repository this entity came from
     */
  protected string _registryAlias = "";

  /**
     * Storing the current visitation status while recursing through entities getting errors.
     */
  protected bool _hasBeenVisited = false;

  /**
     * Whether the presence of a field is checked when accessing a property.
     *
     * If enabled an exception will be thrown when trying to access a non-existent property.
     */
  protected bool$requireFieldPresence = false;

  /**
     * Magic getter to access fields that have been set in this entity
     * Params:
     * string afield Name of the field to access
    */
  Json & __get(string afield) {
    return this.get($field);
  }

  /**
     * Magic setter to add or edit a field in this entity
     * Params:
     * string afield The name of the field to set
     * @param Json aValue The value to set to the field
     */
  void __set(string afield, Json aValue) {
    this.set($field, aValue);
  }

  /**
     * Returns whether this entity contains a field named field
     * and is not set to null.
     * Params:
     * string afield The field to check.
     */
  bool __isSet(string afield) {
    return this.get($field) !isNull;
  }

  /**
     * Removes a field from this entity
     * Params:
     * string afield The field to unset
     */
  void __unset(string afield) {
    this.unset($field);
  }

  /**
     * Sets a single field inside this entity.
     *
     * ### Example:
     *
     * ```
     * entity.set("name", "Andrew");
     * ```
     *
     * It is also possible to mass-assign multiple fields to this entity
     * with one call by passing a hashed array as fields in the form of
     * field: value pairs
     *
     * ### Example:
     *
     * ```
     * entity.set(["name": 'andrew", "id": 1]);
     * echo entity.name // prints andrew
     * echo entity.id // prints 1
     * ```
     *
     * Some times it is handy to bypass setter functions in this entity when assigning
     * fields. You can achieve this by disabling the `setter` option using the
     * `$options` parameter:
     *
     * ```
     * entity.set("name", "Andrew", ["setter": false]);
     * entity.set(["name": 'Andrew", "id": 1], ["setter": false]);
     * ```
     *
     * Mass assignment should be treated carefully when accepting user input, by default
     * entities will guard all fields when fields are assigned in bulk. You can disable
     * the guarding for a single set call with the `guard` option:
     *
     * ```
     * entity.set(["name": 'Andrew", "id": 1], ["guard": false]);
     * ```
     *
     * You do not need to use the guard option when assigning fields individually:
     *
     * ```
     * // No need to use the guard option.
     * entity.set("name", "Andrew");
     * ```
     *
     * You can use the `asOriginal` option to set the given field as original, if it wasn`t
     * present when the entity was instantiated.
     *
     * ```
     * entity = new Entity(["name": 'andrew", "id": 1]);
     *
     * entity.set("phone_number", "555-0134");
     * print_r($entity.getOriginalFields()) // prints ["name", "id"]
     *
     * entity.set("phone_number", "555-0134", ["asOriginal": true]);
     * print_r($entity.getOriginalFields()) // prints ["name", "id", "phone_number"]
     * ```
     * Params:
     * Json[string]|string afield the name of field to set or a list of
     * fields with their respective values
     * @param Json aValue The value to set to the field or an array if the
     * first argument is also an array, in which case will be treated as options
     * @param Json[string] options Options to be used for setting the field. Allowed option
     * keys are `setter`, `guard` and `asOriginal`

     * @throws \InvalidArgumentException
     */
  void set(string[] afield, Json aValue = null, Json[string] options = null) {
    if (isString($field) && !$field.isEmpty) {
      guard = false;
      field = [$field: aValue];
    } else {
      guard = true;
      options = (array) aValue;
    }
    if (!isArray($field)) {
      throw new InvalidArgumentException("Cannot set an empty field");
    }
    options += ["setter": true, "guard": guard, "asOriginal": false];

    if ($options["asOriginal"] == true) {
      this.setOriginalField(array_keys($field));
    }
    foreach ($field as$name : aValue) {
      /** @psalm-suppress RedundantCastGivenDocblockType */
      name = (string)$name;
      if ($options["guard"] == true && !this.isAccessible($name)) {
        continue;
      }
      this.setDirty($name, true);

      if ($options["setter"]) {
        setter = _accessor($name, "set");
        if ($setter) {
          aValue = this. {
            setter
          }
          (aValue);
        }
      }
      if (
        this.isOriginalField($name) &&
        !array_key_exists($name, _original) &&
        array_key_exists($name, _fields) &&
        aValue != _fields[$name]
        ) {
        _original[$name] = _fields[$name];
      }
      _fields[$name] = aValue;
    }
    return;
  }

  /**
     * Returns the value of a field by name
     * Params:
     * string afield the name of the field to retrieve
     */
  Json & get(string fieldName) {
    if (fieldName.isEmpty) {
      throw new InvalidArgumentException("Cannot get an empty field");
    }
    aValue = null;
    fieldIsPresent = false;
    if (array_key_exists(fieldName, _fields)) {
      fieldIsPresent = true;
      aValue =  & _fields[fieldName];
    }
    method = _accessor(fieldName, "get");
    if ($method) {
      result = this. {
        method
      }
      (aValue);

      return result;
    }
    if (!$fieldIsPresent && this.requireFieldPresence) {
      throw new MissingPropertyException([
          "property": fieldName,
          "entity": this.classname,
        ]);
    }
    return aValue;
  }

  /**
     * Enable/disable field presence check when accessing a property.
     *
     * If enabled an exception will be thrown when trying to access a non-existent property.
     * Params:
     * bool aValue `true` to enable, `false` to disable.
     */
  void requireFieldPresence(bool aValue = true) {
    this.requireFieldPresence = aValue;
  }

  /**
     * Returns whether a field has an original value
     * Params:
     * string afield
     */
  bool hasOriginal(string afield) {
    return array_key_exists($field, _original);
  }

  /**
     * Returns the value of an original field by name
     * Params:
     * string afield the name of the field for which original value is retrieved.
     * @param bool allowFallback whether to allow falling back to the current field value if no original exists
     */
  Json getOriginal(string afield, bool$allowFallback = true) {
    if ($field.isEmpty) {
      throw new InvalidArgumentException("Cannot get an empty field");
    }
    if (array_key_exists($field, _original)) {
      return _original[$field];
    }
    if (!$allowFallback) {
      throw new InvalidArgumentException(
        "Cannot retrieve original value for field `%s`".format($field));
    }
    return this.get($field);
  }

  /**
     * Gets all original values of the entity.
     *
     */
  array getOriginalValues() {
    originals = _original;
    originalKeys = array_keys($originals);
    foreach (_fields as aKey : aValue) {
      if (
        !in_array(aKey, originalKeys, true) &&
        this.isOriginalField(aKey)
        ) {
        originals[aKey] = aValue;
      }
    }
    return originals;
  }

  /**
     * Returns whether this entity contains a field named field.
     *
     * It will return `true` even for fields set to `null`.
     *
     * ### Example:
     *
     * ```
     * entity = new Entity(["id": 1, "name": null]);
     * entity.has("id"); // true
     * entity.has("name"); // true
     * entity.has("last_name"); // false
     * ```
     *
     * You can check multiple fields by passing an array:
     *
     * ```
     * entity.has(["name", "last_name"]);
     * ```
     *
     * When checking multiple fields all fields must have a value (even `null`)
     * present for the method to return `true`.
     * Params:
     * string[]|string afield The field or fields to check.
     */
  bool has(string[] afield) {
    foreach ((array)$field as$prop) {
      if (!array_key_exists($prop, _fields) && !_accessor($prop, "get")) {
        return false;
      }
    }
    return true;
  }

  /**
     * Checks that a field is empty
     *
     * This is not working like the PHP `empty()` function. The method will
     * return true for:
     *
     * - `""` (empty string)
     * - `null`
     * - `[]`
     *
     * and false in all other cases.
     * Params:
     * string afield The field to check.
     */
  bool isEmpty(string afield) {
    aValue = this.get($field);
    if (
      aValue.isNull ||
      (
        isArray(aValue) &&
        empty(aValue) ||
        aValue == ""
      )
      ) {
      return true;
    }
    return false;
  }

  /**
     * Checks that a field has a value.
     *
     * This method will return true for
     *
     * - Non-empty strings
     * - Non-empty arrays
     * - Any object
     * - Integer, even `0`
     * - Float, even 0.0
     *
     * and false in all other cases.
     * Params:
     * string afield The field to check.
     */
  bool hasValue(string afield) {
    return !this.isEmpty($field);
  }

  /**
     * Removes a field or list of fields from this entity
     *
     * ### Examples:
     *
     * ```
     * entity.unset("name");
     * entity.unset(["name", "last_name"]);
     * ```
     * Params:
     * string[]|string afield The field to unset.
     */
  auto unset(string[] afield) {
    field = (array)$field;
    foreach ($field as$p) {
      unset(_fields[$p], _dirty[$p]);
    }
    return this;
  }

  /**
     * Sets hidden fields.
     * Params:
     * string[] fields An array of fields to hide from array exports.
     * @param bool merge Merge the new fields with the existing. By default false.
     */
  void setHidden(string[]$fields, bool$merge = false) {
    if ($merge == false) {
      _hidden = fields;

      return;
    }
    fields = chain(_hidden, fields);
    _hidden = array_unique($fields);
  }

  // Gets the hidden fields.
  string[] getHidden() {
    return _hidden;
  }

  /**
     * Sets the virtual fields on this entity.
     * Params:
     * string[] fields An array of fields to treat as virtual.
     * @param bool merge Merge the new fields with the existing. By default false.
     */
  void setVirtual(array$fields, bool$merge = false) {
    if ($merge == false) {
      _virtual = fields;

      return;
    }
    fields = chain(_virtual, fields);
    _virtual = array_unique($fields);
  }

  /**
     * Gets the virtual fields on this entity.
     */
  string[] getVirtual() {
    return _virtual;
  }

  /**
     * Gets the list of visible fields.
     *
     * The list of visible fields is all standard fields
     * plus virtual fields minus hidden fields.
     */
  string[] getVisible() {
    fields = array_keys(_fields);
    fields = chain($fields, _virtual);

    return array_diff($fields, _hidden);
  }

  /**
     * Returns an array with all the fields that have been set
     * to this entity
     *
     * This method will recursively transform entities assigned to fields
     * into arrays as well.
     */
  array toArray() {
    auto result;
    foreach (this.getVisible() as$field) {
      aValue = this.get($field);
      if (isArray(aValue)) {
        result[$field] = [];
        aValue.byKeyValue
          .each!(keyEntity => result[$field][keyEntity.key] = cast(IEntity) keyEntity.value
              ? entity.toArray() : entity);
      }

      else if(cast(IEntity) aValue) {
        result[$field] = aValue.toArray();
      } else {
        result[$field] = aValue;
      }
    }
    return result;
  }

  // Returns the fields that will be serialized as JSON
  array jsonSerialize() {
    return this.extract(this.getVisible());
  }

  bool offsetExists(Json anOffset) {
    return __isSet(anOffset);
  }

  Json & offsetGet(Json anOffset) {
    return this.get(anOffset);
  }

  /**
     * : entity[anOffset] = aValue;
     * Params:
     * string aoffset The offset to set.
     * @param Json aValue The value to set.
     */
  void offsetSet(Json anOffset, Json aValue) {
    this.set(anOffset, aValue);
  }

  /**
     * : unset(result[anOffset]);
     * Params:
     * string aoffset The offset to remove.
     */
  void offsetUnset(Json anOffset) {
    this.unset(anOffset);
  }

  /**
     * Fetch accessor method name
     * Accessor methods (available or not) are cached in _accessors
     * Params:
     * string aproperty the field name to derive getter name from
     * @param string atype the accessor type ("get' or `set")
     */
  protected static string _accessor(string aproperty, string accessorType) {
    className = class;

    if (isSet(_accessors[className][accessorType][aProperty])) {
      return _accessors[className][accessorType][aProperty];
    }
    if (!empty(_accessors[className])) {
      return _accessors[className][accessorType][aProperty] = "";
    }
    if (class == Entity.classname) {
      return "";
    }
    get_class_methods(className).each!((method) {
      string prefix = substr($method, 1, 3);
      if (method[0] != "_" || (prefix != "get" && prefix != "Set")) {
        continue;
      }

      string$field = lcfirst(substr(method, 4));
      snakeField = Inflector :  : underscore($field);
      titleField = ucfirst($field);
      _accessors[className][prefix][$snakeField] = method;
      _accessors[className][prefix][$field] = method;
      _accessors[className][prefix][$titleField] = method;
    });
    if (!isSet(_accessors[className][accessorType][aProperty])) {
      _accessors[className][accessorType][aProperty] = "";
    }
    return _accessors[className][accessorType][aProperty];
  }

  /**
     * Returns an array with the requested fields
     * stored in this entity, indexed by field name
     * Params:
     * @param bool onlyDirty Return the requested field only if it is dirty
     */
  array extract(string[] fieldsToReturn, bool returnOnlyDirty = false) {
    STRINGAA result;
    fieldsToReturn
      .filter!(field => !returnOnlyDirty || this.isDirty(field))
      .each!(field => result[field] = this.get(field));

    return result;
  }

  /**
     * Returns an array with the requested original fields
     * stored in this entity, indexed by field name, if they exist.
     *
     * Fields that are unchanged from their original value will be included in the
     * return of this method.
     * Params:
     * string[] fields List of fields to be returned
     */
  array extractOriginal(array$fields) {
    auto result;
    fields.each!((field) {
      if (this.hasOriginal(field)) {
        result[$field] = this.getOriginal(field);
      }
      else if(this.isOriginalField(field)) {
        result[field] = this.get(field);
      }
    });
    return result;
  }

  /**
     * Returns an array with only the original fields
     * stored in this entity, indexed by field name, if they exist.
     *
     * This method will only return fields that have been modified since
     * the entity was built. Unchanged fields will be omitted.
     */
  array extractOriginalChanged(string[] fields) {
    auto result;
    fields
      .filter!(field => this.hasOriginal(field))
      .each!((field) {
        auto originalField = this.getOriginal(field);
        if (originalField != this.get(field)) {
          result[field] = originalField;
        }
      });
    return result;
  }

  // Returns whether a field is an original one
  bool isOriginalField(string aName) {
    return in_array($name, _originalFields);
  }

  /**
     * Returns an array of original fields.
     * Original fields are those that the entity was initialized with.
     */
  string[] getOriginalFields() {
    return _originalFields;
  }

  /**
     * Sets the given field or a list of fields to as original.
     * Normally there is no need to call this method manually.
     * Params:
     * string[]|string afield the name of a field or a list of fields to set as original
     * @param bool merge
     */
  protected void setOriginalField(string | array$field, bool$merge = true) {
  }
  protected void setOriginalField(string[] fields, bool$merge = true) {
    if (!$merge) {
      _originalFields = fields;

      return;
    }
    fields
      .each!((field) {
        field = (string)$field; if (!this.isOriginalField($field)) {
          _originalFields ~= field;}
        });
      }

    /**
     * Sets the dirty status of a single field.
     * Params:
     * string afield the field to set or check status for
     * @param bool  isDirty true means the field was changed, false means
     * it was not changed. Defaults to true.
     */
    auto setDirty(string afield, bool isDirty = true) {
      if (isDirty == false) {
        this.setOriginalField($field);

        unset(_dirty[$field], _original[$field]);

        return this;
      }
      _dirty[$field] = true;
      unset(_errors[$field], _invalid[$field]);

      return this;
    }

    /**
     * Checks if the entity is dirty or if a single field of it is dirty.
     * Params:
     * string field The field to check the status for. Null for the whole entity.
     */
    bool isDirty(string afield = null) {
      if ($field.isNull) {
        return !_dirty.isEmpty;
      }
      return isSet(_dirty[$field]);
    }

    // Gets the dirty fields.
    sring[] getDirty() {
      return array_keys(_dirty);
    }

    /**
     * Sets the entire entity as clean, which means that it will appear as
     * no fields being modified or added at all. This is an useful call
     * for an initial object hydration
     */
    void clean() {
      _dirty = [];
      _errors = [];
      _invalid = [];
      _original = [];
      this.setOriginalField(array_keys(_fields), false);
    }

    /**
     * Set the status of this entity.
     *
     * Using `true` means that the entity has not been persisted in the database,
     * `false` that it already is.
     * Params:
     * bool new Indicate whether this entity has been persisted.
     */
    auto setNew(bool$new) {
      if ($new) {
        foreach (_fields as myKey : p) {
          _dirty[myKey] = true;
        }
      }
      _new = new;

      return this;
    }

    /**
     * Returns whether this entity has already been persisted.
     */
    bool isNew() {
      return _new;
    }

    /**
     * Returns whether this entity has errors.
     * Params:
     * bool  anIncludeNested true will check nested entities for hasErrors()
     */
    bool hasErrors(bool anIncludeNested = true) {
      if (_hasBeenVisited) {
        // While recursing through entities, each entity should only be visited once. See https://github.com/UIM/UIM/issues/17318
        return false;
      }
      if (Hash.filter(_errors)) {
        return true;
      }
      if (anIncludeNested == false) {
        return false;
      }
      _hasBeenVisited = true;
      try {
        foreach (_fields as$field) {
          if (_readHasErrors($field)) {
            return true;
          }
        }
      } finally {
        _hasBeenVisited = false;
      }
      return false;
    }

    

    / (Returns all validation errors.array getErrors() {
      if (_hasBeenVisited) {
        // While recursing through entities, each entity should only be visited once. See https://github.com/UIM/UIM/issues/17318
        return null;}
        diff = array_diff_key(_fields, _errors); _hasBeenVisited = true; try {
          errors = _errors + (new Collection($diff))
            .filter(function(aValue) {
              return isArray(aValue) || cast(IEntity) aValue;})
              .map(function(aValue) {
                return _readError(aValue);})
                .filter()
                .toArray();} finally {
                  _hasBeenVisited = false;}
                  return errors;}

                  /**
     * Returns validation errors of a field
     * Params:
     * string afield Field name to get the errors from
     */
                  array getError(string afield) {
                    return _errors[$field] ?  ? _nestedErrors($field);}

                    /**
     * Sets error messages to the entity
     *
     * ## Example
     *
     * ```
     * // Sets the error messages for multiple fields at once
     * entity.setErrors(["salary": ["message"], "name": ["another message"]]);
     * ```
     * Params:
     * array errors The array of errors to set.
     * @param bool overwrite Whether to overwrite pre-existing errors for fields
     */
                    auto setErrors(array$errors, bool$overwrite = false) {
                      if ($overwrite) {
                        foreach ($errors as$f : error) {
                          _errors[$f] = (array)$error;}
                          return this;}
                          foreach ($f : error; errors) {
                            _errors += [$f: []];  // String messages are appended to the list,
                            // while more complex error structures need their
                            // keys preserved for nested validator.
                            if (isString($error)) {
                              _errors[$f] ~= error;} else {
                                foreach ($error as myKey : v) {
                                  _errors[$f][myKey] = v;}
                                }
                              }
                              return this;}

                              /**
     * Sets errors for a single field
     *
     * ### Example
     *
     * ```
     * // Sets the error messages for a single field
     * entity.setErrors("salary", ["must be numeric", "must be a positive number"]);
     * ```
     * Params:
     * string afield The field to get errors for, or the array of errors to set.
     * @param string[] aerrors The errors to be set for field
     * @param bool overwrite Whether to overwrite pre-existing errors for field
     */
                              auto setErrors(string afield, string[] aerrors, bool$overwrite = false) {
                                if (isString($errors)) {
                                  errors = [$errors];}
                                  return this.setErrors([$field: errors], overwrite);
                                }

                                /**
     * Auxiliary method for getting errors in nested entities
     * Params:
     * string afield the field in this entity to check for errors
     */
                                protected array _nestedErrors(
                                string fieldName) {
                                  // Only one path element, check for nested entity with error.
                                  if (!fieldName.has(".")) {
                                    entity = this.get(fieldName); if (cast(IEntity)$entity || is_iterable(
                                      entity)) {
                                      return _readError($entity);}
                                      return null;}
                                      // Try reading the errors data with field as a simple path
                                      error = Hash.get(_errors, fieldName); if ($error!isNull) {
                                        return error;}
                                        somePath = split(".", fieldName); // Traverse down the related entities/arrays for
                                        // the relevant entity.
                                        entity = this; len = count(
                                        somePath); while ($len) {
                                          string$part = array_shift(
                                          somePath); len = count(
                                          somePath); val = null; if (cast(IEntity)$entity) {
                                            val = entity.get($part);}
                                            else if(isArray($entity)) {
                                              val = entity[$part] ?  ? false;}
                                              if (
                                                isArray($val) ||
                                              cast(Traversable)$val ||
                                              cast(IEntity)$val
                                                ) {
                                                entity = val;} else {
                                                  somePath ~= part; break;}
                                                }
                                                if (count(somePath) <= 1) {
                                                  return _readError($entity, array_pop(
                                                  somePath));}
                                                  return null;}

                                                  /**
     * Reads if there are errors for one or many objects.
     * Params:
     * \UIM\Datasource\IEntity|array object The object to read errors from.
     */
                                                  protected bool _readHasErrors(
                                                  IEntity[]$object) {
                                                    if (cast(IEntity)$object && object
                                                    .hasErrors()) {
                                                      return true;}
                                                      if (isArray($object)) {
                                                        foreach (
                                                          object as aValue) {
                                                          if (
                                                            _readHasErrors(
                                                            aValue)) {
                                                            return true;}
                                                          }
                                                        }
                                                        return false;}

                                                        /**
     * Read the error(s) from one or many objects.
     * Params:
     * \UIM\Datasource\IEntity|iterable object The object to read errors from.
     * @param string somePath The field name for errors.
     */
                                                        protected array _readError(
                                                        IEntity | iterable$object, string aPath = null) {
                                                          if (somePath!isNull && cast(
                                                            IEntity)$object) {
                                                            return object.getError(
                                                            somePath);}
                                                            if (
                                                              cast(IEntity)$object) {
                                                              return object.getErrors();
                                                            }
                                                            array = array_map(
                                                            function($val) {
                                                              if (
                                                                cast(IEntity)$val) {
                                                                return val.getErrors();
                                                              }
                                                            }, (array)$object); return array_filter(
                                                            array);}

                                                            /**
     * Get a list of invalid fields and their data for errors upon validation/patching
     */
                                                            Json[string] getInvalid() {
                                                              return _invalid;}

                                                              /**
     * Get a single value of an invalid field. Returns null if not set.
     * Params:
     * string afield The name of the field.
     */
                                                              Json getInvalidField(
                                                              string fieldName) {
                                                                return _invalid.get(fieldName, null);
                                                              }

                                                              /**
     * Set fields as invalid and not patchable into the entity.
     *
     * This is useful for batch operations when one needs to get the original value for an error message after patching.
     * This value could not be patched into the entity and is simply copied into the _invalid property for debugging
     * purposes or to be able to log it away.
     * Params:
     * Json[string] fields The values to set.
     * @param bool overwrite Whether to overwrite pre-existing values for field.
     */
                                                              void setFieldsInvalid(array$fields, bool$overwrite = false) {
                                                                foreach ($fields as$field : aValue) {
                                                                  if ($overwrite == true) {
                                                                    _invalid[$field] = aValue;
                                                                    continue;}
                                                                    _invalid += [$field: aValue];
                                                                  }
                                                                }

                                                                void setFieldInvalid($field, aValue, bool$overwrite = false) {
                                                                  if ($overwrite == true) {
                                                                    _invalid[$field] = aValue;
                                                                    continue;}
                                                                    _invalid += [$field: aValue];
                                                                  }

                                                                  /**
     * Sets a field as invalid and not patchable into the entity.
     * Params:
     * string afield The value to set.
     * @param Json aValue The invalid value to be set for field.
     */
                                                                  auto setInvalidField(string afield, Json aValue) {
                                                                    _invalid[$field] = aValue;

                                                                    return this;}

                                                                    /**
     * Stores whether a field value can be changed or set in this entity.
     * The special field `*` can also be marked as accessible or protected, meaning
     * that any other field specified before will take its value. For example
     * `$entity.setAccess("*", true)` means that any field not specified already
     * will be accessible by default.
     *
     * You can also call this method with an array of fields, in which case they
     * will each take the accessibility value specified in the second argument.
     *
     * ### Example:
     *
     * ```
     * entity.setAccess("id", true); // Mark id as not protected
     * entity.setAccess("author_id", false); // Mark author_id as protected
     * entity.setAccess(["id", "user_id"], true); // Mark both fields as accessible
     * entity.setAccess("*", false); // Mark all fields as protected
     * ```
     * Params:
     * string[]|string afield Single or list of fields to change its accessibility
     * @param bool set True marks the field as accessible, false will
     * mark it as protected.
     */
                                                                    auto setAccess(string[] afield, bool$set) {
                                                                      if ($field == "*") {
                                                                        _accessible = array_map(fn($p) : set, _accessible);
                                                                        _accessible["*"] = set;

                                                                        return this;
                                                                      }
                                                                      foreach (
                                                                        (array)$field as$prop) {
                                                                        _accessible[$prop] = set;
                                                                      }
                                                                      return this;
                                                                    }

                                                                    /**
     * Returns the raw accessible configuration for this entity.
     * The `*` wildcard refers to all fields.
     */
                                                                    bool[] getAccessible() {
                                                                      return _accessible;
                                                                    }

                                                                    /**
     * Checks if a field is accessible
     *
     * ### Example:
     *
     * ```
     * entity.isAccessible("id"); // Returns whether it can be set or not
     * ```
     * Params:
     * string afield Field name to check
     */
                                                                    bool isAccessible(string afield) {
                                                                      aValue = _accessible[$field] ?  ? null;

                                                                      return (aValue.isNull && !empty(
                                                                      _accessible["*"])) || aValue;
                                                                    }

                                                                    /**
     * Returns the alias of the repository from which this entity came from.
     */
                                                                    string getSource() {
                                                                      return _registryAlias;
                                                                    }

                                                                    /**
     * Sets the source alias
     * Params:
     * string aalias the alias of the repository
     */
                                                                    auto setSource(string aalias) {
                                                                      _registryAlias = alias;

                                                                      return this;
                                                                    }

                                                                    /**
     * Returns a string representation of this object in a human readable format.
     */
                                                                    override string toString() {
                                                                      return to!string(json_encode(this, JSON_PRETTY_PRINT));
                                                                    }

                                                                    /**
     * Returns an array that can be used to describe the internal state of this
     * object.
     */
                                                                    Json[string] debugInfo() {
                                                                      fields = _fields;
                                                                      foreach (_virtual as$field) {
                                                                        fields[$field] = this
                                                                        .$field;}
                                                                        return fields ~ [
                                                                          "[new]": this.isNew(),
                                                                          "[accessible]": _accessible,
                                                                          "[dirty]": _dirty,
                                                                          "[original]": _original,
                                                                          "[originalFields]": _originalFields,
                                                                          "[virtual]": _virtual,
                                                                          "[hasErrors]": this.hasErrors(),
                                                                          "[errors]": _errors,
                                                                          "[invalid]": _invalid,
                                                                          "[repository]": _registryAlias,
                                                                        ];}
                                                                      }
