/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginSpecific.panelUis
{
	import flash.events.Event;
	
	import mx.containers.VBox;
	import mx.controls.CheckBox;
	import mx.controls.NumericStepper;
	import mx.controls.TextArea;
	import mx.utils.ObjectProxy;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.plugins.WysiwygPluginSpecific.SpecificPluginController;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	
	/**
	 * A base class for the panels Ui elements. Proxies property update
	 */ 
	public class PanelUiBase extends VBox
	{
		
		/**
		 * the object containing all the property object,
		 * with their names a key
		 */ 
		[Bindable]
		public var propertyArray:ObjectProxy;
		
		/**
		 * a const for the name of the playerName property
		 */ 
		public static const PLAYER_NAME_PROPERTY_NAME:String = "playerName";
		
		public function PanelUiBase()
		{
			super();
		}
		
		/**
		 * proxies property update. Dispatch an event containing the updated property uid
		 * that will be used to compare values when the DATA_CHANGe event comes back from
		 * SilexAdminApi. If the uids matches, there is no need to update the panels data
		 */ 
		protected function updatePropertyValue(value:*, propertyName:String):void
		{
			(propertyArray[propertyName] as  Property).updateCurrentValue(value, SpecificPluginController.SPECIFIC_PLUGIN_ID);
			//if the user is changing the playerName
			//we call a method on the ToolBoxApi updating the name of the component
			//displayed in the component toolbox
			if (propertyName == PLAYER_NAME_PROPERTY_NAME)
			{
				ToolBoxAPIController.getInstance().refreshComponentDisplayedName(SilexAdminApi.getInstance().components.getSelection()[0], value);
			}
		}
		
		/**
		 * Select a property on SilexAdminApi, which makes the Wysiwyg
		 * display the specific editor for this particular property
		 * 
		 * @param property the property to select
		 */ 
		protected function selectProperty(property:Property):void
		{
			SilexAdminApi.getInstance().properties.select([property.uid]);
		}
		
		/**
		 * called when the propertyArray has been updated. Can be overiden
		 * to call extra method when property data changed
		 */ 
		public function signalPropertiesUpdate():void
		{
			
		}
		
	}
}