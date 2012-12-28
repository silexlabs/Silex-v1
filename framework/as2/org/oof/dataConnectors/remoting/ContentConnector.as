/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This is a connector for the form webservice. Use with the DataSelector, RecordUpdater, RecordDeleter, and 
 * RecordCreator Components
 * .
* @author Ariel Sommeria-klein
 * */

import mx.remoting.Service;
import mx.remoting.PendingCall;
import mx.rpc.RelayResponder;
import mx.utils.Delegate;
import org.oof.dataConnectors.RemotingResponder;
import mx.services.Log;
import org.oof.dataConnectors.RemotingConnector;
import org.oof.dataConnectors.IContentConnector;

class org.oof.dataConnectors.remoting.ContentConnector extends RemotingConnector implements IContentConnector{

	function ContentConnector(){
		super();
		_className = "org.oof.dataConnectors.remoting.ContentConnector";
		typeArray.push(_className);
	}
	
	/** function getIndividualRecords. 
	*@return void
	*/
	function getIndividualRecords(successCallback:Function, errorCallback:Function, formName:String, ids:Array){
		var pc:PendingCall = _service.getIndividualRecords(formName, ids);
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
		
	}
	
	
	/** function updateRecord
	*@return void
	*/
	function updateRecord(successCallback:Function, errorCallback:Function, formName:String, item:Object, idRecord:Number){
		var pc:PendingCall = _service.updateRecord(formName, item, idRecord);
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
		
	}
	
	/** function deleteRecord
	*@return void
	*/
	function deleteRecord(successCallback:Function, errorCallback:Function, formName:String, idRecord:Number){
		var pc:PendingCall = _service.deleteRecord(formName, idRecord);
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
		
	}

	/** function createRecord
	*@return void
	*/
	function createRecord(successCallback:Function, errorCallback:Function, formName:String, item:Object){
		var pc:PendingCall = _service.createRecord(formName, item);
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
	}
	
	
	/** function getRecords. select data from a datasource
	*@return void
	*/
	function getRecords(successCallback:Function, errorCallback:Function, formName:String, selectedFieldNames:Array, whereClause:String, orderBy:String, count:Number, offset:Number){
		
		var pc:PendingCall = _service.getRecords(formName, selectedFieldNames, whereClause, orderBy, count, offset);
		var responderObj = new RemotingResponder(this, successCallback, errorCallback); 
		pc.responder = new RelayResponder(responderObj, EVENT_SUCCESS, EVENT_ERROR);
	}
	
	
/////////////////////////////////
//Property Accessors
/////////////////////////////////

	/** 
	 * property: serviceName
	 * the service that the connector will use to send email
	 * deerror: email_web_service
	 * */ 
	 
	 	//crappy AS2 way of defining a deerror value for an inspectable parameter defined in base class
		// don't do it! makes property inspector in silex fuck up!
/*	[Inspectable(type = String, defaultValue = "form_web_service")]
	public function set serviceName(val:String){
		super.serviceName = val;
	}
*/
	
}
