/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.CustomList;
/** This list displays rich text in each cell, with a variety of formatting options.
 * There are 2 cell renderers available for this list:
 * RichTextCellRenderer and ToggleCellRenderer.
 * The first is by default. Use the second for multiple selection.
 * 
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * @author Ariel Sommeria-klein
 * */
class org.oof.lists.RichTextList extends CustomList{
	var _autoSize:Object = "none";
	var _wordWrap:Boolean = false;
	var _html:Boolean = true;
	var _embedFonts:Boolean = false;
	function RichTextList(){
		super();
		_className = "org.oof.lists.RichTextList";
		typeArray.push("org.oof.lists.RichTextList");
		if(_cellRenderer == ""){
			_cellRenderer = "RichTextCellRenderer";	
		}
	}
	/** function set autoSize
	* @param val(Object)
	* @returns void
	*/
	[Inspectable(name="cell text auto size",type=Object, defaultValue="center", enumeration="none, left, right, center")]
	public function set autoSize(val:Object){
		_autoSize = val;
	}
	
	/** function get autoSize
	* @returns Object
	*/
	
	public function get autoSize():Object{
		return _autoSize;
	}	
	
	/** function set wordWrap
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="cell text word wrap", type=Boolean, defaultValue=true)]
	public function set wordWrap(val:Boolean){
		_wordWrap = val;
	}
	
	/** function get wordWrap
	* @returns Boolean
	*/
	
	public function get wordWrap():Boolean{
		return _wordWrap;
	}		
	/** function set html
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="cell text use html", type=Boolean, defaultValue=true)]
	public function set html(val:Boolean){
		_html = val;
	}
	
	/** function get wordWrap
	* @returns Boolean
	*/
	
	public function get html():Boolean{
		return _html;
	}		
	
	/** function set embedFonts
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="cell text embed fonts", type=Boolean, defaultValue=false)]
	public function set embedFonts(val:Boolean){
		_embedFonts = val;
	}
	
	/** function get wordWrap
	* @returns Boolean
	*/
	
	public function get embedFonts():Boolean{
		return _embedFonts;
	}		
}