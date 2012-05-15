/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.CustomList;
/** This list integrates the flashloaded photoflow component. You need the proprietary photo flow
 * list to use this.
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * 
 * @author Ariel Sommeria-klein
 * */
class org.oof.lists.PhotoFlow extends CustomList{
	var listBox:MovieClip;
	
	public function photoFlow():Void
	{
		typeArray.push("org.oof.lists.PhotoFlow");
	}
	
	function _initAfterRegister(){
		super._initAfterRegister();
		listBox.addEventListener("onSelectPhoto", this);
	}
	
	function onSelectPhoto(eventObject:Object) {
		selectedIndex = eventObject.index;
		dispatch( { target:this, type:"change" } );
	}	
	
	function onModelChanged(){
		//don't do usual stuff in super!
		// flush existing list
		listBox.removeAll();
		var len:Number = __dataProvider.length;
		for(var i = 0; i < len; i++){
			var photo:Object = new Object();
			photo["url"] = __dataProvider[i]["icon"];
			photo["name"] = "photo" + i;
			listBox.addPhoto(photo);
																								 
		}
	}

}