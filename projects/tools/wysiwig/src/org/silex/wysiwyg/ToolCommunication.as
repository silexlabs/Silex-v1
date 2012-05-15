/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg
{
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.HDividedBox;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.modules.ModuleLoader;
	
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	import org.silex.wysiwyg.toolboxes.addComponents.AddComponentsTool;
	import org.silex.wysiwyg.toolboxes.addComponentsLibrary.AddComponentsLibraryTool;
	import org.silex.wysiwyg.toolboxes.alert.AlertTool;
	import org.silex.wysiwyg.toolboxes.components.ComponentsTool;
	import org.silex.wysiwyg.toolboxes.layouts.LayoutsTool;
	import org.silex.wysiwyg.toolboxes.multiSubLayerComponents.MultiSubLayerComponentsTool;
	import org.silex.wysiwyg.toolboxes.page_properties.PagePropertiesTool;
	import org.silex.wysiwyg.toolboxes.properties.PropertiesTool;
	
	
	/**
	 * The communication class manages the toolBoxes instances and exposes an API<br>
	 *  to manage their addition/removal from the display list. It listens for events<br>
	 *  dispatched by the ToolBoxes and forward them to the controller class. The communication<br>
	 *  class exposes an API to the controller to set the data or selection of the toolboxes.<br>
	 *  It then forwards the new data object to the corresponding ToolBoxes.
	 */ 
	public class ToolCommunication extends Canvas
	{
		/**
		 * The layout ToolBox constant
		 */ 
		public static const LAYOUT_TOOLBOX:int = 0;
		
		/**
		 * The components ToolBox constant
		 */ 
		public static const COMPONENTS_TOOLBOX:int = 1;
		
		/**
		 * The properties ToolBox constant
		 */ 
		public static const PROPERTIES_TOOLBOX:int = 2;
		
		/**
		 * The page properties ToolBox constant
		 */ 
		public static const PAGE_PROPERTIES_TOOLBOX:int = 3;
		
		/**
		 * The alert ToolBox constant
		 */ 
		public static const ALERT_TOOLBOX:int = 4;
		
		/**
		 * the AddComponents toolbox constant
		 */ 
		public static const ADD_COMPONENTS_TOOLBOX:int = 5;
		
		/**
		 * the AddComponentsLibrary toolbox constant
		 */ 
		public static const ADD_COMPONENTS_LIBRARY_TOOLBOX:int = 6;
		
		/**
		 * The component toolbox appearing when multi sub layers are selected
		 */ 
		public static const MULTI_SUB_LAYER_COMPONENTS_TOOLBOX:int = 7;
		
		
		/**
		 * a Vector of ToolBox's references
		 */ 
		private var _toolBoxes:Vector.<SilexToolBase>;
		
		/**
		 * the HDividedBox where the toolbox will be added
		 */ 
		private var _hDividedBox:HDividedBox;
		
		/**
		 * intanciates all toolboxes and stores them in a assoc array
		 */ 
		public function ToolCommunication()
		{
			super();
			
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			_hDividedBox = new HDividedBox();
			_toolBoxes = new Vector.<SilexToolBase>();
			
			//set the toolbox container size 
			this.hDividedBox.percentHeight = 100;
			this.hDividedBox.percentWidth = 100;
			this.hDividedBox.verticalScrollPolicy = ScrollPolicy.OFF;
			this.hDividedBox.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			
	
			
			this.addChild(hDividedBox);
			
			_toolBoxes[LAYOUT_TOOLBOX] = new LayoutsTool();
			_toolBoxes[COMPONENTS_TOOLBOX] = new ComponentsTool();
			_toolBoxes[PROPERTIES_TOOLBOX] = new PropertiesTool();
			_toolBoxes[PAGE_PROPERTIES_TOOLBOX] = new PagePropertiesTool();
			_toolBoxes[ALERT_TOOLBOX] = new AlertTool();
			_toolBoxes[ADD_COMPONENTS_TOOLBOX] = new AddComponentsTool();
			_toolBoxes[ADD_COMPONENTS_LIBRARY_TOOLBOX]  =new AddComponentsLibraryTool();
			_toolBoxes[MULTI_SUB_LAYER_COMPONENTS_TOOLBOX] = new MultiSubLayerComponentsTool();
			
		}
		
		/**
		 * returns the hdivided box containing the toolboxes
		 */
		public function get hDividedBox():HDividedBox
		{
			return _hDividedBox;
		}
		
		/**
		 * sets the data on the selected toolbox
		 * 
		 * @param toolBoxID the ID of the toolbox to be set
		 * @param data the data object to set
		 */ 
		public function setData(toolBoxID:int, data:Object):void
		{
			_toolBoxes[toolBoxID].data = data;
		}
		
		/**
		 * sets the selection on the selected toolbox
		 * 
		 * @param toolBoxID the ID of the toolbox to be set
		 * @param selectedData the data object to set
		 */ 
		public function setSelection(toolBoxID:int, selectedData:Vector.<String>):void
		{
			_toolBoxes[toolBoxID].selection = selectedData;
		}
		
		/**
		 * used to call a specific function on a toolbox
		 * 
		 * @param toolBoxID the ID of the toolbox on which to call the function
		 * @param methodName the name of the method to call
		 * @param arguments an object containing the argmument of the function 
		 */ 
		public function callMethod(toolBoxID:int, methodName:String, arguments:Object = null):*
		{
			var ret:* = _toolBoxes[toolBoxID].callMethod(methodName, arguments);
			return ret;
		}
		
		/**
		 * returns the corresponding toolbox
		 * 
		 * @param toolBoxId the id of the toolbox to return
		 */ 
		public function getToolBox(toolBoxId:int):SilexToolBase
		{
			return _toolBoxes[toolBoxId] as SilexToolBase;
		}
		
		/**
		 * adds the selected toolbox to the displayList if it hasn't been added already
		 * 
		 * @param toolBoxID the ID of the toolbox to be added
		 */ 
		public function show(toolBoxID:int):void
		{
			_toolBoxes[toolBoxID].show(this);
		}
		
		/**
		 * removes the selected toolbox from the displayList if it has been added already
		 * 
		 * @param toolBoxID the ID of the toolbox to be removed
		 */ 
		public function hide(toolBoxID:int):void
		{
			_toolBoxes[toolBoxID].hide(this);
		}
	}
}