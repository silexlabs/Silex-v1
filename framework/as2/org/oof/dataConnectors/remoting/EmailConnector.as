/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This is a connector for the email webservice. Use with Email Sender.
* @author Ariel Sommeria-klein
 * */
import mx.utils.Delegate;
import org.oof.dataConnectors.RemotingResponder;
import mx.remoting.PendingCall;
import mx.rpc.RelayResponder;
import org.oof.dataConnectors.RemotingConnector;

class org.oof.dataConnectors.remoting.EmailConnector extends RemotingConnector{
	function EmailConnector(){
		super();
		_className = "org.oof.dataConnectors.remoting.EmailConnector";
		typeArray.push(_className);
	}	
	/** function sendMail
	*@return void
	*/
	function sendMail(successCallback:Function, errorCallback:Function, subject:String, body:String, from:String, to:String, cc:String, bcc:String){
		var pc:PendingCall = _service.sendMail(subject, body, from, to, cc, bcc);
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
		
	}
	/** 
	 * property: serviceName
	 * the service that the connector will use to send email
	 * deerror: email_web_service
	 * */ 
	 
	 	//crappy AS2 way of defining a deerror value for an inspectable parameter defined in base class
		// don't do it! makes property inspector in silex fuck up!
/*	[Inspectable(type = String, defaultValue = "email_web_service")]
	public function set serviceName(val:String){
		super.serviceName = val;
	}
*/
}