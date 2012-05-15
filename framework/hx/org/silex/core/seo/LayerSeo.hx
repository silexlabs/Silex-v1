/*This file is part of Silex - see http://projects.silexlabs.org/?/silex
Silex is © 2010-2011 Silex Labs and is released under the GPL License:
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * class used to read & write a seo.xml v2 file to/from a LayerSeoModel.
 * 
 * @author	Raphael Harmel
 * @version 1.0
 * @date   2011-05-25
 */

package org.silex.core.seo;

import php.FileSystem;
import php.Lib;
import php.NativeArray;
import php.io.File;
import org.silex.core.XmlUtils;
import org.silex.core.seo.Constants;
import org.silex.core.seo.LayerSeoModel;

class LayerSeo
{
	// CONSTANTS DEFINING V2 SEO XML NODE NAMES. some inline have been removed because of "not supported in recursive loops" warning.
	static var SEO_DATA_NODE_NAME:String = 'seoData';
	static var VERSION_ATTRIBUTE_NAME:String = 'version';
	static var VERSION_ATTRIBUTE_VALUE:String = '2';
	static var LAYER_SEO_NODE_NAME:String = 'layerSeo';
	static var DEEPLINK_ATTRIBUTE_NAME:String = 'deeplink';
	static inline var COMPONENTS_NODE_NAME:String = 'components';
	// CONTENT_NODE_NAME is sent from AS and corresponds to COMPONENTS_NODE_NAME in the V2 xml format.
	static var CONTENT_NODE_NAME:String = 'content';
	static inline var COMPONENT_NODE_NAME:String = 'component';
	static var LINKS_NODE_NAME:String = 'links';
	static inline var LINK_NODE_NAME:String = 'link';
	
	
	/**
	 * reads a seo file and returns the Php Native Array LayerSeoModel equivalent for the specified deeplink.
	 * 
	 * inputs: a seo file's path, a deeplink
	 * returns: Php Native Array LayerSeoModel equivalent
	 */
	public static function read(fileName:String, deeplink=""):NativeArray
	{
		// init
		var layerSeoModel:LayerSeoModel;
		var layerSeoNativeArray:NativeArray = null;
		
		// read Xml file and get corresponding LayerSeoModel
		layerSeoModel = readLayerSeoModel(fileName, deeplink);
		
		// get corresponding Native Array
		layerSeoNativeArray = layerSeoModel2PhpArray(layerSeoModel);
		
		// returns it
		return layerSeoNativeArray;		
	}

	/**
	 * reads a xml seo file and returns the LayerSeoModel equivalent for the specified deeplink.
	 * 
	 * inputs: a seo file's path, a deeplink
	 * returns: LayerSeoModel equivalent
	 */
	public static function readLayerSeoModel(fileName:String, deeplink=""):LayerSeoModel
	{
		// read Xml file
		var layerSeoXml:Xml = readXml(fileName, deeplink);
		var layerSeoModel:LayerSeoModel;
		var layerSeoNativeArray:NativeArray = null;
		
		// get corresponding LayerSeoModel
		layerSeoModel = xml2LayerSeoModel(layerSeoXml);
		
		// get corresponding Native Array
		//layerSeoNativeArray = layerSeoModel2PhpArray(layerSeoModel);
		
		// returns it
		return layerSeoModel;
	}

	
	/**
	 * reads a seo file and returns the XML content without indent for a specific deeplink.
	 * 
	 * inputs: a seo file's path, a deeplink
	 * returns: an un-indented layerSeo XML
	 */
	public static function readXml(fileName:String, deeplink=""):Xml
	{
		if (FileSystem.exists(fileName))
		{
			var layerSeoXml:Xml = Xml.createElement('root');
			var layerSeoString:String;
			
			// Read file
			layerSeoString = File.getContent(fileName);
			
			// checks if layer file is v1 (contains '<element'), and in that case stop execution as v1 files are not parsable by the php haxe parser
			if (layerSeoString.toLowerCase().indexOf('<element') == -1)
			{
				// check if file is not empty or having a signe empty node (avoids errors)
				if ( (layerSeoString != '') && (layerSeoString != '<>') && (layerSeoString != '</>') )
				{
					// parse data to Xml
					layerSeoXml = Xml.parse(layerSeoString);
					// remove indent
					layerSeoXml = XmlUtils.cleanUp(layerSeoXml.firstElement());
					
					// if the existing layerSeo xml file is v2 (first element is <seoData version="2">)
					var childElement:Xml;
					if ((layerSeoXml.nodeName == SEO_DATA_NODE_NAME) && (layerSeoXml.get(VERSION_ATTRIBUTE_NAME) == VERSION_ATTRIBUTE_VALUE ))
					{
						var emptyDeeplinkNode:Xml = Xml.createElement('root');
						
						// loop over all children to find the layerSeo node with the correct deeplink attribute
						for ( childElement in layerSeoXml.elementsNamed(LAYER_SEO_NODE_NAME))
						{
							// if <layerSeo deeplink="deeplink"> node is found in layerSeoXmlOriginal, return it
							if (childElement.get(DEEPLINK_ATTRIBUTE_NAME) == deeplink)
							{
								return childElement;
							}
							
							// if <layerSeo deeplink=""> node is found in layerSeoXmlOriginal, set emptyDeeplinkNode to this value
							if (childElement.get(DEEPLINK_ATTRIBUTE_NAME) == '')
							{
								emptyDeeplinkNode = childElement;
							}
						}
						// in case deeplink has not been found, return emptyDeeplinkNode
						return emptyDeeplinkNode;
					}
				}
			}
		}
		return null;
	}

