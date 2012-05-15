/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.cellRenderers.RichTextCellRenderer; 

/** this is the companion cell renderer to the reorderable rich text list. You must have this in
 * your library if you want your reorderable rich text list to function. It adds drag/drop functionality to the rich text list.
 * @author Ariel Sommeria-klein
 * */
class org.oof.lists.cellRenderers.DraggableRichTextCellRenderer extends RichTextCellRenderer{
	static var START_DRAG_EVENT = "onStartDrag";
	static var STOP_DRAG_EVENT = "onStopDrag";
	static var DRAG_EVENT = "onDrag";
	
	private var _isDragging:Boolean = false;
	
	function onPressCallback () {
		_isDragging = true;
		//start drag. drag is only vertical(for now, ideally it would be depending on the list's dimensions, direction).
		//dragging must be limited within the bounds of the list, but this can't be done here. The list must do it in the event listener
		startDrag(false, 0, - height * 0.5, 0, height * 0.5);
		dispatchEvent({target:this, type:START_DRAG_EVENT}); 
	}
	
	//common function for onRelease and onReleaseOutside
	private function doOnRelease(){
		_isDragging = false;
		stopDrag();
		dispatchEvent({target:this, type:STOP_DRAG_EVENT}); 
	}

	function onReleaseCallback () {
		super.onReleaseCallback();
		doOnRelease();
	}

	function onReleaseOutsideCallback () {
		super.onReleaseOutsideCallback();
		doOnRelease();
	}

	function onMouseMoveCallback () {
		//don't call super! for some unknown reason, this messes up the dragging. Any ideas on why this happens are welcome. A.S.K.
		//super.onMouseMoveCallback();
		if(_isDragging){
			dispatchEvent({target:this, type:DRAG_EVENT}); 
		}
	}

	
}