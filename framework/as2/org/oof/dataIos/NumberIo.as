/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.DataIo;

/** This is the base class is for input and output of numbers. a bit like a stringio, except that it does some 
 * type checking and conversion.
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.NumberIo extends DataIo{
	static private var className:String = "org.oof.dataIos.NumberIo";
	private var _possibleFieldPaths:Array;
	private var _fieldPath:String;
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		_fieldPath = _possibleFieldPaths[0];

	 }
	/** private function getDataFromUi
	* get the data from the user interface. For example, if the dataIo is a text field, read the text field
	* @return Number
	*/
	private function getDataFromUi():Number{
		throw new Error(this + " getDataFromUi not implemented");
		return null;
	}
	
	/** private function setUiData
	* display the data on the user interface. For example, if the dataIo is a text field, set the text field value
	* @returns void
	*/
	private function setUiData(val:Number){
		throw new Error(this + " setUiData not implemented");
		return null;
	}
	
	/** function get value
	*  simply retrieve the data from ui, without the field name. 
	* @returns Number. 
	*/
	
	function get value():Number{
		return getDataFromUi();
		
	}
	
	/** function set value
	*  simply set the data from ui, without the field name. 
	* @returns void 
	*/
	
	function set value(val:Object){
			if(typeof val == "string"){
				setUiData(parseInt(String(val)));
			}else if(typeof val == "number"){
				setUiData(Number(val));
			}else{
				setUiData(-1);
			}
		
	}
	
	
	/** function set possibleFieldPaths
	* @param val(Array)
	* @returns void
	*/
	[Inspectable(name="field path", type=Array, defaultValue="")]
	public function set possibleFieldPaths(val:Array){
		_possibleFieldPaths = val;
	}
	
	/** function get possibleFieldPaths
	* @returns Array
	*/
	
	public function get possibleFieldPaths():Array{
		return _possibleFieldPaths;
	}	

}