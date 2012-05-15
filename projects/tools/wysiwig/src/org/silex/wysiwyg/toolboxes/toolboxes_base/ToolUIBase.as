/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.toolboxes_base
{
	import flash.errors.IllegalOperationError;
	import flash.filters.DropShadowFilter;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.containers.VBox;
	
	/**
	 * The Base class for all ToolBoxes UI
	*/ 
	public class ToolUIBase extends VBox
	{
		/**
		 * sets the ToolBox default size and style
		 */ 
		public function ToolUIBase()
		{
			super();
			
			this.styleName = "ToolBoxBody";
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			
		}
		
		/**
		 * set the selected data on a toolBox
		 * 
		 * @param value the data to be set
		 */ 
		public function select(value:Vector.<String>):void
		{
			throw new IllegalOperationError("Abstract method");
		}
		
		/**
		 * used to call a specific function on a toolbox
		 * 
		 * @param methodName the name of the method to call
		 * @param arguments an object containing the argmument of the function 
		 */ 
		public function callMethod(methodName:String, arguments:Object):*
		{
			var functionToCall:Function = this[methodName];
			var ret:* = functionToCall(arguments);
			return ret;
		}
	}
}