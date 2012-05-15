/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginPropertyEditors
{
	import flash.events.Event;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Properties;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	
	
	/**
	 * This is a base class for property editors masking common tasks like
	 * retrieveing the selected property from the SilexAdminAPI
	 */ 
	public class PropertyEditorsBase extends Application
	{
		
		/**
		 * allow easy access to the selected property
		 */ 
		[Bindable]
		protected var _selectedProperty:Property;
		
		/**
		 * stores all the properties in an object where the keys are
		 * the properties name
		 */ 
		[Bindable]
		protected var _propertyArray:ObjectProxy;
		
		/**
		 * the names of the properties used by this panel.
		 * ex : "x", "y", "width"...
		 */ 
		protected var _filterValues:Array;
		
		
		/**
		 * the constant storing the property editors ID
		 */ 
		public static const PROPERTY_EDITOR_ID:String = "propertyEditor";
		
		public function PropertyEditorsBase()
		{
			super();
			this.styleName = "propertyEditorPlugin";
			percentHeight = 100;
			percentWidth = 100;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			registerFilterValues();
		}
		
		/**
		 * retrieve the selected property from the SilexAdminAPI and store
		 * a reference to all property in an indexed object
		 */ 
		protected function refreshProperty():void
		{
			var selectedPropertyUid:String = SilexAdminApi.getInstance().properties.getSelection()[0];
		
			
			//retrieve the sorted properties from SilexAdminApi
			var propertiesObj:ObjectProxy = new ObjectProxy(SilexAdminApi.getInstance().properties.getSortedData(null,_filterValues)[0]);
			
			//if no component is selected, do nothing
			if (propertiesObj == null)
			{
				return;
			}
			
			//translate the properties description
			for (var propertyName:String in propertiesObj)
			{
				if (propertiesObj[propertyName] is Property)
				{
					var property:Property = propertiesObj[propertyName];
					if (resourceManager.findResourceBundleWithResource('WYSIWYG', property.description))
					{
						property.description = resourceManager.getString('WYSIWYG', property.description);
					}
					
					if (property.uid == selectedPropertyUid)
					{
						_selectedProperty = property;
					}
				}
				
			}
			
			_propertyArray = propertiesObj;
			
		}
		
		/**
		 * set listeners on the SilexAdminApi
		 */ 
		protected function initListeners():void
		{
			SilexAdminApi.getInstance().properties.addEventListener(
				AdminApiEvent.EVENT_DATA_CHANGED, onPropertiesDataChanged, false, 0, true);
			
			SilexAdminApi.getInstance().properties.addEventListener(
				AdminApiEvent.EVENT_SELECTION_CHANGED, onPropertiesDataChanged, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
		}
		
		/**
		 * remove the listeners on the SilexAdminApi
		 */ 
		protected function removeListeners():void
		{
			SilexAdminApi.getInstance().properties.removeEventListener(AdminApiEvent.EVENT_DATA_CHANGED, onPropertiesDataChanged);
			SilexAdminApi.getInstance().properties.removeEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, onPropertiesDataChanged);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false,0, true);
		}
		
		/**
		 * When the user selects another property, refresh the selected properties
		 */ 
		protected function onPropertiesSelectionChange(event:AdminApiEvent):void
		{
			refreshProperty();
		}
		
		/**
		 * When the application is added, set it's listeners and refresh
		 * it's data
		 */ 
		protected function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initListeners();
			refreshProperty();

		}
	
		/**
		 * removes the editors listener when closed
		 */ 
		protected function onRemoved(event:Event):void
		{
			removeListeners();
		}
		
		/**
		 * Abstract the property object update process, so that we can add the Property Editors
		 * ID as originator
		 * 
		 * @param newValue the newValue to affect to the property
		 * @param propertyName the name of the property to update
		 */ 
		protected function updatePropertyValue(newValue:*, propertyName:String):void
		{
			(_propertyArray[propertyName] as Property).updateCurrentValue(newValue, PROPERTY_EDITOR_ID);
		}
		
		/**
		 * closer the current editor by loading the default editor
		 */ 
		protected function closeEditor():void
		{
			var toolBoxApiController:ToolBoxAPIController = ToolBoxAPIController.getInstance();
			toolBoxApiController.loadEditor(toolBoxApiController.getDefaultEditor().editorUrl, toolBoxApiController.getDefaultEditor().description);
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
		 * Abstract the process of updating the selected property to add the properties
		 * editor ID to it
		 * 
		 * @param newValue the newValue to affect to the selected property
		 */ 
		protected function updateSelectedProperties(newValue:*):void
		{
			_selectedProperty.updateCurrentValue(newValue, PROPERTY_EDITOR_ID);
		}
		
		/**
		 * When the properties data change, close the editor data if he isn't the 
		 * originator of this DATA_CHANGE
		 * 
		 * @param event the triggered AdminApiEvent
		 */ 
		protected function onPropertiesDataChanged(event:AdminApiEvent):void
		{
			if (event.data != PROPERTY_EDITOR_ID)
			{
				closeEditor();
			}
		}
	}
}