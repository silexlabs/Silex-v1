/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.OofBase; 
import org.oof.lists.cellRenderers.CellRendererBase; 
/**
 * companion cell renderer to the media list. probably obsolete too.
* @author Ariel Sommeria-klein
 * */

class org.oof.lists.cellRenderers.MediaCellRenderer extends CellRendererBase{
	
	// UI
	var container:MovieClip;

	function MediaCellRenderer(){
		super();
		container.play_btn.onPress = Delegate.create(this,onPressCallback);
		container.play_btn.onRelease = Delegate.create(this,onReleaseCallback);
		container.play_btn.onReleaseOutside = Delegate.create(this,onReleaseOutsideCallback);
		container.play_btn.useHandCursor = false;

	}
	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height

	function setValue(str:String, item:Object, sel:Boolean) : Void{
		super.setValue(str, item, sel);
		// display data
		container.label1.text = str;
		container.label2.text = OofBase.getObjAtPath(item.data, listOwner.label2FieldPath);


	
		if(listOwner.useVariableRowHeight){
			if(!listOwner.isHorizontal){
				var newVal = container._height + _cellMarginY * 2;
				setSize(width, newVal);		
			}else{
				var newVal = container._width + _cellMarginX * 2;
				setSize(newVal, height);		
			}
		}
	}

	function redraw()
	{
		super.redraw();
		container._x = Math.round((_width - container._width) / 2);
		container._y = Math.round((_height - container._height) / 2);
	}
}