/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.IEventDispatcher;

[Event(name="dataChanged", type="flash.events.Event")]
[Event(name=" selectionChanged", type="flash.events.Event")]
/**
 * the site and the editor are organized in lists of items. 
 * Each item has a unique generated object id, to be used to manipulate them. 
 * */
interface org.silex.adminApi.listModels.IListModel extends IEventDispatcher
{
	/**
	 * get the data from the list.  It returns an array of arrays of proxies. It takes as parameter an array of container uids. 
	 * For example, suppose you have 2 SubLayers, “over” and “under”. Each of them contains one component, “overComp1” and “underComp1”.  
	 * The “over” SubLayer is selected. 
	 * Calling getData on the components ListModel without parameters will return information about the components on the selected SubLayer. So here it will return the component proxies [[“overComp1”]]. 
	 * Calling getData(["over", "under"]) will return the component proxies[[“overComp1”], [underComp1"]]
	 * 
	 * @param containerIds The uids of the containers. For example when asking for Components, the ids of the Relative SubLayers. 
	 * If null, it will use the current selection of the containers
	 *  
	 * @returns a dictionary.
	 * */
	function getData(containerUids:Array):Array;
	
	/**
	 * add an item to the list
	 * @param data the data to add. Should usually a string, but for now loose typing is maintained
	 * @param containerUid an optionnal param pointing to which container to add
	 * @returns the uid of the created component
	 * */
	function addItem(data:Object, containerUid:String):String
	
	/**
	 * delete an item from the list. 
	 * This is not done elsewhere because its not so bad if something goes wrong.
	 * @param objectId 
	 * */
	function deleteItem(objectId:String):Void;

	/**
	 * hides an item
	 * @param objectId1 the objectId of the first item in the list
	 * @param objectId2 the objectId of the second item in the list
	 * */
	function swapItemDepths(objectId1:String, objectId2:String):Void;

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
	function getSortedData(containerUids:Array, filterValues:Array, filterName:String, returnKeyName:String):Array;
	
	/**
	 * Copy the currently selected items in a list. Implemented
	 * as needed
	 */
	function copy():Void
	
	/**
	 * Paste the previously copied items
	 * in a list
	 * @param targetContainerUid the uid of the container into which thr objects
	 * will be pasted
	 */
	function paste(targetContainerUid:String):Void
	
	/**
	 * get objects from an array of uids and returns them as an array
	 * @param objectsUids the uids of the objects to retrieve
	 * @return an array of ListedObjectBase
	 * */
	function getObjectsByUids(objectsUids:Array):Array;
	/**
	 * select some items in the list
	 * @param objectIds an array of objectIds
	 * @param data an optionnal data object sent back with the select event
	 * */
	function select(objectIds:Array, data:Object):Void;
	
	/**
	 * reorder all the objects in the list.
	 * @param orderedObjectIds an array of objectIds representing the wanted order. This must contain all the objectIds once and only once, or it will fail
	 * */
	function changeOrder(orderedObjectIds:Array):Void;	
	/**
	 * get the capabilities of the list
	 * @returns an array of strings each describing a capability matching one of the functions in this interface
	 * @see model.silexIo.ListModelCapabilities
	 * */
	function getCapabilities():Array;
	
	/**
	 * sometimes an exterior function needs the list to signal that its data has changed, even if the list itself doesn't know it
	 * For example if the selected component changes, the properties data has changed and the component proxy must 
	 * call this method.
	 * Each List is responsable for calling this method on the lists on which this has a direct impact, but no further, as there is a cascade
	 * effect. For example changing layouts calls this on layers, which calls it on components, which calls it on properties etc.
	 * */
	function signalDataChanged(data:Object):Void;
	
	/**
	 * Returns the parent of the list, for instance the parent of the properties list
	 * is the components list
	 */
	function getParent():IListModel;
	
}