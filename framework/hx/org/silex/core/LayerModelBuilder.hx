/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * use this to build a Layer Model object that can be saved from the actual Layer. 
 * in this class "specific" property name means a property name as described for the virtual machine, and "generic" property name means a property name that is 
 * virtual machine agnostic. For example "_x" is the as2 specific form of "x", which is generic. For most properties, these 2 are the same, the ones where there
 * is a difference usually  being DOM  related. 
 * note: if the component clip contains a "main" clip, this class uses that as the component and the clip itself. This covers the historical 
 * components that are all in a "main" clip because there is no AS2 document class. However this could screw up if there is a "main" clip but it's not 
 * the wrapped component.
 * @author Ariel Sommeria-klein http://arielsommeria.com
 */

package org.silex.core;
import flash.Lib;
import flash.SharedObject;
import haxe.Log;
import org.silex.adminApi.ComponentDescriptor;
import org.silex.adminApi.ComponentDescriptorManager;
import org.silex.core.component.As2DomConverter;
import org.silex.core.component.IDomConverter;
import org.silex.core.component.LegacyPlayerTypes;
import org.silex.publication.ActionModel;
import org.silex.publication.ComponentModel;
import org.silex.publication.LayerModel;
import org.silex.publication.SubLayerModel;

class LayerModelBuilder 
{
	public function new() 
	{
		
	}
	
	
	/**
	*  sets the properties in a component model using the component's descriptor.
	*  loops to go through the different parent descriptors
	*  doesn't store a property if its value is undefined or null. 
	*  */
	private function buildPropertiesUsingDescriptor(component:Dynamic, componentModel:ComponentModel, descriptor:ComponentDescriptor){		
		//the next next descriptor in the inheritance chain
		var nextDescriptor:ComponentDescriptor = descriptor;
		var domConverter:IDomConverter = new As2DomConverter();
		while(nextDescriptor != null){
			//flash.Lib.trace("nextDescriptor" + Std.string(nextDescriptor));
			//trace("using descriptor for class" + nextDescriptor.className);
			for (genericPropertyName in nextDescriptor.properties.keys()) {
				var propertyHash = nextDescriptor.properties.get(genericPropertyName);
				var shouldSaveProperty:Bool = propertyHash.get("isRegistered") != "false";
				if(shouldSaveProperty){					
					var specificPropertyName:String = domConverter.genericPropertyNameToSpecific(genericPropertyName);
					var propertyCurrentValue:Dynamic = Reflect.field(component, specificPropertyName);
					//don't store if undefined or null
					if(propertyCurrentValue == null){
						continue;
					}	
					//.Lib.trace("store property " + genericPropertyName + propertyCurrentValue);
					componentModel.properties.set(genericPropertyName, propertyCurrentValue);
				}
			}
			nextDescriptor = ComponentDescriptorManager.getInstance().findDescriptorByClassName(nextDescriptor.parentDescriptorClassName);				
		}
		//flash.Lib.trace("componentModel" + Std.string(componentModel));
	}
	
	/**
	*  sets the properties in a component model using the components editable properties. Use for components that don't have a descriptor
	*  */
	private function buildComponentPropertiesUsingEditableProperties(component:Dynamic, componentModel:ComponentModel, editableProperties:Dynamic){
		var domConverter:IDomConverter = new As2DomConverter();
		for (field in Reflect.fields(editableProperties)) {
			var editableProperty:Dynamic = Reflect.field(editableProperties, field);
			if(editableProperty.isRegistered){
				var specificPropertyName:String = editableProperty.name;
				var genericPropertyName:String = domConverter.specificPropertyNameToGeneric(specificPropertyName);
				var propertyCurrentValue:Dynamic = Reflect.field(component, specificPropertyName);
				//don't store if undefined or null
				if(propertyCurrentValue == null){
					continue;
				}					
				componentModel.properties.set(genericPropertyName, propertyCurrentValue);
			}
		}
	}
	
