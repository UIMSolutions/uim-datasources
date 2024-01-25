module uim.cake.datasources.pagings.exceptions.pageoutofbounds;

import uim.cake;

@safe:

// Exception raised when requested page number does not exist.
class PageOutOfBoundsException : UimException {
    protected string _messageTemplate = "Page number `%s` could not be found.";
}
