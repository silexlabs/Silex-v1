/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import Base64.*;

import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listModels.Components;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.listedObjects.ListedObjectBase;
import org.silex.adminApi.util.ClipFind;
import org.silex.adminApi.util.ComponentHelper;
import org.silex.adminApi.util.T;
import org.silex.core.Layout;
import org.silex.link.HaxeLink;
import org.silex.ui.Layer;
import org.silex.ui.UiBase;
 /**
 * the Property proxy. A proxy for accessing and manipulating a Property remotely.
 * 
 * note, a property is on a component(uibase), not a ComponentLoadInfo. 
 * This is due to the internal structure of silex, where components can be referred to without necessarily being loaded
 * 
 * note: all strings are received base64 encoded, because ExternalInterface corrupts certain characters
 * see http://mihai.bazon.net/blog/externalinterface-is-unreliable
 * update : its only for outgoing strings when compiled for Flash8. 
 * So do the encoding only when sending from AS2 to AS3, not the other way.
 * */

class org.silex.adminApi.listedObjects.PropertyProxy extends ListedObjectBase
{
	/**
	 * the silex type
	 * */
	public var type:String;
	
	/**
	 * a subtype for the property to better qualilfy it.
	 * ex: Enum, RichText, Url
	 */
	public var subType:String;
	
	/**
	 * the current value. No strong type yet. 
	 * */
	public var currentValue:Object;
	

	/**
	 * find the component to whom this property belongs
	 * */
	private function getRelativeComponent():UiBase{
		var split:Array = uid.split("/");
		var propertyName:Object = split.pop();
		var component:UiBase = ComponentHelper.getComponent(split.join("/"));
		//T.y("getRelativeComponent : ", component);
		return component;
	}
	
	/**
	 * changes the current value in the proxy, updates the component's property, and does everything necessary so that the change is taken into account
	 * 
	 * @param newValue the new value to give to the property
	 * @param orginatorId an Id given by the plugin updating the property, so that he can know he is the originator of this updated
	 * when the DATA_CAHNGED event comes back to him
	 * */
	public function updateCurrentValue(newValue:Object, originatorId:String):Void {
		
		SilexAdminApi.getInstance().historyManager.addUndoableAction(
		new HaxeLink.getHxContext().org.silex.adminApi.undoableActions.UpdatePropertyValue(this.uid, this.currentValue));

		var component:UiBase = getRelativeComponent();
		if(!component){
			//component doesn't exist
			T.y("component not found, couldn't update property");
			return;
		}
		if(name == "playerName"){
			//special case for playerName property. The layer's players array must also be updated
			var componentProxy = ComponentProxy.createFromComponent(component);
			var componentLoadInfo:Object = componentProxy.getComponentLoadInfo();
			//T.y("old player name on load info : ", componentLoadInfo.label);
			componentLoadInfo.label = newValue;
		}
		
		var domConverter:Object = new HaxeLink.getHxContext().org.silex.core.component.As2DomConverter();
		var platformSpecificPropertyName:String = domConverter.genericPropertyNameToSpecific(name);		
		//T.y("updateCurrentValue of ", name, "platformSpecificPropertyName", platformSpecificPropertyName, "old : ", component[platformSpecificPropertyName], ", setting to ", newValue);
		component[platformSpecificPropertyName] = newValue;
		
		//refresh the Relative layout
		component.layoutInstance.isDirty = true;
		
		SilexAdminApi.getInstance().properties.signalDataChanged(originatorId);
	}
	
	/**
	 * generate a uid for a Property, that can be used to find the Property again
	 * */
	public static function getPropertyUid(component:UiBase, propertyIndex:Number):String{
		var ret:String = ComponentHelper.getComponentUid(component) + "/" + propertyIndex;
		//T.y("getPropertyUid : ", ret); 
		return ret;		
	}
	
	/**
	 * create a PropertyProxy from a component and an index in its editableProperties array. 
	 * */
	public static function createPropertyProxyFromComponent(component:UiBase, propertyIndex:Number, editableProperties:Array):PropertyProxy{
		//T.y("createPropertyProxyFromComponent", arguments);
		var propertyProxy:PropertyProxy = new PropertyProxy();
		var untypedProperty:Object = editableProperties[propertyIndex];
		for(var key:String in untypedProperty){
			propertyProxy[key] = untypedProperty[key];
		}
		
		var domConverter:Object = new HaxeLink.getHxContext().org.silex.core.component.As2DomConverter();
		//T.y("domConverter", domConverter);

		//get the specific and generic names. This assumes that a name that is already generic will remain unchanged
		var genericPropertyName:String = domConverter.specificPropertyNameToGeneric(untypedProperty.name);
		var platformSpecificPropertyName:String = domConverter.genericPropertyNameToSpecific(untypedProperty.name);
		propertyProxy.name = genericPropertyName;
		//T.y("platformSpecificPropertyName", platformSpecificPropertyName); 
		propertyProxy.currentValue = component[platformSpecificPropertyName];

		
		//T.y("createPropertyProxyFromComponent. propertyProxy.name", propertyProxy.name, "propertyProxy.currentValue", propertyProxy.currentValue);
		propertyProxy.uid = getPropertyUid(component, propertyIndex);
		return propertyProxy;
	}	
	
	/**
	 * create a PropertyProxy from its uid. 
	 * */
	public static function createPropertyProxyFromUid(propertyUid:String):PropertyProxy{
		var split:Array = propertyUid.split("/");
		var propertyIndex:Number = Number(split.pop());
		var component:UiBase = UiBase(ClipFind.findClip(split));
		var componentProxy:ComponentProxy = ComponentProxy.createFromComponent(component);
		var editableProperties:Array = componentProxy.getEditableProperties();		
		return createPropertyProxyFromComponent(component, propertyIndex, editableProperties);
	}	
	
	
}