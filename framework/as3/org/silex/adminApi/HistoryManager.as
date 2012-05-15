
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi
{
	import flash.events.EventDispatcher;
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.util.Serialization;
	/**
	 * This class allows the AS3 plugins to access a narrower interface to the AS2 HistoryManager
	 */
	public class HistoryManager extends EventDispatcher
	{
		
		private static var FUNC_UNDO:String = "undo";
		
		private static var FUNC_REDO:String = "redo";
		
		private static var FUNC_FLUSH:String = "flush";
		
		private static var FUNC_GET_UNDO:String = "getUndo";
		
		private static var FUNC_GET_REDO:String = "getRedo";
		
		private var _targetName:String = "historyManager";
		
		public static const HISTORY_DATA_CHANGED:String = "historyDataChanged";
		
		public function HistoryManager() 
		{
			
		}
		
		/**
		 * calls the AS2 undo method through ExternalInterfaceController.
		 */
		public function undo():void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_UNDO, []);
		}
		
		/**
		 * calls the AS2 redo method through ExternalInterfaceController.
		 */
		public function redo():void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_REDO, []);
		}
		
		public function flush():void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_FLUSH, []);
		}
		
		public function getUndo():Object {
			
			return ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_GET_UNDO, null);
			
		}
		
		public function getRedo():Object {
			
			return ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_GET_REDO, null);
			
		}
		
	}

}