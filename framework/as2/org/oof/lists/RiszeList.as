/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/** This list take the size of its content, i.e. all the items are visible, there is no scroll possible.
 * 
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * @author Alexandre Hoyau
 * */
class org.oof.lists.RiszeList extends org.oof.lists.RichTextList {
	
	public function RiszeList()
	{
		typeArray.push("org.oof.lists.RiszeList");
	}
	
	function onLoad(){
		super.onLoad();
		redraw();
	}
	function redraw(){
		super.redraw();
		if (listContent._height>0 && listContent._width>0 && (listContent._height!=height || listContent._width!=width))
			this.setSize(listContent._width,listContent._height);
	}
}