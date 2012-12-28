/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This component is for deleting records. The connector used needs to be able to write, and the 
 * only one that can at the moment is Database Connector. To delete a record, call del.
 * This component has one extra field: idRecordString. Use the idRecordString parameter
 * to set the id of the record that will be deleted.
 * 
* @author Ariel Sommeria-klein
 * */
import org.oof.DataIo;
import org.oof.OofBase;
import org.oof.DataUser;
import mx.utils.Delegate;
import org.oof.dataConnectors.IContentConnector;
import org.oof.DataContainer;

/////////////////////////////////////////
// events
// available for use in
// * ActionScript (event listeners or callbacks)
// * SILEX (commands)
/////////////////////////////////////////
[Event("onDeleteRecord")]
[Event("onError")]

class org.oof.dataUsers.RecordDeleter extends DataUser{
	
	/////////////////////////////////////////
	// public callback functions
	// corresponding to the events
	/////////////////////////////////////////
	/** 
	 * group: events/callbacks
	 * */
	var onDeleteRecord:Function;
	
	/**
	 * group: internal
	 * */
	private var _connector:IContentConnector = null;
	private var _formName:String = null;
	private var _idRecord:Number = undefined;
	private var _idRecordString:String = null;
	/////////////////////////////////////////
	// class methods
	/////////////////////////////////////////
	
	/**constructor
	*
	*/
	function RecordDeleter(){
		super();
		_className = "org.oof.dataUsers.recordWriters.RecordDeleter";
		typeArray.push(_className);
	}

	 /** function doOnConnectorFound
	*@returns void
	*/
	function doOnConnectorFound(oofComp:OofBase){
		super.doOnConnectorFound(oofComp);
		_connector = IContentConnector(oofComp);
	}


	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////
	/** onDeleteRecordCallback
	 * Called by the connector in return of a request to update or create a record. Passed as the callbackFunction parameter in a call to connector.updateRecord or createRecord
	 * Dispatch the onSetRecord event
	 *@params re	
	 */
	function onDeleteRecordCallback(){
			
		// dispatch the onDeleteRecord event
		dispatch({type:"onDeleteRecord",target:this});
		
		// call onDeleteRecord callback
		if (onDeleteRecord) onDeleteRecord();
	}
	/**
	 * group: public functions
	 * */
	 
	 
	/** function del (delete reserved keyword)
	* @returns  void
	*/
	public function del():Void {
		_idRecord = parseInt(silexPtr.utils.revealAccessors(_idRecordString, this));
		_connector.deleteRecord(Delegate.create(this, onDeleteRecordCallback), Delegate.create(this, onErrorCallback), _formName, _idRecord);
	}
	/**
	 * group: inspectable properties
	 * */
	 		
	/** property: formName
	 * this is the name of the table in the database.
	 * */
	
	[Inspectable(name="data feed", type=String, defaultValue="")]
	public function set formName(val:String){
		_formName = val;
	}
	
	public function get formName():String{
		return _formName;
	}	
	
	/** function set idRecordString
	* @param val(String)
	* @returns void
	*/
	
	[Inspectable(name="record id", type=String, defaultValue="")]
	public function set idRecordString(val:String){
		_idRecordString = val;
	}
	
	/** function get idRecordString
	* @returns String
	*/
	
	public function get idRecordString():String{
		return _idRecordString;
	}	
	

	
}
