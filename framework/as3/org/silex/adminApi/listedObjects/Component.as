/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listedObjects
{
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.util.Serialization;

	/**
	 * a component in silex.
	 * */
	public class Component extends ListedObjectBase implements IVisibility
	{
		
		/**
		 * the open icon function, on the remote component
		 * */
		private static const FUNC_OPEN_ICON:String = "openIcon";
		
		private static const FUNC_SET_VISIBLE:String = "setVisible";
		
		private static const FUNC_GET_VISIBLE:String = "getVisible";
		
		private static const FUNC_SET_EDITABLE:String = "setEditable";
		
		private static const FUNC_GET_EDITABLE:String = "getEditable";
		
		private static const FUNC_GET_TYPE_ARRAY:String = "getTypeArray";
		
		private static const FUNC_GET_SPECIFIC_EDITOR_URL:String = "getSpecificEditorUrl";
		
		private static const FUNC_GET_AS2_URL:String = "getAs2Url";
	
		private static const FUNC_GET_CLASS_NAME:String = "getClassName";
		
		private static const FUNC_GET_ICON_URL:String = "getIconUrl";
		
		private static const FUNC_GET_IS_VISUAL:String = "getIsVisual";
		
		public function Component()
		{
			super();
		}
		
		/**
		 * this is information about the type of the component, mainly to be used by the editor to open a matching design view
		 * this is an array of strings
		 * */
		public function get typeArray():Array
		{
			return ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_TYPE_ARRAY, null)  as Array;	
		}

		/**
		 * if a component is used as an icon, it is possible to open it from the editor. This opens the corresponding page
		 * @param forceOpen if the component is editable, then it can't open
		 * the icon unless forceOpen is true.
		 * */
		public function openIcon(forceOpen:Boolean = false):void{
			ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_OPEN_ICON, [forceOpen]);	
		}
		
		
		/**
		 * set visible
		 * */
		public function setVisible(value:Boolean):void{
			ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_SET_VISIBLE, [value]);	
		}
		
		/**
		 * get visible
		 * */
		public function getVisible():Boolean{
			return ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_VISIBLE, null);	
 
		}		
		
		
		/**
		 * set editable
		 * */
		public function setEditable(value:Boolean):void{
			ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_SET_EDITABLE, [value]);	
		}		
		
		/**
		 * get editable
		 * */
		public function getEditable():Boolean{
			return ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_EDITABLE, null);	
			
		}		
		
		/**
		 * get specific editor url
		 * */
		public function getSpecificEditorUrl():String{
			var ret:Object = ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_SPECIFIC_EDITOR_URL, null);
			if(ret){
				return ret.toString();
			}else{
				return null;
			}
			
		}		
		
		/**
		 * get as2 url
		 * */
		public function getAs2Url():String{
			var ret:Object = ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_AS2_URL, null);
			if(ret){
				return ret.toString();
			}else{
				return null;
			}
			
		}	
		
		/**
		 * get as2 url
		 * */
		public function getClassName():String{
			var ret:Object = ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_CLASS_NAME, null);
			if(ret){
				return ret.toString();
			}else{
				return null;
			}
			
		}	
		
		/**
		* returns the url of the icon representing the component from the descriptor
		*/
		public function getIconUrl():String
		{
			var ret:Object = ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_ICON_URL, null);
			if(ret){
				return ret.toString();
			}else{
				return null;
			}
		}
		
		/**
	 * return wheter the component is visual (Image, text...) or non-visual
	 * (data selector, connectors...)
	 */
	public function getIsVisual():Boolean
	{
		var ret:Object = ExternalInterfaceController.getInstance().callJsApiComponentFunction(uid, FUNC_GET_IS_VISUAL, null);
			if(ret){
				return Boolean(ret.toString());
			}else{
				return false;
			}
	}
		
		
			
	}
}