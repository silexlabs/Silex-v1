/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for Components
 * */
 
import mx.data.encoders.Num;
import mx.utils.StringFormatter;
import org.silex.adminApi.listedObjects.PropertyProxy;
import org.silex.adminApi.listModels.IListModel;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.listModels.adding.ComponentAddInfo;
import org.silex.adminApi.listModels.adding.ComponentAdder;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.adminApi.util.ComponentHelper;
import org.silex.adminApi.util.T;
import org.silex.core.Utils;
import org.silex.core.plugin.HookEvent;
import org.silex.core.plugin.HookManager;
import org.silex.ui.Layer;
import org.silex.ui.LayerHooks;
import org.silex.ui.UiBase;
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.link.HaxeLink;

class  org.silex.adminApi.listModels.Components extends ListModelBase
{
	public static var EVENT_COMPONENT_CREATED:String = "EVENT_COMPONENT_CREATED";
	
	public static var EVENT_COMPONENT_CREATED_ERROR:String = "EVENT_COMPONENT_CREATED_ERROR";
	
	public static var EVENT_COMPONENT_START_PASTE:String = "EVENT_COMPONENT_START_PASTE";
	
	public static var EVENT_COMPONENT_END_PASTE:String = "EVENT_COMPONENT_END_PASTE";
	
	private var _componentAdder:ComponentAdder;

	public function Components()
	{
		super();
		_componentAdder = new ComponentAdder(this);
		_objectName = "components";
		_dependantLists.push("properties");
		_dependantLists.push("actions");
		_silexPtr.application.addEventListener(_silexPtr.config.APP_EVENT_COMPONENT_CHANGED, Utils.createDelegate(this, onComponentChanged));
	}
	
	private function onComponentChanged(event:Object):Void{
		//T.y("onComponentChanged");
		signalDataChanged();
	}
	

	
	private function doGetData(containerUids:Array):Array{
		//T.t("Components getData");
		var ret:Array = new Array();
		if(!containerUids){
			containerUids = SilexAdminApi.getInstance().layers.getSelection();
		}
		var numLayers: Number = containerUids.length;
		for(var i:Number = 0; i < numLayers; i++){
			var layerUid:String = containerUids[i];
			var layer:Layer = LayerProxy.createFromUid(layerUid).getLayer();
			//T.y("layer : ", layer);
			var componentsInLayer:Array = layer.players;
			//T.y("componentsInLayer : ",componentsInLayer);
			var numComponentsInLayer:Number = componentsInLayer.length;
			var componentProxys:Array = new Array();
			for(var j:Number = 0; j < numComponentsInLayer; j++){
				var componentProxy:ComponentProxy = ComponentProxy.createFromLayer(layer, j);
				componentProxys.push(componentProxy);
			}
			
			ret.push(componentProxys);
		}
		return ret;
	}	
	
	/**
	 * Retrieve all the components from all the layouts and layers 
	 * matching uids sent as parameter in an
	 * array
	 * @return a one dimensionnal array of ComponentProxy
	 */
	public function getObjectsByUids(objectsUids:Array):Array {
		
		//return an empty array if no uids are defined
		if (objectsUids == undefined || objectsUids.length == 0)
		{
			return new Array();
		}
		
		var ret:Array = new Array();
		var numObjectsUids:Number = objectsUids.length;
		
		for (var i:Number = 0; i < numObjectsUids; i++)
		{
			ret.push(ComponentProxy.createFromUid(objectsUids[i]));
		}
		
		return ret;
	}

	/**
	 * add an item to the selected layer. 
	 * If there is not exactly one selected layer, the method fails
	 * @param data The url of the media to add
	 * @param containerUid an optionnal param pointing to which layer to add the new component
	 * to. If it's null, it will take the first selected layer
	 * @returns uid of created component
	 * */
	public function addItem(data:Object, containerUid:String):String
	{
		//TO DO : implement this undoable action
		//SilexAdminApi.getInstance().historyManager.flush();
				
		var ret:String = _componentAdder.addItem(data, containerUid);
		
		
		//Just flush for now, will be implemented later
		SilexAdminApi.getInstance().historyManager.flush();
		/**SilexAdminApi.getInstance().historyManager.addUndoableAction(
		new HaxeLink.getHxContext().org.silex.adminApi.undoableActions.AddComponent(ret, data));**/
		
		//We quote it, as adding a component is asynchrous,
		//we wait for the compont creation event to signal change
		//signalDataChanged();
		return ret;
	}
	
	
	
	
	
