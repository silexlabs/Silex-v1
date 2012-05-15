/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/


import org.oof.dataIos.stringIos.TextFieldIo;
import mx.utils.Delegate;
/** This component is a text field io, but checks and limits what a user inputs. 
 * Quite limited, but useful in some cases. Maybe a RegExp engine would be useful here.
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.stringIos.LimitedTextFieldIo extends TextFieldIo{
	static private var className:String = " org.oof.dataIos.stringIos.LimitedTextFieldIo";
	private var _forbidUpperCase:Boolean = false;
	private var _forbidSpaces:Boolean = false;

	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		ioTextField.onChanged = Delegate.create(this, limitInputChars);
	 }
	 
	 function limitInputChars() {
		 var text:String = ioTextField.text;
		 var lastChar:String = text.charAt(text.length - 1);
		 if (_forbidUpperCase) {
			 if (lastChar != lastChar.toLowerCase()) {
				 lastChar = lastChar.toLowerCase();
				 ioTextField.text = text.substr(0, text.length - 1) + lastChar;
			 }
		 }
		 
		 if (_forbidSpaces) {
			 if (lastChar == " ") {
				 ioTextField.text = text.substr(0, text.length - 1);
			 }
		 }
		 
	 }
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////

	/** function set forbidUpperCase
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="forbid upper case", type=Boolean, defaultValue=false)]
	public function set forbidUpperCase(val:Boolean){
		_forbidUpperCase = val;
	}
	
	/** function get forbidUpperCase
	* @returns Boolean
	*/
	
	public function get forbidUpperCase():Boolean{
		return _forbidUpperCase;
	}	
	
	/** function set forbidSpaces
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="forbid spaces", type=Boolean, defaultValue=false)]
	public function set forbidSpaces(val:Boolean){
		_forbidSpaces = val;
	}
	
	/** function get forbidSpaces
	* @returns Boolean
	*/
	
	public function get forbidSpaces():Boolean{
		return _forbidSpaces;
	}	
	
	
}