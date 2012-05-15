/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import org.oof.DataIo;
import org.oof.DataUser;
import mx.utils.Delegate;
import org.oof.DataContainer;
import org.oof.dataConnectors.IContentConnector;

// tags to use (see http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00002497.html)
// [Inspectable(name="",defaultValue="",category="")]
// [Bindable]
// [ChangeEvent("change1", "change2", "change3")]
// 18x18 pixel icon: [IconFile("component_name.png")]

/* example of an item as seen by php:
(
    [0] => Array
        (
            [0] => address
            [1] => qsd
        )

    [1] => Array
        (
            [0] => title
            [1] => dddda 
        )

)

*/

/////////////////////////////////////////
// events
// available for use in
// * ActionScript (event listeners or callbacks)
// * SILEX (commands)
/////////////////////////////////////////
/**
 * Event : onSetRecord
 * */
[Event("onSetRecord")]
/**
 * Event : onError
 * */
[Event("onError")]
/**
 *  class: org.oof.dataUsers.RecordWriter
 * 
 * This is a base class for record creator and record updater. 
 * Both share the same functionality of gathering data and passing it to a connector.
 * you need to set the connector path, the inputs from which to gather data, and call
 * create on the record creator or update on the record updater.
 * example for "inputs"
 * if you have a field called "name" and another called "address" in your database, you can
 * call a textFieldIo "nameIo" and another "addressIo", and put the following in "inputs":
 * 
 * name=<<nameIo.value>>
 * 
 * address=<<addressIo.value>>
 * 
 * 
 * This is the reverse functionality to the DataSelector's "outputFormats".
 * 
* author:
 * 
 * author Ariel Sommeria-klein
 * */
class org.oof.dataUsers.RecordWriter extends DataUser{
	
	/////////////////////////////////////////
	// public callback functions
	// corresponding to the events
	/////////////////////////////////////////
	/**
	 * group: events/callbacks
	 * */
	var onSetRecord:Function;
	var onTestUniqueOk:Function;
	var onTestUniqueKo:Function;
	
	/////////////////////////////////////////
	// parameters
	// public attributes
	// parameters in Flash IDE
	// available properties in SILEX (=> editable in properties tool box)
	/////////////////////////////////////////
	
	/** 
	 * group: internal
	 * */
	/** _connector
	 * description
	 * data connector used by this selector
	 * 
	 */
	private var _connector:IContentConnector = null;
	private var _formName:String = null;
	private var _inputs:Array = null;
	private var _idRecord:Number = undefined;
	
	/////////////////////////////////////////
	// class methods
	/////////////////////////////////////////
	
	/**constructor
	*
	*/
	function RecordWriter(){
		super();
		_className = "org.oof.dataUsers.RecordWriter";
		typeArray.push(_className);
		_inputs = new Array();
	}

	 /** function doOnConnectorFound
	*@returns void
	*/
	function doOnConnectorFound(oofComp:OofBase){
		super.doOnConnectorFound(oofComp);
		_connector = IContentConnector(oofComp);
	}
	
	/** function getItem
	* @returns  Array
	-*/
	function getItem():Object {
		var item:Object = new Object();
		var len = _inputs.length;
		for(var i = 0; i < len; i++){
			var inputString = _inputs[i];
			//if the accessor is not right(component not instanciated, for example)
			//the accessor will resolve input to "". It will therefore not be included
			//in the item sent to the connector
			var input = silexPtr.utils.revealAccessors(inputString, this);
			
			if(input != ""){
				var delimiterPos = input.indexOf("=");
				var colName = input.substr(0, delimiterPos);
				var val = input.substr(delimiterPos + 1);
				item[colName] = val;
			}else{
			}
				
		}
		return item;
		
	}

	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////

	/** onSetRecordCallback
	 * Called by the connector in return of a request to update or create a record. Passed as the callbackFunction parameter in a call to connector.updateRecord or createRecord
	 * Dispatch the onSetRecord event
	 *@params re	
	 */
	function onSetRecordCallback(){
			
		// dispatch the onSetRecord event
		dispatch({type:"onSetRecord",target:this});
		
		// call onSetRecord callback
		if (onSetRecord) onSetRecord();
	}
	/** 
	 * group: public functions
	 * */

	
	/** function get idRecord
	 * once you have created or updated a record, you can get the id of the record here.
	* @returns Number
	*/
	public function get idRecord():Number{
		return _idRecord;
	}	
	
	
	/** 
	 * group: inspectable properties
	 * */	 	
	 
	/**
	 * property: inputs
	 * an array of fields that will be sent to the server. see summary for example.
	 * */
	[Inspectable(name = "inputs", type = Array)]
	public function set inputs(val:Array){
		_inputs = val;
	}

	
	public function get inputs():Array{
		return _inputs;
	}	

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
	
	
}
