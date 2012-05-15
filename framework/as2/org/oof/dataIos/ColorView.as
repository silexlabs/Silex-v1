/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.DataIo;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import mx.utils.Delegate;
import flash.geom.*;

/** This is the the class for a simple color viewer
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.ColorView extends DataIo{
	private var _colorViewer:MovieClip;
	private var _colorHexText:TextField;
	private var _colorCode:Number = 0xFFFFFF;
	
	var COLOR_VIEWER_SQUARE_DIM:Number = 32; //no const?
	/**
	 * group: internal
	 * */
	
	public function ColorView(){
		super();
		
		_className = "org.oof.dataIos.ColorView"; 
		typeArray.push(_className);
		
		_colorViewer = this.createEmptyMovieClip("_colorViewer", this.getNextHighestDepth());
		_colorViewer._x = 0;
		_colorViewer._y = 0;
	}

	private function setColorViewerColor(viewer:MovieClip, tf:TextField, color:Number){
		var bitmapData:BitmapData = new BitmapData(COLOR_VIEWER_SQUARE_DIM, COLOR_VIEWER_SQUARE_DIM, false, color);
		tf.text = parseColorCodeToString(color);
		viewer.attachBitmap(bitmapData, this.getNextHighestDepth());
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister():Void{
		super._initAfterRegister();
		_colorViewer.onRelease = Delegate.create(this, onObjRelease);
		value = "000000";
	}
	 
	/**
	*function parseColorCodeToString
	* parses from int to hex, with padding, and converts to uppercase
	*@returns String
	*/
	private function parseColorCodeToString(code:Number):String{
		var res_str:String = code.toString(16);
		while(res_str.length < 6){
			res_str = "0" + res_str;
		}
		return res_str.toUpperCase();
	}
	
	private function onObjRelease():Void{
		this.dispatch({type: "onRelease", target:this });
	}
	
	/**
	 * group: public
	 * */
	 
	/** function get value
	*  simply retrieve the data from ui, without the field name.  see dataIo
	* @returns String. 
	*/
	
	function get value():String{
		return parseColorCodeToString(_colorCode);
	}
	
	/** function set value 
	*  simply set the data from ui, without the field name. see dataIo
	* @returns void 
	*/
	
	function set value(val:String):Void{
		if((val == null) || (val == undefined)){
			val = "FFFFFF";
		}
		_colorCode = parseInt(val, 16);
		this.dispatch({type: "onChanged", target:this });
		setColorViewerColor(_colorViewer, _colorHexText, _colorCode);		
		
	}


}