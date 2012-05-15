/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.dataIos.StringIo;
/** This component is a wrapper for the Flash text field. It's pretty limited, but functional for 
 * input and output of text. 
 * 
* @author Ariel Sommeria-klein
 * */
 class org.oof.dataIos.stringIos.TextFieldIo extends StringIo{
	static private var className:String = "org.oof.dataIos.stringIos.TextFieldIo";
	
	private var _textIsEditable:Boolean = false; 
	private var _useHtml:Boolean = false; 
	private var _keyListenerObj:Object = null;
	private var _loadFromUrl:Boolean = false;
	
	//ui
	var ioTextField:TextField;
	var stringHolder:String; //workaround so that html text works with textfield
	
	//callbacks
	var onEnter:Function = null;
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		if(_textIsEditable){
			ioTextField.type = "input";
			ioTextField.border = true;
		}else{
			ioTextField.type = "dynamic";
			ioTextField.border = false;
		}
		ioTextField.variable = "stringHolder";
		ioTextField.background = false;
		ioTextField.html = _useHtml;
		ioTextField.onSetFocus = Delegate.create(this, onTextSetFocus);
		ioTextField.onKillFocus = Delegate.create(this, onTextKillFocus);
		_keyListenerObj = new Object();
		Key.addListener(_keyListenerObj);
		
		size();
	}
	
	function onKeyPress(){
		if (Key.isDown(Key.ENTER)){
			if(onEnter) onEnter();
			dispatch({type:"onEnter"});
		}
			
	}
	
	function onTextSetFocus(){
		_keyListenerObj.onKeyDown = Delegate.create(this, onKeyPress);
	}
	
	function onTextKillFocus(){
		_keyListenerObj.onKeyDown = null;
		
	}
	
	/** private function getDataFromUi
	* get the data from the user interface. For example, if the dataIo is a text field, read the text field
	* @return Object
	*/
	private function getDataFromUi():Object{
		if(_useHtml){
			return ioTextField.htmlText;
		}else{
			return ioTextField.text;
		}
	}
	
	function loadVarsOnData(src:String){
		if (src != undefined) {
			stringHolder = src;
		}
	}
	/** private function setUiData
	* display the data on the user interface. For example, if the dataIo is a text field, set the text field value
	* @returns void
	*/
	private function setUiData(val:String){
		if(!_loadFromUrl){
			stringHolder = val;
		}else{
			var lorem_lv:LoadVars = new LoadVars();
			lorem_lv.onData = Delegate.create(this, loadVarsOnData);
			var url = buildUrl(val);
			lorem_lv.load(url);
		}
	}

	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
		
	/** function set loadFromUrl
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set loadFromUrl(val:Boolean){
		_loadFromUrl = val;
	}
	
	/** function get loadFromUrl
	* @returns Boolean
	*/
	
	public function get loadFromUrl():Boolean{
		return _loadFromUrl;
	}	
	
	/** function set textIsEditable
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set textIsEditable(val:Boolean){
		_textIsEditable = val;
	}
	
	/** function get textIsEditable
	* @returns Boolean
	*/
	
	public function get textIsEditable():Boolean{
		return _textIsEditable;
	}	
	
   public function size(){
		ioTextField._width = width;
		ioTextField._height = height;
	}
	
	/** function set autoSize
	* @param val(Object)
	* @returns void
	*/
	[Inspectable(name="auto size", type=Object, defaultValue="none", enumeration="none, left, right, center")]
	public function set autoSize(val:Object){
		ioTextField.autoSize = val;
	}
	
	/** function get autoSize
	* @returns Object
	*/
	
	public function get autoSize():Object{
		return ioTextField.autoSize;
	}	
	
	/** function set wordWrap
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="word wrap", type=Boolean, defaultValue=false)]
	public function set wordWrap(val:Boolean){
		ioTextField.wordWrap = val;
	}
	
	/** function get wordWrap
	* @returns Boolean
	*/
	
	public function get wordWrap():Boolean{
		return ioTextField.wordWrap;
	}	
	
	/** function set useHtml
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type=Boolean, type=Boolean, defaultValue=false)]
	public function set useHtml(val:Boolean){
		_useHtml = val;
	}
	
	/** function get useHtml
	* @returns Boolean
	*/
	
	public function get useHtml():Boolean{
		return _useHtml;
	}	
	
	
}