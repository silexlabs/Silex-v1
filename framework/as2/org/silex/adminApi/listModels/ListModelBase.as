/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.data.types.Int;
import mx.events.EventDispatcher;

import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listModels.IListModel;
import org.silex.adminApi.util.T;
import org.silex.core.Api;



/**
 * implementation of IListModel.
 * note: this could be optimized by caching getData, but it's not worth it yet
 * */

class org.silex.adminApi.listModels.ListModelBase implements IListModel
{
	static private var _silexPtr:Api = null;	
	
	/**
	 * delay, in ms
	 * */
	static private var EVENT_DELAY:Number = 50; 
	
	private var _selectedObjectIds:Array = null;
	
	/**
	* object name. used for reflection(knowing which class this is). The name of the instance in SilexAdminApi. For example : layouts(watch the case!)
	* initialize in subclass
	*/
	private var _objectName:String;
	
	/**
	 * dependant lists. Names of the instances in SilexAdminApi of the lists whose content is dependant on this one.
	 * For example, layers are dependant on layouts, components are dependant on layers etc.
	 * This is to used for managing dependancies between the lists when their data changes
	 * */
	private var _dependantLists:Array; 
	
	/**
	 * the id of the timer interval used to schedule a DATA_CHANGED event
	 * 0 if none is scheduled, otherwise set to intervalId returned by setInterval
	 * */
	private var _dataChangedIntervalId:Number = 0;
	
	/**
	 * A buffer storing the data of the list as they are requested. 
	 * Reseted when the data changes
	 */
	private var _objectsBuffer:Object;
	
	
	
	
	public function ListModelBase()
	{
		super();
		if(!_silexPtr){
			_silexPtr = _global.getSilex(this);
		}
        EventDispatcher.initialize(this);
		//empty, to start with
		_selectedObjectIds = new Array();
		_dependantLists = new Array();
	}
	
	/**
	 * Proxies acces to the data of a list. Stores the data in a buffer
	 * objects to spped up subsequent request of the same data. The buffer
	 * is reseted when the data changes on the list
	 * @param	containerUids the uids of parent list
	 * @return an array of array of ListedObjectBase
	 */
	public function getData(containerUids:Array):Array
	{
		//represents a unique key constructed from the
		//containerUids request
		var requestID:String = "";
		
		//if no containerUids has been defined,
		//then the list default data will be returned and stored
		//under the "default" key name
		if (containerUids == null)
		{
			requestID = "default";
		}
		
		//else contruct the key from the containers uids
		else
		{
			for (var i:Number = 0; i < containerUids.length; i++)
			{
				requestID += containerUids[i];
			}
		}

		//instantiate the object buffer if had just been
		//reseted
		if (_objectsBuffer == null)
		{
			_objectsBuffer = new Object();
		}
		
		//if it is the first time this particular request
		//is made, process it then store it's result
		if (_objectsBuffer[requestID] == null)
		{
			_objectsBuffer[requestID] = doGetData(containerUids);
		}
		
		//return the request with the right key
		return _objectsBuffer[requestID];
	}
	
	private function doGetData(containerUids:Array):Array
	{
		return null;
	}
	
	/**
	 * add an item
	 * implement in sub class if relevant to the listed data
	 * @param data the data to add the list object
	 * @param containerUid an optionnal param pointing to which container to add
	 * the new list object
	 * */
	public function addItem(data:Object, containerUid:String):String
	{
		return null;
	}
	
	/**
	 * delete an item
	 * implement in sub class if relevant to the listed data
	 * */
	public function deleteItem(objectId:String):Void
	{
	}
	
	/**
	 * swap item depths
	 * implement in sub class if relevant to the listed data
	 * */
	public function swapItemDepths(objectId1:String, objectId2:String):Void
	{
	}	
	
	public function getSelection():Array
	{
		return _selectedObjectIds;
	}
	
	public function select(objectIds:Array, data:Object):Void
	{
		_selectedObjectIds = objectIds;
		
		//T.y(_objectName, " select : ",_selectedObjectIds,", data : "+data);
		var eventForLocal:Object = {target:this, type:AdminApiEvent.EVENT_SELECTION_CHANGED, data:data};
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(AdminApiEvent.EVENT_SELECTION_CHANGED, _objectName, data);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
		signalDependantListsDataChanged(data);
	}
	
