/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for layouts
 * */
 
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.listedObjects.LayoutProxy;
import org.silex.core.Layout;
import org.silex.core.Utils;
import org.silex.adminApi.util.T;
import org.silex.link.HaxeLink;

class org.silex.adminApi.listModels.Layouts extends ListModelBase
{
	public function Layouts()
	{
		super();
		_objectName = "layouts";
		_dependantLists.push("layers");
		_silexPtr.application.addEventListener("saveLayoutDone", Utils.createDelegate(this, onSaveLayoutDone));
		_silexPtr.application.addEventListener(_silexPtr.config.APP_EVENT_LAYOUT_REMOVED, Utils.createDelegate(this, onLayoutsChanged));
		_silexPtr.application.addEventListener(_silexPtr.config.APP_EVENT_LAYOUT_ADDED, Utils.createDelegate(this, onLayoutsChanged));
	}
	
	private function onLayoutsChanged(event:Object):Void{
		signalDataChanged();
	}
	
	private function onSaveLayoutDone(event:Object):Void{
		var layoutProxy:LayoutProxy = LayoutProxy.createFromLayout(event.layout);
		var layoutUid:String = layoutProxy.uid;
		//T.y("onSaveLayoutDone", event.error,layoutUid);
		var eventData:Object = {uid:layoutUid};
		var adminApiEvent:AdminApiEvent;
		if(event.errorMessage){
			eventData.errorMessage = event.errorMessage;
			adminApiEvent = new AdminApiEvent(AdminApiEvent.EVENT_SAVE_LAYOUT_ERROR, _objectName, eventData);
		}else{
			adminApiEvent = new AdminApiEvent(AdminApiEvent.EVENT_SAVE_LAYOUT_OK, _objectName, eventData);
		}
		ExternalInterfaceController.getInstance().dispatchEvent(adminApiEvent);
	}
	
	/**
	 * override of the select method to add a call to the HistoryManager for undo/redo
	 * @param	objectIds the selected layout Id
	 */
	public function select(objectIds:Array, data:Object):Void
	{
		SilexAdminApi.getInstance().historyManager.addUndoableAction(new HaxeLink.getHxContext().org.silex.adminApi.undoableActions.SelectLayer(SilexAdminApi.getInstance().layouts.getSelection()));

		super.select(objectIds, data);
	}
	
	/**
	 * Delete a layout by removing all icons reference pointing to it
	 * in it's parent layout
	 * 
	 * @param	objectIds the uid of the layout to delete
	 */
	public function deleteItem(objectIds:String):Void
	{
		
		//get all the layouts from the SilexAdminAPi
		var layouts:Array = SilexAdminApi.getInstance().layouts.getData()[0];
		
		//a reference to the currently selected layout
		var selectedLayout:LayoutProxy;
		//a reference to the selected layout parent
		var selectedLayoutParent:LayoutProxy;
		
		//loop in the layout array to get the layout to delete and it's parent
		for (var m:Number = 0; m<layouts.length; m++)
		{
			if (layouts[m].uid == objectIds)
			{
				selectedLayout = layouts[m];
				
				//if the first layout is the selected layout, 
				//then do nothing, as this is the start layout that
				//can't be deleted
				if (m == 0)
				{
					T.y("the start layout can't be deleted");
					return;
				}
				
				
				selectedLayoutParent = layouts[m-1];
			}
		}
		
		//get all the layers from the parent layout of the selected layout
		var layerArray:Array = SilexAdminApi.getInstance().layers.getData([selectedLayoutParent.uid])[0];

		var componentsArray:Array = new Array();
		
		//loop in the layers to extract all their components
		for (var i:Number = 0; i< layerArray.length; i++)
		{
			var tempComponentArray:Array = SilexAdminApi.getInstance().components.getData([layerArray[i].uid])[0];
			componentsArray = componentsArray.concat(tempComponentArray);
		}
		var propertiesArray:Array = new Array();
		
		//loop in all the components to extract there properties
		for (var j:Number = 0; j<componentsArray.length; j++)
		{
			var propertyList:Object = SilexAdminApi.getInstance().properties.getSortedData([componentsArray[j].uid], 
				["iconIsIcon", "iconDeeplinkName", "iconPageName", "iconLayoutName", "iconIsDefault"], "name")[0];
				
			//we check if the selected component can be an icon
			if (propertyList["iconIsIcon"] != undefined)
			{
				propertiesArray.push(propertyList);
			}
		
		}
		
		//loop in all the properties to find a component where the iconPageName properties matches the name of the
		//layout to delete
		for (var k:Number = 0; k<propertiesArray.length; k++)
		{
			//if there is a match set the iconIsIcon property of the component to false, deleting the referende to the layout that needs to be deleted
			//then saves the parent layout
			if (propertiesArray[k]["iconPageName"].currentValue == selectedLayout.name)
			{
				propertiesArray[k]["iconIsIcon"].updateCurrentValue(false);
				propertiesArray[k]["iconIsDefault"].updateCurrentValue(false);
				propertiesArray[k]["iconPageName"].updateCurrentValue("");
				propertiesArray[k]["iconDeeplinkName"].updateCurrentValue("");
				propertiesArray[k]["iconLayoutName"].updateCurrentValue("");
				selectedLayout.close();
				
				break;
			}
			
		}
		
	}
	
	/**
	 * note : containerUids is unused for layouts. The id is always "site"
	 * */
	private function doGetData(containerUids:Array):Array{
		//T.y("Layouts getData");
		var layoutProxys:Array = new Array();
		var silexLayouts:Array = _silexPtr.application.layouts;
		var len:Number = silexLayouts.length;
		for(var i:Number = 0; i < len; i++){
			var layout:Layout = silexLayouts[i];
			var layoutProxy:LayoutProxy = LayoutProxy.createFromLayout(layout);
			layoutProxys.push(layoutProxy);
			//Test
			////T.y("layoutProxy back to layout : ", LayoutProxy.getLayout(layoutProxy.uid).sectionName); 
		}
		return new Array(layoutProxys);
	}
	
}
