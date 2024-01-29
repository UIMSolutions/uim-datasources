/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources;

@safe:
import uim.datasources;

use InvalidArgumentException;

/**
 * Contains logic for storing and checking rules on entities
 *
 * RulesCheckers are used by Table classes to ensure that the
 * current entity state satisfies the application logic and business rules.
 *
 * RulesCheckers afford different rules to be applied in the create and update
 * scenario.
 *
 * ### Adding rules
 *
 * Rules must be callable objects that return true/false depending on whether
 * the rule has been satisfied. You can use RulesChecker::add(), RulesChecker::addCreate(),
 * RulesChecker::addUpdate() and RulesChecker::addDelete to add rules to a checker.
 *
 * ### Running checks
 *
 * Generally a Table object will invoke the rules objects, but you can manually
 * invoke the checks by calling RulesChecker::checkCreate(), RulesChecker::checkUpdate() or
 * RulesChecker::checkDelete().
 */
class RulesChecker
{
    /**
     * Indicates that the checking rules to apply are those used for creating entities
     */
    const string CREATE = "create";

    /**
     * Indicates that the checking rules to apply are those used for updating entities
     */
    const string UPDATE = "update";

    /**
     * Indicates that the checking rules to apply are those used for deleting entities
     */
    const string DELETE = "delete";

    /**
     * The list of rules to be checked on both create and update operations
     *
     * @var array<uim.cake.Datasource\RuleInvoker>
     */
    protected _rules = null;

    /**
     * The list of rules to check during create operations
     *
     * @var array<uim.cake.Datasource\RuleInvoker>
     */
    protected _createRules = null;

    /**
     * The list of rules to check during update operations
     *
     * @var array<uim.cake.Datasource\RuleInvoker>
     */
    protected _updateRules = null;

    /**
     * The list of rules to check during delete operations
     *
     * @var array<uim.cake.Datasource\RuleInvoker>
     */
    protected _deleteRules = null;

    /**
     * List of options to pass to every callable rule
     *
     * @var array
     */
    protected _options = null;

    /**
     * Whether to use I18n functions for translating default error messages
     */
    protected bool _useI18n = false;

    /**
     * Constructor. Takes the options to be passed to all rules.
     *
     * @param array<string, mixed> $options The options to pass to every rule
     */
    this(STRINGAA someOptions = null) {
        _options = $options;
        _useI18n = function_exists("__d");
    }

    /**
     * Adds a rule that will be applied to the entity both on create and update
     * operations.
     *
     * ### Options
     *
     * The options array accept the following special keys:
     *
     * - `errorField`: The name of the entity field that will be marked as invalid
     *    if the rule does not pass.
     * - `message`: The error message to set to `errorField` if the rule does not pass.
     *
     * @param callable $rule A callable function or object that will return whether
     * the entity is valid or not.
     * @param array|string|null $name The alias for a rule, or an array of options.
     * @param array<string, mixed> $options List of extra options to pass to the rule callable as
     * second argument.
     * @return this
     */
    function add(callable $rule, $name = null, STRINGAA someOptions = null) {
        _rules[] = _addError($rule, $name, $options);

        return this;
    }

    /**
     * Adds a rule that will be applied to the entity on create operations.
     *
     * ### Options
     *
     * The options array accept the following special keys:
     *
     * - `errorField`: The name of the entity field that will be marked as invalid
     *    if the rule does not pass.
     * - `message`: The error message to set to `errorField` if the rule does not pass.
     *
     * @param callable $rule A callable function or object that will return whether
     * the entity is valid or not.
     * @param array|string|null $name The alias for a rule or an array of options.
     * @param array<string, mixed> $options List of extra options to pass to the rule callable as
     * second argument.
     * @return this
     */
    function addCreate(callable $rule, $name = null, STRINGAA someOptions = null) {
        _createRules[] = _addError($rule, $name, $options);

        return this;
    }

    /**
     * Adds a rule that will be applied to the entity on update operations.
     *
     * ### Options
     *
     * The options array accept the following special keys:
     *
     * - `errorField`: The name of the entity field that will be marked as invalid
     *    if the rule does not pass.
     * - `message`: The error message to set to `errorField` if the rule does not pass.
     *
     * @param callable $rule A callable function or object that will return whether
     * the entity is valid or not.
     * @param array|string|null $name The alias for a rule, or an array of options.
     * @param array<string, mixed> $options List of extra options to pass to the rule callable as
     * second argument.
     * @return this
     */
    function addUpdate(callable $rule, $name = null, STRINGAA someOptions = null) {
        _updateRules[] = _addError($rule, $name, $options);

        return this;
    }

