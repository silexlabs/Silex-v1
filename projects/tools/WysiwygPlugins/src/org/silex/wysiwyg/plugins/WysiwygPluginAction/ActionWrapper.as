/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.plugins.WysiwygPluginAction
{
	import org.silex.adminApi.listedObjects.Action;
	import org.silex.wysiwyg.toolboxApi.interfaces.IAction;

	/**
	 * Wrapp an action object. Used to send IAction obects to sub-application
	 */
	public class ActionWrapper implements IAction
	{
		/**
		 * The wrapped Action
		 */
		private var _action:Action;
		
		/**
		 * sets the wrapped action
		 * @param	action the wrapped action
		 */
		public function ActionWrapper(action:Action)
		{
			_action = action;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get functionName():String
		{
			return _action.functionName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get modifier():String
		{
			return _action.modifier;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get parameters():Array
		{
			return _action.parameters;
		}
		
		/**
		 * returns the wrapped action
		 */
		public function get action():Action
		{
			return _action;
		}
		
		
		
	}
}