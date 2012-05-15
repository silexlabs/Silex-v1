/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for Actions
 * */
 
import mx.utils.StringFormatter;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.listedObjects.ActionProxy;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.ui.Layer;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.T;
import org.silex.ui.UiBase;
import org.silex.link.HaxeLink;

class  org.silex.adminApi.listModels.Actions extends ListModelBase
{
	public function Actions()
	{
		super();
		_objectName = "actions";
	}
	
	public function getData(containerUids:Array):Array{
		//T.y("Actions getData");
		var ret:Array = new Array();
		if(!containerUids){
			containerUids = SilexAdminApi.getInstance().components.getSelection();
		}
		var numComponents: Number = containerUids.length;
		for(var i:Number = 0; i < numComponents; i++){
			var componentUid:String = containerUids[i];
			var component:UiBase = ComponentProxy.createFromUid(componentUid).getComponent();
			//T.y("component : ", component);
			var actions:Array = component.actions;
			var numEditableActions:Number = actions.length;
			var actionProxys:Array = new Array();
			for(var j:Number = 0; j < numEditableActions; j++){
				var actionProxy:ActionProxy = ActionProxy.createFromComponent(component, j);
				actionProxys.push(actionProxy);
			}
			
			ret.push(actionProxys);
		}
		return ret;
	}	
	
	
	
	
	/**
	 * add an action to the target component. If no target component is defined,
	 * add it to the first selected component
	 * If there is not exactly one selected component, the method fails
	 * @param data The action to add
	 * @param targetComponentUid the uid of the component to which an action must be added
	 * @returns uid of created action
	 * */
	public function addItem(data:Object, targetComponentUid:String):String
	{
		
		if(!data.functionName){
			//T.y("addItem. has no functionName. failed");
			return null;
		}
		
		//the uid of the component that will be targeted
		var selectedComponentUid:String;
		
		//use the one provided if any
		if (targetComponentUid != undefined)
		{
			selectedComponentUid = targetComponentUid;
		}
		//else use the first selected component uid
		else
		{
			//T.y("components addItem ", data);
			var selectedComponentUids:Array = SilexAdminApi.getInstance().components.getSelection();
			if(selectedComponentUids.length != 1){
				//T.y(selectedComponentUids.length, " components selected, must be one and only one. addItem failed");
				return null;
			}
			
			selectedComponentUid = selectedComponentUids[0];
			
		}
		
		var selectedComponent:UiBase = ComponentProxy.createFromUid(selectedComponentUid).getComponent();
		if(!selectedComponent){
			//T.y("component not found at ", selectedComponentUids[0], ". add failed");
			return null;
		}
		
		
		selectedComponent.actions.push(data);
		
		selectedComponent.layoutInstance.isDirty = true;
		
		var actionProxy:ActionProxy = ActionProxy.createFromComponent(selectedComponent, selectedComponent.actions.length - 1);
		
		SilexAdminApi.getInstance().historyManager.addUndoableAction(
		new HaxeLink.getHxContext().org.silex.adminApi.undoable_actions.AddAction(
		actionProxy.uid));
		
		signalDataChanged();
		return actionProxy.uid;
		
	}
	
	/**
	 * delete an action from the selected component. 
	 * If there is not exactly one selected component, the method fails
	 * 
	 * @param data The uid of the action to delete
	 * @returns uid of created action
	 * */
	public function deleteItem(objectId:String):Void
	{
	
		//TO DO : implement this undoable action
		//SilexAdminApi.getInstance().historyManager.flush();
		
		//T.y("components deleteItem ", objectId);
		var actionProxy:ActionProxy = ActionProxy.createFromUid(objectId);
		if(!actionProxy){
			//T.y("action proxy with uid ", objectId, " not found. delete failed");
			return;
		}
		var component:UiBase = actionProxy.getRelativeComponent();
		var indexOfActionToDelete:Number = actionProxy.getIndexInRelativeComponent();
		component.actions.splice(indexOfActionToDelete, 1);		
		
		component.layoutInstance.isDirty = true;
	}
	
	/**
	 * swap the depths of 2 actions. changes the component actions
	 * @param objectId1 the uid of the first action
	 * @param objectId2 the uid of the second action
	 * */
	public function swapItemDepths(objectId1:String, objectId2:String):Void
	{
		//T.y("actions swapItemDepths ", objectId1, ", ", objectId2);
		var actionProxy1:ActionProxy = ActionProxy.createFromUid(objectId1);
		if(!actionProxy1){
			//T.y("action proxy with uid ", objectId1, " not found. swap failed");
			return;
		}
		
		var actionProxy2:ActionProxy = ActionProxy.createFromUid(objectId2);
		if(!actionProxy2){
			//T.y("action proxy with uid ", objectId2, " not found. swap failed");
			return;
		}
		
		
		var component:UiBase = actionProxy1.getRelativeComponent();
		if(component != actionProxy2.getRelativeComponent()){
			//T.y("actions not in same component. swap failed");
		} 
		var index1:Number = actionProxy1.getIndexInRelativeComponent();
		var index2:Number = actionProxy2.getIndexInRelativeComponent();
		
		
		var tempStore:Object = component.actions[index1];
		component.actions[index1] = component.actions[index2];
		component.actions[index2] = tempStore;
		
	}	
	
	
	/**
	 * reorder all the objects in the list.
	 * note: this does not check that there are no duplicates in the orderedObjectIds 
	 * @param orderedObjectIds an array of objectIds representing the wanted order. This must contain all the objectIds once and only once, or it will fail. They must be in the same layer.
	 * */
	function changeOrder(orderedObjectIds:Array):Void{
		//T.y("actions changeOrder " , orderedObjectIds);
		var numNew:Number = orderedObjectIds.length;
		var referenceActionProxy:ActionProxy = ActionProxy.createFromUid(orderedObjectIds[0]);
		var referenceComponent:UiBase = referenceActionProxy.getRelativeComponent();
		var numOld:Number = referenceComponent.actions.length;
		if(numNew != numOld){
			//T.y("not same length. failed");
			return;
		}
		var newActionsArray:Array = new Array();
		for(var i:Number = 0; i < numNew; i++){
			var actionProxy:ActionProxy = ActionProxy.createFromUid(orderedObjectIds[i]);
			if(!actionProxy){
				//T.y("couldn't find action matching ", orderedObjectIds[i], ". failed")
				return;
			}
			if(actionProxy.getRelativeComponent() != referenceComponent){
				//T.y("action at ", orderedObjectIds[i], " in wrong component: ", actionProxy.getRelativeComponent(), ". Should be in ", referenceComponent, ". failed");
				return;
			}
			var action:Object = actionProxy.getAction();
			newActionsArray.push(action);
		}
		referenceComponent.actions = newActionsArray;
		
	
		
		signalDataChanged();
	}		
				
}