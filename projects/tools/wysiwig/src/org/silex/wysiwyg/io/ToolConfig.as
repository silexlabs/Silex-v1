/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.io
{
	import flash.display.LoaderInfo;
	import flash.errors.IllegalOperationError;
	import flash.external.ExternalInterface;
	
	import mx.core.FlexGlobals;
	
	import nl.demonsters.debugger.MonsterDebugger;

	/**
	 * Lists config constants
	 */ 
	public class ToolConfig
	{
		/**
		 * A path to the media folder path used by the library toolbox
		 */ 
		private var _mediaFolderPath:String;
		
		/**
		 * A path to the media folder path used by the library preview
		 */ 
		private var _mediaPreviewPath:String;
		
		/**
		 * A path to the default library media
		 */ 
		private var _libraryDefaultPicturePath:String;
		
		/**
		 * A path to the gateway path used by the ftp web service
		 */ 
		private var _gatewayPath:String;
		
		/**
		 * A path to the web service listing folder contents
		 */ 
		private var _dataExchangeServicePath:String;		
		
		/**
		 * A path to the property plugins
		 */ 
		private var _propertyPluginsPath:String;
		
		/**
		 * A path to the property editor plugins
		 */ 
		private var _propertyEditorPluginsPath:String;
		
		/**
		 * lists all the propertyPlugins in the property plugins folder
		 */ 
		private var _propertyPluginsArray:Array;
		
		/**
		 * lists all the propertyEditorPlugins in the property editor plugins folder
		 */ 
		private var _propertyEditorsPlugins:Object;
		
		/**
		 * lists all the available gabarits
		 */ 
		private var _gabaritList:Array;
		
		/**
		 * an array listing the available language
		 */ 
		private var _availableLanguages:Array;
		
		/**
		 * the default language of the wyswiwyg
		 */ 
		private var _defaultLanguage:String;
		
		/**
		 * the name of the default language bundle
		 */ 
		private var _wysiwygLanguageBundleName:String;
		
		/**
		 * the path to the language folder
		 */ 
		private var _langPath:String;
		
		/**
		 * an array storing each localised string for the wysiwyg
		 */ 
		private var _localisedStrings:Array;
		
		/**
		 * the root Url of the Silex Server
		 */ 
		private var _rootUrl:String;
		
		/**
		 * the classname of the embedded object frame. Used when the user wants
		 * to add an AS3 swf to the stage
		 */ 
		private var _embeddedObjectClassName:String;
		
		/**
		 * the as2 url of the embedded object frame swf. Used when the user wants
		 * to add an AS3 swf to the stage
		 */ 
		private var _embeddedObjectAS2Url:String;
		
		/**
		 * the name of the property of the embedded object frame. Used when the user wants
		 * to add an AS3 swf to the stage
		 */ 
		private var _embeddedObjectProperty:String;
		
		/**
		 * the path in the server where the components skins are located
		 */ 
		private var _skinsFolderPath:String;
		
		/**
		 * The path of the PHP script used to upload files to the server
		 */ 
		private var _uploadScriptPath:String;
		
		/**
		 * the PHP session id
		 */ 
		private var _session_id:String;
		
		/**
		 * The url of the panel loaded at startup
		 * in the properties toolbox
		 */ 
		private var _defaultEditorUrl:String;
		
		private static var _toolConfig:ToolConfig;
		
		
		
		public function ToolConfig(privateClass:PrivateClass)
		{
			
		}
		
		/**
		 * returns the singleton of the class, instantiate it and set it's values if it
		 * does'nt already exist
		 */ 
		public static function getInstance():ToolConfig
		{
			if (_toolConfig)
			{
				return _toolConfig;
			}
			
			else
			{
				
				
				_toolConfig = new ToolConfig(new PrivateClass);
				
				_toolConfig._propertyEditorsPlugins = new Object();
				
				_toolConfig._mediaFolderPath = FlexGlobals.topLevelApplication.parameters.mediaFolderPath;
				_toolConfig._mediaPreviewPath = FlexGlobals.topLevelApplication.parameters.mediaPreviewPath; 
				_toolConfig._libraryDefaultPicturePath = FlexGlobals.topLevelApplication.parameters.libraryDefaultPicturePath;
				_toolConfig._embeddedObjectClassName = FlexGlobals.topLevelApplication.parameters.embeddedObjectClassName;
				_toolConfig._embeddedObjectAS2Url = FlexGlobals.topLevelApplication.parameters.embeddedObjectAS2Url;
				_toolConfig._embeddedObjectProperty = FlexGlobals.topLevelApplication.parameters.embeddedObjectProperty;
				_toolConfig._gatewayPath = "../../cgi/gateway.php";
				_toolConfig._dataExchangeServicePath = "data_exchange.listFolderContent";
				_toolConfig._propertyPluginsPath = FlexGlobals.topLevelApplication.parameters.baseUrlPropertyPlugins;
				_toolConfig._propertyEditorPluginsPath = FlexGlobals.topLevelApplication.parameters.baseUrlPropertyEditorPlugins;
				_toolConfig._session_id = FlexGlobals.topLevelApplication.parameters.session_id;
				
				_toolConfig._uploadScriptPath = FlexGlobals.topLevelApplication.parameters.uploadScriptPath;
				_toolConfig._skinsFolderPath = FlexGlobals.topLevelApplication.parameters.skinsFolderPath;
				_toolConfig._defaultEditorUrl = FlexGlobals.topLevelApplication.parameters.defaultEditorUrl;
				_toolConfig._wysiwygLanguageBundleName = "WYSIWYG";
				_toolConfig._availableLanguages = FlexGlobals.topLevelApplication.parameters.availableLanguages.split(",");
				_toolConfig._defaultLanguage = FlexGlobals.topLevelApplication.parameters.defaultLanguage; 
				_toolConfig._langPath = FlexGlobals.topLevelApplication.parameters.baseUrlLanguage;
				
				_toolConfig._propertyPluginsArray = FlexGlobals.topLevelApplication.parameters.propertyPlugins.split(",");
				var tempPropertyArray:Array = FlexGlobals.topLevelApplication.parameters.propertyEditorPlugins.split("&");
				
				for (var i:int = 0; i<tempPropertyArray.length; i++)
				{
					var temp:Array = tempPropertyArray[i].split("=");
					if (temp[0] != "")
					{
						_toolConfig._propertyEditorsPlugins[temp[0]] = temp[1];
					}
				}
				
				
				
				_toolConfig._gabaritList = FlexGlobals.topLevelApplication.parameters.gabaritUrl.split(",");

				
				_toolConfig._localisedStrings = FlexGlobals.topLevelApplication.parameters.localisedStrings.split("&");
				
				_toolConfig._rootUrl = FlexGlobals.topLevelApplication.parameters.rootUrl;
				
				return _toolConfig;
			}
		}
		
		public function get embeddedObjectAS2Url():String
		{
			return _embeddedObjectAS2Url;
		}
		
		public function get embeddedObjectProperty():String
		{
			return _embeddedObjectProperty;
		}
		
		public function get defaultEditorUrl():String
		{
			return _defaultEditorUrl;
		}
		
		public function get embeddedObjectClassName():String
		{
			return _embeddedObjectClassName;
		}
		
		public function get localisedStrings():Array
		{
			return _localisedStrings;
		}
		
		public function get propertyPluginsArray():Array
		{
			return _propertyPluginsArray;
		}
		
		public function get propertyEditorsPlugins():Object
		{
			return _propertyEditorsPlugins;
		}
		
		public function get mediaFolderPath():String
		{
			return _mediaFolderPath;
		}
		
		public function get mediaPreviewPath():String
		{
			return _mediaPreviewPath;
		}
		
		public function get libraryDefaultPicturePath():String
		{
			return _libraryDefaultPicturePath;
		}
		
		public function get gatewayPath():String
		{
			return _gatewayPath;
		}
		
		public function get dataExchangeServicePath():String
		{
			return _dataExchangeServicePath;
		}
		
		public function get propertyPluginsPath():String
		{
			return _propertyPluginsPath;
		}	
		
		public function get session_id():String
		{
			return _session_id;
		}
		
		public function get propertyEditorPluginsPath():String
		{
			return _propertyEditorPluginsPath;
		}
		
		public function get gabaritList():Array
		{
			return _gabaritList;
		}
		
		public function get wysiwygLanguageBundleName():String
		{
			return _wysiwygLanguageBundleName;
		}
		
		public function get availableLanguages():Array
		{
			return _availableLanguages;
		}
		
		public function get defaultLanguage():String
		{
			return _defaultLanguage;
		}
		
		public function get langPath():String
		{
			return _langPath;
		}
			
		public function get rootUrl():String
		{
			return _rootUrl;
		}
		
		public function get skinsFolderPath():String
		{
			return _skinsFolderPath;
		}
		
		public function get uploadScriptPath():String
		{
			return _uploadScriptPath;
		}
		
	}
}

class PrivateClass
{
	public function PrivateClass():void
	{
		
	}
}