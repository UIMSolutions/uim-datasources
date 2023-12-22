module source.uim.datasources.exceptions.missingproperty;

import uim.cake;

@safe:
// A required property does not exist for an entity.
class DDSOMissingPropertyException : DDSOException {
  protected string _messageTemplate = "Property `%s` does not exist for the entity `%s`.";
}

auto DSOMissingPropertyException() {
  return new DDSOMissingPropertyException();
}
