/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This is a connector for the login webservice. Use with the Login Component.
* @author Ariel Sommeria-klein
 * */
import mx.remoting.*;
import mx.rpc.*;
import mx.utils.Delegate;
import org.oof.dataConnectors.RemotingResponder;
import org.oof.dataConnectors.RemotingConnector;
class org.oof.dataConnectors.remoting.LoginConnector extends RemotingConnector
{
	/**Group: Internal
	 * */
	 
	
	public function LoginConnector(){
		super();
		_className = "org.oof.dataConnectors.remoting.LoginConnector";
		typeArray.push(_className);
	}
	
	/**Group: Public
	 * */
	 
	/** 
	 * function: login
	 * logs in. called by login component
	 * */	
	function login(successCallback:Function, errorCallback:Function, pseudo:String, password:String)
	{
		_service.connection.setCredentials(pseudo, password);
		var pc:PendingCall = _service.login();
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
	}
		

	/** 
	 * function: logout
	 * logs out. called by login component
	 * */	
	function logout(successCallback:Function, errorCallback:Function)
	{	
		//only way I found to properly reset credentials before asking for logout. 
		//if not this, _authenticate is called by server
		_service = new Service(_gatewayUrl, null, _serviceName );
		var pc:PendingCall = _service.logout();
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
	}
	
	 	//crappy AS2 way of defining a deerror value for an inspectable parameter defined in base class
		// don't do it! makes property inspector in silex fuck up!
/*	[Inspectable(type = String, defaultValue = "login_web_service")]
	public function set serviceName(val:String){
		super.serviceName = val;
	}
*/
}
