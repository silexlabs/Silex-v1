/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for Layers
 * */
 
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.listedObjects.LayoutProxy;
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.core.Layout;
import org.silex.ui.Layer;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.T;
import org.silex.link.HaxeLink;

class  org.silex.adminApi.listModels.Layers extends ListModelBase
{
	public function Layers()
	{
		super();
		_objectName = "layers";
		_dependantLists.push("components");
	}
	
	/**
	 * overrride to add an undoable action. Set the selection than check if at least one layer
	 * is selected
	 * */
	public function select(objectIds:Array, data:Object):Void
	{	
		SilexAdminApi.getInstance().historyManager.addUndoableAction(new HaxeLink.getHxContext().org.silex.adminApi.undoableActions.SelectSubLayer(SilexAdminApi.getInstance().layers.getSelection()));
		
		//if no layer are to be selected,
		//select the top layer
		if (objectIds.length == 0)
		{
			objectIds = new Array(getHighestLayerUid());
		}
		
		super.select(objectIds, data);
	}
	
	/**
	 * Delete a layer by deleting it's parent layout, it also delete
	 * all the layers of the deleted layout.
	 * 
	 * @param	objectIds the uid of the layer to delete
	 */
	public function deleteItem(objectIds:String):Void
	{
		
		//get all the layouts from the SilexAdminAPi
		var layouts:Array = SilexAdminApi.getInstance().layouts.getData()[0];
		
		//a reference to the currently parent layout, owning the layer to delete
		var parentLayout:LayoutProxy;
		
		//loop in the layouts array
		for (var layoutsIdx:Number = 0; layoutsIdx < layouts.length; layoutsIdx++)
		{
			//for each layout, get it's layers
			var layers:Array = SilexAdminApi.getInstance().layers.getData([layouts[layoutsIdx].uid])[0];
			
			
			//loop in the current layout layers
			for (var layersIdx:Number = 0; layersIdx < layers.length; layersIdx++)
			{
				//if one of it's layer has the same uid as the layer
				//that must be deleted, then this is the parent layout that
				//must be deleted
				if (layers[layersIdx].uid == objectIds)
				{
					parentLayout = layouts[layoutsIdx];
					break;
				}
			}
		}
		
		//delete the parent layout
		SilexAdminApi.getInstance().layouts.deleteItem(parentLayout.uid);
	}
	
	
	private function doGetData(containerUids:Array):Array{
		//T.y("Layers getData. containerUids : ",containerUids);
		//T.y("Layers getData. selected layouts : ",SilexAdminApi.getInstance().layouts.getSelection());
		var ret:Array = new Array();
		if(!containerUids){
			containerUids = SilexAdminApi.getInstance().layouts.getSelection();
		}
		//T.y("Layers getData. getting for layouts : ",containerUids);
		var numLayouts: Number = containerUids.length;
		for(var i:Number = 0; i < numLayouts; i++){
			var layoutUid:String = containerUids[i];
			var layout:Layout = LayoutProxy.getLayout(layoutUid);
			//T.y("layout : " + layout);
			var layersInLayout:Array = layout.layers;
			var layerContainers:Array = layout.layerContainers;
			var childLayoutContainer:MovieClip = layout.currentChildLayoutContainer;
			var numLayersInLayout:Number = layersInLayout.length;
			var layerProxys:Array = new Array();
			for(var j:Number = 0; j < numLayersInLayout; j++){
				var layer:Layer = layersInLayout[j];
				var layerContainer:MovieClip = layerContainers[j];
				var layerProxy:LayerProxy = LayerProxy.createFromLayer(layer);
				//trace("layer name : "+layer+ " / layer depth : " + layer._parent._parent._parent.getDepth()+" /name : "+layerProxy.name);
				layerProxys.push(layerProxy);
				//T.y("layerProxy back to layer : " + LayerProxy.createFromUid(layerProxy.uid)); 
			}
			
			ret.push(layerProxys);
		}
		return ret;
	}	
	
	/**
	 * Check if at least one layer is selected and if not, 
	 * selects the top layer
	 */
	private function checkSelection():Void
	{
		if (_selectedObjectIds.length == 0)
		{
			SilexAdminApi.getInstance().layers.select([getHighestLayerUid()]);
		}
	}
	
	/**
	 * Returns the uid of the top layer
	 */
	private function getHighestLayerUid():String
	{
		var layoutsData:Array = SilexAdminApi.getInstance().layouts.getData()[0];
		var highestLayout:LayoutProxy = layoutsData[layoutsData.length - 1];
		var layersData:Array = SilexAdminApi.getInstance().layers.getData([highestLayout.uid])[0];
		var highestLayer:LayerProxy = layersData[layersData.length - 1];
		return highestLayer.uid;
	}
	
	/**
	 * Set the new layers selection and check if at least one
	 * is selected
	 */
	public function set selectedObjectIds(value:Array):Void
	{
		_selectedObjectIds = value;
		checkSelection();
	}
	
			
}