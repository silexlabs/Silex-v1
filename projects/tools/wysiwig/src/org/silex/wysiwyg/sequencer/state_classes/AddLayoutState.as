/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes 
{
	import mx.resources.ResourceManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.SimpleAlertVO;
	import org.silex.wysiwyg.toolboxes.page_properties.PagePropertiesVO;
	
	/**
	 * a state designed to add a layout to a silex site
	 */
	public class AddLayoutState extends StateBaseShortcut
	{
		
		/**
		 * hides the component toolbox, show the page properties toolbox and
		 * sets listeners on it
		 */
		public function AddLayoutState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication);
			
			_toolCommunication.hide(ToolCommunication.COMPONENTS_TOOLBOX);
			_toolCommunication.show(ToolCommunication.PAGE_PROPERTIES_TOOLBOX);
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, doAddLayoutCallback);
			_toolCommunication.addEventListener(CommunicationEvent.CANCEL_DATA_CHANGED, doExitAddLayoutState);
			_toolCommunication.addEventListener(CommunicationEvent.ICON_SELECTION_CHANGED, iconSelectionChangedCallback);
			_toolCommunication.addEventListener(CommunicationEvent.PARENT_PAGE_SELECTION_CHANGED, parentPageSelectionChangedCallback);
			_toolCommunication.addEventListener(CommunicationEvent.FORM_ERROR, addLayoutFormErrorCallback);
			
			startAddLayout();
			
		}
		
		
		/**
		 * When the user wants to add a layout, enters the default state, then instantiate a PagePropertiesVO value object.
		 * This object will store all the necessary data displayed by the pagePropertiesToolbox
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		private function startAddLayout():void
		{
			var pagePropertiesVO:PagePropertiesVO = new PagePropertiesVO();
			//the pagePropertiesVO is filled with all the currently displayed layout. Only the layouts containing components are extracted
			pagePropertiesVO = setLayoutsList(pagePropertiesVO);
			
			//if no layout with components that can be used as icon are available, displays an error
			if (pagePropertiesVO.layoutList.length == 0)
			{
				noLayoutError();
				return;
			}
			
			var layouts:Array = _silexAdminApi.layouts.getData()[0] as Array;
			
			var selectedLayout:Layout;
			
			//if no layers are selected, we check if layouts are selected
			if(_silexAdminApi.layers.getSelection() == null || _silexAdminApi.layers.getSelection().length ==0)
			{
				//if no layout are selected, we use the first one
				if (_silexAdminApi.layouts.getSelection() == null || _silexAdminApi.layouts.getSelection().length == 0)
				{
					selectedLayout = layouts[0];
				}
				
				//else, we look for the one with the matching uid
				else
				{
					for (var j:int = 0; j<layouts.length; j++)
					{
						if ((layouts[j] as Layout).uid == _silexAdminApi.layouts.getSelection()[0])
						{
							selectedLayout = layouts[j];
						}
					}
				}
			}
			
			//else, we find to which layout belong the selected layer
			else
			{
				var selectedLayersUid:Array = _silexAdminApi.layers.getSelection();
				for (j=0; j<layouts.length; j++)
				{
					var layers:Array = _silexAdminApi.layers.getData([layouts[j].uid])[0];
					for(var k:int = 0; k<layers.length; k++)
					{
						for (var l:int = 0; l<selectedLayersUid.length; l++)
						{
							if (selectedLayersUid[l] == layers[k].uid)
							{
								selectedLayout = layouts[j];
							}
						}
					}
				}
			}
			
			
			
			
			
			//loop in the layout list to extract the currently selected layout. 
			for (var i:int = 0; i<pagePropertiesVO.layoutList.length; i++)
			{
				//if there is a match, fills the pagePropertiesVO with the selected layout
				if (pagePropertiesVO.layoutList[i].uid == selectedLayout.uid)
				{
					pagePropertiesVO.selectedLayout = pagePropertiesVO.layoutList[i];
				}
			}
			
			//if there is a selected layout
			if (pagePropertiesVO.selectedLayout)
			{
				//fills the pagePropertiesVO with the list of the selected layout components
				pagePropertiesVO = setComponentList(pagePropertiesVO);
				
				//check if they are components that can be used as icon
				if (pagePropertiesVO.componentsList[0] != null)
				{
					
					dispatchEvent(new ToolsEvent(ToolsEvent.FORM_ERROR, null, true));
					//set the selected component on the pagePropertiesVO with the first component of the list
					pagePropertiesVO.selectedComponent = pagePropertiesVO.componentsList[0];
					
					
					//sets the list of the selected component's properties on the pagePropertiesVO
					pagePropertiesVO = setPropertiesList(pagePropertiesVO);
					//sets the data on the PageProperties toolbox
					_toolCommunication.setData(ToolCommunication.PAGE_PROPERTIES_TOOLBOX, pagePropertiesVO);
				}
				else
				{
					//if no components can be used as icon, we show a message and close the toolbox
					noComponentError();
				}
				
			}
				
				//else if no layout is selected, it means that the currently selected
				//layout contains no components and is not stored in the layout list. An
				//alert toolbox is displayed containing a no component message
			else
			{
				noComponentError();
			}
			
		}
		
		
		/**
		 * sets the list of layout currently displayed which contains at least one component
		 * 
		 * @param	pagePropertiesVO the value object on which the data will be set
		 */
		private function setLayoutsList(pagePropertiesVO:PagePropertiesVO):PagePropertiesVO
		{
			//get all the currently displayed layout from the SilexAdminApi
			var tempLayoutArray:Array = _silexAdminApi.layouts.getData()[0];
			var layoutArray:Array = new Array();
			//loop in the layout array
			for (var i:int = 0; i<tempLayoutArray.length; i++)
			{
				//a flag determining if the layout must be added to the definitive layout array.
				//the layout is only added if he has one or many component which can be used as icon
				var flagLayout:Boolean = false;
				
				//get the layers from the selected layout
				var tempLayerArray:Array = _silexAdminApi.layers.getData([tempLayoutArray[i].uid])[0];
				//loop in the layer array
				for (var j:int = 0; j<tempLayerArray.length; j++)
				{
					var availableComponents:Array = _silexAdminApi.components.getData([tempLayerArray[j].uid])[0];
					
					//if the layer has one or many components
					if (availableComponents.length > 0)
					{
						for (var k:int = 0; k<availableComponents.length; k++)
						{
							var iconProperty:Property = _silexAdminApi.properties.getSortedData([(availableComponents[k] as Component).uid], ["iconIsIcon","iconDeeplinkName","iconPageName","iconLayoutName", "iconIsDefault"])[0].iconIsIcon;
							
							if (iconProperty != null)
							{
								if (iconProperty.currentValue != true)
								{
									//set the component flag to true
									flagLayout = true;
								}
								
							}
						}
						
					}
				}
				
				//if the component flag is true
				if (flagLayout)
				{
					//adds the layout to the definitive layout array
					layoutArray.push(tempLayoutArray[i]);
				}
			
			}
			
			//sets the definitive layout array on the pagePropertiesVO
			pagePropertiesVO.layoutList = layoutArray;
			
			return pagePropertiesVO;
		}
		
		/**
		 * Sets the list of Property object of the selected component on the pagePropertiesVO
		 * @param	pagePropertiesVO the value object on which the data will be set
		 */
		private function setPropertiesList(pagePropertiesVO:PagePropertiesVO):PagePropertiesVO
		{
			var flagIconComponent:Boolean = false;
			var propertyArray:Array = new Array();
			
			//get all the required icon properties of the selected component
			var propertyList:Object = _silexAdminApi.properties.getSortedData([pagePropertiesVO.selectedComponent.uid], 
				 ["iconIsIcon","iconDeeplinkName","iconPageName","iconLayoutName", "iconIsDefault"])[0];
		
			
			//wrapps the property array in a PropertyArrayWrapper
			pagePropertiesVO.propertiesList = propertyList;
			
			return pagePropertiesVO;
		}
		
		/**
		 * set the list of components of the selected layout on the PagePropertiesVO
		 * @param	pagePropertiesVO the value object on which the data will be set
		 */
		private function setComponentList(pagePropertiesVO:PagePropertiesVO):PagePropertiesVO
		{
			//get the selected layout's layers
			var layersArray:Array = _silexAdminApi.layers.getData([pagePropertiesVO.selectedLayout.uid])[0];
			
			var componentsArray:Array = new Array();
			
			//a flag storing wether the selected layout already has a default icon,
			//in which case we can't add anotther one
			var hasDefaultIconFlag:Boolean = false;
			
			//loop in the layer array
			for (var i:int = 0; i<layersArray.length; i++)
			{
				//for each layer, get his components
				var tempComponentsArray:Array = _silexAdminApi.components.getData([layersArray[i].uid])[0];
				for ( var j:int = 0; j< tempComponentsArray.length; j++)
				{
					//for each component, we check that it has an iconIsIcon property
					//as if it does'nt, it can't be used as an icon and musn't be added to the array
					//we also check that the component isn't already an icon as a component can be only be icon for
					//one layer at a time
					
					//REMINDER HACK : we get the data for multiple properties, as when we only ask for one
					//it sometimes returns a Property object whose properties are all null. It probably is a JS/AS communication bug
					//, we treat the communication as synchronous but it is actually asynchronous so sometimes the data are not
					//initialised in time
					var properties:Object = _silexAdminApi.properties.getSortedData([(tempComponentsArray[j] as Component).uid], ["iconIsIcon","iconDeeplinkName","iconPageName","iconLayoutName", "iconIsDefault"])[0];
					var iconProperty:Property = properties.iconIsIcon;
					if (iconProperty != null)
					{
						if (iconProperty.uid != null )
						{
							if(iconProperty.currentValue == false)
							{
								componentsArray.push(tempComponentsArray[j]);
							}
							
						}
					}
					
					var iconIsDefaultProperty:Property = properties.iconIsDefault;
					if (iconIsDefaultProperty != null)
					{
						if(iconIsDefaultProperty.uid != null)
						{
							if (iconIsDefaultProperty.currentValue == true)
							{
								hasDefaultIconFlag = true;
							}
						}
					}
					
					
				}
			}
			//set the list of components on the pagePropertiesVO
			pagePropertiesVO.componentsList = componentsArray;
			//set the flag specifiing if there are default icon
			pagePropertiesVO.hasDefaultIcon = hasDefaultIconFlag;

			return pagePropertiesVO;

		}
		

		
		/**
		 * When the user forgets to fill the name of the new layout, open the alert toolbox informing him
		 * @param	event the trigerred Communication event
		 */
		private function addLayoutFormErrorCallback(event:CommunicationEvent):void
		{
			var alertInfo:SimpleAlertVO = new SimpleAlertVO(
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_CREATE_NEW_LAYER_NO_NAME_ERROR_TITLE'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_CREATE_NEW_LAYER_NO_NAME_ERROR_MESSAGE'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_CREATE_NEW_LAYER_NO_NAME_ERROR_OK_LABEL')
			);
			
			
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, doAddLayoutCallback);
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, endAddLayoutFormErrorCallback);
			_toolCommunication.setData(ToolCommunication.ALERT_TOOLBOX, alertInfo);
			_toolCommunication.show(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * When the user clicks on the ok button of alert toolbox, hide the alert toolbox and removes it's listeners
		 * 
		 * @param	event the trigerred Communication event
		 */
		private function endAddLayoutFormErrorCallback(event:CommunicationEvent):void
		{
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, endAddLayoutFormErrorCallback);
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, doAddLayoutCallback);
			_toolCommunication.hide(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * When the user selects a different component in the icon combobox, the pagePropertiesVO list of properties is updated
		 * to match the newly selected component
		 * 
		 * @param	event the trigerred Communication event
		 */
		private function iconSelectionChangedCallback(event:CommunicationEvent):void
		{
			var pagePropertiesVO:PagePropertiesVO = event.data as PagePropertiesVO;
			
			pagePropertiesVO = setPropertiesList(pagePropertiesVO);
			
			_toolCommunication.setData(ToolCommunication.PAGE_PROPERTIES_TOOLBOX, pagePropertiesVO);
		}
		
		
		/**
		 * When the user selects a different layout in the parent page, the pagePropertiesVO list of components and
		 * list of properties is updated to match the newly selected layout
		 * 
		 * @param	event the trigerred Communication event
		 */
		private function parentPageSelectionChangedCallback(event:CommunicationEvent):void
		{
			var pagePropertiesVO:PagePropertiesVO = event.data as PagePropertiesVO;
			
			pagePropertiesVO = setComponentList(pagePropertiesVO);
			pagePropertiesVO.selectedComponent = pagePropertiesVO.componentsList[0];
			
			pagePropertiesVO = setPropertiesList(pagePropertiesVO);
			_toolCommunication.setData(ToolCommunication.PAGE_PROPERTIES_TOOLBOX, pagePropertiesVO);
		}
		
		/**
		 * When the user validates the page properties form, the selected component's properties are changed
		 * to turn the component into an icon
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		private function doAddLayoutCallback(event:CommunicationEvent):void
		{
			var pagePropertiesVO:PagePropertiesVO = event.data as PagePropertiesVO;
			
			//set the component as an icon
			(pagePropertiesVO.propertiesList["iconIsIcon"] as Property).updateCurrentValue(true);
			
			//set the name of the created layout
			(pagePropertiesVO.getPageName()).updateCurrentValue(pagePropertiesVO.newPageName);
			
			//set if the icon is a default icon (always opened)
			(pagePropertiesVO.getIsDefaultIcon()).updateCurrentValue(pagePropertiesVO.newIsIconeDefault);
			
			//set the deeplink that will appear in the browser adress bar
			(pagePropertiesVO.getPageDeepLink()).updateCurrentValue(pagePropertiesVO.newPageDeepLink);
			
			//set the name of the gabarit used by the new layout
			(pagePropertiesVO.getGabarit()).updateCurrentValue(pagePropertiesVO.newGabarit);
			
			//we need to make sure that no longer is selected,
			//else the selected component won't be able to to open the new layout
			//if it is editable
			_silexAdminApi.layers.select([]);
			
			//opens the newly created page
			pagePropertiesVO.selectedComponent.openIcon(true);
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState, true));
			
		}
		
		/**
		 * When the user cancels the layout creation, the application enters the default state
		 * 
		 * @param	event the trigerred Communication event
		 */
		private function doExitAddLayoutState(event:CommunicationEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
		}
		
		/**
		 * displays the alert toolbox with a message informing the user that there are no compponents on the 
		 * selected layout
		 */
		private function noComponentError():void
		{
			
			
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, doAddLayoutCallback);
			var alertInfo:SimpleAlertVO = new SimpleAlertVO(
				ResourceManager.getInstance().getString("WYSIWYG", "PAGE_PROPERTIES_ERROR_NO_ICON_TITLE"),
				ResourceManager.getInstance().getString("WYSIWYG", "PAGE_PROPERTIES_ERROR_NO_ICON_MESSAGE"),
				ResourceManager.getInstance().getString("WYSIWYG", "ALERT_TOOLBOX_DELETE_START_LAYER_ERROR_OK_LABEL")
				
			);
			
			alertInfo.data = new Object();	
			
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, endError);
			_toolCommunication.setData(ToolCommunication.ALERT_TOOLBOX, alertInfo);
			_toolCommunication.show(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * displays the alert toolbox with a message informing the user that there are no layouts with
		 * components that can be used as icon
		 */
		private function noLayoutError():void
		{
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, doAddLayoutCallback);
			var alertInfo:SimpleAlertVO = new SimpleAlertVO(
				ResourceManager.getInstance().getString("WYSIWYG", "PAGE_PROPERTIES_ERROR_NO_LAYOUT_TITLE"),
				ResourceManager.getInstance().getString("WYSIWYG", "PAGE_PROPERTIES_ERROR_NO_LAYOUT_MESSAGE"),
				ResourceManager.getInstance().getString("WYSIWYG", "ALERT_TOOLBOX_DELETE_START_LAYER_ERROR_OK_LABEL")
				
			);
			
			alertInfo.data = new Object();	
			
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, endError);
			_toolCommunication.setData(ToolCommunication.ALERT_TOOLBOX, alertInfo);
			_toolCommunication.show(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * Hides the alert toolbox when the user clicks the ok button and removes listeners on it
		 * 
		 * @param	event the trigerrd Communication event
		 */
		private function endError(event:CommunicationEvent):void
		{
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, endError);
			_toolCommunication.hide(ToolCommunication.ALERT_TOOLBOX);
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
		}
		
		
		/**
		 * hides the pageProperties toolbox and removes the listeners on it
		 */
		override public function destroy():void
		{
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, doAddLayoutCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.CANCEL_DATA_CHANGED, doExitAddLayoutState);
			_toolCommunication.hide(ToolCommunication.PAGE_PROPERTIES_TOOLBOX);
			_toolCommunication.addEventListener(CommunicationEvent.ADD_LAYOUT, addLayoutCallback);
		}
		
	}

}