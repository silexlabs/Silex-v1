/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.publication;
import org.silex.core.XmlUtils;

using StringTools;

/**
*  This class is the Parser used to parse and create Layer objects' XML representation.
*/ 
class LayerParser
{
	/**
	*  This method takes a Layer object and returns its XML representation.
	*/
	public static function layer2XML(layer : LayerModel) : Xml
	{
		var xml = Xml.createDocument();
		//trace("layer2XML");
		//Xml.createProlog not implemented in as2!
		//xml.addChild(Xml.createProlog('xml version="1.0" encoding="utf-8"'));
		var layerNode = Xml.createElement("layer");
		xml.addChild(layerNode);
		var subNode = Xml.createElement("subLayers");
		layerNode.addChild(subNode);
		for(subLayer in layer.subLayers)
		{
			var subLayerNode = Xml.createElement("subLayer");
			subLayerNode.set("id", subLayer.id);
			subLayerNode.set("zIndex", Std.string(subLayer.zIndex));
			
			var componentsNode = Xml.createElement("components");
			for(comp in subLayer.components)
			{
				var compNode = Xml.createElement("component");
				
				if(comp.as2Url != null) compNode.addChild(generateXml(comp.as2Url, "as2Url"));
				if(comp.html5Url != null) compNode.addChild(generateXml(comp.html5Url, "html5Url"));
				if(comp.className != null) compNode.addChild(generateXml(comp.className, "className"));
				if(comp.componentRoot != null) compNode.addChild(generateXml(comp.componentRoot, "componentRoot"));
				
				//Generate properties
				var propNode = Xml.createElement("properties");
				compNode.addChild(propNode);
				for(prop in comp.properties.keys())
				{
					propNode.addChild(generateXml(comp.properties.get(prop), prop, true));
				}
				
				//generate actions
				var actionsNode = Xml.createElement("actions");
				compNode.addChild(actionsNode);
				for(action in comp.actions)
				{
					var actionNode = Xml.createElement("action");					
					actionNode.addChild(generateXml(action.functionName, "functionName", true));
					actionNode.addChild(generateXml(action.modifier, "modifier", true));
					var parametersNode = Xml.createElement("parameters");
					for (parameter in action.parameters) {
						parametersNode.addChild(generateXml(parameter, "parameter", true));
					}	
					actionNode.addChild(parametersNode);
					actionsNode.addChild(actionNode);
				}
				
				
				
//				var htmlEquivalentNode = Xml.createElement("htmlEquivalent");
//				htmlEquivalentNode.addChild(Xml.createCData(comp.htmlEquivalent));
//				compNode.addChild(htmlEquivalentNode);
				
				componentsNode.addChild(compNode);
			}
			subLayerNode.addChild(componentsNode);
			subNode.addChild(subLayerNode);
		}

		return xml;
	}
	
	
	/**
	*  some temp code to adapt old as2 urls for components from media to plugins
	*  */
	private static function adaptAs2Url(url:String):String{
		if(url.indexOf("media/components/oof") != -1){
//			flash.Lib.trace("adaptAs2ssUrl"+ url + url.indexOf("media/components/oof/"));
			url = url.replace("media/components/oof/", "plugins/oofComponents/as2/");
			url = url.replace("cmp.", "");
		}	
		
		//replace media component url by plugin url 
		else if (url.indexOf("media/components/") != -1){
				if (url.indexOf("media/components/SRTPlayer.cmp.swf") != -1)
				{
					url = url.replace("media/components/SRTPlayer.cmp.swf", "plugins/silexComponents/as2/SRTPlayer/SRTPlayer.swf");
				}
				else if (url.indexOf("media/components/buttons/label_button.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/label_button.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton.swf");
				}
				
				else if (url.indexOf("media/components/buttons/label_button2.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/label_button2.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton2.swf");
				}
				
				else if (url.indexOf("media/components/buttons/label_button3.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/label_button3.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton3.swf");
				}
				
				else if (url.indexOf("media/components/buttons/label_button4.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/label_button4.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton4.swf");
				}
				
				else if (url.indexOf("media/components/buttons/futurist_button.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/futurist_button.cmp.swf", "plugins/silexComponents/as2/futuristButton/futuristButton.swf");
				}
				
				else if (url.indexOf("media/components/buttons/scale9_button1.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/scale9_button1.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/scale9Button1.swf");
				}
				
				else if (url.indexOf("media/components/buttons/simple_flash_button1.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/simple_flash_button1.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/simpleFlashButton1.swf");
				}
				
				else if (url.indexOf("media/components/buttons/simple_flash_button2.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/simple_flash_button2.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/simpleFlashButton2.swf");
				}
				
				
				
				else if (url.indexOf("plugins/silexComponents/as2/simpleFlashButton/button.swf") != -1)
				{
					url = url.replace("plugins/silexComponents/as2/simpleFlashButton/button.swf", "plugins/silexComponents/as2/labelButton/button.swf");
				}
				
				else if (url.indexOf("media/components/Geometry.cmp.swf") != -1)
				{
					url = url.replace("media/components/Geometry.cmp.swf", "plugins/baseComponents/as2/Geometry.swf");
				}
				
				else if (url.indexOf("media/components/buttons/button.cmp.swf") != -1)
				{
					url = url.replace("media/components/buttons/button.cmp.swf", "plugins/silexComponents/as2/labelButton/button.swf");
				}
				
		}
		
//		flash.Lib.trace("adaptAs2Url"+ url + url.indexOf("media/components/oof"));
		return url;	
	}
	/**
	*  This method takes an XML representation of a Layer and returns a Layer object<br/>
	*  Attention: The returned Layer object can't have its name correctly set. You may want to use Layer.load
	*/
	public static function xml2Layer(xml : Xml) : LayerModel
	{
		var layer = new LayerModel();
		//Iterate on Sublayers
		if(xml.firstElement().elementsNamed("subLayers").hasNext())
			for(subNode in xml.firstElement().elementsNamed("subLayers").next().elementsNamed("subLayer"))
			{
				var subLayer = new SubLayerModel();
				subLayer.id = subNode.get("id");
				subLayer.zIndex = Std.parseInt(subNode.get("zIndex"));
			
				if(subNode.elementsNamed("components").hasNext())
					for(componentNode in subNode.elementsNamed("components").next().elementsNamed("component"))
					{
						var comp = new ComponentModel();
						if(componentNode.elementsNamed("className").hasNext()){
							comp.className = componentNode.elementsNamed("className").next().firstChild().toString();
						}
						if(componentNode.elementsNamed("as2Url").hasNext()){
							comp.as2Url = componentNode.elementsNamed("as2Url").next().firstChild().toString();
							//adaptation!! TODO remove
							comp.as2Url = adaptAs2Url(comp.as2Url);
						}
						if(componentNode.elementsNamed("html5Url").hasNext()){
							comp.html5Url = componentNode.elementsNamed("html5Url").next().firstChild().toString();
						}						
						if(componentNode.elementsNamed("componentRoot").hasNext()){
							comp.componentRoot = componentNode.elementsNamed("componentRoot").next().firstChild().toString();
						}						
						//Iterate on properties
						if(componentNode.elementsNamed("properties").hasNext()){
							for(prop in componentNode.elementsNamed("properties").next().elements())
							{
								comp.properties.set(prop.nodeName, parseObject(prop));
							}
						}
						
						//iterate on actions
						if (componentNode.elementsNamed("actions").hasNext()) {
							//trace("has actions");
							for(actionNode in componentNode.elementsNamed("actions").next().elementsNamed("action"))
							{
								var actionModel:ActionModel = new ActionModel();
								actionModel.functionName = parseObject(actionNode.elementsNamed("functionName").next());
								actionModel.modifier = parseObject(actionNode.elementsNamed("modifier").next());
								
								//parse parameters
								for(parameterNode in actionNode.elementsNamed("parameters").next().elementsNamed("parameter"))
								{
									//trace(parameterNode);
									actionModel.parameters.add(parseObject(parameterNode));
								}
								//trace(actionModel);	
								comp.actions.add(actionModel);
							}
						}
						
						//trace(comp);
						subLayer.components.add(comp);
					}
				layer.subLayers.add(subLayer);
			}

		return layer;
	}
	