	/**
	 * converts a seo xml to a LayerSeoModel.
	 * 
	 * inputs: a seo xml
	 * returns: a LayerSeoModel
	 */
	public static function xml2LayerSeoModel(xml:Xml):LayerSeoModel
	{
		var layerSeoModel:LayerSeoModel = Utils.createLayerSeoModel();
		//layerSeoModel.components = new Array<ComponentSeoModel>();
		var componentSeoModel:ComponentSeoModel;
		var componentSeoLinkModel:ComponentSeoLinkModel = null;
		
		if(xml != null)
		{
			// for all xml's elements nodes
			for (layerSeoProp in xml.elements())
			{
				// TODO: a check on LAYER_SEO_PROPERTIES
				//trace(layerSeoProp.nodeName + ' - ' + Reflect.hasField(layerSeoModel,layerSeoProp.nodeName));
				// if node is one of the layerSeoModel base properties
				//if (Reflect.hasField(LAYER_SEO_PROPERTIES,layerSeoProp.nodeName))
				//{
				//trace(layerSeoProp.nodeName);
					// if nodeName is not components (i.e. normal properties)
					if (layerSeoProp.nodeName != COMPONENTS_NODE_NAME)
					{
						// checks if layerSeoProp has at least a child (avoids errors)
						if (layerSeoProp.firstChild() != null)
						{
							Reflect.setField(layerSeoModel, layerSeoProp.nodeName, layerSeoProp.firstChild().nodeValue);
						}
					}
					// if nodeName is components (i.e. array of component)
					else
					{
						// for all components, fill componentSeoModel with component's parameters
						for (component in layerSeoProp.elements())
						{
							componentSeoModel = null;
							componentSeoModel.specificProperties = new Hash<String>();
							componentSeoModel.links = new Array<ComponentSeoLinkModel>();
							// for all component properties
							for (componentProp in component.elements())
							{
								// if nodeName is not links (i.e. normal properties)
								if (componentProp.nodeName != LINKS_NODE_NAME)
								{
									// checks if componentProp has at least a child (avoids errors)
									if (componentProp.firstChild() != null)
									{
										var isGenericProperty:Bool = false;
										// loop to check if component property is part of the generic properties
										for (componentGenericPropertyName in Constants.COMPONENT_GENERIC_PROPERTIES.iterator())
										{
											// is component property part of the generic properties ?
											if (componentProp.nodeName == componentGenericPropertyName)
											{
												Reflect.setField(componentSeoModel, componentGenericPropertyName, componentProp.firstChild().nodeValue);
												isGenericProperty = true;
												break;
											}
										}
										// if property is specific and if it is not a link, add the property to specificProperties
										if ( !isGenericProperty && (componentProp.nodeName != 'links') )
										{
											componentSeoModel.specificProperties.set(componentProp.nodeName, componentProp.firstChild().nodeValue);
										}
									}

								}
								// if nodeName is links (i.e. array of link)
								else
								{
									// for all links
									for (link in componentProp.elements())
									{
										//componentSeoLinkModel = new ComponentSeoLinkModel();
										componentSeoLinkModel = null;
										// for all link properties
										for (componentSeoLinkProp in link.elements())
										{
											// checks if componentSeoLinkProp has at least a child (avoids errors)
											if (componentSeoLinkProp.firstChild() != null)
											{
												Reflect.setField(componentSeoLinkModel, componentSeoLinkProp.nodeName, componentSeoLinkProp.firstChild().nodeValue);
											}
										}
										// push link to componentSeoModel.links
										componentSeoModel.links.push(componentSeoLinkModel);
									}
								}
							}
							// push component to layerSeoModel.components
							layerSeoModel.components.push(componentSeoModel);
						}
					}
				//}
			}
		}
		return layerSeoModel;
	}

