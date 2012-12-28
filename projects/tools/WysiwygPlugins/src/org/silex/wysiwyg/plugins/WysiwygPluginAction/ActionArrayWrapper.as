/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.plugins.WysiwygPluginAction
{
	import org.silex.adminApi.listedObjects.Action;
	import org.silex.wysiwyg.toolboxApi.interfaces.IActionArray;

	public class ActionArrayWrapper implements IActionArray
	{
		
		/**
		 * the array containing the Action objects
		 */
		private var _actionArray:Array;
		
		/**
		 * the name of the component holding the actions
		 */
		private var _componentName:String;
		
		/**
		 * the string listing all actions and their properties
		 */
		private var _actionString:String;
		
		/**
		 * the array of modified actions which will replace the current action array
		 */
		private var _newActionArray:Array;
		
		/**
		 * Sets the array of actions and the component name
		 * @param	actionArray the array of actions
		 * @param	componentName the component name
		 */
		public function ActionArrayWrapper(actionArray:Array, componentName:String)
		{
			_actionArray = actionArray;
			_componentName = componentName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get actionArray():Array
		{
			return _actionArray;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get componentName():String
		{
			return _componentName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get actionString():String
		{
			return _actionString;
		}
		
	
		/**
		 * @inheritDoc
		 */
		public function set actionString(value:String):void
		{
			_actionString = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addAction(modifier:String, functionName:String, parameters:Array):void
		{
			var action:Action = new Action();
			action.update(functionName, modifier, parameters);
			_actionArray.push(new ActionWrapper(action));
		}
		
		/**
		 * @inheritDoc
		 */
		public function resetActionArray():void
		{
			_actionArray = new Array();
		}
		
		/**
		 * @inheritDoc
		 */
		public function set newActionArray(value:Array):void
		{
			_newActionArray = value;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get newActionArray():Array
		{
			return _newActionArray;
		}
	}
}