/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginSpecific.panels
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.utils.ObjectProxy;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Properties;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.adminApi.selection.SelectionManager;
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.plugins.WysiwygPluginSpecific.SpecificPluginController;
	
	/**
	 * This is a base class for properties panel in the wysiwyg. It is in charge of refreshing the panel properties
	 * when an event occurs on the SilexAdminApi (component creation, deletion, property update...)
	 */ 
	public class PanelBase extends Application
	{
		//////////////////////////
		// ATTRIBUTES
		/////////////////////////
		
		/**
		 * the Array containing reference to the
		 * panelUiBase objects. Each of them is a part of the panel's UI
		 */ 
		protected var _panelUis:Array;
		
		/**
		 * the names of the properties used by this panel.
		 * ex : "x", "y", "width"...
		 */ 
		protected var _filterValues:Array;
		
		/**
		 * Determine wether the panel must be refreshed. For instance when the selection
		 * on the components changes, it triggers an event which refresh the panel, then another is
		 * dispatched as the data changed on the properties, which would also refrzsh the panel 
		 * if it weren't for this flag
		 */ 
		private var _refreshPanelFlag:Boolean
		
		//////////////////////////
		// CONSTRUCTOR
		/////////////////////////
		
		/**
		 * Sets default style and add listener for when this panel is added 
		 * to the stage
		 */ 
		public function PanelBase()
		{
			super();
			
			this.styleName = "propertyPlugin";
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false,0, true);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0, true);
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
			
			_refreshPanelFlag = true;
		}
		
		//////////////////////////
		// PROTECTED METHODS
		/////////////////////////
		
		/**
		 * Initialise the panel and listeners
		 * when the application creation is complete
		 */ 
		protected function onCreationComplete(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			 
			_panelUis = new Array();
			registerPanelsUi();
			registerFilterValues();
		}
		
		/**
		 * When the application is added, set it's listeners and refresh
		 * it's data
		 */ 
		protected function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initListeners();
			refreshPanel();
		}
		
		/**
		 * When this application is unloaded, remove all it's
		 * listeners for clean garbage collection
		 * 
		 * @event the triggerred FlexEvent
		 */ 
		protected function onRemoveApplication(event:Event):void
		{
			removeListeners();
		}
		
		/**
		 * initialise the listeners on the SilexAdminAPi and the current application
		 */ 
		protected function initListeners():void
		{
			SilexAdminApi.getInstance().properties.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, onPropertiesDataChanged, false, 0, true);
			SilexAdminApi.getInstance().components.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, onComponentsSelectionChanged, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoveApplication, false, 0, true);
			
		}
		
		/**
		 * remove the previously added listeners
		 */ 
		protected function removeListeners():void
		{
			SilexAdminApi.getInstance().properties.removeEventListener(AdminApiEvent.EVENT_DATA_CHANGED, onPropertiesDataChanged);
			SilexAdminApi.getInstance().components.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, onComponentsSelectionChanged, false, 0, true);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveApplication);
			//the panel waits to be added to the stage again to refresh
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0, true);
		}
		
		/**
		 * When the selection of components changes, refresh the whole panel, and set a flag
		 * so that the subsequent properties data changed event won't refresh the panel also.
		 * This method is only called when a component of the same type as the current is selected,
		 * else the current panel is closed, another one is opened and this method is'nt called
		 * 
		 * @param event the triggerred AdminAPi event
		 */ 
		protected function onComponentsSelectionChanged(event:AdminApiEvent):void
		{
			refreshPanel();
			_refreshPanelFlag = false;
		}
		
		/**
		 * When the data changes on the SilexAdminApi properties, refresh the panel if it isn't
		 * the originator of the data change or update some of the properties if the
		 * selection Tool is at the origin of the data change
		 * 
		 * @param event the triggerred AdminAPi event
		 */ 
		protected function onPropertiesDataChanged(event:AdminApiEvent):void
		{
			//check if the panel has just been refreshed (for instance after a component
			// selection change) and only refresh the panel if it hasn't
			if (_refreshPanelFlag == true)
			{
				switch (event.data)
				{
					case SpecificPluginController.SPECIFIC_PLUGIN_ID:
					break;
					
					case SelectionManager.SELECTION_MANAGER_ID:
					updatePanel(["x","y","width,","height","rotation"]);
					break;
					
					default:
					refreshPanel();	
				}
			}
			
			_refreshPanelFlag = true;
		}
		
		/**
		 * Refresh the panels data by retrieving the properties from the SilexAdminAPI.
		 */ 
		protected function refreshPanel():void
		{	
			var propertiesObj:ObjectProxy = getPropertyObject(_filterValues);
			refreshPropertyObject(propertiesObj);
		}
		
		/**
		 * update some of the properties of the panels, defined by the filter
		 * values
		 * @param filterValues the name of the properties to update
		 */ 
		protected function updatePanel(filterValues:Array):void
		{
			//retrieve the property object to update
			var propertiesObj:ObjectProxy = getPropertyObject(filterValues);
			
			//retrieve the current panel property object from the first panel
			var currentPropertiesObj:ObjectProxy = _panelUis[0].propertyArray;
			
			//replace all the current property object with the same name as the 
			//updated property object
			for (var propertyName:String in currentPropertiesObj)
			{
				if (propertiesObj[propertyName] != null)
				{
					currentPropertiesObj[propertyName] = propertiesObj[propertyName];
				}
			}
			
			//refresh the panels display
			refreshPropertyObject(currentPropertiesObj);
			
		}
		
		/**
		 * refresh the property object on all panels then calls the overridable
		 * signalPropertiesUpdate method
		 * @param propertyObject the property object replacing the current property
		 * object on all panels
		 */ 
		protected function refreshPropertyObject(propertyObject:ObjectProxy):void
		{
			//send the properties object to every panel and signal the change
			for (var i:int = 0; i<_panelUis.length; i++)
			{
				_panelUis[i].propertyArray = propertyObject;
				_panelUis[i].signalPropertiesUpdate();
			}
		}
		
		/**
		 * Retrieve properties object from SilexAdminApi and return them as a map
		 * where the name of the property is the key 
		 * @filterValues the names of the properties to retrieve
		 */ 
		protected function getPropertyObject(filterValues:Array):ObjectProxy
		{
			//retrieve the sorted properties from SilexAdminApi
			var propertiesObj:ObjectProxy = new ObjectProxy(SilexAdminApi.getInstance().properties.getSortedData(null,filterValues)[0]);
			
			//if no component is selected, return an empty object
			if (propertiesObj == null)
			{
				return new ObjectProxy();
			}
			
			//translate the properties description
			for (var propertyName:String in propertiesObj)
			{
				
				if (propertiesObj[propertyName] is Property)
				{
					var property:Property = propertiesObj[propertyName] as Property;
					
					if (resourceManager.findResourceBundleWithResource('WYSIWYG', property.description))
					{
						property.description = resourceManager.getString('WYSIWYG', property.description);
					}
				}
			}
			
			return propertiesObj;
		}
		
		/**
		 * Sets the names of the values that needs to be retrieved
		 * by the SilexAdminApi. By default null, meaning that it will return all
		 * data from SilexAdminApi
		 */ 
		protected function registerFilterValues():void
		{
			_filterValues = null;
		}
		
		/**
		 * Overriden by inheriting application to add their panelUiComponent
		 */ 
		protected function registerPanelsUi():void
		{
			throw new IllegalOperationError("abstract method, needs to be overriden");
		}
		
		//////////////////////////
		// PRIVATE METHODS
		/////////////////////////
		
		/**
		 * When all the component update is done, we check if the panel needs
		 * an horizontal scrollbar. This is work around to prevent the 
		 * vertical scrollbar to trigger the display of the horizontal scrollbar
		 */ 
		private function onUpdateComplete(event:FlexEvent):void
		{
			//if a vertical scrollbar is present
			if (verticalScrollBar)
			{
				//we need to check if the horizontal scrollbar is only displayed
				//because of the vertical scrollbar width
				if (this.maxHorizontalScrollPosition < ScrollBar.THICKNESS)
				{
					//if it is, we remove the horizontal scrollbar
					this.horizontalScrollPolicy = ScrollPolicy.OFF;
				}
				else
				{
					//else we restore the auto scroll policy
					this.horizontalScrollPolicy = ScrollPolicy.AUTO;
				}
			}
		}
	}
}