	/**
	 * converts a LayerSeoModel to a Php Native Array.
	 * 
	 * inputs: a LayerSeoModel
	 * returns: a PHP Native Array
	 */
	public static function layerSeoModel2PhpArray(layerSeoModel:LayerSeoModel):NativeArray
	{
		var layerSeoHash:Hash<Dynamic> = new Hash<Dynamic>();
		var layerSeoNativeArray:NativeArray = null;
		var componentsArray:Array<Dynamic> = new Array<Dynamic>();
		var componentsNativeArray:NativeArray = null;
		var componentHash:Hash<Dynamic> = null;
		var componentNativeArray:NativeArray = null;
		var linksArray:Array<Dynamic> = null;
		var linksNativeArray:NativeArray = null;
		var linkHash:Hash<String> = null;
		var linkNativeArray:NativeArray = null;
		
		// for all layerSeo's properties
		for(layerSeoModelProp in Constants.LAYER_SEO_PROPERTIES.iterator())
		{
			//Reflect.setField(layerSeoNativeArray, layerSeoModelProp, Reflect.field(layerSeoModel, layerSeoModelProp));
			layerSeoHash.set(layerSeoModelProp, Reflect.field(layerSeoModel, layerSeoModelProp));
		}
		// if there is at least one component
		if (layerSeoModel.components.length != 0)
		{
			// for all components
			for (component in layerSeoModel.components)
			{
				componentHash = new Hash<Dynamic>();

				// process generic properties
				for (componentProp in Constants.COMPONENT_GENERIC_PROPERTIES.iterator())
				{
					if (Reflect.field(component, componentProp) != null)
					{
						componentHash.set(componentProp, Reflect.field(component, componentProp));
					}
				}
				
				// process specific properties
				for (specificProp in component.specificProperties.keys())
				{
					if (component.specificProperties.get(specificProp) != null)
					{
						componentHash.set(specificProp, component.specificProperties.get(specificProp));
					}
				}
				
				// process links
				if (component.links.length != 0)
				{
					linksArray = new Array<Dynamic>();
					for (link in component.links)
					{
						linkHash = new Hash<String>();
						for (linkProp in Constants.COMPONENT_LINK_PROPERTIES.iterator())
						{
							if (Reflect.field(link, linkProp) != null)
							{
								linkHash.set(linkProp, Reflect.field(link, linkProp));
							}
						}
						linkNativeArray = Lib.associativeArrayOfHash(linkHash);
						linksArray.push(linkNativeArray);
						linksNativeArray = Lib.toPhpArray(linksArray);
					}
					componentHash.set(LINKS_NODE_NAME, linksNativeArray);
				}
				componentNativeArray = Lib.associativeArrayOfHash(componentHash);
				componentsArray.push(componentNativeArray);
				componentsNativeArray = Lib.toPhpArray(componentsArray);
			}
		}
		layerSeoHash.set(COMPONENTS_NODE_NAME, componentsNativeArray);
		
		layerSeoNativeArray = Lib.associativeArrayOfHash(layerSeoHash);
		return layerSeoNativeArray;
	}

