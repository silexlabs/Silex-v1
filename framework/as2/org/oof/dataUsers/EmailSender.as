/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import org.oof.DataUser;
import mx.utils.Delegate;
import org.oof.dataConnectors.remoting.EmailConnector;
import org.oof.dataIos.stringIos.TextFieldIo;
/** This component is for sending emails. The connector used must be the email connector.
 * configure the connector path(see DataUser), configure the server (OofMail.ini, in 
 * the /conf/ directory), configure the different fields( from, to, body, etc.)
 * and call sendMail.
 * You can then notify the user that the mail was called successfully when you catch
 * the "onSendMailSuccess" event.
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataUsers.EmailSender extends DataUser{
	/**
	 * group: Internal
	 * */
	 
	static private var className:String = "org.oof.dataUsers.Email";
	
	private var _subject:String = null;
	private var _body:String = null;
	private var _from:String = null;
	private var _to:String = null;
	private var _cc:String = null;
	private var _bcc:String = null;
	private var _connector:EmailConnector = null;

	/**
	 * group: Events/Callbacks
	 * */
	var onSendMailSuccess:Function = null;
	
	/**
	 * group: Internal
	 * */
	
	 /** function doOnConnectorFound
	*@returns void
	*/
	function doOnConnectorFound(oofComp:OofBase){
		super.doOnConnectorFound(oofComp);
		_connector = EmailConnector(oofComp);
	}

	/**
	 * group: public functions
	 * */
	
	/** function sendMail
	 */
	function sendMail(){
		var subject = silexPtr.utils.revealAccessors (_subject,this);
		var body = silexPtr.utils.revealAccessors (_body,this);
		var from = silexPtr.utils.revealAccessors (_from,this);
		var to = silexPtr.utils.revealAccessors (_to,this);
		var cc = silexPtr.utils.revealAccessors (_cc,this);
		var bcc = silexPtr.utils.revealAccessors (_bcc,this);
	 	_connector.sendMail(Delegate.create(this, onSendMailCallback), Delegate.create(this, onErrorCallback), subject, body, from, to, cc, bcc); 
	}

	/**
	 * group: Internal
	 * */	 
	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////

	/** function onSendMailCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the sendMailSuccess event
	*/
	function onSendMailCallback(){
		// dispatch the loginSuccess event
		dispatch({type:"sendMailSuccess",target:this});
		// call onLoginSuccess callback
		if (onSendMailSuccess) onSendMailSuccess();
			
	}
	/**
	 * group: inspectable properties
	 * */	
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	/** function set subject
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type = String)]
	public function set subject(val:String){
		_subject = val;
	}
	
	/** function get subject
	* @returns String
	*/
	
	public function get subject():String{
		return _subject;
	}		

	/** function set body
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type = String)]
	public function set body(val:String){
		_body = val;
	}
	
	/** function get body
	* @returns String
	*/
	
	public function get body():String{
		return _body;
	}		
	
	/** function set from
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type = String)]
	public function set from(val:String){
		_from = val;
	}
	
	/** function get from
	* @returns String
	*/
	
	public function get from():String{
		return _from;
	}		

	/** function set to
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type = String)]
	public function set to(val:String){
		_to = val;
	}
	
	/** function get to
	* @returns String
	*/
	
	public function get to():String{
		return _to;
	}		

	/** function set cc
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type = String)]
	public function set cc(val:String){
		_cc = val;
	}
	
	/** function get cc
	* @returns String
	*/
	
	public function get cc():String{
		return _cc;
	}		

	/** function set bcc
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type = String)]
	public function set bcc(val:String){
		_bcc = val;
	}
	
	/** function get bcc
	* @returns String
	*/
	
	public function get bcc():String{
		return _bcc;
	}		

}