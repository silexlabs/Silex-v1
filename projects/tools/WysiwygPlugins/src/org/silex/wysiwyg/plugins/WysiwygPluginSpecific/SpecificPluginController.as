/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginSpecific
{
	import flash.external.ExternalInterface;
	
	import mx.core.FlexGlobals;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Component;

	/**
	 * The controller of the plugin. 
	 * Get the selected component(s) data from the SilexAdminApi and use the returned typeArray(s) 
	 * to determine the panel to load.
	 */ 
	public class SpecificPluginController
	{
		/**
		 * the folder in which the panels .swf are located
		 */ 
		private var _panelsFolderUrl:String;
		
		/**
		 * the root url of the server, retrieved via FlashVars
		 */ 
		private var _rootUrl:String;
		
		/**
		 * The list of panels name
		 */ 
		private var _panelsList:Array;
		
		public static const SPECIFIC_PLUGIN_ID:String = "specificPlugin";
		
		/**
		 * get the plugin conf from JavaScript
		 */ 
		public function SpecificPluginController()
		{
			_panelsFolderUrl = FlexGlobals.topLevelApplication.parameters.baseUrlSpecificPanels;
			_panelsList = FlexGlobals.topLevelApplication.parameters.specificPanels.split(",");
			_rootUrl = FlexGlobals.topLevelApplication.parameters.rootUrl;
		}
		
		/**
		 * returns the right specific panel url
		 */ 
		public function getSpecificPanelUrl():Object
		{
			return doGetSpecificPanelUrl();
		}
		
		
		/**
		 * returns the selected components
		 * 
		 */ 
		private function getSelectedComponents():Array
		{
			return SilexAdminApi.getInstance().components.getObjectsByUids(SilexAdminApi.getInstance().components.getSelection());;
		}
		
		
		/**
		 * parse component(s) type array and return the required specific
		 * panel url
		 * 
		 * @param typeArray the array describing the component's inheritance hierarchy
		 */ 
		private function doGetSpecificPanelUrl():Object
		{
			//a flag speicifing if an editor has been specifically build for the selected component
			//or if a default editor was used
			var flagSpecificEditor:Boolean = false;
			
			//retrieve the selected components
			var selectedComponents:Array = getSelectedComponents();
			//if multiple components are selected, opens the specific
			//multi-components panel
			if (selectedComponents.length > 1)
			{
				//we set the flag to true, as though it is a default panel for multiple selection
				//it shows all the needed properties
				flagSpecificEditor = true;
				
				return {url:_panelsFolderUrl + "MultiSelection.swf", isSpecificEditor:flagSpecificEditor};
			}
			
			var selectedComponent:Component = selectedComponents[0];
			//if the component specific editor url has been specified
			//in the component Descriptor, returns it
			if (selectedComponent.getSpecificEditorUrl() != null)
			{
				//an url has been speicified for the component so we set the flag to true
				flagSpecificEditor = true;
				return {url:_rootUrl + selectedComponent.getSpecificEditorUrl(), isSpecificEditor:flagSpecificEditor};
			}
			
			//at last, use the type array to find the panel
			var typeArray:Array = selectedComponent.typeArray;
			
			//check if the typeArray is defined
			if (typeArray != null)
			{
				//loop in the each item of the type array
				var typeArrayLength:int = typeArray.length;
				typeArray.reverse();
				for (var j:int = 0; j<typeArrayLength; j++)
				{
					var propertyPluginsArrayLength:int = _panelsList.length;
					for (var k:int = 0; k<propertyPluginsArrayLength; k++)
						{
							//if a specific panel matches the typeArray name,
							//returns the url of the specific editor swf
							if ((replace(typeArray[j] as String, ".", "_")+".swf") == _panelsList[k] as String)
							{
								return  {url:_panelsFolderUrl + replace(typeArray[j], ".", "_") + ".swf", isSpecificEditor:flagSpecificEditor};
							}
						}
						
				}
			}
			
			
			
			
			//if there is no match, sends the default editor url
			return {url:_panelsFolderUrl + "Base.swf", isSpecificEditor:flagSpecificEditor} ;
		}
		
		/**
		 * utility method replacing characters in a string
		 * @param	org the string whick will be parsed
		 * @param	fnd the characters that need to be replaced
		 * @param	rpl the replacing characther
		 */
		private function replace(org:String, fnd:String, rpl:String):String
		{
			return org.split(fnd).join(rpl);
		}
	}
}