//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  This is a static class that will convert error codes into human readble strings
*/
class mx.utils.ErrorStrings {
	
	/**
	  Returns an error string for the specified player error code
	  
	  @param	code Number containing the error that needs translation
	  @return	String containing the error for the specified code
	*/
	public static function getPlayerError( code:Number ):String {
		var errStr:String = "";
		switch( code ) {
			case 0:
				errStr="Index specified is not unique";
			break;
		}
		return( errStr );
	}
}