/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources;

@safe:
import uim.datasources;

use ArrayObject;
import uim.cake.events.IEventDispatcher;

/**
 * A trait that allows a class to build and apply application.
 * rules.
 *
 * If the implementing class also : EventAwareTrait, then
 * events will be emitted when rules are checked.
 *
 * The implementing class is expected to define the `RULES_CLASS` constant
 * if they need to customize which class is used for rules objects.
 */
trait RulesAwareTrait
{
    /**
     * The domain rules to be applied to entities saved by this table
     *
     * @var uim.datasources.RulesChecker
     */
    protected _rulesChecker;

    /**
     * Returns whether the passed entity complies with all the rules stored in
     * the rules checker.
     *
     * @param uim.cake.Datasource\IEntity $entity The entity to check for validity.
     * @param string $operation The operation being run. Either "create", "update" or "delete".
     * @param \ArrayObject|array|null $options The options To be passed to the rules.
     */
    bool checkRules(IEntity $entity, string $operation = RulesChecker::CREATE, $options = null) {
        $rules = this.rulesChecker();
        $options = $options ?: new ArrayObject();
        $options = is_array($options) ? new ArrayObject($options) : $options;
        $hasEvents = (this instanceof IEventDispatcher);

        if ($hasEvents) {
            $event = this.dispatchEvent(
                "Model.beforeRules",
                compact("entity", "options", "operation")
            );
            if ($event.isStopped()) {
                return $event.getResult();
            }
        }

        $result = $rules.check($entity, $operation, $options.getArrayCopy());

        if ($hasEvents) {
            $event = this.dispatchEvent(
                "Model.afterRules",
                compact("entity", "options", "result", "operation")
            );

            if ($event.isStopped()) {
                return $event.getResult();
            }
        }

        return $result;
    }

    /**
     * Returns the RulesChecker for this instance.
     *
     * A RulesChecker object is used to test an entity for validity
     * on rules that may involve complex logic or data that
     * needs to be fetched from relevant datasources.
     *
     * @see uim.datasources.RulesChecker
     * @return uim.cake.Datasource\RulesChecker
     */
    function rulesChecker(): RulesChecker
    {
        if (_rulesChecker != null) {
            return _rulesChecker;
        }
        /** @psalm-var class-string<uim.cake.Datasource\RulesChecker> $class */
        $class = defined("static::RULES_CLASS") ? static::RULES_CLASS : RulesChecker::class;
        /** @psalm-suppress ArgumentTypeCoercion */
        _rulesChecker = this.buildRules(new $class(["repository": this]));
        this.dispatchEvent("Model.buildRules", ["rules": _rulesChecker]);

        return _rulesChecker;
    }

    /**
     * Returns a RulesChecker object after modifying the one that was supplied.
     *
     * Subclasses should override this method in order to initialize the rules to be applied to
     * entities saved by this instance.
     *
     * @param uim.cake.Datasource\RulesChecker $rules The rules object to be modified.
     * @return uim.cake.Datasource\RulesChecker
     */
    function buildRules(RulesChecker $rules): RulesChecker
    {
        return $rules;
    }
}
