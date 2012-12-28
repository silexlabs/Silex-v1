/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginGroups
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	//import flash.events.TimerEvent;
	//import flash.utils.Timer;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.listedObjects.Action;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Property;

	/**
	 * Class to handle copy and paste of selected components
	 */
	public class ComponentCopier extends EventDispatcher
	//class ComponentCopier extends EventDispatcher
	{
		
		private static var _componentCopier:ComponentCopier;
		
		/**
		 * An array storing each selected components name, type, url, and an array containing all of it's propertyProxy.
		 */ 
		private var _copiedComponents:Array;
		//private var bufferData:Array;
		
		/**
		 * stores the number of remaining components to paste.
		 */ 
		private var _addedComponentsPendingCalls:int;
		
		/**
		 * stores the uids of the pasted component to select them all at the end of the process.
		 */ 
		private var _addedComponentsUids:Array;
		

		
		/**
		 * Singleton, don't use, use getInstance()
		 */ 
		public function ComponentCopier()
		{
			_addedComponentsUids = new Array();
		}
		
		public static function getInstance():ComponentCopier
		{
			if (_componentCopier == null)
			{
				_componentCopier = new ComponentCopier();
			}
			
			return _componentCopier;
		}
		
		/**
		 * Returns wether components have already been copied
		 */ 
		public function areItemsCopied():Boolean
		{
			if (_copiedComponents != null)
			{
				return true;
			}
			
			else
			{
				return false;
			}
		}
		
		/**
		 * Get the selected components from the SilexAdminAPI and their properties,
		 * deduce the component types based on it's typeArray. Store the data in the _copiedComponents array.
		 */ 
		public function copy():void
		{
			//reset the stored components array
			_copiedComponents = new Array();
			
			//stops here if no components are selected
			if (SilexAdminApi.getInstance().components.getData().length == 0)
			{
				return;
			}
			
			var selectedComponentsUid:Array = SilexAdminApi.getInstance().components.getSelection();
			//get the selected components and their properties
			var components:Array = SilexAdminApi.getInstance().components.getData()[0];
			
			var selectedComponents:Array = new Array();
			
			for (var i:int = 0; i<components.length; i++)
			{
				for (var j:int = 0; j<selectedComponentsUid.length; j++)
				{
					if (components[i].uid == selectedComponentsUid[j])
					{
						selectedComponents.push(components[i]);
					}
				}
			}
			

			var selectedProperties:Array = SilexAdminApi.getInstance().properties.getData();
			selectedProperties.reverse();
			
			var selectedActions:Array = SilexAdminApi.getInstance().actions.getData();
			selectedActions.reverse();
			
			for ( i = 0; i<selectedComponents.length; i++)
			{
				//store the component name
				var componentName:String = (selectedComponents[i] as Component).name;
				//stores the component metadata (url for image and video, text for Text)
				var componentMetadata:String = (selectedComponents[i] as Component).getAs2Url();
				//stores the className of the component
				var componentClassName:String = (selectedComponents[i] as Component).getClassName();
				//determine it's type
				var componentType:String = ComponentAddInfo.TYPE_COMPONENT;
				//stores all of the component properties	
				var componentProperties:Array = selectedProperties[i];
				//stores all the component actions
				var componentActions:Array = selectedActions[i];
				
				var initObj:Object = new Object();
				for ( j = 0; j<componentProperties.length; j++)
				{
					if ((componentProperties[j] as Property).name != "playerName")
					{
						initObj[(componentProperties[j] as Property).name] = (componentProperties[j] as Property).currentValue;
					}
				
				}
				
				
				_copiedComponents.push({
					name: componentName, 
					metadata:componentMetadata, 
					className:componentClassName,
					type:ComponentAddInfo.TYPE_COMPONENT, 
					initObj:initObj,
					properties:componentProperties,
					actions:componentActions});
			}
			
			
		}
		
		/**
		 * set the _addedComponentsPendingCalls to the length of the _copiedComponents array then calls the do paste function.
		 */ 
		public function paste():void
		{
			if (_copiedComponents.length == 0)
			{
				return;
			}
			
			_addedComponentsPendingCalls = _copiedComponents.length;
			doPaste();
		}
		
		/**
		 * add the component at index _addedComponentsPendingCalls, set listener on SilexAdminApi 
		 * for a COMPONENT_CREATED event setting the callback to the endPaste() method.
		 * Stores the added component'uid in the _addedComponentsUid array.
		 */ 
		private function doPaste():void
		{
			SilexAdminApi.getInstance().components.addEventListener(Components.EVENT_COMPONENT_CREATED, endPaste);
			
			var componentData:Object = new Object();
			componentData.playerName = _copiedComponents[_addedComponentsPendingCalls - 1].name;
			componentData.metaData = _copiedComponents[_addedComponentsPendingCalls -1 ].metadata;
			componentData.className = _copiedComponents[_addedComponentsPendingCalls -1 ].className;
			componentData.initObj = _copiedComponents[_addedComponentsPendingCalls -1 ].initObj;
			componentData.type = _copiedComponents[_addedComponentsPendingCalls - 1].type;
			
			_addedComponentsUids.push(SilexAdminApi.getInstance().components.addItem(componentData));
		}
		
		/**
		 * Removes the COMPONENT_CREATED event listener, 
		 * get the last added components propertyProxies using 
		 * it's uid stored in the _addedComponentsUid, 
		 * and set all it's values to match those of the stored data of 
		 * the _copiedComponents array at the _addedComponentsPendingCalls index. 
		 * decrement the _addedComponentsPendingCalls value. 
		 * if the value is superior to 0, calls the doPaste() 
		 * method, else select all the newly added component with their stored Uids, 
		 * then empties the array.
		 */ 
		private function endPaste(event:AdminApiEvent):void
		{
			SilexAdminApi.getInstance().components.removeEventListener(Components.EVENT_COMPONENT_CREATED, endPaste);
			
			var lastAddedComponentProperties:Array = SilexAdminApi.getInstance().properties.getData([_addedComponentsUids[_addedComponentsUids.length - 1]])[0];
			var copiedComponentsActions:Array = _copiedComponents[_addedComponentsPendingCalls -1].actions;
			
			
			//we select the last added component to add actions to it
			SilexAdminApi.getInstance().components.select([_addedComponentsUids[_addedComponentsUids.length - 1]]);
			//then add a new action for each saved action
			for (var i:int = 0; i<copiedComponentsActions.length; i++)
			{
				SilexAdminApi.getInstance().actions.addItem({
					functionName: (copiedComponentsActions[i] as Action).functionName,
					modifier: (copiedComponentsActions[i] as Action).modifier,
					parameters: (copiedComponentsActions[i] as Action).parameters
				});
			}
			
			_addedComponentsPendingCalls--;
			
			if (_addedComponentsPendingCalls > 0)
			{
				doPaste();
			}
			
			else
			{
				//unselect all coponents, we could select all the added
				//but it sometimes triggers error of not found component
				//propably caused by JavaScript asynchronous calls
				SilexAdminApi.getInstance().components.select([]);
				_addedComponentsUids = new Array();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		* The getter to access the copied data
		*/
		public function get copiedComponents():Array {
			return _copiedComponents;
		}
		/**
		* The setter to set the data to be pasted
		*/
		public function set copiedComponents(value:Array):void {
			_copiedComponents = value;
		}
		
	}
}