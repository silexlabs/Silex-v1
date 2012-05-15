/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.rpc.ResultEvent;
import mx.rpc.FaultEvent;
/** 
 * this is a responder object, to be used when making an RPC call. Using this avoids constructing an object
 *	in the body of a function.
 * @author Ariel Sommeria-klein
 * */
class org.oof.dataConnectors.RemotingResponder{
	
	var _successCallback:Function = null;
	var _errorCallback:Function = null;
	var _connector:OofBase = null;
	function RemotingResponder(connector:OofBase, successCallback:Function, errorCallback:Function) {
		_connector = connector;
		_successCallback = successCallback;
		_errorCallback = errorCallback;
	}
	
	/**function onError, as defined for remoteing
	*@returns void
	*/
	function onError(error:FaultEvent){
		var errorMessage:String = "";
		errorMessage = errorMessage + "There was a problem: " + error.fault.faultstring;
		errorMessage = errorMessage + "\nThe errorcode is: " + error.fault.faultcode;
		errorMessage = errorMessage + "\nThe detail: " + error.fault.detail;
		errorMessage = errorMessage + "\nThe error class name is: " + error.fault.type;	
		//_root.getURL("----------","_blank");
		if(_errorCallback != null){
			_errorCallback(error.fault.faultstring);
		}
	}
	
	/**function onSuccess, , as defined for remoteing
	*@returns void
	*/
	function onSuccess(re:ResultEvent){
		if(_successCallback != null)
			_successCallback(re.result);
	}
	
}