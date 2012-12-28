/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.listedObjects.Action;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Property;

	/**
	 * A class proxying copy/pasting of components
	 */ 
	public class ComponentCopier
	{
		
		private static var _componentCopier:ComponentCopier;
		
		/**
		 * Check wether items have already been copied
		 */ 
		private var _areItemsAlreadyCopied:Boolean;
		
		/**
		 * Singleton, don't use, use getInstance()
		 */ 
		public function ComponentCopier()
		{
			
		}
		
		public static function getInstance():ComponentCopier
		{
			if (_componentCopier == null)
			{
				_componentCopier = new ComponentCopier();
			}
			
			return _componentCopier;
		}
		
		/**
		 * Returns wether components have already been copied
		 */ 
		public function areItemsCopied():Boolean
		{
			return _areItemsAlreadyCopied;
		}
		
		/**
		 * Call the copy component method on silexAsminApi, and set the component copied flag to true
		 */ 
		public function copy():void
		{
			_areItemsAlreadyCopied = true;
			SilexAdminApi.getInstance().components.copy();
		}
		
		/**
		 * Call the paste component method on SilexAdminApi
		 */ 
		public function paste():void
		{
			SilexAdminApi.getInstance().components.paste(SilexAdminApi.getInstance().layers.getSelection()[0]);
		}
		
		
		
	}
}