	/**
	 * @inheritDoc
	 * */
	public function getSortedData(containerUids:Array, filterValues:Array, filterName:String, returnKeyName:String):Array
	{
	
		var ret:Array = new Array();
		
		//if no containerUids has been definded, we use the currently selected listed objects on the parent
		// a listed object can be a property, a component, a layer...
		if (containerUids == undefined)
		{
			//return a reference to the parent list
			var parentList:IListModel = getParent();
			containerUids = parentList.getSelection();
		}
		
		var containerUidsLength:Number = containerUids.length;
		
		//we loop in the selected listed objects
		for (var i:Number = 0; i < containerUidsLength; i++)
		{
			//the object that will contained each of the selected properties
			var listedObjects:Object = new Object();
			
			//the array of listed objects object, retrieved with the current parent list Uid
			var listedObjectsList:Array = this.getData([containerUids[i]])[0];
			//if no values to filter listed objects has been defined,
			//we return them all
			if (filterValues == undefined)
			{
				var listedObjectListLength:Number = listedObjectsList.length;
				
				for (var j:Number = 0; j < listedObjectListLength; j++)
				{
					//we retrieve the value of the defined filter name
					var listedObjectFilterName:String = listedObjectsList[j][filterName];
					//then use it as the key storing the listed object
					listedObjects[listedObjectFilterName] = listedObjectsList[j];
				}
			}
			
			//else if values to filter the listed objects have been defined
			else
			{
				var listedObjectListLength:Number = listedObjectsList.length;
				
				//we loop in the list of listed objects
				for ( var k:Number = 0; k < listedObjectListLength; k++)
				{
					var filterValuesLength:Number = filterValues.length;
					
					//then we loop in the values to retrieve
					for (var l:Number = 0; l < filterValuesLength; l++)
					{
						//if the filterName property of the current listed object is among
						//the filtered values
						if (listedObjectsList[k][filterName] == filterValues[l])
						{
							if (returnKeyName != undefined)
							{
								//we store the listed object, using the return key name as key
								listedObjects[listedObjectsList[k][returnKeyName]] = listedObjectsList[k];
							}
							else
							{
								//else, if the return key name is not defined, use the filterValue value
								listedObjects[filterValues[l]] = listedObjectsList[k];
							}
							
						}
					}
				}
			} 
			
			//we push the retrieved object in the return array
			//each element of this array will represent a parent listed object
			//for instance, if we get the sorted data of the properties list model,
			//each item is a component which is the parent list of the properties
			ret.push(listedObjects);
		}
		
		return ret;
	}
	
	public function getCapabilities():Array{
		return null;
	}
	
	/**
	 * tell all the lists that are dependant on this one that their data has changed
	 * 
	 * @param data an optionnal object sent back with the data changed event
	 * */
	private function signalDependantListsDataChanged(data:Object):Void{
		//T.y("signalDependantListsDataChanged at ", _objectName,",data : "+data );
		var len:Number = _dependantLists.length;
		for(var i:Number = 0; i < len; i++){
			var listInstanceName:String = _dependantLists[i]; 
			var list:IListModel = SilexAdminApi.getInstance()[listInstanceName];
			if(!list){
				//T.y("couldn't find list with name ", listInstanceName);
				//return, so that problem in code is immediately visible
				return;
			}
			list.signalDataChanged(data);
		}
		
		
	}
	
	/**
	 * called by a timer to call a remote data changed event
	 * 
	 * @param data an optionnal data object
	 * */
	private function delayedDataChangedEventCallBack(data:Object):Void{
		//T.y("delayedDataChangedEventCallBack. interval id : ", _dataChangedIntervalId,",data : "+data); 
		clearInterval(_dataChangedIntervalId);
		var eventForLocal:Object = {target:this, type:AdminApiEvent.EVENT_DATA_CHANGED, data:data};
		dispatchEvent(eventForLocal);
		
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(AdminApiEvent.EVENT_DATA_CHANGED, _objectName, data);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
		_dataChangedIntervalId = 0;
		signalDependantListsDataChanged(data);
	}
	
	/**
	 * dispatches a DATA_CHANGED event locally and remotely(beyond AS2)
	 * The events are  expensive, so delay it and if necessary get rid of it if another one is scheduled to be dispatched. This 
	 * avoids it being triggered too often
	 * */
	public function signalDataChanged(data:Object):Void{
		//T.y("signalDataChanged at ", _objectName, ", interval id : ", _dataChangedIntervalId, ", data : "+data);
		//lose selection
		selectedObjectIds = new Array();
		
		//when the data changes, reset the buffer
		_objectsBuffer = null;
		
		if(_dataChangedIntervalId == 0){
			//no event already scheduled, so schedule one
			_dataChangedIntervalId = setInterval(this, "delayedDataChangedEventCallBack", EVENT_DELAY, data);			
		}else{
			//T.y("don't transmit remote event, already scheduled");
		}
		
	}
	
	/**
	 * reorder all the objects in the list.
	 * note: this does not check that there are no duplicates in the orderedObjectIds 
	 * @param orderedObjectIds an array of objectIds representing the wanted order. This must contain all the objectIds once and only once, or it will fail. They must be in the same layer.
	 * implement in sub class if relevant to the listed data
	 * */
	public function changeOrder(orderedObjectIds:Array):Void{
	
	}	
	
	/**
	 * @inheritDoc
	 */
	public function copy():Void
	{
		
	}
	
	/**
	 * @inheritDoc
	 */
	public function paste(targetContainerUid:String):Void
	{
		
	}
	
	/**
	 * @inheritDoc
	 */
	public function getObjectsByUids(objectsUids:Array):Array {
		return null;
	}
	
	public function getParent():IListModel
	{
		return null;
	}
	
	/**
	 * setter for selected object uids. To be overriden in inheriting classes
	 */
	public function set selectedObjectIds(value:Array):Void
	{
		_selectedObjectIds = value;
	}
	
	public function get selectedObjectIds():Array
	{
		return _selectedObjectIds;
	}
	
	/**
	* event dispatcher functions, for mixin. They are defined here as real functions rather than as callbacks to respect the interface.
	 * Their content will be ignored, so dpn't touch!!
	*/

	public function dispatchEvent(eventObj:Object):Void
	{
	}
	
	public function addEventListener(event:String, handler):Void
	{
	}
	
	public function removeEventListener(event:String, handler):Void
	{
	}
	
	
	
}
