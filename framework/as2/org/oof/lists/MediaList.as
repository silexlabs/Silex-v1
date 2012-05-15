/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.CustomList
/** This is a list that adds a second label to the basic component. This is probably
 * obsolete.
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * 
 * @author Ariel Sommeria-klein 
 *
 * */
class org.oof.lists.MediaList extends CustomList{
	private var _label2FieldPath:String = null;
	
	function MediaList() {
		typeArray.push("org.oof.lists.MediaList");
		if(_cellRenderer == ""){
			_cellRenderer = "MediaCellRenderer";	
		}

	}
	
	/** function set label2FieldPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="second label field path", type=String, defaultValue="")]
	public function set label2FieldPath(val:String){
		_label2FieldPath = val;
	}
	
	/** function get label2FieldPath
	* @returns String
	*/
	
	public function get label2FieldPath():String{
		return _label2FieldPath;
	}	


}