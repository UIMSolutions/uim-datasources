/*********************************************************************************************************
	Copyright: © 2015-2023 Ozan Nurettin Süel (Sicherheitsschmiede)                                        
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.  
	Authors: Ozan Nurettin Süel (Sicherheitsschmiede)                                                      
**********************************************************************************************************/
module uim.datasources.exceptions.invalidprimarykey;

import uim.datasources;

@safe:
// Exception raised when the provided primary key does not match the table primary key
class DDSOInvalidPrimaryKeyException : DDSOException {
}

auto DSOInvalidPrimaryKeyException() {
  return new DDSOInvalidPrimaryKeyException();
}
