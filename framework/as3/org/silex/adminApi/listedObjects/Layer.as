/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listedObjects
{
	import org.silex.adminApi.ExternalInterfaceController;

	/**
	 * a layer, as contained by a layout in silex. 
	 * */
	public class Layer extends ListedObjectBase implements IVisibility
	{
		private static const FUNC_SET_VISIBLE:String = "setVisible";
		
		private static const FUNC_GET_VISIBLE:String = "getVisible";
		
		private static const FUNC_SET_EDITABLE:String = "setEditable";
		
		private static const FUNC_GET_EDITABLE:String = "getEditable";
		
		public function Layer()
		{
			super();
		}
		
		
		
		/**
		 * set visible
		 * */
		public function setVisible(value:Boolean):void{
			ExternalInterfaceController.getInstance().callJsApiLayerFunction(uid, FUNC_SET_VISIBLE, [value]);	
		}
		
		/**
		 * get visible
		 * */
		public function getVisible():Boolean{
			return ExternalInterfaceController.getInstance().callJsApiLayerFunction(uid, FUNC_GET_VISIBLE, null);	
			
		}		
		
		public function setEditable(value:Boolean):void
		{
			ExternalInterfaceController.getInstance().callJsApiLayerFunction(uid, FUNC_SET_EDITABLE, [value]);
		}
		
		public function getEditable():Boolean
		{
			return ExternalInterfaceController.getInstance().callJsApiLayerFunction(uid, FUNC_GET_EDITABLE, null);
		}
		
		
	}
}