/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.publication;

#if neko
import neko.io.File;
#end
#if php
import php.io.File;
#end

/**
*  This class represents a Layer and allows one to read and write them to disk.
*/
class LayerModel
{
	/**
	*  The list of SubLayers composing this Layer
	*/
	public var subLayers : List<SubLayerModel>;
	/**
	*  The Layer's name
	*/
	public var name : String;
	
	public function new()
	{
		subLayers = new List<SubLayerModel>();
		name = "";
	}
	
	/**
	*  Returns the SubLayerModel representing the SubLayer with id==name<br/>
	*  Returns null if not found.
	*/
	public function getSubLayerNamed(name : String) : Null<SubLayerModel>
	{
		for(sl in subLayers)
		{
			if(sl.id == name)
				return sl;
		}
		return null;
	}
	
	#if (neko || php)
	/**
	*  This function loads values from the xml file representing a Layer.
	*  It correctly sets the Layer's name.<br/>
	*  Returns true in case of success, false otherwise.<br/>
	*  @arg basePath The path to the publication's content directory (ex: content/myPublication)
	*  @arg layerName The name of the Layer to be loaded. Used to know from which XML file to load it.
	*/
	public static function load(basePath : String, layerName : String) : LayerModel
	{
		var path : String = basePath+ "/" + layerName + ".xml";
		var tmpLayer = LayerParser.xml2Layer(Xml.parse(File.getContent(path)));
		tmpLayer.name = layerName;
		tmpLayer.subLayers = tmpLayer.subLayers;
		
		return tmpLayer;
	}
	#end
	
	#if (neko || php)
	/**
	*  This function saves the xml representation of this Layer in a file on disk.<br/>
	*  Returns true in case of success, false otherwise.<br/>
	*  @arg basePath The path to the publication's content directory (ex: content/myPublication)
	*/
	public function save(basePath : String) : Bool
	{
//		try
//		{
			var path : String = basePath + "/" + this.name + ".xml";
			var fileOut = File.write(path, false);
			fileOut.writeString(LayerParser.layer2XML(this).toString());
			fileOut.close();
			
			return true;
//		} catch(e: Dynamic)
//		{
//			return false;
//		}
	}
	#end
}