	/**
	 * delete an item from the selected layer. 
	 * If there is not exactly one selected layer, the method fails
	 * 
	 * @param data The uid of the component to delete
	 * @returns uid of created component
	 * */
	public function deleteItem(objectId:String):Void
	{
		
		//Just flush for now, will be implemented later
		SilexAdminApi.getInstance().historyManager.flush();
		/**SilexAdminApi.getInstance().historyManager.addUndoableAction(
		new HaxeLink.getHxContext().org.silex.adminApi.uundoableActionsDeleteComponent(componentProxy));*/
		
		//T.t("components deleteItem ", objectId);
		var componentProxy:ComponentProxy = ComponentProxy.createFromUid(objectId);		
		
		
		
		if(!componentProxy){
			//T.t("component proxy with uid ", objectId, " not found. delete failed");
			return;
		}
		
		componentProxy.getComponent().layoutInstance.isDirty = true;
		
		var layer:Layer = componentProxy.getRelativeLayer();
		var indexOfComponentToDelete:Number = componentProxy.getIndexInRelativeLayer();
		componentProxy.getComponent().unloadMovie();
		layer.players.splice(indexOfComponentToDelete, 1);	
		
		
		
		signalDataChanged();
	}
	
	/**
	 * override of the select method to add a call to the HistoryManager for undo/redo
	 * @param	objectIds the selected components Ids
	 */
	public function select(objectIds:Array, data:Object):Void
	{
		
		var selectedComponentsIds:Array = SilexAdminApi.getInstance().components.getSelection();
		
		for(var i:Number = 0; i < selectedComponentsIds.length; i++)
		{
			var currentComponentProxy:ComponentProxy = ComponentProxy.createFromUid(selectedComponentsIds[i]);
			var currentComponent = currentComponentProxy.getComponent();
			
			currentComponent.isSelected = false;
		}
		
		SilexAdminApi.getInstance().historyManager.addUndoableAction(
		new HaxeLink.getHxContext().org.silex.adminApi.undoableActions.SelectComponents(selectedComponentsIds));
		
		//check if the components to select are editable,
		//they are actually added to the selection only if they are editable
		var newComponentsSelectionUids:Array = new Array();
		for (var i:Number = 0; i < objectIds.length; i++)
		{
			var selectedComponent:ComponentProxy = ComponentProxy.createFromUid(objectIds[i]);
			if (selectedComponent.getEditable() == true)
			{
				newComponentsSelectionUids.push(selectedComponent.uid);
				var currentComponent = selectedComponent.getComponent();
				currentComponent.isSelected = true;
			}
		}
		
		super.select(newComponentsSelectionUids, data);
	}
	
	/**
	 * Copy currently selected components with a helper class
	 */
	public function copy():Void
	{
		HaxeLink.getHxContext().org.silex.adminApi.util.ComponentCopier.getInstance().copy();
	}
	
	/**
	 * Paste currently selected components with a helper class.
	 * Signal the start of the paste process
	 */
	public function paste(targetLayerUid:String):Void
	{
		var eventForLocal:Object = {target:this, type:EVENT_COMPONENT_START_PASTE};
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(EVENT_COMPONENT_START_PASTE, _objectName);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
		
		HaxeLink.getHxContext().org.silex.adminApi.util.ComponentCopier.getInstance().paste(targetLayerUid);
	}
	
	/**
	 * swap the depths of 2 items. changes the layer players array and refreshes the layer
	 * @param objectId1 the uid of the first item
	 * @param objectId2 the uid of the second item
	 * */
	public function swapItemDepths(objectId1:String, objectId2:String):Void
	{
		//T.t("components swapItemDepths ", objectId1, ", ", objectId2);
		var componentProxy1:ComponentProxy = ComponentProxy.createFromUid(objectId1);
		if(!componentProxy1){
			//T.t("component proxy with uid ", objectId1, " not found. swap failed");
			return;
		}
		
		var componentProxy2:ComponentProxy = ComponentProxy.createFromUid(objectId2);
		if(!componentProxy2){
			//T.t("component proxy with uid ", objectId2, " not found. swap failed");
			return;
		}
		
		
		var layer:Layer = componentProxy1.getRelativeLayer();
		if(layer != componentProxy2.getRelativeLayer()){
			//T.t("components not in same layer. swap failed");
		} 
		var index1:Number = componentProxy1.getIndexInRelativeLayer();
		var index2:Number = componentProxy2.getIndexInRelativeLayer();
		
		
		var tempStore:Object = layer.players[index1];
		layer.players[index1] = layer.players[index2];
		layer.players[index2] = tempStore;
		
		componentProxy1.getComponent().layoutInstance.isDirty = true;
		
		layer.refresh();
		signalDataChanged();
	}	
	
