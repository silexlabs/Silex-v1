/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.listedObjects.PropertyProxy;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listModels.Components;
import org.silex.adminApi.listModels.adding.ComponentAddInfo;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.adminApi.util.ComponentHelper;
import org.silex.adminApi.util.T;
import org.silex.core.plugin.HookEvent;
import org.silex.core.plugin.HookManager;
import org.silex.ui.Layer;
import org.silex.ui.LayerHooks;
import org.silex.ui.UiBase;
import org.silex.core.Utils;
import org.silex.link.HaxeLink;

/**
 * Delegate class for Components List Model. Handles adding a component to a layer
 */
class org.silex.adminApi.listModels.adding.ComponentAdder{
	
	private var _components:Components; 
	
	private var _pendingComponents:Array;
	/**
	 * constructor
	 * */
	public function ComponentAdder(components:Components){
		_components = components;
		_pendingComponents = new Array();
		//doesn't work! use hook instead
		//_silexPtr.application.addEventListener("allPlayersLoaded", Utils.createDelegate(this, onAllPlayersLoaded));
		
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.addHook(LayerHooks.REGISTER_PLAYER_START_HOOK_UID, Utils.createDelegate(this, onAllPlayersLoaded));
		hookManager.addHook(LayerHooks.COMPONENT_LOAD_ERROR, Utils.createDelegate(this, onComponentLoadError));
		
		//T.y("ComponentAdder constructor");
		
	}
	
	/**
	 * call the method on the Components object dispatching an error event
	 */
	private function onComponentLoadError():Void
	{
		_components.signalComponentCreatedError();
	}
	
	
	/**
	 * we listen to LayerHooks.REGISTER_PLAYER_START_HOOK_UID, that is called by a layer when a player registers with it. This is useful when we add a component to the 
	 * stage, so that a data changed event is dispatched once it is loaded and its properties are set
	 * we store in an array pending components (components that have not said they have been created)
	 * hookData is an array with one element, the loaded component.
	 * match it to pending components and if yes call signalComponentCreated on Components
	 * note: we can't do this without matching, because components are created all the time during navigation, and we're only interested 
	 * in those created through addItem
	 * */ 
	private function onAllPlayersLoaded(event:HookEvent):Void {
	
		
	
		//T.y("onAllPlayersLoaded ", event.hookData);
		var loadedComponent:UiBase = event.hookData[0];
		var compUid:String = ComponentHelper.getComponentUid(loadedComponent);
		//T.y("comp to string ", compUid);		
		//T.y("_pendingComponents : ", _pendingComponents);
		var len:Number = _pendingComponents.length;
		//T.y("len : "+ len);
		for(var i:Number = 0; i < len;i++){
			var compInstanceName:String = _pendingComponents[i].instanceName;
			var pos:Number = compUid.indexOf(compInstanceName);
			//T.y("pos", pos);
			if(pos > 0){
				//comp matches! remove from _pendingComponents and signal. set editable to true
				//we retrieve the componentAddInfo from the _pendingComponents array
				var componentAddInfo:ComponentAddInfo = _pendingComponents[i].componentAddInfo;
				_pendingComponents.splice(i, 1);
				var componentProxy:ComponentProxy = ComponentProxy.createFromComponent(loadedComponent);
				
				//init the components properties before sending the event
				initComponentProperties(componentProxy.uid, componentAddInfo);
				//we signal the component creation 
				_components.signalComponentCreated();
				componentProxy.setEditable(true);
				return;
			}
		}
	}	
	
	/**
	 * this is the internal name of the component. It must be unique to avoid collisions, and give some information about what it is
	 * */
	private function generateInstanceName(componentAddInfo:ComponentAddInfo):String{
		//date to avoid name collision
		var my_date:Date = new Date();
		var	aleaNumber:Number = Math.round(my_date.getTime());
		return aleaNumber.toString();
	}
	
