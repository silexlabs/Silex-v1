/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.DataIo;
/** This is the base class is for the input and output of strings.
 * It adds url building functionality(see urlPrefix, below). 
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.StringIo extends DataIo{
	
	/**
	 * group: internal
	 * */
	private var _possibleFieldPaths:Array;
	private var _fieldPath:String = null;
	private var _urlPrefix:String = null;
	private var _fullUrl:String = null;
	
	public function StringIo(){
		super();
		_className = "org.oof.dataIos.StringIo"; 
		typeArray.push(_className);
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
		super._initAfterRegister();
		_fieldPath = _possibleFieldPaths[0];

	 }
	 
	private function buildUrl(val:String){
		if((val != null) && (val != '')){
		// + "?" + Math.random() used to get a fresh copy, not load from cache
			_fullUrl = silexPtr.utils.revealAccessors (_urlPrefix, this) + val; // + "?" + Math.random();
			return fullUrl;
		}else{
			return null;
		}
	}
	
	 
	/** private function getDataFromUi
	* get the data from the user interface. For example, if the dataIo is a text field, read the text field
	* @return String
	*/
	private function getDataFromUi():String{
		throw new Error(this + " getDataFromUi not implemented");
		return null;
	}
	
	/** private function setUiData
	* display the data on the user interface. For example, if the dataIo is a text field, set the text field value
	* @returns void
	*/
	private function setUiData(val:String){
		throw new Error(this + " setUiData not implemented");
		return null;
	}
	
	/**
	 * group: public
	 * */
	 
	/** function get value
	*  simply retrieve the data from ui, without the field name.  see dataIo
	* @returns String. 
	*/
	
	function get value():String{
		return getDataFromUi();
		
	}
	
	/** function set value 
	*  simply set the data from ui, without the field name. see dataIo
	* @returns void 
	*/
	
	function set value(val:String){
		if((val == null) || (val == undefined)){
			val = "";
		}
		setUiData(val);
		
	}

	/** 
	 * property: urlPrefix
	 * a prefix for loading data from an url. 
	 * For example if your display has to play
	 * a media that is at http://youserver.com/media/test.jpg, but the value that is 
	 * passed is test.jpg, set urlPrefix to http://youserver.com/media/
	 * */
	[Inspectable(name="url base", type=String, defaultValue="")]
	public function set urlPrefix(val:String){
		_urlPrefix = val;
	}
	
	public function get urlPrefix():String{
		return _urlPrefix;
	}		

	/** 
	 * property: fullUrl
	 * the whole url : urlPrefix + value
	 * */
	public function get fullUrl():String{
		return _fullUrl;
	}
		


}