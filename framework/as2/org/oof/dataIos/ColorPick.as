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

/** This is the the class for 2 objects: the full color picker, which includes the palette, the preview color and the selected color
* and a simple color viewer, which is just the selected color viewer(the other objects are undefined)
* the class also includes code for text fields, but it is unused at the moment
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.ColorPick extends DataIo{
	private var _palette:MovieClip;
	private var _paletteBitmapData:BitmapData;
	private var _previewColorViewer:MovieClip;
	private var _selectedColorViewer:MovieClip;
	private var _previewColorHexText:TextField;
	private var _selectedColorHexText:TextField;
	private var _selectedColorCode:Number = 0xFFFFFF;
	
	var COLOR_VIEWER_SQUARE_DIM:Number = 61.9; //no const?
	var COLOR_VIEWER_SQUARE_DIM_ALONE:Number = 32; //no const?
	/**
	 * group: internal
	 * */
	
	public function ColorPick(){
		super();
		
		_className = "org.oof.dataIos.ColorPick"; 
		typeArray.push(_className);
		
		//code to generate palette. use bitmap resource for now
		/*
		_palette = this.createEmptyMovieClip("_palette", this.getNextHighestDepth());
		_paletteBitmapData = new BitmapData(100, 80, false, 0x00CCCCCC);
		_paletteBitmapData.colorTransform(_paletteBitmapData.rectangle, new ColorTransform(1, 0, 0, 1, 255, 0, 0, 0));
		_palette.attachBitmap(_paletteBitmapData, this.getNextHighestDepth());
		*/
		_previewColorViewer = this.createEmptyMovieClip("_previewColorViewer", this.getNextHighestDepth());
		_previewColorViewer._x = 541.6;
		_previewColorViewer._y = 0;
		
		_selectedColorViewer = this.createEmptyMovieClip("_selectedColorViewer", this.getNextHighestDepth());
		_selectedColorViewer._x = 541.6;
		_selectedColorViewer._y = 162.4;
/*
		var previewTitle:TextField = createTextField("previewTitle", this.getNextHighestDepth(), _palette._width + 100, 0, 100, 20);
		previewTitle.text = "preview color";
		
		createTextField("_previewColorHexText", this.getNextHighestDepth(), _palette._width + 100, 20, 100, 20);
		_previewColorHexText.border = true;
	
		var selectedTitle:TextField = createTextField("selectedTitle", this.getNextHighestDepth(), _palette._width + 100, 70, 100, 20);
		selectedTitle.text = "selected color";
		
		createTextField("_selectedColorHexText", this.getNextHighestDepth(), _palette._width + 100, 90, 100, 20);
		_selectedColorHexText.type = "input";
		_selectedColorHexText.border = true;
		_selectedColorHexText.onChanged = Delegate.create(this, onSelectedColorHexTextChanged);
		
		_palette.onRollOver = Delegate.create(this, onPaletteRollOver);
		_palette.onRollOut = Delegate.create(this, onPaletteRollOut);
		_previewColorHexText.text = "preview";
		_selectedColorHexText.text = "selected";
*/		
	}
	private function onPaletteRollOver():Void {
		_palette.onMouseDown = Delegate.create(this, onPaletteMouseDown);
		_palette.onMouseMove = Delegate.create(this, onPaletteMouseMove);
	}
	
	private function setColorViewerColor(viewer:MovieClip, tf:TextField, color:Number){
		var bitmapData:BitmapData = new BitmapData(COLOR_VIEWER_SQUARE_DIM, COLOR_VIEWER_SQUARE_DIM, false, color);
		tf.text = parseColorCodeToString(color);
		viewer.attachBitmap(bitmapData, this.getNextHighestDepth());
	}
	
	private function onPaletteRollOut():Void {
		_palette.onMouseDown = null;
		_palette.onMouseMove = null;
		
	}
	
	private function onSelectedColorHexTextChanged():Void{
		value = _selectedColorHexText.text;
	}
	
	function takeSnapshot(mc:MovieClip):BitmapData {
		var sp:BitmapData = new BitmapData(mc._width, mc._height, true, 0x000000);
		sp.draw(mc, new Matrix(), new ColorTransform(), "normal");
		return sp;
	
	}
	

	private function onPaletteMouseMove():Void {
		setColorViewerColor(_previewColorViewer, _previewColorHexText, getColorHexCodeFromPalette());
	}

	private function onPaletteMouseDown():Void {
		var colorCode:Number = getColorHexCodeFromPalette();
		setColorViewerColor(_selectedColorViewer, _selectedColorHexText, colorCode);
		_selectedColorCode = colorCode;
		this.dispatch({type: "onChanged", target:this });
	}

	private function getColorHexCodeFromPalette():Number{
		return _paletteBitmapData.getPixel(_palette._xmouse, _palette._ymouse);
	}

	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister():Void{
		super._initAfterRegister();
		_paletteBitmapData = takeSnapshot(_palette);
		_palette.onRollOver = Delegate.create(this, onPaletteRollOver);
		_palette.onRollOut = Delegate.create(this, onPaletteRollOut);
		_previewColorViewer.onRelease = Delegate.create(this, onObjRelease);
		_selectedColorViewer.onRelease = Delegate.create(this, onObjRelease);
		_palette.onRelease = Delegate.create(this, onObjRelease);
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
		return parseColorCodeToString(_selectedColorCode);
	}
	
	/** function set value 
	*  simply set the data from ui, without the field name. see dataIo
	* @returns void 
	*/
	
	function set value(val:String):Void{
		if((val == null) || (val == undefined)){
			val = "FFFFFF";
		}
		_selectedColorCode = parseInt(val, 16);
		this.dispatch({type: "onChanged", target:this });
		setColorViewerColor(_selectedColorViewer, _selectedColorHexText, _selectedColorCode);	
		
	}


}