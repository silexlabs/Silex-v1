/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * loads and manages component descriptors.
 * example of a descriptor:
 * 
 * <?xml version="1.0" encoding="utf-8"?>
<componentDescriptor version="1.0"><!-- no extension for now. see later. All components are visual for now. As such, no dom relative properties need to be mentionned here-->
	<name>Image</name>
	<as2Url>as2/Image.swf</as2Url><!-- relative to root of plugin folder -->
	<properties>
		<x>
			<type>Float</type>
			<minValue>-5000</minValue>
			<maxValue>5000</maxValue>
		</x>
		<y>
			<type>Float</type>
			<minValue>-5000</minValue>
			<maxValue>5000</maxValue>
		</y>
		<width>
			<type>Float</type>
			<minValue>-5000</minValue>
			<maxValue>5000</maxValue>
		</width>		
		<height>
			<type>Float</type>
			<minValue>-5000</minValue>
			<maxValue>5000</maxValue>
		</height>		
		<url>
			<type>String</type><!-- not optional -->
                        <isUrl>true</isUrl>
			<default>./media/logosilex.jpg</default><!-- optional -->
			<group>attributes</group><!-- could be replaced by tags, maybe? optional, default is attribute-->
			<isRegistered>true</isRegistered><!-- optional, default is true -->
			<description>the url of the media. Absolute, or relative to root of silex</description><!-- optional, defaults to name  -->

		</url>
	</properties>
</componentDescriptor>
*
 * @author Ariel Sommeria-klein http://arielsommeria.com
 */

package org.silex.adminApi;
import haxe.Log;

class ComponentDescriptorManager 
{
	private static var _instance:ComponentDescriptorManager;
	
	private var _descriptors:Array<ComponentDescriptor>;
	
	private var _onGetComponentDescriptorsResultCallBack :Void -> Void;
	
	private function new() 
	{
		//singleton
		
	}
	
	/**
	 * singleton accessor
	 * @return
	 */
	public static function getInstance():ComponentDescriptorManager {
		if (_instance == null) {
			_instance = new ComponentDescriptorManager();
		}
		return _instance;
	}
	
	/**
	 * called when the service returns data successfully
	 * @param	r
	 */
	private function onGetComponentDescriptorsResult( r : Array<Dynamic> ) {
		_descriptors = new Array<ComponentDescriptor>();
		for (untypedDescriptor in r) {
			//trace("untypedDescriptor : " +  Std.string(untypedDescriptor));
			var descriptor:ComponentDescriptor = new ComponentDescriptor();
			descriptor.componentName = untypedDescriptor.componentName;
			descriptor.className = untypedDescriptor.className;
			descriptor.as2Url = untypedDescriptor.as2Url;
			descriptor.html5Url = untypedDescriptor.html5Url;
			descriptor.specificEditorUrl = untypedDescriptor.specificEditorUrl;
			descriptor.componentRoot = untypedDescriptor.componentRoot;
			descriptor.metaData = untypedDescriptor.metaData;
			descriptor.parentDescriptorClassName = untypedDescriptor.parentDescriptorClassName;
			descriptor.properties = new Hash<Hash<String>>();
			for (propertyName in Reflect.fields(untypedDescriptor.properties)) {
				var untypedProperty:Dynamic = Reflect.field(untypedDescriptor.properties, propertyName);
				var property:Hash<String> = new Hash<String>();
				for (attributeName in Reflect.fields(untypedProperty)) {
					var untypedAttribute:Dynamic = Reflect.field(untypedProperty, attributeName);
					property.set(attributeName, untypedAttribute);
				}
				descriptor.properties.set(propertyName, property);
			}
			//flash.Lib.trace("descriptor : " +  Std.string(descriptor));
			//trace(descriptor.properties.get("x").get("minValue"));
			//trace("editableProperties : " + Std.string(descriptor.getEditableProperties()));
			_descriptors.push(descriptor);
		}
		
		//trace(findDescriptorByUrl("plugins/BaseComponents/as2/Image.cmp.swf"));
		
		if(_onGetComponentDescriptorsResultCallBack != null){
			_onGetComponentDescriptorsResultCallBack();
			_onGetComponentDescriptorsResultCallBack = null;
		}
	}
	
