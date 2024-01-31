/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.exceptions.recordnotfound;

@safe:
import uim.datasources;

// Exception raised when a particular record was not found
class DDSORecordNotFoundException : DatasourceException {
	mixin(ExceptionThis!("DSORecordNotFoundException"));

    override bool initialize(IData[string] configData = null) {
		if (!super.initialize(configData)) { return false; }
		
		this
			.messageTemplate("Record not found.");

		return true;
	}
}
mixin(ExceptionCalls!("DSORecordNotFoundException"));