	/**
	*  This function takes a property's or metadata's subnode and returns the corresponding object.
	*/
	private static function parseObject(node : Xml) : Dynamic
	{
		switch(node.get("type"))
		{
			case null: //default type is string, and implicit. so no type means type is String
				var toRet : String = "";
				for (nv in node)
				{
					toRet += nv.nodeValue;
				}
				return toRet;
			case "Integer":
				return Std.parseInt(node.firstChild().nodeValue);
			case "Boolean":
				return node.firstChild().nodeValue != "false";
			case "Float":
				return Std.parseFloat(node.firstChild().nodeValue);
			case "Array":
				var arr = new Array<Dynamic>();
				for(item in node.elementsNamed("item"))
				{
					arr.push(parseObject(item));
				}
				return arr;
			case "Object":
				//TODO: Implement
				var hashTable = new Hash<Dynamic>();
				for(el in node.elements())
				{
					hashTable.set(el.nodeName, parseObject(el));
				}
				return hashTable;
			default: //Default is String
				//trace("parsing String: " + node.firstChild().nodeValue);
				//trace("There are " + node.toString());
				var toRet : String = "";
				for (nv in node)
				{
					toRet += nv.nodeValue;
				}
				return toRet;
		}
		return null;
	}
	
	/**
	*  This function takes a "SILEX Object" and its name and converts it to its XML representation.
	*  @param useCDATA Sets if we should use CDATA blocks for Strings.
	*/
	private static function generateXml(obj : Dynamic, name : String, useCData : Bool = false) : Xml
	{
		//TODO: Use component descriptor to know what type to use.
		
		var e = Xml.createElement(name);
		if(Std.is(obj, String))
		{
			//String is default type, so don't set it explicitly.
			if (useCData == false) {
				var n = Xml.createPCData(obj);
				e.addChild(n);
			} else {
				var n = Xml.createCData(obj);
				e.addChild(n);
			}
			//e.addChild(n);
			return e;
		} else if(Std.is(obj, Int))
		{
			e.set("type", "Integer");
			var n = Xml.createPCData(Std.string(obj));
			e.addChild(n);
			return e;
		}else if(Std.is(obj, Bool))
		{
			e.set("type", "Boolean");
			var n = Xml.createPCData(Std.string(obj));
			e.addChild(n);
			return e;
		}else if(Std.is(obj, Float))
		{
			e.set("type", "Float");
			var n = Xml.createPCData(Std.string(obj));
			e.addChild(n);
			return e;
		} else if(Std.is(obj, Array))
		{
			e.set("type", "Array");
//			var n = Xml.createPCData()
			
			for(item in cast(obj, Array<Dynamic>))
			{
				var n = generateXml(item, "item", true);
				e.addChild(n);
			}
			return e;
		} else if(Std.is(obj, Hash))
		{
			e.set("type", "Object");
			
			for(k in cast(obj, Hash<Dynamic>).keys())
			{
				var n = generateXml(obj.get(k), k);
				e.addChild(n);				
			}
			return e;
		}
		return null;
	}
	
	/**
	*  This method takes a layer object and a boolean (indent) and returns either the XML string equivalent, either the indented XML string equivalent.
	*/
	public static function layer2XMLString(layer : LayerModel, indent : Bool) : String
	{
		var layerXml:Xml = layer2XML(layer);
		
		if (indent == true) {
			return XmlUtils.xml2StringIndent(layerXml);
		}
		else {
			return layerXml.toString();
		}
		
	}

}