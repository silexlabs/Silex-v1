/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.plugins.viewMenu
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * 	ViewMenuModel. Contains a local copy of the tools data, and dispatches events when these are changed. Contains the state of the viewmenu.
	 * dispatches Event.CHANGE when the view menu item data changes
	 * */
	public class ViewMenuModel extends EventDispatcher
	{
		[Bindable]
		private var _viewMenuItems:Array;
		
		public function ViewMenuModel(target:IEventDispatcher=null)
		{
			super(target);
		}

		public function get viewMenuItems():Array
		{
			return _viewMenuItems;
		}

		public function set viewMenuItems(value:Array):void
		{
			_viewMenuItems = value;
			dispatchEvent(new Event(Event.CHANGE));
		}



	}
}