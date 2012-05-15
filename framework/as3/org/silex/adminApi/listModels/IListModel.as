/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listModels
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	[Event(name="dataChanged", type="flash.events.Event")]
	[Event(name=" selectionChanged", type="flash.events.Event")]
	/**
	 * the site and the editor are organized in lists of items. 
	 * Each item has a unique generated object id, to be used to manipulate them. 
	 * */
	public interface IListModel extends IEventDispatcher
	{
		/**
		 * get the data from the list. This is a dictionary of arrays of the contained data. 
		 * For example, if this is the Layers list, it is a dictionary of arrays of Layers. The keys to the dictionary are the ids of 
		 * the Layouts. So, if there 3 Layouts, start, welcome, and hello. start and hello are selected. Each Layout contains an "over" and "under" layer.
		 * The return value is then start->[over, under], hello->[over, under]
		 * data is of the form array of arrays, Relative untyped objects. It's the implementing class' duty to convert them to typed objects
		 *  
		 * @param containerIds The uids of the containers. For example when asking for Layers, the ids of the Relative Layouts. 
		 * If null, it will use the current selection of the containers
		 * 
		 * @returns an associative array.
		 * */
		function getData(containerUids:Array =  null):Array;
		
		/**
		* get objects from an array of uids and returns them as an array
		* @param objectsUids the uids of the objects to retrieve
		* @return an array of ListedObjectBase
		* */
		function getObjectsByUids(objectsUids:Array):Array;
		
		/**
		 * get the type of the data in the list
		 * @returns the type of the data in the list. 
		 * @see model.silexIo.listedObjects
		 * @returns a class. 
		 * */
		function getDataType():Class;

		/**
		 * add an item to the list
		 * @param data the data to add. Should usually a string, but for now loose typing is maintained
		 * @returns the uid of the created component
		 * */
		function addItem(data:Object):String;
		
		/**
		 * delete an item from the list. 
		 * This is not done elsewhere because its not so bad if something goes wrong.
		 * @param objectId 
		 * */
		function deleteItem(objectId:String):void;

		/**
		 * hides an item
		 * @param objectId1 the objectId of the first item in the list
		 * @param objectId2 the objectId of the second item in the list
		 * */
		function swapItemDepths(objectId1:String, objectId2:String):void;
		
		/**
		 * reorder all the objects in the list.
		 * @param orderedObjectIds an array of objectIds representing the wanted order. This must contain all the objectIds once and only once, or it will fail
		 * */
		function changeOrder(orderedObjectIds:Array):void;
		/**
		 * get the selected members of of the list.
		 * @returns an array of objectIds
		 * */
		function getSelection():Array;
		
		/**
		 * get sorted datas from the list. For instance for the Properties ListModel,
		 * if the filterName is "name" and the filterValues are "x" and "y", for each selected component
		 * or for each uid in the containerUids, it returns an object where each key is the name of the returned
		 * Property ("x" and "y") and each value is a typed Property object. On the Components object, you can use this method
		 * to retrieve Component object by class name.
		 * 
		 * @param containerUids the array of uids of the targeted List objects to retrieve data from
		 * @param filterValues the values to retrieve on the targeted object. For instance for a Property, you
		 * may want to retrieve "x", "y", "width" and "height"
		 * @param filterName the name of the value to filter with (might be "name" or "uid" for instance)
		 * @param returnKeyName the name of the value to use as key for each element of the returned object.
		 *
		 */ 
		function getSortedData(containerUids:Array = null, filterValues:Array = null, filterName:String = "name", returnKeyName:String = "name"):Array;
		
		/**
		 * Copy the currently selected items in a list. Implemented
		 * as needed
		 */
		function copy():void
		
		/**
		 * Paste the previously copied items
		 * in a list
		 * @param targetContainerUid the uid of the container into which thr objects
		 * will be pasted
		 */
		function paste(targetContainerUid:String = null):void
		
		/**
		 * select some items in the list
		 * @param objectIds an array of objectIds
		 * @param data an optionnal data object sent back with the select event
		 * */
		function select(objectIds:Array, data:Object = null):void;
		
		/**
		 * get the capabilities of the list
		 * @returns an array of strings each describing a capability matching one of the functions in this interface
		 * @see model.silexIo.ListModelCapabilities
		 * */
		function getCapabilities():Array;
	}
}