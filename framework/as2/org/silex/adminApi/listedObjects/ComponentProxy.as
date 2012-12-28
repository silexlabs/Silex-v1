/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listedObjects.ComponentClickListener;
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.adminApi.listedObjects.ListedObjectBase;
import org.silex.adminApi.util.ClipFind;
import org.silex.adminApi.util.T;
import org.silex.core.Utils;
import org.silex.link.HaxeLink;
import org.silex.ui.Layer;
import org.silex.ui.UiBase;
 /**
 * the Component proxy. A proxy for accessing and manipulating a Component remotely. The case of the component is special: it is not stocked as such in the layer, but 
 * only as an untyped load info object, referred to here as componentLoadInfo, and typed Object. 
 * So this class serves as a proxy for getting this component load info, and also has methods to identify and find the real component
 * 
 * a component must be based on UiBase, because that is where editable properties is defined
 * */

class org.silex.adminApi.listedObjects.ComponentProxy extends ListedObjectBase
{
	
	public function ComponentProxy()
	{
		super();
	}
	
	
	/**
	 * get the associated component. Note: the component does not necessarily exist!
	 * */
	public function getComponent():UiBase{
		var split:Array = uid.split("/");
		var componentInstanceName:Object = split.pop();
		var layer:Layer = getRelativeLayer();
		var ret:UiBase = layer[componentInstanceName].main;
		//T.y("getComponentFromUid " , ret);
		return ret; 
	}
	
	private static function getRelativeLayerFromUid(uid):Layer{
		var split:Array = uid.split("/");
		split.pop();
		var layer:Layer = LayerProxy.createFromUid(split.join("/")).getLayer();
		//T.y("getRelativeLayer " , layer);
		return layer;
	}
	
	/**
	 * get layer Relative the associated component
	 * */
	public function getRelativeLayer():Layer{
		return getRelativeLayerFromUid(uid);
	}
	
	private static function getIndexInRelativeLayerFromUid(uid:String){
		var split:Array = uid.split("/");		
		var componentInstanceName:Object = split.pop();
		var layer:Layer = getRelativeLayerFromUid(uid);
		var playersArray:Array = layer.players;
		var numComponentsInLayer:Number = playersArray.length; 
		for(var i:Number = 0; i < numComponentsInLayer; i++){
			var componentLoadInfo:Object = playersArray[i];
			if(componentLoadInfo._name == componentInstanceName){
				return i;
			}
		}
		//T.y("error: couldn't getIndexInRelativeLayer for comp : " , uid); 
		return -1;
		
	}
	/**
	 * get index  in Relative layer's player array
	 * */
	public function getIndexInRelativeLayer():Number{
		return getIndexInRelativeLayerFromUid(uid);
	}
	/**
	 * get the matching Component load info
	 * */
	public function getComponentLoadInfo():Object{
		var indexInPlayersArray = getIndexInRelativeLayer();
		var layer:Layer = getRelativeLayer();
		var ret:Object = layer.players[indexInPlayersArray];
		//T.y("getComponentLoadInfo : " , uid , ", returns " , ret);
		return ret;
		
	}
	
	/**
	 * open the icon associated with the component
	 * @param forceOpen if the component is editable, then it can't open
	 * the icon unless forceOpen is true. (It makes the component non-editable
	 * before opening the icon)
	 * */
	public function openIcon(forceOpen:Boolean):Void {
		
		var component:UiBase = getComponent();
		
		if (forceOpen == false)
		{
			component.openIcon();
		}
		else
		{
			if (component.isEditable == true)
			{
				component.isEditable = false;
				component.openIcon();
				component.isEditable = true;
			}
			else
			{
				component.openIcon();
			}
		}
		
	}
	
	/**
	 * set visible
	 * */
	public function setVisible(value:Boolean):Void{
		//T.y("setVisible", value);
		var component:UiBase = getComponent();
		component.isVisible = value;
		component.temporarilyVisibleInAdminMode = value;
		SilexAdminApi.getInstance().components.signalDataChanged();
	}
	
	/**
	 * get visible
	 * */
	public function getVisible():Boolean {
		//non-visual component are never visible
		if (getIsVisual() == false)
		{
			return false;
		}
		
		var component:UiBase = getComponent();
		
		return component._visible;
	}
	
	/**
	 * set editable
	 * adds/removes listener to select on click
	 * */
	public function setEditable(value:Boolean):Void{
		var component:UiBase = getComponent();
		//T.y("component setEditable.", value, ", component setEditable: ", component.setEditable);
		//T.y("isEditable before", component.isEditable);
		component.isEditable = value;
		//T.y("isEditable after", component.isEditable);
		SilexAdminApi.getInstance().components.signalDataChanged();
	}

	/**
	 * get editable
	 * */
	public function getEditable():Boolean{
		var component:UiBase = getComponent();
		
		//if a component or it's isEditable var is null
		//we return true so that it can be easily deleted
		if (component == undefined)
		{
			return true;
		}
		
		if (component.isEditable == undefined)
		{
			return true;
		}
		
		//T.y("component getEditable", component, component.isEditable);
		return component.isEditable;
	}
	
