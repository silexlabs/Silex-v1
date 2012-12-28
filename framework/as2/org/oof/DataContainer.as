/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
/** this is a component to store dynamic data. Use this to hold data for a data selector, for example.
 * You can inspect its contents by using a data container viewer.
 * @author Ariel Sommeria-klein
 * */
class org.oof.DataContainer extends OofBase {
	
	private var _dataNames:Array = null;
	
	public function DataContainer(){
		typeArray.push("org.oof.DataContainer");
	}
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
	 	super._initAfterRegister();
		for (var i = 0; i < _dataNames.length; i++) {
			this[_dataNames[i]] = new Object();
		}
		
	 }
	
	/**
	* get pointer to container object. if it doesn't exist yet, create it and add it to _dataNames
	*/
	function getContainer(objName:String){
		if(objName == null){
			return null;
		}
		if(this[objName] == undefined){
			dataNames.push(objName);
			this[objName] = new Object();
		}
		return this[objName];
		 
	 }
	 
	/** function set dataNames
	* @param val(Array)
	* @returns void
	*/
	[Inspectable(name="data names", type=Array, defaultValue="")]
	public function set dataNames(val:Array){
		_dataNames = val;
	}
	
	/** function get dataNames
	* @returns Array
	*/
	
	public function get dataNames():Array{
		return _dataNames;
	}	
	 
}