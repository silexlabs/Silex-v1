/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes
{
	import flash.errors.IllegalOperationError;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.containers.Canvas;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.effects.Dissolve;
	import mx.effects.Fade;
	import mx.effects.WipeRight;
	import mx.effects.Zoom;
	import mx.modules.Module;
	
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.ToolUIBase;

	/**
	 * The base class for all ToolBox controller classes, defines default behaviour
	 */ 
	public class SilexToolBase extends Canvas
	{
		/**
		 * a reference to the ToolBox's UI
		 */ 
		protected var _toolUI:ToolUIBase;
		
		/**
		 * a reference to the ToolBox's UI selection
		 */ 
		protected var _selection:Vector.<String>;
		
		public function SilexToolBase()
		{
			super();
			this.percentHeight = 100;
			
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			
		}
		
		/**
		 * get the selected item from the ToolBox
		 */ 
		public function get selection():Vector.<String>
		{
			return _selection;
		}
		
		/**
		 * sets the data on the toolbox UI
		 * 
		 * @param value the data to be set
		 */ 
		override public function set data(value:Object):void
		{
			_toolUI.data = value;
		}
		
		/**
		 * get the selected item on the ToolBox
		 * 
		 * @param value the data to be set
		 */ 
		public function set selection(value:Vector.<String>):void
		{
			_toolUI.select(value);
		}
		
		/**
		 * add this toolBox to the displayList
		 * 
		 * @param target the toolBox parent
		 */ 
		public function show(target:ToolCommunication):void
		{
			if (! target.hDividedBox.getChildByName(this.name))
			{
				target.hDividedBox.addChild(this);
			}
			
			else
			{
				(target.hDividedBox.getChildByName(this.name) as UIComponent).includeInLayout = true;
				target.hDividedBox.getChildByName(this.name).visible = true;
			}
		}
		
		/**
		 * used to call a specific function on a toolbox
		 * 
		 * @param methodName the name of the method to call
		 * @param arguments an object containing the argmument of the function 
		 */ 
		public function callMethod(methodName:String, arguments:Object):*
		{
			var ret:* = _toolUI.callMethod(methodName, arguments);
			return ret;
		}
		
		/**
		 * removes this toolBox from the displayList
		 * 
		 * @param target the toolBox parent
		 */ 
		public function hide(target:ToolCommunication):void
		{
			if ( target.hDividedBox.getChildByName(this.name))
			{
				(target.hDividedBox.getChildByName(this.name) as UIComponent).includeInLayout = false;
				target.hDividedBox.getChildByName(this.name).visible = false;
			}
			
			
		}
	}	
}