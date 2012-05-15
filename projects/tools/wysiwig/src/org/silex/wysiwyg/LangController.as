/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	import mx.resources.Locale;
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listedObjects.Message;
	import org.silex.wysiwyg.io.ToolConfig;
	
	/**
	 * this classes proxies acces to the ressource manager when the user wants to change the language of the wysiwyg
	 * it sets the new local and load the corresponding local text file 
	 * if the bundle does'nt already exist
	 */ 
	public class LangController extends UIComponent
	{
		
		
		public function LangController()
		{
			super();
		}
		
		/**
		 * checks first if the requested language as already been loaded for the wysiwyg
		 * RessourceBundle and adds it if not
		 * 
		 * @param language the requested language local
		 */ 
		public function setLanguage(language:String):void
		{
			//if the requested local does not exist on the wysiwyg resourceBundle
			if (resourceManager.getResourceBundle(language, "WYSIWYG") == null)
			{
				//load the local corresponding text file
				doSetLanguage();
			}
		}
		
		
		/**
		 * Retrieve the localised strings from the ToolConfig, parse it and create a new
		 * ressource bundle for the new local
		 * 
		 * @param event the complete event
		 */ 
		private function doSetLanguage():void
		{
			//an array storing each translated text and it's translation
			//for the corresponding local
			var langData:Array = ToolConfig.getInstance().localisedStrings;
			
			//creates a new ressource bundle for the new local
			var rb:ResourceBundle = new ResourceBundle(resourceManager.localeChain[0], "WYSIWYG");
			
			//sets the ressource bundle values in it's content object
			for (var i:int = 0; i<langData.length; i++)
			{
				var tempLangData:Array = langData[i].split("=");
				rb.content[tempLangData[0]] = tempLangData[1];
			}
			
			//adds the ressource bundle to the ressource manager
			resourceManager.addResourceBundle(rb);
			//update the ressource manager
			resourceManager.update();
			//then set the new local on the wysiwyg
			//resourceManager.localeChain = [_loadedLocal];
			
		}
	}
}