	/**
	 * calls the service function data_exchange.getComponentDescriptors through the silex com object. 
	 * asynchronous(web service), so pass a callback that will be called when the descriptors are loaded.
	 * note: an event system here would be nice!!
	 * @param	callBack
	 */
	public function loadDescriptors(callBack: Void -> Void):Void {
		
		untyped _global.getSilex(this).com.getComponentDescriptors(onGetComponentDescriptorsResult);
		if (_onGetComponentDescriptorsResultCallBack != null) {
			throw "_onGetComponentDescriptorsResultCallBack already set";
		}
		_onGetComponentDescriptorsResultCallBack = callBack;
		
		/*
		//test code for standalone operation
		var url = "http://localhost/silex/v1.6.1/silex_server/cgi/gateway.php";
		var c = haxe.remoting.AMFConnection.urlConnect(url);
		//c.setErrorHandler(onError);
		c.data_exchange.getComponentDescriptors.call([], onGetComponentDescriptorsResult);		
		/*
		*/
	}
	
	/**
	 * looks in the available descriptors to see which one matches the url. 
	 * @param	url
	 * @return null if none found
	 */
	public function findDescriptorByUrl(url:String):ComponentDescriptor {	
		//flash.Lib.trace("findDescriptorByUrl");
		if (_descriptors == null) {
			return null;
		}
		//flash.Lib.trace(url);
		for (descriptor in _descriptors) {
			if (descriptor.as2Url == url) {
				//flash.Lib.trace(descriptor);
				return descriptor;
			}
		}
		
		return null;
	}
	
	/**
	 * looks in the available descriptors to see which one matches the class name. 
	 * @param	className
	 * @return null if none found
	 */
	public function findDescriptorByClassName(className:String):ComponentDescriptor {	
		//flash.Lib.trace("findDescriptorByClassName" + className);
		if (_descriptors == null) {
			return null;
		}
		for (descriptor in _descriptors) {
			if (descriptor.className == className) {
				//flash.Lib.trace("findDescriptorByClassName" + descriptor);
				//trace(descriptor);
				return descriptor;
			}
		}
		
		return null;
	}	
	
	/**
	 * silex legacy components contain their own property descriptors, described in the "editableProperties" array. Use this function to mimic its structure.
	 * @return
	 */
	public function buildEditableProperties(descriptor:ComponentDescriptor):Array<Dynamic>{
		//flash.Lib.trace("buildEditableProperties");
		var editableProperties:Array<Dynamic> = new Array<Dynamic>();
		//the next next descriptor in the inheritance chain
		var nextDescriptor:ComponentDescriptor = descriptor;
		while(nextDescriptor != null){
			//flash.Lib.trace("nextDescriptor" + Std.string(nextDescriptor));
			//trace("using descriptor for class" + nextDescriptor.className);
			for (key in nextDescriptor.properties.keys()) {
				var property:Hash<String> = nextDescriptor.properties.get(key);
				var editableProperty:Dynamic = {};
				for (key in property.keys()) {
					Reflect.setField(editableProperty, key, property.get(key));
				}
				Reflect.setField(editableProperty, "name", key);
				
				//we check if a property with the same name already exists
				//in the editableProperties array. If it does, we override it
				//else, we just push it in the array
				var flagExistingProperty:Bool = false;
				for (i in 0...editableProperties.length)
				{
					if (editableProperties[i].name == key)
					{
						editableProperties[i] = editableProperty;
						flagExistingProperty = true;
						break;
					}
				}
				
				if (flagExistingProperty == false)
				{
					editableProperties.push(editableProperty);
				}
				
			}
			nextDescriptor = ComponentDescriptorManager.getInstance().findDescriptorByClassName(nextDescriptor.parentDescriptorClassName);				
		}
		return editableProperties;
	}
	
	
}