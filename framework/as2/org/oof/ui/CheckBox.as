/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.utils.Delegate;
/** this is an oof checkbox. With it you can toggle a property on another oof component. The property must be a boolean(true or false) 
 * @author Ariel Sommeria-klein
 * */
class org.oof.ui.CheckBox extends OofBase{
	/**
	 * group: events/callbacks
	 * */
	public static var ON_CHECKED:String = "onChecked";
	public static var ON_UNCHECKED:String = "onUnchecked";
	public static var ON_RELEASE:String = "onRelease";
	
	/** 
	 * group: internal 
	 * */
	private var _checked:Boolean = false;
	
	public function CheckBox(){
		_className = "org.oof.ui.CheckBox";
		typeArray.push("org.oof.ui.CheckBox");
	}/** 
	 * group: visual elements
	 * */
	
	var clipToShowWhenChecked:MovieClip;
	var clipToShowWhenUnchecked:MovieClip;
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tabChildren = true;
		updateUi();
	}
	
	private function updateUi():Void{
		clipToShowWhenChecked._visible = _checked;
		clipToShowWhenUnchecked._visible = !_checked;
	}
	
	private function onRelease():Void{
		_checked = !_checked;
		updateUi();		
		
		if(_checked){
			dispatch({type:ON_CHECKED, target:this});
		}else{
			dispatch({type:ON_UNCHECKED, target:this});
			
		}
		dispatch({type:ON_RELEASE, target:this});
		
	}
	
	/** 
	 * group: public functions and properties. 
	 * */ 
	public function get checked():Boolean{
		return _checked;
	}
	
	public function set checked(value:Boolean):Void{
		if(_checked != value){
			_checked = value;
			updateUi();
		}
	}	
}