/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
class org.silex.ui.menu.ContextMenuItemWithKeyboardShortcut extends ContextMenuItem{
	//const
	static var F5_ASCII:Number = 116;
	var _keyCodeLc:Number = -1;
	var _keyCodeUc:Number = -1;
	var _withCtrlKey:Boolean = false;
	//key can be a number (ascii code) :  This is for example for F5, not a key, but ascii 116
	//or a character. "L".
	//if you need both cases, don't use the keycode, use the string
    public function ContextMenuItemWithKeyboardShortcut(caption:String, callbackFunction:Function, key:Object, withCtrlKey:Boolean)
    {
	    super(caption, callbackFunction, false, enabled, true);
		_withCtrlKey = withCtrlKey;
		if(typeof key == "string"){
			_keyCodeLc = key.toLowerCase().charCodeAt(0);
			_keyCodeUc = key.toUpperCase().charCodeAt(0);
		}else{
			_keyCodeLc = Number(key);
		}
        Key.addListener(this);
    }

    public function onKeyDown():Void
    {
		if(_withCtrlKey && !Key.isDown(Key.CONTROL)){
			return;
		}
		
		if(!_withCtrlKey && Key.isDown(Key.CONTROL)){
			return;
		}
		
		if(!enabled){
			return;
		}
		
        if((Key.getCode() == _keyCodeLc) || (Key.getCode() == _keyCodeUc))
        {
            onSelect();
        }
    }
	
}