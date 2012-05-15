/*
	this file is part of OOF
	OOF : Open Source Open Minded Flash Components

	OOF is (c) 2008 Alexandre Hoyau and Ariel Sommeria-Klein. It is released under the GPL License:

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License (GPL)
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
	
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.cellRenderers.RichTextCellRenderer; 

/** this is the companion cell renderer to the reorderable rich text list. You must have this in
 * your library if you want your reorderable rich text list to function. It adds drag/drop functionality to the rich text list.
 * @author Ariel Sommeria-klein
 * */
class SpecialCellRenderer02 extends RichTextCellRenderer{
	
		function onRollOverCallback () {
		super.onRollOverCallback ();
		bg_btn["gotoAndStop"](2);
	}
	
		function onRollOutCallback () {
		super.onRollOutCallback ();
		bg_btn["gotoAndStop"](1);
	}
	


	function onPressCallback () {
		super.onPressCallback ();
		bg_btn["gotoAndStop"](3);
	}
	
	
	function onReleaseCallback () {
		super.onReleaseCallback ();
		bg_btn["gotoAndStop"](2);
	}
	
	
}