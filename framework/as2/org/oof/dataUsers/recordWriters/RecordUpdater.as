/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This component is for updating records. The connector used needs to be able to write, and the 
 * only one that can at the moment is Database Connector. To update a record, call update.
 * This component has one extra field: idRecordString. Use this to set the id of the record
 * that will be updated.
 * 
* @author Ariel Sommeria-klein
 * */
import org.oof.dataUsers.RecordWriter;
import mx.utils.Delegate;


class org.oof.dataUsers.recordWriters.RecordUpdater extends RecordWriter{
	/**
	 * group: internal
	 * */
	 
	function RecordUpdater(){
		super();
		_className = "org.oof.dataUsers.recordWriters.RecordUpdater";
		typeArray.push(_className);
	}
	
	private var _idRecordString:String = null;
	/** function update
	* @returns  void
	*/
	function update() {
		_idRecord = parseInt(silexPtr.utils.revealAccessors(_idRecordString, this));
		_connector.updateRecord(Delegate.create(this, onSetRecordCallback), Delegate.create(this, onErrorCallback), _formName, getItem(), _idRecord);
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
