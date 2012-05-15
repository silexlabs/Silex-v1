/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.lists.CustomList;
import mx.events.EventDispatcher;
/** This list is for a slide menu.
 * 
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * @author Alexandre Hoyau
 * */
class org.oof.lists.SlideMenu extends org.oof.lists.CustomList{
	var listBox:MovieClip;
	
	 /** function called when item clicked.
	 * NOTE: the component has been modified to have the following lines
 	this.ICO.onRelease = function() {
		this._parent._parent._parent.chooseItemCallback(this.index);
	};
	*/
	public function SlideMenu()
	{
		typeArray.push("org.oof.lists.SlideMenu");
	}
	
	function chooseItemCallback(id) {
		selectedIndex = id;
		dispatchEvent({target:this,type:"change"});
	}	
	
	// Returns the item at the specified index. don't use one in base class!
	function getItemAt(i:Number) {
		return listBox.iconHolder["ico" + _selectedIndex];
	}
		
	function redraw(){
		super.redraw();
		// update the number of rows and cells
		if (!_onLoadEventOccurred || !listContent) {
			return;
		}
		
		// flush existing list
		for(var i = 0; i < length; i++){
			listBox.removeIcon(i); //doesn't work in component. ids don't start from 0 afterwards. WTF??
		}
		
		listBox.id = 0; //need to reset this, because bug in shit slidemenu
		var len = __dataProvider.length;
		for(var i = 0; i < len; i++){
			listBox.addIcon(__dataProvider[i][labelField], __dataProvider[i]["icon"]);
			listBox.iconHolder["ico" + i].label = __dataProvider[i][labelField];
			listBox.iconHolder["ico" + i].icon = __dataProvider[i]["icon"];
		}
		
		
	}
}