/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.utils.Delegate;
import org.oof.OofBase; 
import org.oof.lists.cellRenderers.RichTextCellRenderer; 

/** this is like a rich text cell renderer, except that the alpha of the background is set to 50% every other cell
 * giving a 'stripe' effect
 * @author Ariel Sommeria-klein
 * */
class org.oof.lists.cellRenderers.StripeCellRenderer extends RichTextCellRenderer {
	
	function setValue(str:String, item:Object, sel:Boolean) : Void {
		super.setValue(str, item, sel);		
		var cellIndex = getCellIndex();
		var pos = cellIndex.itemIndex * listOwner.itemsPerRow + cellIndex.columnIndex;
		var doShade:Boolean = (pos % 2) > 0;
		if (doShade) {
			bg_btn._alpha = 50;
		}
	}
	
}