/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.core;
import org.silex.publication.LayerModel;
import org.silex.publication.SubLayerModel;

/**
 *  all the haxe code that would be in the Layer (as2 Layout) class if it were in Haxe. To merge once this is the case
 * @author Ariel Sommeria-klein sommeria.ariel (at) gmail.com
 */

class LayerHelper 
{

	public function new() 
	{
		
	}
	
	/**
	 * if you try to do this in AS2 directly, you get a corrupted Haxe XML object. Use this instead
	 * @param	xmlStr
	 * @return
	 */
	public static function parseXml(xmlStr:String):Xml {
		return Xml.parse(xmlStr);
	}
	
	/**
	 * looks in the model for the subLayer model matching the sub layer
	 * @param	subLayer: org.silex.ui.Layer
	 * @param	model
	 * @return
	 */
	public static function getSubLayerModel(subLayer:Dynamic, model:LayerModel):SubLayerModel {
		//trace("getSubLayerModel" + subLayer.name + subLayer);
		var subLayerId:String = subLayer.name;
		for (subLayerModel in model.subLayers.iterator()) {
			//strace("id : " + subLayerModel.id);
			if (subLayerModel.id == subLayer.name) {
				return subLayerModel;
			}
		}
		trace("sub layer not found for " + subLayer.name + ", returning first available sublayer model");
		return model.subLayers.first();
		
		
	}
	
}