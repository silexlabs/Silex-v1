/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.dataIos.StringIo;
/** This component is a place holder for a Number. This is probably obsolete.
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.numberIos.HiddenNumberIo extends StringIo{
	static private var className:String = "org.oof.dataIos.numberIos.HiddenNumberIo";
	
	private var _hiddenValue:Number;
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
	 }
	
	/** private function getDataFromUi
	* get the data from the user interface. For example, if the dataIo is a text field, read the text field
	* @return Number
	*/
	private function getDataFromUi():Number{
		return _hiddenValue;
	}
	
	/** private function setUiData
	* display the data on the user interface. For example, if the dataIo is a text field, set the text field value
	* @returns void
	*/
	private function setUiData(val:Number){
		_hiddenValue = val;
	}

	
	
}