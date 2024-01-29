/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.exceptions.missingdatasource;

import uim.datasources;

@safe:
// Used when a datasource cannot be found.
class DDSOMissingDatasourceException : DDSOException {
	mixin(ExceptionThis!("DSOMissingDatasourceException"));

    override bool initialize(IData[string] configData = null) {
		if (!super.initialize(configData)) { return false; }
		
		this
			.messageTemplate("Datasource class %s could not be found. %s");

		return true;
	}
}
mixin(ExceptionCalls!("DSOMissingDatasourceException"));
