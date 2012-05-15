/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.listedObjects.ListedObjectBase;
import org.silex.adminApi.util.ClipFind;
import org.silex.ui.Layer;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.util.T;
import org.silex.ui.UiBase;
 /**
 * the layer proxy. A proxy for accessing and manipulating a layer remotely
 * */

class org.silex.adminApi.listedObjects.LayerProxy extends ListedObjectBase
{
	
	public function LayerProxy()
	{
		super();
	}
	
	
	/**
	 * set visible
	 * */
	public function setVisible(value:Boolean):Void{
		
		var layer:Layer = getLayer();
		//T.y("layer setEditable.", value, ", layer : ", layer);
		var componentsInLayer:Array = layer.players;
		////T.y("componentsInLayer : ", ObjectDumper.toString(componentsInLayer));
		var numComponentsInLayer:Number = componentsInLayer.length;
		var componentProxys:Array = new Array();
		for(var j:Number = 0; j < numComponentsInLayer; j++){
			var componentProxy:ComponentProxy = ComponentProxy.createFromLayer(layer, j);
			componentProxy.setVisible(value);
		}
	}
	
	/**
	 * get visible
	 * */
	public function getVisible():Boolean{
		var layer:Layer = getLayer();
		
		var componentsInLayer:Array = layer.players;
		
		var numComponentsInLayer:Number = componentsInLayer.length;
		
		//if there are no components on this layer, 
		//the default is non-editable
		if (numComponentsInLayer == 0)
		{
			return false;
		}
		var componentProxys:Array = new Array();
		for(var j:Number = 0; j < numComponentsInLayer; j++){
			var componentProxy:ComponentProxy = ComponentProxy.createFromLayer(layer, j);
			if (componentProxy.getVisible() == true)
			{
				return true;
			}
		}
		
		return false;
	}
		
	/**
	 * get associated layer
	 * */
	public function getLayer():Layer{
		var retMc:MovieClip = ClipFind.findClip(uid.split("/"));
		//T.y("getLayer : ", uid, ", returns ", retMc);
		return Layer(retMc);
		
	}
	
	
	/**
	 * set editable
	 * sets editable on all the layer's components
	 * */
	public function setEditable(value:Boolean):Void {
		var layer:Layer = getLayer();
		//T.y("layer setEditable.", value, ", layer : ", layer);
		var componentsInLayer:Array = layer.players;
		////T.y("componentsInLayer : ", ObjectDumper.toString(componentsInLayer));
		var numComponentsInLayer:Number = componentsInLayer.length;
		var componentProxys:Array = new Array();
		for(var j:Number = 0; j < numComponentsInLayer; j++){
			var componentProxy:ComponentProxy = ComponentProxy.createFromLayer(layer, j);
			componentProxy.setEditable(value);
		}
		
		
		
	}
	
	/**
	 * Return wether the layer is editable or not. The layer
	 * is considered editable if at least one of it's component is editable
	 */
	public function getEditable():Boolean
	{
		var layer:Layer = getLayer();
		
		var componentsInLayer:Array = layer.players;
		
		var numComponentsInLayer:Number = componentsInLayer.length;
		
		//if there are no components on this layer, 
		//the default is non-editable
		if (numComponentsInLayer == 0)
		{
			return false;
		}
		var componentProxys:Array = new Array();
		for(var j:Number = 0; j < numComponentsInLayer; j++){
			var componentProxy:ComponentProxy = ComponentProxy.createFromLayer(layer, j);
			if (componentProxy.getEditable() == true)
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * generate a uid for a layer, that can be used to find the layer again
	 * */
	public static function getLayerUid(layer:Layer):String{
		//T.y("getLayerUid : ", layer._target); 
		return layer._target;		
	}
	
	/**
	 * static constructor
	 * */
	public static function createFromLayer(layer:Layer):LayerProxy{
		var layerProxy:LayerProxy = new LayerProxy();
		layerProxy.name = layer.name;
		layerProxy.uid = getLayerUid(layer);
		return layerProxy;
	}		
	
	public static function createFromComponent(component:UiBase):LayerProxy {
		var layer:Layer = Layer(component.layerInstance);
		return createFromLayer(layer);
	}
	
	/**
	 * static constructor
	 * */
	public static function createFromUid(uid:String):LayerProxy{
		var layer:Layer = Layer(ClipFind.findClip(uid.split("/")));
		return createFromLayer(layer);
	}			
}