	/**
	 * writes a Layer Seo to the layer seo xml file with the deeplink as attribute.
	 * 
	 * inputs: a layer file name, a deeplink, a LayerSeoModel php NativeArray, an indent boolean
	 * returns: nothing
	 */
	public static function write(fileName:String, deeplink:String, layerSeoModelArray:NativeArray,indent:Bool):Void

	{
		// converts the input PHP native array to layerSeoModel
		var layerSeoModel:LayerSeoModel = phpArray2LayerSeoModel(layerSeoModelArray,deeplink);

		// converts the layerSeoModel to Xml
		var layerSeoModelXml:Xml = layerSeoModel2Xml(layerSeoModel,deeplink);
		//var layerSeoModelXml:Xml = layerSeoModel2Xml(layerSeoModel);
		
		// writes the Xml to layer seo file
		writeXml(fileName, deeplink, layerSeoModelXml, indent);
	}
	
	/*
	 * writes the LayerSeoModel to the layer seo xml file with the deeplink as attribute.
	 * 
	 * inputs: a layer file name, a deeplink, a LayerSeoModel, an indent boolean
	 * returns: nothing
	 */
	public static function writeLayerSeoModel(fileName:String, deeplink:String, layerSeoModel:LayerSeoModel,indent:Bool):Void
	{
		var layerSeoModelXml:Xml = layerSeoModel2Xml(layerSeoModel,deeplink);
		writeXml(fileName, deeplink, layerSeoModelXml, indent);
	}
	
	/**
	 * converts a PHP array to a LayerSeoModel.
	 * 
	 * inputs: a PHP array, a deeplink
	 * returns: an LayerSeoModel
	 */
	public static function phpArray2LayerSeoModel(layerSeoArray:NativeArray, deeplink:String):LayerSeoModel
	{
		var layerSeoModel:LayerSeoModel = null;
		layerSeoModel.components = new Array<ComponentSeoModel>();
		
		// converts the layerSeoArray to an Hash
		var layerSeoModelHash:Hash<Dynamic> = Lib.hashOfAssociativeArray(layerSeoArray);

		// fill the layerSeoModel main properties
		for (prop in Constants.LAYER_SEO_PROPERTIES.iterator())
		{
			Reflect.setField(layerSeoModel, prop, layerSeoModelHash.get(prop));
		}
		
		// converts the Hash CONTENT_NODE_NAME key value to Array
		var componentsArray:Array<Dynamic> = Lib.toHaxeArray(layerSeoModelHash.get(CONTENT_NODE_NAME));
		
		// fill the layerSeoModel components informations
		var componentHash:Hash<Dynamic> = new Hash<Dynamic>();
		// for all components
		for (component in componentsArray)
		{
			var componentSeoModel:ComponentSeoModel = null;
			componentSeoModel.specificProperties = new Hash<String>();
			componentSeoModel.links = new Array<ComponentSeoLinkModel>();
			// fill the componentHash with component's parameters
			componentHash = Lib.hashOfAssociativeArray(component);
			var componentGenericPropertyName:String;

			// fill componentSeoModel with component's parameters
			for (phpNativeArrayComponentPropertyName in componentHash.keys())
			{
				var isGenericProperty:Bool = false;
				// loop to check if component property is part of the generic properties
				for (componentGenericPropertyName in Constants.COMPONENT_GENERIC_PROPERTIES.iterator())
				{
					// is component property part of the generic properties ?
					if (phpNativeArrayComponentPropertyName == componentGenericPropertyName)
					{
						Reflect.setField(componentSeoModel, componentGenericPropertyName, componentHash.get(componentGenericPropertyName));
						isGenericProperty = true;
						break;
					}
				}
				// if property is specific and if it is not a link, add the property to specificProperties
				if ( !isGenericProperty && (phpNativeArrayComponentPropertyName != 'links') )
				{
					componentSeoModel.specificProperties.set(phpNativeArrayComponentPropertyName, componentHash.get(phpNativeArrayComponentPropertyName));
				}
			}
			
			// converts the component's Hash LINKS_NODE_NAME key value to Array
			var linksArray:Array<Dynamic> = Lib.toHaxeArray(componentHash.get(LINKS_NODE_NAME));
			// fill the layerSeoModel components informations
			var linkHash:Hash<Dynamic> = new Hash<Dynamic>();
			// for all links
			for (link in linksArray)
			{
				var componentSeoLinkModel:ComponentSeoLinkModel = null;
				// fill componentSeoLinkModel with component's link
				for (index in Constants.COMPONENT_LINK_PROPERTIES.iterator())
				{
					linkHash = Lib.hashOfAssociativeArray(link);
					Reflect.setField(componentSeoLinkModel, index, linkHash.get(index));
				}
				// add link to componentSeoModel.links array
				componentSeoModel.links.push(componentSeoLinkModel);
			}
			// add component to layerSeoModel.components array
			layerSeoModel.components.push(componentSeoModel);
			
		}
		
		return layerSeoModel;
	}

