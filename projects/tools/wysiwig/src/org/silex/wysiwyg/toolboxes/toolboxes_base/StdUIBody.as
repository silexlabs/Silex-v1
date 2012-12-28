/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.toolboxes_base
{
	import flash.errors.IllegalOperationError;
	
	import mx.containers.VBox;
	
	/**
	 * The standard tool box UI body class
	 * 
	 * @author Yannick
	 */
	public class StdUIBody extends VBox
	{
		
		/**
		 * a reference to the item currently selected in the toolbox
		 */ 
		[Bindable]
		private var _currentSelection:Object;
		
		
		public function StdUIBody()
		{
			super();
		}
		
		/**
		 * get the currently selected object
		 */ 
		public function get currentSelection():Object
		{
			return _currentSelection;
		}
		
		/**
		 * sets the currently selected object
		 * 
		 * @param value the data to be set
		 */ 
		public function set currentSelection(value:Object):void
		{
			_currentSelection = value;
		}
		
		/**
		 * select an item in the toolbox's list
		 * 
		 * @param value the data to be selected
		 */ 
		public function selectListItem(value:Object):void
		{
			throw new IllegalOperationError("Abstract method");
		}
		

	}
}