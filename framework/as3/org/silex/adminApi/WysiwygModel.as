/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * class for manipulating the admin model. Contains everything editor related that isn't in the lists. It's here simply so that it isn't in the 
	 * main SilexAdminApi class
	 * 
	 * */
	public class WysiwygModel extends EventDispatcher
	{
		public static const EVENT_ZOOM_CHANGED:String = "EVENT_ZOOM_CHANGED";
		
		public static const EVENT_TOOL_BOX_VISIBILITY_CHANGED:String = "EVENT_TOOL_BOX_VISIBILITY_CHANGED";
		
		public static const EVENT_TOOL_BOX_DISPLAY_MODE_CHANGED:String = "EVENT_TOOL_BOX_DISPLAY_MODE_CHANGED";
		
		/**
		 * display mode for the tool box. in a div. public
		 */
		public static const TOOLBOX_DISPLAY_MODE_DIV:int = 0;
		
		/**
		 * display mode for the tool box. in a popup. public
		 */
		public static const TOOLBOX_DISPLAY_MODE_POPUP:int = 1;
		
		/**
		 * remote function getZoom
		 * */
		private static const FUNC_GET_ZOOM:String = "getZoom";
		
		/**
		 * remote function setZoom
		 * */
		private static const FUNC_SET_ZOOM:String = "setZoom";
		
		/**
		 * remote function getToolBoxVisibility
		 * */
		private static const FUNC_GET_TOOL_BOX_VISIBILITY:String = "getToolBoxVisibility";
		
		/**
		 * remote function setToolBoxVisibility
		 * */
		private static const FUNC_SET_TOOL_BOX_VISIBILITY:String = "setToolBoxVisibility";
		
		/**
		 * remote function getToolBoxDisplayMode
		 * */
		private static const FUNC_GET_TOOL_BOX_DISPLAY_MODE:String = "getToolBoxDisplayMode";
		
		/**
		 * remote function setToolBoxDisplayMode
		 * */
		private static const FUNC_SET_TOOL_BOX_DISPLAY_MODE:String = "setToolBoxDisplayMode";
		
		
		/**
		 * it's the name of the instance in the AS2/JS SilexAdminApi. For example "layouts" Be careful of the case!
		 * */
		private static const API_OBJ_NAME:String = "wysiwygModel";
		
		public function WysiwygModel()
		{
			super();
		}
		
		public function getZoom():Number{
			return ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_GET_ZOOM, null) as Number;
		}
		
		public function setZoom(value:Number):void{
			ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_SET_ZOOM, [value]);
		}
		
		public function getToolBoxVisibility():Boolean
		{
			return ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_GET_TOOL_BOX_VISIBILITY, null) as Boolean;
		}
		
		public function setToolBoxVisibility(value:Boolean):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_SET_TOOL_BOX_VISIBILITY, [value]);
		}
		
		public function getToolBoxDisplayMode():Number
		{
			return ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_GET_TOOL_BOX_DISPLAY_MODE, null) as Number;
		}
		
		public function setToolBoxDisplayMode(value:Number):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_SET_TOOL_BOX_DISPLAY_MODE, [value]);
		}
		
		
		
		
	}
}