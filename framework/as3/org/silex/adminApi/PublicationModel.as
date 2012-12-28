/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import org.silex.adminApi.util.Serialization;

	public class PublicationModel extends EventDispatcher
	{
		/**
		 * remote function getEmbeddedFonts
		 * */
		public static const FUNC_GET_EMBEDDED_FONTS:String = "getEmbeddedFonts";
		
		public static const FUNC_SET_SCALE_MODE:String = "setScaleMode";
		
		public static const FUNC_GET_SCALE_MODE:String = "getScaleMode";
		
		public static const FUNC_GET_CONF:String = "getConf";
		
		public static const FUNC_REVEAL_ACCESSORS:String = "revealAccessors";
		
		/**
		 * defines the publication scale mode constants
		 */
		public static const SHOW_ALL:String = "showAll";
	
		public static const NO_SCALE:String = "noScale";
	
		public static const SCROLL:String = "scroll";
	
		public static const PIXEL:String = "pixel";
	
		/**
		 * the name of the event dispatched when the scale mode changes
		 */
		public static const EVENT_SCALE_MODE_CHANGED:String = "eventScaleModeChanged";
		
		/**
		 * it's the name of the instance in the AS2/JS SilexAdminApi. For example "layouts" Be careful of the case!
		 * */
		private static const API_OBJ_NAME:String = "publicationModel";
		
		public function PublicationModel() 
		{
			
		}
		
		public function revealAccessors(target:String):String
		{
			return String(ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_REVEAL_ACCESSORS, [target]));
		}
		
		public function getEmbeddedFonts():Array{
			var frommApi:Object = ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_GET_EMBEDDED_FONTS, [null]);
			return frommApi as Array;
		}
		
		
		
		/**
		 * set the scale mode of the publication
		 * @param	scaleMode the target scale mode
		 */
		public function setScaleMode(scaleMode:String):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_SET_SCALE_MODE, [scaleMode]);
		}
	
		/**
		 * get the publication scale mode
		 * @return the publication's scalemode
		 */
		public function getScaleMode():String
		{
			return String(ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_GET_SCALE_MODE, null));
		}
		
		public function getConf():Object
		{
			
			var fromApi:Object =  ExternalInterfaceController.getInstance().callJsApiFunction(API_OBJ_NAME, FUNC_GET_CONF, [null]);
			var ret:Object = new Object();
			
			for (var key:String in fromApi)
			{
				var decoded:ByteArray = Base64.decode(key as String); 
				decoded.position = 0;
				var newKey:String =  decoded.toString();
				ret[newKey] = fromApi[key];
				
			}
			
			return ret;
			
		}
		
	}
}