/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listModels
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.util.Serialization;
	
	public class ListModelBase extends EventDispatcher implements IListModel
	{	
		/**
		 * remote function getData
		 * */
		public static const FUNC_GET_DATA:String = "getData";
		
		/**
		 * remote function getObjectsByUids
		 */
		public static const FUNC_GET_OBJECTS_BY_UIDS:String = "getObjectsByUids";
		
		/**
		 * remote function getSortedData
		 */ 
		public static const FUNC_GET_SORTED_DATA:String = "getSortedData";
		
		/**
		 * remote function select
		 * */
		public static const FUNC_SELECT:String = "select";
		
		/**
		 * remote function getSelection
		 * */
		public static const FUNC_GET_SELECTION:String = "getSelection";
		
		/**
		 * remote function addItem
		 * */
		public static const FUNC_ADD_ITEM:String = "addItem";
		
		/**
		 * remote function deleteItem
		 * */
		public static const FUNC_DELETE_ITEM:String = "deleteItem";
		
		/**
		 * remote function swapItemDepths
		 * */
		public static const FUNC_SWAP_ITEM_DEPTHS:String = "swapItemDepths";
		
		/**
		 * remote function changeOrder
		 * */
		public static const FUNC_CHANGE_ORDER:String = "changeOrder";
		
		/**
		 * remote function copy
		 * */
		public static const FUNC_COPY:String = "copy";
		
		/**
		 * remote function paste
		 * */
		public static const FUNC_PASTE:String = "paste";
		
		/**
		 * set in derived class
		 * it's the name of the instance in the AS2 SilexAdminApi. For example "layouts" Be careful of the case!
		 * */
		protected var _equivalentAS2ObjectName:String = null;
		
		/**
		 * used to instanciate typed objects
		 * */
		protected var _dataType:Class;
		
		public function ListModelBase()
		{
			super();
			
		}
		

		/**
		 * convert an untyped object (coming from silex through js) to a typed one (for AS3 consumption)
		 * */
		protected function untypedToTyped(untyped:Object):Object{
			var typed:Object = new _dataType();
			for (var key:String in untyped){
				var untypedSubObj:Object = untyped[key];
				typed[key] = untypedSubObj;
			} 
			
			return typed;
		}
		
		/**
		 * @inheritdoc
		 * Note: When the ToolBox is running in a popup, arrays are passed as objects(and not arrays as they should).
		 * Somehow the typing is lost, and only in popups. So casting is not possible, and we must rebuild an array
		 * the data structure we want to convert to is an array of arrays of typed objects.
		 * That is what we have to start with, except that it is more or less completely untyped, depending on wether or not this is running in a popup
		 * */
		public function getData(containerUids:Array =  null):Array
		{			
			var fromApi:Object = ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_GET_DATA, [containerUids]);
			var arrayOfArrays:Array = fromApi as Array;
			for each(var array:Array in arrayOfArrays){
				var numUntyped:uint = array.length;
				for(var i:uint = 0; i < numUntyped; i++){
					var untyped:Object = array[i]; 
					//replace untyped by type in array
					array[i] = untypedToTyped(untyped);
				}
			}
			return arrayOfArrays;

		}
		
		/**
		 * Retrieve a selection of ListObjectBase from a list with their uids and 
		 * returns them as an array of typed objects
		 */
		public function getObjectsByUids(objectsUids:Array):Array {
			var fromApi:Object = ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_GET_OBJECTS_BY_UIDS, [objectsUids]);
			
			var objectsArray:Array = fromApi as Array;
			var numObjects:int = objectsArray.length;
			
			for (var i:int = 0; i < numObjects; i++)
			{
				var untyped:Object = objectsArray[i]; 
				//replace untyped by type in array
				objectsArray[i] = untypedToTyped(untyped);
			}
			
			return objectsArray;
		}
		
		/**
		 * Copy the currently selected items in a list. Implemented
		 * as needed
		 */
		public function copy():void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_COPY, []);
		}
		
		/**
		 * Paste the previously copied items
		 * in a list
		 */
		public function paste(targetContainerUid:String = null):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_PASTE, [targetContainerUid]);
		}
		
		/**
		 * @inheritdoc
		 * */
		public function getSortedData(containerUids:Array = null, filterValues:Array = null, filterName:String = "name", returnKeyName:String = "name"):Array
		{
			//we retrieve the sorted objects from SilexAdminApi
			var fromApi:Object = ExternalInterfaceController.getInstance().callJsApiFunction(
				_equivalentAS2ObjectName, FUNC_GET_SORTED_DATA, [containerUids, filterValues, filterName, returnKeyName]);
			
			//we cast the result as an array
			var arrayOfObjects:Array = fromApi as Array;
			
			//each element of the array is an object
			for (var i:int = 0; i<arrayOfObjects.length; i++)
			{
				//for each value in the object,
				//we take the untyped values and convert them into a
				//strongly typed object
				for (var key:Object in arrayOfObjects[i])
				{
					var untyped:Object = arrayOfObjects[i][key];
					arrayOfObjects[i][key] = untypedToTyped(untyped);
				}
			}
			return arrayOfObjects;
		}
		
		
		/**
		 * @inheritdoc
		 * */
		public function getDataType():Class
		{
			return _dataType;
		}
		
		/**
		 * add an item. 
		 * @param data. It's an object, and so untyped. For a component it's the media url as a String, for actions to be defined.
		 * This might be changed in the future to add stronger typing
		 * */
		public function addItem(data:Object):String
		{
			return ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_ADD_ITEM, [data]) as String;
		}
		
		/**
		 * @inheritdoc
		 * */
		public function deleteItem(objectId:String):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_DELETE_ITEM, [objectId]);
		}
		
		/**
		 * @inheritdoc
		 * */
		public function swapItemDepths(objectId1:String, objectId2:String):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_SWAP_ITEM_DEPTHS, [objectId1, objectId2]);
		}
		
		/**
		 * @inheritdoc
		 * */
		public function getSelection():Array
		{
			var frommApi:Object = ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_GET_SELECTION, [null]);
			return frommApi as Array;
		}
		
		/**
		 * @inheritdoc
		 * */
		public function select(objectIds:Array, data:Object = null):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_SELECT, [objectIds,data]);
		}
		
		/**
		 * @inheritdoc
		 * */
		public function getCapabilities():Array{
			return null;
		}
		
		/**
		 * @inheritdoc
		 * */
		public function changeOrder(orderedObjectIds:Array):void{
			ExternalInterfaceController.getInstance().callJsApiFunction(_equivalentAS2ObjectName, FUNC_CHANGE_ORDER, [orderedObjectIds]);

		}
	}
}