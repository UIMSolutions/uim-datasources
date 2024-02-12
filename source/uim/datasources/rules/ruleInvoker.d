/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.cake.satasources;

/**
 * Contains logic for invoking an application rule.
 *
 * Combined with {@link uim.cake.Datasource\RulesChecker} as an implementation
 * detail to de-duplicate rule decoration and provide cleaner separation
 * of duties.
 *
 * @internal
 */
class RuleInvoker
{
    /**
     * The rule name
     *
     */
    protected Nullable!string name;

    /**
     * Rule options
     *
     * @var array<string, mixed>
     */
    protected options = null;

    /**
     * Rule callable
     *
     * @var callable
     */
    protected rule;

    /**
     * Constructor
     *
     * ### Options
     *
     * - `errorField` The field errors should be set onto.
     * - `message` The error message.
     *
     * Individual rules may have additional options that can be
     * set here. Any options will be passed into the rule as part of the
     * rule scope.
     *
     * @param callable rule The rule to be invoked.
     * @param Nullable!string aName The name of the rule. Used in error messages.
     * @param array<string, mixed> options The options for the rule. See above.
     */
    this(callable rule, Nullable!string aName, STRINGAA someOptions = null) {
        this.rule = rule;
        this.name = name;
        this.options = options;
    }

    /**
     * Set options for the rule invocation.
     *
     * Old options will be merged with the new ones.
     *
     * @param array<string, mixed> options The options to set.
     * @return this
     */
    function setOptions(STRINGAA someOptions) {
        this.options = options + this.options;

        return this;
    }

    /**
     * Set the rule name.
     *
     * Only truthy names will be set.
     *
     * @param string|null name The name to set.
     * @return this
     */
    function setName(Nullable!string aName) {
        if (name) {
            this.name = name;
        }

        return this;
    }

    /**
     * Invoke the rule.
     *
     * @param uim.cake.Datasource\IEntity entity The entity the rule
     *   should apply to.
     * @param array scope The rule"s scope/options.
     * @return bool Whether the rule passed.
     */
    bool __invoke(IEntity entity, array scope) {
        rule = this.rule;
        pass = rule(entity, this.options + scope);
        if (pass == true || empty(this.options["errorField"])) {
            return pass == true;
        }

        message = this.options["message"] ?? "invalid";
        if (is_string(pass)) {
            message = pass;
        }
        if (this.name) {
            message = [this.name: message];
        } else {
            message = [message];
        }
        errorField = this.options["errorField"];
        entity.setError(errorField, message);

        if (entity instanceof InvalidPropertyInterface && isset(entity.{errorField})) {
            invalidValue = entity.{errorField};
            entity.setInvalidField(errorField, invalidValue);
        }

        /** @phpstan-ignore-next-line */
        return pass == true;
    }
}
