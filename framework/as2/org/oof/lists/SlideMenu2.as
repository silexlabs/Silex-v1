/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.transitions.Tween;
import mx.transitions.easing.*;

/** This list is a nice menu where there is a gap between the selected item and the items bellow.
 * 
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * @author Alexandre Hoyau
 * */
class org.oof.lists.SlideMenu2 extends org.oof.lists.RichTextList
{
	static var TWEEN_TYPE:Function = Strong.easeOut;
	//static var TWEEN_DURATION:Number = 1;
	
	public function SlideMenu2()
	{
		super();
		_className = "org.oof.lists.SlideMenu2";
		typeArray.push("org.oof.lists.SlideMenu2");
	}
	
	private function onLoad() 
	{
		super.onLoad();
		
		// only one row		
		_itemsPerRow = 1;
		
		// only vertical
		isHorizontal = false;
	}
	private function refreshRowsAndCells()
	{
		super.refreshRowsAndCells();
		var i;
		var isSelected;
/*		for (var i = 0; i < _rowCount; i++)
		{
			var cell_mc:MovieClip = _rows[i];
			var isSelected:Boolean = (i == selectedIndex);

			// cell data
			var labelVal = __dataProvider[i][labelField];
			var dataVal = __dataProvider[i];
			cell_mc.setValue(labelVal, dataVal, isSelected);

			if (_useVariableRowHeight)
			{
				//leave rowheight free.
				cell_mc.setSize(this.width / _itemsPerRow, cell_mc.height);
			}
			else
			{
				//set both dimensions
				cell_mc.setSize(this.width / _itemsPerRow, _fixedRowHeight);
			}
		}			
*/		// y positions
		var yPosition:Number = 0;
		for (i = 0; i < _rowCount; i++)
		{
			var cell_mc:MovieClip = _rows[i];

			//cell_mc._y = yPosition;
			sendCellToPosition(cell_mc, yPosition);
			
			isSelected = (i == selectedIndex);
			

			if (isSelected)
				yPosition = height - heightOfCellsStartingAtIndex(i + 1);
			else
				yPosition += cell_mc._height;
		}
	}
	private function heightOfCellsStartingAtIndex(idx:Number) 
	{
		var sum:Number = 0;
		for (var i = idx; i < _rowCount; i++)
		{
			sum += _rows[i]._height;
		}
		return sum;
	}
	private function sendCellToPosition(cell_mc:MovieClip, yPosition:Number) 
	{
		if (cell_mc.slideTwin) 
			cell_mc.slideTwin.continueTo(yPosition);
		else
			cell_mc.slideTwin = new Tween(cell_mc, "_y", TWEEN_TYPE, cell_mc._y, yPosition, _easingDuration, true);
	}
}