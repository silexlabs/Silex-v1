/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** a companion cell renderer for the rich text list, much like
 * the rich text cell renderer, except that the behavior is different.
 * If you use this renderer, clicking on an item toggles it 
 * instead of selecting it and deselecting the previous one.
 * This is useful when you want to propose multiple selection.
 * @author Ariel Sommeria-klein
 * */
import mx.utils.Delegate;
import org.oof.lists.cellRenderers.RichTextCellRenderer; 

class org.oof.lists.cellRenderers.ToggleCellRenderer extends RichTextCellRenderer{
	
	// UI
	var selectedMc:MovieClip;
	var notSelectedMc:MovieClip;

	function setValue(str:String, item:Object, sel:Boolean) : Void{
		super.setValue(str, item, sel);	
		_isSelected = sel;
		redraw();
	}
	
	function redraw(){
		super.redraw();
		if(_isSelected){
			selectedMc._visible = true;
			notSelectedMc._visible = false;
		}else{
			selectedMc._visible = false;
			notSelectedMc._visible = true;
		}
	}
	
	function onReleaseCallback() {
		//don't call super.onReleaseCallback!
		if(listOwner.multipleSelection){
			var indices = listOwner.selectedIndices;
			if (_isSelected) {
				//remove from indices
				var len = indices.length;
				var index = getOneDimIndex();
				for(var i = 0; i < len; i++){
					if(indices[i] == index){
						indices.splice(i, 1);
						break;
					}
				}
			}else{
				indices.push(getOneDimIndex());
			}
			//explicitly call the setter function, otherwise its code won't be called
			listOwner.selectedIndices = indices;
		}else{
			if (_isSelected) {
				//toggle off
				listOwner.selectedIndex = undefined;
			}else {
				listOwner.selectedIndex = getOneDimIndex();
			}
		}
		redraw();
	}
	

}