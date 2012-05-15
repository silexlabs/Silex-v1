/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This component is for creating records. The connector used needs to be able to write, and the 
 * only one that can at the moment is Database Connecgrustor. see also record writer.
 * 
* @author Ariel Sommeria-klein
 * */
import org.oof.dataUsers.RecordWriter;
import mx.utils.Delegate;
import org.oof.OofBase;


class org.oof.dataUsers.recordWriters.RecordCreator extends RecordWriter{
	/**
	 * group: internal
	 * */
	function RecordCreator(){
		super();
		_className = "org.oof.dataUsers.recordWriters.RecordCreator";
		typeArray.push(_className);
	}
	
	
	/** onSetRecordCallback
	 * Called by the connector in return of a request to update or create a record. Passed as the callbackFunction parameter in a call to connector.updateRecord or createRecord
	 * Dispatch the onSetRecord event
	 *@params re	
	 */
	function onSetRecordCallback(re:Object){
		_idRecord = Number(re);
		super.onSetRecordCallback(re);
	}
	/**
	 * group: public functions
	 * */
	 	
	/** function create
	* @returns  void
	*/
	function create() {
		_connector.createRecord(Delegate.create(this, onSetRecordCallback), Delegate.create(this, onErrorCallback), _formName,  getItem());
	}
	
	function doOnConnectorFound(oofComp:OofBase){
		super.doOnConnectorFound(oofComp);
		//create();
	}
		
}