	private function buildComponentModel(componentLoadInfo:Dynamic, subLayerContainingComponent:Dynamic):ComponentModel {
		var componentModel:ComponentModel = new ComponentModel();
		var component:Dynamic = subLayerContainingComponent[componentLoadInfo._name];
		if (component.main) {
			component = component.main;
		}
		
		//get descriptor, if exists
		var descriptor:ComponentDescriptor =  null;
		
		if (componentLoadInfo.className != null)
		{
			descriptor = ComponentDescriptorManager.getInstance().findDescriptorByClassName(componentLoadInfo.className);
		}
		else if(componentLoadInfo.type == LegacyPlayerTypes.COMPONENT){
			descriptor = ComponentDescriptorManager.getInstance().findDescriptorByUrl(componentLoadInfo.mediaUrl);			
		}else{
			var className:String = LegacyPlayerTypes.playerType2ComponentClass.get(componentLoadInfo.type);
			//flash.Lib.trace("className" + className);
			descriptor = ComponentDescriptorManager.getInstance().findDescriptorByClassName(className);		
		}
		
		//flash.Lib.trace("descriptor " + descriptor);
		//flash.Lib.trace("componentLoadInfo.className " + componentLoadInfo.className);
		//build properties
		if (descriptor != null) {
			//trace("component has descriptor" + descriptor);
			buildPropertiesUsingDescriptor(component, componentModel, descriptor);
			componentModel.as2Url = componentLoadInfo.mediaUrl;
			componentModel.className = descriptor.className;
			componentModel.componentRoot = descriptor.componentRoot;
			componentModel.metaData = descriptor.metaData;
			//flash.Lib.trace("descriptor.html5Url" + descriptor.html5Url);
			componentModel.html5Url = descriptor.html5Url;
				
		}else if (component.editableProperties != null) {
			var editableProperties:Dynamic = component.editableProperties;
			//flash.Lib.trace("component has editableProperties : " + Std.string(editableProperties));
			buildComponentPropertiesUsingEditableProperties(component, componentModel, editableProperties);
			componentModel.as2Url = componentLoadInfo.mediaUrl;
		}
		componentModel.properties.set(ComponentModel.FIELD_PLAYER_NAME, component.playerName);
		
		
		//store actions
		//trace("actions"  + Std.string(component.actions));
		for(i in 0...component.actions.length) {
			var componentAction:Dynamic = component.actions[i];
			//trace("componentAction" + Std.string(componentAction));
			var actionModel:ActionModel = new ActionModel();
			actionModel.functionName = componentAction.functionName;
			actionModel.modifier = componentAction.modifier;
			for (j in 0...componentAction.parameters.length) {
				var parameter:String = cast(componentAction.parameters[j], String);
				actionModel.parameters.add(parameter);
			}
			componentModel.actions.add(actionModel);
		}
		
		
		//flash.Lib.trace("componentModel" + Std.string(componentModel));
		return componentModel;
	}
	
	/**
	 * The only public entry point to the class. analyzes a Layer and returns a model for it
	 * yes this code is confusing, because of the change in names. It should disappear hopefully.
	 * old layout = layer
	 * old layer = sublayer
	 * @param	layer The layer(old org.silex.core.Layout) to analyze. untyped because AS2 object
	 * @return
	 */
	public function buildLayerModel(layer:Dynamic):LayerModel {
		flash.Lib.trace("buildLayerModel");
		var subLayers:Dynamic = layer.layers;
			//trace("buildLayerModel");
		var layerModel:LayerModel = new LayerModel();
		for (i in 0...subLayers.length) {
			//trace("buildLayerModel. field" +  field);
			var subLayer:Dynamic = subLayers[i];
			var componentLoadInfos:Dynamic = subLayer.players;
			var subLayerModel:SubLayerModel = new SubLayerModel();
			var zIndexCounter:Int = 0;
			for (j in 0...componentLoadInfos.length) {
			//	trace("buildSubLayerModel. field" +  field);
				var componentLoadInfo:Dynamic = componentLoadInfos[j];
				var componentModel:ComponentModel = buildComponentModel(componentLoadInfo, subLayer);
				subLayerModel.components.add(componentModel);
				subLayerModel.id = subLayer.name;
				subLayerModel.zIndex = zIndexCounter;
				zIndexCounter++;
				
			}
			layerModel.subLayers.add(subLayerModel);
			
		}
		//untyped org.silex.adminApi.util.T.t("layerModel", layerModel);
		return layerModel;
	}
	
}