	/**
	 * determine the init object to pass to the new item added to the layer, depending on the component add info
	 * */
	private function getInitObj(componentAddInfo:ComponentAddInfo):Object{
		switch(componentAddInfo.type){
			case ComponentAddInfo.TYPE_AUDIO:
			case ComponentAddInfo.TYPE_VIDEO:
			case ComponentAddInfo.TYPE_IMAGE:
				var mediaUrl:String = componentAddInfo.metaData;
				return {name_str: generatePlayerName(componentAddInfo.playerName, this), media_str: mediaUrl};
			case ComponentAddInfo.TYPE_TEXT:
				return {name_str: generatePlayerName(componentAddInfo.playerName, this), text_str: componentAddInfo.metaData};
			case ComponentAddInfo.TYPE_FRAMED_LOCATION:
				return {location:componentAddInfo.metaData,name_str:generatePlayerName(componentAddInfo.playerName, this)};
			case ComponentAddInfo.TYPE_FRAMED_EMBEDDED_OBJECT:
				return {embededObject:componentAddInfo.metaData,name_str:generatePlayerName(componentAddInfo.playerName, this)};
			case ComponentAddInfo.TYPE_FRAMED_HTML_TEXT:
				return {htmlText:componentAddInfo.metaData,name_str:generatePlayerName(componentAddInfo.playerName, this)};
			case ComponentAddInfo.TYPE_COMPONENT:
				return null;
		}
		//T.y("getInitObj failed, type unknown : ", componentAddInfo.type);
		return null;
		
	}
	/**
	 * Detect name duplication and add a number after the name if a component already has this name. For example, if you put 3 times the same image on stage, they will be named image1, image2, image3.
	 * Dirty hack, should be done before, when playerName is set. Probably in createFromUntyped.
	 */
	public static function generatePlayerName(playerName:String, instance:Object):String
	{
		if (_global.getSilex(instance).application.getPlayerByName(playerName) != null)
		{
			var playerIndex:Number = 1;
			do
			{
				playerIndex++;
			}while (_global.getSilex(instance).application.getPlayerByName(playerName+playerIndex.toString()) != null)

			//trace("generatePlayerName - name already exist - returns "+ playerName+playerIndex.toString());
			return playerName+playerIndex.toString();
		}
		return playerName;
	}
	
	/**
	 * get the information to add to the layer's player array. This is the information that the layer needs to instanciate the component
	 * */
	private function getComponentLoadInfo(componentAddInfo:ComponentAddInfo, instanceName:String):Object{
		switch(componentAddInfo.type){
			case ComponentAddInfo.TYPE_AUDIO:
			case ComponentAddInfo.TYPE_VIDEO:
			case ComponentAddInfo.TYPE_IMAGE:
			case ComponentAddInfo.TYPE_TEXT:
				return {_name:instanceName, type:componentAddInfo.type, label:generatePlayerName(componentAddInfo.playerName, this)};
			case ComponentAddInfo.TYPE_FRAMED_LOCATION:
			case ComponentAddInfo.TYPE_FRAMED_EMBEDDED_OBJECT:
			case ComponentAddInfo.TYPE_FRAMED_HTML_TEXT:
				return {_name:instanceName, type:"AsFrame", label:generatePlayerName(componentAddInfo.playerName, this)};
			case ComponentAddInfo.TYPE_COMPONENT:
				return { _name:instanceName, type:componentAddInfo.type, mediaUrl: componentAddInfo.metaData, 
				label:generatePlayerName(componentAddInfo.playerName, this), className:componentAddInfo.className};
		}
		//T.y("getComponentLoadInfo failed, type unknown : ", componentAddInfo.type);
		return null;		
	}	
	
	
	/**
	 * add an item to a layer. 
	 * If no layer uid is provided, add to the first selected layer
	 * @param data The url of the media to add
	 * @param layerUid an optionnal layer uid to which add the component to
	 * @returns uid of created component
	 * */
	public function addItem(data:Object, layerUid:String):String
	{
		//T.y("add item", data);
		var componentAddInfo:ComponentAddInfo = ComponentAddInfo.createFromUntyped(data);
		if(!componentAddInfo){
			return null;
		}
	
		var selectedLayer:Layer;
		
		//the uid is either provided
		if (layerUid != undefined)
		{
			selectedLayer = LayerProxy.createFromUid(layerUid).getLayer();
		}
		//or is the firsyt among the selected layers
		else
		{
			var selectedLayerUids:Array = SilexAdminApi.getInstance().layers.getSelection();
			if(selectedLayerUids.length == 0){
				T.y(selectedLayerUids.length + " at least one layer must be selected");
				return null;
			}
			selectedLayer = LayerProxy.createFromUid(selectedLayerUids[0]).getLayer();
		}
		
		if(!selectedLayer){
			T.y("layer not found. add failed");
			return null;
		}
		
		var instanceName:String = generateInstanceName(componentAddInfo);
		var initObj:Object = getInitObj(componentAddInfo);
		var componentLoadInfo:Object = getComponentLoadInfo(componentAddInfo, instanceName);
		//T.y("instanceName : ", instanceName, ", initObj : ", initObj, " componentLoadInfo : ", componentLoadInfo);
		selectedLayer.loadPlayer(componentLoadInfo, initObj);
		
		//add to players in first position
		selectedLayer.players.unshift(componentLoadInfo);
		var componentProxy:ComponentProxy = ComponentProxy.createFromLayer(selectedLayer, 0);
		
		//make it editable:
		componentProxy.setEditable(true);
		
		//set layout to dirty
		_global.getSilex(this).application.getLayout(selectedLayer).isDirty=true;		
		
		
		_pendingComponents.push({instanceName:instanceName, componentAddInfo:componentAddInfo});

		
		return componentProxy.uid;
		
	}	
	
