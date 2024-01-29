module uim.datasources;

import uim.cake;

@safe:

/**
 * Generic ResultSet decorator. This will make any traversable object appear to
 * be a database result
 *
 * @template T of \UIM\Datasource\IEntity|array
 * @implements \UIM\Datasource\IResultSet<T>
 */
class ResultSetDecorator : Collection, IResultSet {
 
    Json[string] debugInfo() {
        parentInfo = super.__debugInfo();
        aLimit = Configure.read("App.ResultSetDebugLimit", 10);

        return chain($parentInfo, ["items": this.take(aLimit).toArray()]);
    }
}