	/**
	 * converts a LayerSeoModel to an XML.
	 * 
	 * inputs: a LayerSeoModel, a deeplink
	 * returns: an XML
	 */
	public static function layerSeoModel2Xml(layerSeoModel:LayerSeoModel,deeplink:String):Xml
	{
		var layerSeoModelXml:Xml = Xml.createElement(LAYER_SEO_NODE_NAME);
		layerSeoModelXml.set(DEEPLINK_ATTRIBUTE_NAME, deeplink);
		var tempXml:Xml = null;
		var propertiesXml:Xml = null;
		var value:String;
		
		// for all layerSeo's properties
		for (prop in Constants.LAYER_SEO_PROPERTIES.iterator())
		{
			// if property value is not null and not empty, add corresponding Xml node
			if ( (Reflect.field(layerSeoModel, prop) != null) && (Reflect.field(layerSeoModel, prop) != '') )
			{
				propertiesXml = Xml.createElement(prop);
				value = (Reflect.field(layerSeoModel, prop)).toString();
				propertiesXml.addChild(Xml.createCData(value));
				layerSeoModelXml.addChild(propertiesXml);
			}
		}
		
		// add components
		tempXml = Xml.createElement(COMPONENTS_NODE_NAME);
		var component:ComponentSeoModel;
		var link:ComponentSeoLinkModel;
		var componentXml:Xml = null;
		var componentPropertiesXml:Xml = null;
		var linksXml:Xml = null;
		var linkXml:Xml = null;
		var linkPropertiesXml:Xml = null;
		
		// if no components, add nothing
		if (layerSeoModel.components.length != 0)
		{
			// for all components
			for (component in layerSeoModel.components)
			{
				componentXml = Xml.createElement(COMPONENT_NODE_NAME);
				// for all components' generic properties
				for (index in Constants.COMPONENT_GENERIC_PROPERTIES.iterator())
				{
					// if property value is not null or empty, add corresponding Xml node
					if ( (Reflect.field(component, index) != null) && (Reflect.field(component, index) != '') )
					{
						componentPropertiesXml = Xml.createElement(index);
						value = (Reflect.field(component, index)).toString();
						componentPropertiesXml.addChild(Xml.createCData(value));
						componentXml.addChild(componentPropertiesXml);
					}
				}
				// for all components' specific properties
				for (index in component.specificProperties.keys())
				{
					// if property value is not null or empty, add corresponding Xml node
					if ( (component.specificProperties.get(index) != null) && (component.specificProperties.get(index) != '') )
					{
						componentPropertiesXml = Xml.createElement(index);
						value = Std.string(component.specificProperties.get(index));
						componentPropertiesXml.addChild(Xml.createCData(value));
						componentXml.addChild(componentPropertiesXml);
					}
				}
				
				// add links
				// if no links, add nothing
				if (component.links.length != 0)
				{
					linksXml = Xml.createElement(LINKS_NODE_NAME);
					// for all links
					for (link in component.links)
					{
						linkXml = Xml.createElement(LINK_NODE_NAME);
						//for (index in link.keys.iterator())
						for (index in Constants.COMPONENT_LINK_PROPERTIES.iterator())
						{
							// if property value is not null and not empty, add corresponding Xml node
							if ( (Reflect.field(link, index) != null) && (Reflect.field(link, index) != '') )
							{
								linkPropertiesXml = Xml.createElement(index);
								value = (Reflect.field(link, index)).toString();
								linkPropertiesXml.addChild(Xml.createCData(value));
								linkXml.addChild(linkPropertiesXml);
							}
						}
						linksXml.addChild(linkXml);
					}
					componentXml.addChild(linksXml);
				}
				tempXml.addChild(componentXml);
			}
			layerSeoModelXml.addChild(tempXml);
		}
		return layerSeoModelXml;
	}

