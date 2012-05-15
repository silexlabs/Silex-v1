/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.utils.Delegate;
import org.oof.DataContainer;
/**
 * base class for all data users.
 * this is the glue between a connector and inputs/outputs. 
 * all datausers use a connector, so here you find the connector path.
 * all datausers can store their data internally, or use a data container, so 
 * here you find resultContainer.
 * 
 * @author Ariel Sommeria-klein
 * 
 * */
 
[Event("onConnectorFound")]
class org.oof.DataUser extends OofBase{
	/**
	 * group: events/callbacks
	 * */
	 
	/** event: onError
	 * all data users share the onError event.
	 * */ 
	var onError:Function = null;
	/** 
	 * group: internal 
	 * */
	private static var FIELD_ID:String = "id";
	 
	 //path to the connector. Don't declare connector here, but in derived class, so as to give connector a stronger type
	private var _connectorPath:String = null;
	private var _resultContainerPath:String = null;
	private var _resultContainer:Object;
	private var _error:String = null;

	public function DataUser()
	{
		typeArray.push("org.oof.DataUser");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	public function _initAfterRegister(){
		super._initAfterRegister();
		_resultContainer = new Object(); ///used if _resultContainer not set, or container not found
		var splitted = _resultContainerPath.split(".");
		tryToLinkWith(splitted[0], Delegate.create(this, doOnResultContainerFound));
		tryToLinkWith(_connectorPath, Delegate.create(this, doOnConnectorFound));
	
	}
	
	 /** function doOnResultContainerFound
	*@returns void
	*/
	function doOnResultContainerFound(oofComp:OofBase){
		var objName = _resultContainerPath.split(".")[1];
		if(objName != null){
			var container = DataContainer(oofComp);
			_resultContainer = container.getContainer(objName);
		}
	}
	
	 /** function doOnConnectorFound. set connector by casting oofcomp in derived class
	*@returns void
	*/
	function doOnConnectorFound(oofComp:OofBase){
		//don't dispatch onConnectorFound event here! 
		//derived class has not finished its doOnConnectorFound, so it can have some unbalanced effects
		
	}
	
	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////

	/** function onErrorCallback
	*@returns void
	* dispatch the loginError event with the event object's error property set to the error description
	*/
	function onErrorCallback(errorString:String){
		_error = errorString;
		dispatch({type:"onError",target:this,error:errorString});
		dispatch({type:errorString,target:this});
		// call onError callback
		if (onError) onError();
	}
	/** 
	 * group: public functions and properties. 
	 * */ 
	
	/** 
	 * property: error
	 * the last error received by the data user
	 * */ 	
	 public function get error():String{
		 return _error;
	 }
		 
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** 
	 * group: inspectable properties
	 * */

	/** 
	 * property: connectorPath
	 * the path to a connector. The data user uses the connector to read
	 * and write data from/to a source. 
	 * */	 
	[Inspectable(type=String, defaultValue="connector")]
	public function set connectorPath(val:String){
		_connectorPath = val;
	}

	
	public function get connectorPath():String{
		return _connectorPath;
	}	
	
	/** 
	 * property: resultContainerPath
	 * the path to a data container.
	 * if this is left empty, the data user will store data 
	 * internally. otherwise it will store data here
	 *  
	 * */	 
	[Inspectable(type=String,defaultValue="",category="parameters")]
	function set resultContainerPath(val:String){
		_resultContainerPath = val;
	}	
	
	function get resultContainerPath():String{
		return _resultContainerPath;
	}
}
