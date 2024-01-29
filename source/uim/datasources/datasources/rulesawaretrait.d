module uim.datasources;

import uim.cake;

@safe:

/**
 * A template that allows a class to build and apply application.
 * rules.
 *
 * If the implementing class also : EventAwareTrait, then
 * events will be emitted when rules are checked.
 *
 * The implementing class is expected to define the `RULES_CLASS` constant
 * if they need to customize which class is used for rules objects.
 */
mixin RulesAwareTemplate {
    // The domain rules to be applied to entities saved by this table
    protected RulesChecker _rulesChecker = null;

    /**
     * Returns whether the passed entity complies with all the rules stored in
     * the rules checker.
     * Params:
     * \UIM\Datasource\IEntity entity The entity to check for validity.
     * @param string aoperation The operation being run. Either 'create", "update' or 'delete'.
     * @param \ArrayObject<string, mixed>|array|null options The options To be passed to the rules.
     */
   bool checkRules(
        IEntity entity,
        string aoperation = RulesChecker.CREATE,
        ArrayObject[] options = null
    ) {
        rules = this.rulesChecker();
        options = options ?: new ArrayObject();
        options = isArray($options) ? new ArrayObject($options): options;
        hasEvents = (cast(IEventDispatcher)this);

        if ($hasEvents) {
            event = this.dispatchEvent(
                "Model.beforeRules",
                compact("entity", "options", "operation")
            );
            if ($event.isStopped()) {
                return event.getResult();
            }
        }
        result = rules.check($entity, operation, options.getArrayCopy());

        if ($hasEvents) {
            event = this.dispatchEvent(
                "Model.afterRules",
                compact("entity", "options", "result", "operation")
            );

            if ($event.isStopped()) {
                return event.getResult();
            }
        }
        return result;
    }
    
    /**
     * Returns the RulesChecker for this instance.
     *
     * A RulesChecker object is used to test an entity for validity
     * on rules that may involve complex logic or data that
     * needs to be fetched from relevant datasources.
     */
    RulesChecker rulesChecker() {
        if (_rulesChecker !isNull) {
            return _rulesChecker;
        }
        /** @var class-string<\UIM\Datasource\RulesChecker>  className */
         className = defined("RULES_CLASS") ? RULES_CLASS : RulesChecker.classname;
        /**
         * @psalm-suppress ArgumentTypeCoercion
         * @phpstan-ignore-next-line
         */
       _rulesChecker = this.buildRules(new className(["repository": this]));
        this.dispatchEvent("Model.buildRules", ["rules": _rulesChecker]);

        return _rulesChecker;
    }
    
    /**
     * Returns a RulesChecker object after modifying the one that was supplied.
     *
     * Subclasses should override this method in order to initialize the rules to be applied to
     * entities saved by this instance.
     * Params:
     * \UIM\Datasource\RulesChecker rules The rules object to be modified.
     */
    RulesChecker buildRules(RulesChecker rules) {
        return rules;
    }
}