	/**
	 * reorder all the objects in the list.
	 * note: this does not check that there are no duplicates in the orderedObjectIds 
	 * @param orderedObjectIds an array of objectIds representing the wanted order. This must contain all the objectIds once and only once, or it will fail. They must be in the same layer.
	 * */
	public function changeOrder(orderedObjectIds:Array):Void {
	
		SilexAdminApi.getInstance().historyManager.addUndoableAction(
		new HaxeLink.getHxContext().org.silex.adminApi.undoableActions.ChangeComponentsOrder(SilexAdminApi.getInstance().components.getData()));
		
		var selectedComponentsUid:Array = SilexAdminApi.getInstance().components.getSelection();
		var i:Number;
		var selectedComponentsProxies:Array = new Array();
		for (i = 0; i < selectedComponentsUid.length; i++)
		{
			selectedComponentsProxies.push(ComponentProxy.createFromUid(selectedComponentsUid[i]).getComponent());
		}
		
		
		
		//T.t("components changeOrder " , orderedObjectIds);
		var numNew:Number = orderedObjectIds.length;
		var referenceComponentProxy:ComponentProxy = ComponentProxy.createFromUid(orderedObjectIds[0]);
		var referenceLayer:Layer = referenceComponentProxy.getRelativeLayer();
		var numOld:Number = referenceLayer.players.length;
		if(numNew != numOld){
			//T.t("not same length. failed");
			return;
		}
		var newPlayersArray:Array = new Array();
		for( i = 0; i < numNew; i++){
			var componentProxy:ComponentProxy = ComponentProxy.createFromUid(orderedObjectIds[i]);
			if(!componentProxy){
				//T.t("couldn't find component matching ", orderedObjectIds[i], ". failed")
				return;
			}
			if(componentProxy.getRelativeLayer() != referenceLayer){
				//T.t("component at ", orderedObjectIds[i], " in wrong layer: ", componentProxy.getRelativeLayer(), ". Should be in ", referenceLayer, ". failed");
				return;
			}
			var componentLoadInfo:Object = componentProxy.getComponentLoadInfo();
			newPlayersArray.push(componentLoadInfo);
		}
		referenceLayer.players = newPlayersArray;
		
		referenceComponentProxy.getComponent().layoutInstance.isDirty = true;
		
		referenceLayer.refresh();
		
		selectedComponentsUid = new Array();
		for (i = 0; i < selectedComponentsProxies.length; i++)
		{
			selectedComponentsUid.push(ComponentProxy.createFromComponent(selectedComponentsProxies[i]).uid);
		}
		
		signalDataChanged();
		_selectedObjectIds = selectedComponentsUid;
		var eventForLocal:Object = {target:this, type:AdminApiEvent.EVENT_SELECTION_CHANGED, data:_selectedObjectIds};
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(AdminApiEvent.EVENT_SELECTION_CHANGED, _objectName, _selectedObjectIds);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);

	}	
	
	/**
	 * Called by ComponentCopier to signal the end of one or multiple
	 * component paste
	 */
	public function signalComponentPasted():Void
	{
		_objectsBuffer = null;
		
		var eventForLocal:Object = {target:this, type:EVENT_COMPONENT_END_PASTE};
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(EVENT_COMPONENT_END_PASTE, _objectName);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
	}
	
	/**
	 * called by ComponentAdder when component is created, 
	 * send an event
	 * */
	public function signalComponentCreated():Void {
		
		_objectsBuffer = null;
		
		var eventForLocal:Object = {target:this, type:EVENT_COMPONENT_CREATED};
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(EVENT_COMPONENT_CREATED, _objectName);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
	}
	
	/**
	 * called by ComponentAdder when there was a problem while creating the component
	 */
	public function signalComponentCreatedError():Void
	{
		_objectsBuffer = null;
		
		var eventForLocal:Object = { target:this, type:EVENT_COMPONENT_CREATED_ERROR };
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(EVENT_COMPONENT_CREATED_ERROR, _objectName);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
	}
	
	public function getParent():IListModel
	{
		return SilexAdminApi.getInstance().layers;
	}
	
	public function set selectedObjectIds(value:Array):Void
	{
		var selectedComponentsIds:Array = SilexAdminApi.getInstance().components.getSelection();

		for(var i:Number = 0; i < selectedComponentsIds.length; i++)
		{
			var currentComponentProxy:ComponentProxy = ComponentProxy.createFromUid(selectedComponentsIds[i]);
			var currentComponent = currentComponentProxy.getComponent();

			currentComponent.isSelected = false;
		}
		
		super.selectedObjectIds = value;
	}		
}