	public function getTypeArray():Array{
		var component:UiBase = getComponent();
		//T.y("getTypeArray : " , uid , component.typeArray);
		return component.typeArray;
	}
	/**
	 * create a component proxy from a layer and an index in the layer's players array
	 * */
	public static function createFromLayer(layer:Layer, playerIndex:Number):ComponentProxy{
		var componentProxy:ComponentProxy = new ComponentProxy();
		var componentLoadInfo:Object = layer.players[playerIndex];
		componentProxy.name = componentLoadInfo.label;
		componentProxy.uid = LayerProxy.getLayerUid(layer) + "/" + componentLoadInfo._name;
		return componentProxy;
	}	
	
	/**
	 * create a component proxy from a uid
	 * */
	public static function createFromUid(uid:String):ComponentProxy{
		var indexInPlayersArray = getIndexInRelativeLayerFromUid(uid);
		var layer:Layer = getRelativeLayerFromUid(uid);
		return createFromLayer(layer, indexInPlayersArray);
		
	}
	
	/**
	 * create a component proxy from a component. Look in its layer, find its index, and call createFromLayer
	 * warning, this is a brittle function. Don't use unless no alternative. 
	 * based on the name structure: _level0.layoutContainer.application.show.contentContainer_mc.content_mc.container_mc.main.logosilex_1274798591139.main
	 * is findable in a layer by its parent's name:  logosilex_1274798591139
	 * 
	 * */
	public static function createFromComponent(component:UiBase):ComponentProxy{
		var layer:Layer = Layer(component.layerInstance);
		var numLayers:Number = layer.players.length;
		var playerIndex:Number = -1;
		//T.y("component._parent._name : ", component._parent._name);
		for(var i:Number = 0; i < numLayers; i++){
			var componentLoadInfo:Object = layer.players[i];
			//T.y("componentLoadInfo._name : ", componentLoadInfo._name);
			if(componentLoadInfo._name == component._parent._name){
				playerIndex = i;
				break;
			}
		}
		if(playerIndex == -1){
			//T.y("error, component not found in layer : ", layer);
			return null;
		}else{
			return createFromLayer(layer, playerIndex);
		}
		 
	}
	
	/**
	 * either returns the components editable properties, or mimics it using the component descriptor
	 * used to support both legacy components and components with descriptors
	 * */
	public function getEditableProperties(){
		var componentLoadInfo:Object = getComponentLoadInfo(); 
		var component:UiBase = getComponent();
		var componentDescriptorManager:Object = HaxeLink.getHxContext().org.silex.adminApi.ComponentDescriptorManager.getInstance();
		//T.y(componentLoadInfo.className, componentLoadInfo )
		var componentDescriptor:Object = componentDescriptorManager.findDescriptorByClassName(componentLoadInfo.className);
		
		var editableProperties:Array;
		if(componentDescriptor){
			//component descriptor is available. Use it!
			//T.y("component descriptor available");
			editableProperties = componentDescriptorManager.buildEditableProperties(componentDescriptor);
		}else{
			editableProperties = component.editableProperties;	
		}
		//T.y("editableProperties", editableProperties);
		return editableProperties;
	}
	
	
	/**
	 * get the component descriptor. null if not available
	 * private for now, could be made public later
	 * */
	private function getComponentDescriptor():Object{
		var componentLoadInfo:Object = getComponentLoadInfo(); 
		var componentDescriptorManager:Object = HaxeLink.getHxContext().org.silex.adminApi.ComponentDescriptorManager.getInstance();
		
		if (componentLoadInfo.className != null)
		{
			return componentDescriptorManager.findDescriptorByClassName(componentLoadInfo.className);
		}
		
		return componentDescriptorManager.findDescriptorByUrl(componentLoadInfo.mediaUrl);
	}
	
	/**
	 * gets the specific editor from the component descriptor if it exists
	 * */
	public function getSpecificEditorUrl():Object{
		var componentDescriptor:Object = getComponentDescriptor();
		//T.y("getSpecificEditorUrl", componentDescriptor);
		if(componentDescriptor){
			return componentDescriptor.specificEditorUrl;
		}else{
			return null;
		}
	}
	
	/**
	 * returns the url of the icon representing the component from the descriptor
	 */
	public function getIconUrl():String
	{
		var componentDescriptor:Object = getComponentDescriptor();
		//T.y("getIconUrl", componentDescriptor);
		if(componentDescriptor){
			return componentDescriptor.metaData.pluginRelativeUrl + componentDescriptor.metaData.addComponentParams.iconUrl;
		}else{
			return null;
		}
	}
	
	/**
	 * gets the url for the as2 swf from the component load info or descriptor if it exists
	 * */
	public function getAs2Url():Object{
		
		//T.y("getSpecificEditorUrl", componentDescriptor);
		var componentLoadInfo:Object = getComponentLoadInfo();
		if (componentLoadInfo.mediaUrl != null)
		{
			return componentLoadInfo.mediaUrl;
		}
		else
		{
			var componentDescriptor:Object = getComponentDescriptor();
			if(componentDescriptor){
				return componentDescriptor.as2Url;
			}else{
				return null;
			}
		}
		
	}
	
	/**
	 * get the component's className
	 */
	public function getClassName():Object
	{
		var componentDescriptor:Object = getComponentDescriptor();
		if(componentDescriptor){
			return componentDescriptor.className;
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
		var componentDescriptor:Object = getComponentDescriptor();
		if (componentDescriptor) {
				if (componentDescriptor.metaData.isVisual != undefined)
				{
					if (componentDescriptor.metaData.isVisual == "false")
					{
						return false;
					}
					
					else
					{
						return true;
					}
				}
				else
				{
					return true;
				}
			
		}else{
			return true;
		}
	}
	
	

}