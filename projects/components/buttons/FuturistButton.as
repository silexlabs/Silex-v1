/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.core.Utils;
class FuturistButton extends org.silex.ui.components.buttons.ButtonBase {
	
	function  set width(num:Number) {
		redraw();
	}
	function  get width() {
		return bg_mc._width;
	}
	function  set height(num:Number) {
		redraw();
	}
	function  get height() {
		return bg_mc._height;
	}
	public function set rotation( rotationNumber:Number):Void{
	}
	
	public function get rotation():Number{
		return 0;
	}

	
	var _buttonLabel:String="default label";
	function get buttonLabel():String {
		return _buttonLabel;
	}
	function set buttonLabel (_str:String) {
		_buttonLabel=_str;
		redraw();
	}
	
	/**
	 * function redraw
	 * @return void
	 */
	function redraw(){
		super.redraw();

		//silexInstance.utils.trace("components.buttons.SimpleButtonWithText redraw - "+bg_mc+" - "+bg_mc.animText_mc+" - "+bg_mc.animText_mc._width);
		bg_mc.bg_mc._width=bg_mc.animText_mc.title_mc._width;
		bg_mc.bg_mc._height=bg_mc.animText_mc.title_mc._height;
	}

	function _initialize() {
		super._initialize()
		//editableProperties
		this.editableProperties.unshift(
			{ name :"buttonLabel" ,		description:"label", 				type: silexInstance.config.PROPERTIES_TYPE_TEXT		, defaultValue: "label"	, isRegistered:true,group:"attributes" }
		);
		redraw();
	}
	/**
	 * selectIcon
	 * called by openIcon and core.application::openSection
	 * to be overriden by sub classes - mark the media as selected?
	 */ 
	function selectIcon(isSelected:Boolean){
		bg_mc.gotoAndStop("out");
	}
	
	function _onRollOver():Void{
		super._onRollOver();
		bg_mc.gotoAndStop("over");
	}
	function _onRollOut():Void{
		super._onRollOut();
		bg_mc.gotoAndStop("out");
	}
}