	/**
	 * init the created component with the properties value given as parameters
	 * @param	componentUid the UId of the component to init
	 * @param	componentAddInfo the componentAddInfo object used to create the component
	 */
	private function initComponentProperties(componentUid:String, componentAddInfo:ComponentAddInfo):Void
	{
		
		//get a reference to the componentDescriptorManager to retrieve the component descriptor
		var componentDescriptorManager:Object = HaxeLink.getHxContext().org.silex.adminApi.ComponentDescriptorManager.getInstance();
		
		//retrieve the component descriptor using it's className
		var componentDescriptor:Object = componentDescriptorManager.findDescriptorByClassName(componentAddInfo.className);
		
		//an arrray storing the descriptor, plus all of it's parents
		var componentDescriptors:Array = new Array(componentDescriptor);
		
		//retrieve all the parent descriptors of a component
		while (getComponentParentDescriptors(componentDescriptor) != null)
		{
			var newDescriptor:Object = getComponentParentDescriptors(componentDescriptor);
			componentDescriptors.push(newDescriptor);
			componentDescriptor = newDescriptor;
		}

		
		//extract the initObj from the componentAddInfo object
		var initObj:Object = componentAddInfo.initObj;
		
		//initObj = descriptorDefaultValues;
		
		//recreate the componentProxy from the given url
		var addedComponent:ComponentProxy = ComponentProxy.createFromUid(componentUid);
		//retrieve all of the component's properties
		var properties:Array = SilexAdminApi.getInstance().properties.getData([componentUid])[0];
		
		var propertiesLength:Number = properties.length;
		var propertiesIdx:Number = 0;
		//loop in all of the properties
		for (propertiesIdx = 0 ; propertiesIdx < propertiesLength; propertiesIdx++)
		{
			
			//if the name of one of the properties matches a key
			//of the init object
			var propertyName:String = properties[propertiesIdx].name;
			var property:PropertyProxy = properties[propertiesIdx];
			
			if (initObj[propertyName] != null )
			{
				//update the value of the property with the value from the init object
				property.updateCurrentValue(initObj[propertyName]);
			}
			
			//else we search the property defaultValues of the descriptors
			else
			{
				var componentDescriptorsLength:Number = componentDescriptors.length;
				
				//we loop in the retrieved descriptors
				for (var i:Number = 0; i < componentDescriptorsLength; i++)
				{
					//we get the current descriptor properties (it is a Haxe hashTable)
					var componentDescriptorProperties:Object = componentDescriptors[i].properties;
						//we search if a default value has been defined for this proeprty using Haxe hash table's methods
						//(we don't init the proeprty if it is the player name)
						if (componentDescriptorProperties.get(propertyName).get("defaultValue") != undefined
						&& propertyName != "playerName")
						{
						
						//if it exists, we store the value. It is returned from the XML as a string	
						var untypedValue:String = componentDescriptorProperties.get(propertyName).get("defaultValue");
					
						//we type the value based on the property type
						//then update the value of the property
						switch (property.type)
						{
							case "Boolean":
							if (untypedValue == "true")
							{
								property.updateCurrentValue(true);
							}
							
							else 
							{
								property.updateCurrentValue(false);
							}
							break;
							
							case "Float":
							case "Integer":
								property.updateCurrentValue(Number(untypedValue));
							break;
							
							case "Array":
								var untypedArray:Array = untypedValue.split(",");
								var typedArray:Array;
								typedArray = getTypedArray(untypedArray, property.subType);
								property.updateCurrentValue(typedArray);
							
							break;
							
							default:
								property.updateCurrentValue(String(untypedValue));
							break;
						}
						
						break;
					
					}
				}
			}
			
		
		}
	}
	
	private function getTypedArray(untypedArray:Array, type:String):Array
	{
		var ret:Array = new Array();
		
		switch (type)
		{
			case "Gradient":
			for (var i:Number = 0; i < untypedArray.length; i++)
			{
				ret.push(Number(untypedArray[i]));
			}
			break;
			
			case "String":
			for (var i:Number = 0; i < untypedArray.length; i++)
			{
				ret.push(String(untypedArray[i]));
			}
			break;
			
			default:
			for (var i:Number = 0; i < untypedArray.length; i++)
			{
				ret.push(String(untypedArray[i]));
			}
			break;
			
		}
		
		return ret;
	}
	
	/**
	 * search for a parent descriptor and returns it if found
	 * @param	componentDescriptor the descriptor that will be searched
	 * @return the found parent descriptor
	 */
	private function getComponentParentDescriptors(componentDescriptor:Object):Object
	{
		var componentDescriptorManager:Object = HaxeLink.getHxContext().org.silex.adminApi.ComponentDescriptorManager.getInstance();
		
		
		if (componentDescriptorManager.findDescriptorByClassName(componentDescriptor.parentDescriptorClassName) == undefined)
		{
			return null;
			
		}
		
		else
		{
			return componentDescriptorManager.findDescriptorByClassName(componentDescriptor.parentDescriptorClassName);
		}

	}
	
	
}