	/**
	 * writes/replaces the deeplink layerSeo xml into the layer seo xml file.
	 * 
	 * inputs: a layer file name, a deeplink, a LayerSeoModel xml, an indent boolean
	 * returns: nothing
	 */
	public static function writeXml(fileName:String, deeplink:String, xmlContent:Xml,indent:Bool):Void
	{
		var layerSeoXmlFinal:Xml = Xml.createDocument();
		
		// initalise layerSeoXmlTemp
		var layerSeoXmlTemp:Xml = Xml.createElement(SEO_DATA_NODE_NAME);
		layerSeoXmlTemp.set(VERSION_ATTRIBUTE_NAME, VERSION_ATTRIBUTE_VALUE);

		// remove indent from xmlContent
		xmlContent = XmlUtils.cleanUp(xmlContent);

		// fill layerSeoXmlTemp with xmlContent
		layerSeoXmlTemp.addChild(xmlContent);
			
		var layerSeoXmlOriginal:Xml;
		var stringContent:String = null;
		
		// if file exists
		if (FileSystem.exists(fileName))
		{
			// gets file content
			var fileContent:String = File.getContent(fileName);
			
			try
			{
				// read xml file, parse it to xml and remove indent
				layerSeoXmlOriginal = XmlUtils.stringIndent2Xml(fileContent);
			} catch(e : Dynamic)
			{
				layerSeoXmlOriginal = null;
			}

			// check if file is not empty or having a signe empty node (avoids errors)
			if ( layerSeoXmlOriginal != null )
			{		
				// if the existing layerSeo xml file is v2 (first element is <seoData version="2">), add/replace xmlContent node
				var childElement:Xml;
				if ((layerSeoXmlOriginal.nodeName == SEO_DATA_NODE_NAME) && (layerSeoXmlOriginal.get(VERSION_ATTRIBUTE_NAME) == VERSION_ATTRIBUTE_VALUE))
				{
					// replace initial layerSeoXmlTemp data to layerSeoXmlOriginal
					layerSeoXmlTemp = layerSeoXmlOriginal;
					// loop over all children to find the layerSeo node with deeplink attribute
					for ( childElement in layerSeoXmlOriginal.elementsNamed(LAYER_SEO_NODE_NAME))
					{
						// if <layerSeo deeplink="deeplink"> node is found in layerSeoXmlOriginal, remove xmlContent from layerSeoXmlTemp
						if (childElement.get(DEEPLINK_ATTRIBUTE_NAME) == deeplink)
						{
							layerSeoXmlTemp.removeChild(childElement);
							
						}
						// add xmlContent to layerSeoXmlTemp
						layerSeoXmlTemp.addChild(xmlContent);
					}
				}
				else
				{
					trace('Publication layer seo file is not in the v2 format for deeplink: ' + deeplink + '. Please save it manually via the Wysiwyg');
				}
			}
		}
		// not needed anymore as file is created automatically
		/*else
		{
			//trace('Seo file does not exists');
			untyped __call__('print_r',fileName + " file does not exists.<BR>\n");
		}*/
		
		// add layerSeoXmlTemp to layerSeoXmlFinal
		layerSeoXmlFinal.addChild(layerSeoXmlTemp);
		
		// if indent is true, indent xml
		if( indent )
			stringContent = "\n" + XmlUtils.xml2StringIndent(layerSeoXmlFinal);
		// if not, keep xml as is
		else
			stringContent = layerSeoXmlFinal.toString();
		
		// add UTF-8 header => seems to be not necessary, and creates paring error when editing in IE
		//stringContent = "\xEF\xBB\xBF" + stringContent;

		// add xml header
		stringContent = '<?xml version="1.0" encoding="UTF-8"?>' + stringContent;
		
		// write stringContent to file
		File.putContent(fileName, stringContent);

	}
	
}
