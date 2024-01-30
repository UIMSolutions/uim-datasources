module uim.datasources.exceptions.missingproperty;

import uim.datasources;

@safe:
// A required property does not exist for an entity.
class DDSOMissingPropertyException : DDSOException {
	mixin(ExceptionThis!("DSOMissingPropertyException"));

    override bool initialize(IData[string] configData = null) {
		if (!super.initialize(configData)) { return false; }
		
		this
			.messageTemplate("Property `%s` does not exist for the entity `%s`.");

		return true;
	}
}
mixin(ExceptionCalls!("DSOMissingPropertyException"));