    /**
     * Adds a rule that will be applied to the entity on delete operations.
     *
     * ### Options
     *
     * The options array accept the following special keys:
     *
     * - `errorField`: The name of the entity field that will be marked as invalid
     *    if the rule does not pass.
     * - `message`: The error message to set to `errorField` if the rule does not pass.
     *
     * @param callable $rule A callable function or object that will return whether
     * the entity is valid or not.
     * @param array|string|null $name The alias for a rule, or an array of options.
     * @param array<string, mixed> $options List of extra options to pass to the rule callable as
     * second argument.
     * @return this
     */
    function addDelete(callable $rule, $name = null, STRINGAA someOptions = null) {
        _deleteRules[] = _addError($rule, $name, $options);

        return this;
    }

    /**
     * Runs each of the rules by passing the provided entity and returns true if all
     * of them pass. The rules to be applied are depended on the $mode parameter which
     * can only be RulesChecker::CREATE, RulesChecker::UPDATE or RulesChecker::DELETE
     *
     * @param uim.cake.Datasource\IEntity $entity The entity to check for validity.
     * @param string $mode Either "create, "update" or "delete".
     * @param array<string, mixed> $options Extra options to pass to checker functions.
     * @return bool
     * @throws \InvalidArgumentException if an invalid mode is passed.
     */
    bool check(IEntity $entity, string $mode, STRINGAA someOptions = null) {
        if ($mode == self::CREATE) {
            return this.checkCreate($entity, $options);
        }

        if ($mode == self::UPDATE) {
            return this.checkUpdate($entity, $options);
        }

        if ($mode == self::DELETE) {
            return this.checkDelete($entity, $options);
        }

        throw new InvalidArgumentException("Wrong checking mode: " ~ $mode);
    }

    /**
     * Runs each of the rules by passing the provided entity and returns true if all
     * of them pass. The rules selected will be only those specified to be run on "create"
     *
     * @param uim.cake.Datasource\IEntity $entity The entity to check for validity.
     * @param array<string, mixed> $options Extra options to pass to checker functions.
     */
    bool checkCreate(IEntity $entity, STRINGAA someOptions = null) {
        return _checkRules($entity, $options, array_merge(_rules, _createRules));
    }

    /**
     * Runs each of the rules by passing the provided entity and returns true if all
     * of them pass. The rules selected will be only those specified to be run on "update"
     *
     * @param uim.cake.Datasource\IEntity $entity The entity to check for validity.
     * @param array<string, mixed> $options Extra options to pass to checker functions.
     */
    bool checkUpdate(IEntity $entity, STRINGAA someOptions = null) {
        return _checkRules($entity, $options, array_merge(_rules, _updateRules));
    }

    /**
     * Runs each of the rules by passing the provided entity and returns true if all
     * of them pass. The rules selected will be only those specified to be run on "delete"
     *
     * @param uim.cake.Datasource\IEntity $entity The entity to check for validity.
     * @param array<string, mixed> $options Extra options to pass to checker functions.
     */
    bool checkDelete(IEntity $entity, STRINGAA someOptions = null) {
        return _checkRules($entity, $options, _deleteRules);
    }

    /**
     * Used by top level functions checkDelete, checkCreate and checkUpdate, this function
     * iterates an array containing the rules to be checked and checks them all.
     *
     * @param uim.cake.Datasource\IEntity $entity The entity to check for validity.
     * @param array<string, mixed> $options Extra options to pass to checker functions.
     * @param array<uim.cake.Datasource\RuleInvoker> $rules The list of rules that must be checked.
     */
    protected bool _checkRules(IEntity $entity, STRINGAA someOptions = null, array $rules = null) {
        $success = true;
        $options += _options;
        foreach ($rules as $rule) {
            $success = $rule($entity, $options) && $success;
        }

        return $success;
    }

    /**
     * Utility method for decorating any callable so that if it returns false, the correct
     * property in the entity is marked as invalid.
     *
     * @param callable|uim.cake.Datasource\RuleInvoker $rule The rule to decorate
     * @param array|string|null $name The alias for a rule or an array of options
     * @param array<string, mixed> $options The options containing the error message and field.
     * @return uim.cake.Datasource\RuleInvoker
     */
    protected function _addError(callable $rule, $name = null, STRINGAA someOptions = null): RuleInvoker
    {
        if (is_array($name)) {
            $options = $name;
            $name = null;
        }

        if (!($rule instanceof RuleInvoker)) {
            $rule = new RuleInvoker($rule, $name, $options);
        } else {
            $rule.setOptions($options).setName($name);
        }

        return $rule;
    }
}
