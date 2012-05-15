/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.properties
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarMode;
	import mx.controls.SWFLoader;
	import mx.core.ContainerCreationPolicy;
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	import org.silex.wysiwyg.utils.SimpleLoader;
	
	/**
	 * This class loads external flex application at runtime with a SWFLoader. Each application is a panel used 
	 * to change the selected component(s) properties.
	 * 
	 */ 
	public class PropertiesUI extends StdUI
	{
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// CONSTANTS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * const for the method name updating the name of the components displayed
		 * in the toolbox header
		 */ 
		public static const UPDATE_HEADER_TEXT:String = "updateHeaderText";
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 *  stores the currently loaded toolbox URL
		 */ 
		private var _currentURL:String;
		
		/**
		 * the SWFLoader used to load applications
		 */ 
		private var _loader:SWFLoader;
		
		/**
		 * the loadbar displayed during plugin loading
		 */ 
		private var _loadBar:ProgressBar;
		
		/**
		 * Stores wether the SWFLOader is loading a plugin so we can safely stop the loading
		 */ 
		private var _pending:Boolean;
		
		/**
		 * Stores the successfuly loaded panel to prevent uneccessary reload, where the key
		 * id the url of the loaded SWF
		 */ 
		private var _loadedPlugins:Object;
		
		/**
		 * Check if the creation complete event has been called on this toolbox to prevent 
		 * manipulating display object not yet instantiated
		 */ 
		private var _toolboxReady:Boolean;
		
		/**
		 * In the case where an editor must be loaded before the toolbox is ready (before it's creation is complete),
		 * stores the editor data so that it can be loaded as soon as the toolbox is ready
		 */ 
		private var _pendingEditor:Object;
		
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// CONTRUCTOR
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Initatialise the toolbox parts. 
		 */ 
		public function PropertiesUI()
		{
			//the toolbox will be ready when onCreationComplete is called
			_toolboxReady = false;
			
			//sets the classes of the toolbox parts
			_toolBoxHeaderClass = PropertiesUIHeader;
			_toolBoxBodyClass =  PropertiesUIBody;
			_toolBoxFooterClass = PropertiesUIFooter;
			
			
			_loadBar = new ProgressBar();
			_loadBar.mode = ProgressBarMode.MANUAL;
			_loadBar.width = 300;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			super();
			
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PUBLIC METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * update the name of the components displayed in the header
		 * 
		 * @param arguments contains the name string to display
		 */ 
		public function updateHeaderText(arguments:Object):void
		{
			_toolBoxHeader.subTitle = arguments as String;
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// OVERRIDEN METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Retrieve the new panel tio load datas from the data object
		 * and loads it if it isn't already loaded
		 * 
		 * @param value the new data object
		 */ 
		override public function set data(value:Object):void
		{
			//if the toolbox creation is not yet complete, 
			//stores the editor data, to be used when the 
			//toolbox is ready
			if (_toolboxReady == false)
			{
				_pendingEditor = value;
				return;
			}
			
			//if the new url is different from the currently loaded
			if (value.editorUrl != _currentURL && value != null)
			{
				//if the SWFLoader is loading, cleanly stop the process
				if (_pending == true)
				{
					_loader.removeEventListener(Event.COMPLETE, onPluginLoadComplete);
					_loader.removeEventListener(ProgressEvent.PROGRESS, onPluginLoadComplete);
					_loader.unloadAndStop();
					_toolBoxBody.removeChild(_loadBar);
				}
					
				else
				{
					_toolBoxBody.removeChild(_loader);
				}
				
				
				//if the plugin was already loaded and stored, use the stored plugin to 
				//prevent unecessary loading
				if (_loadedPlugins[ToolConfig.getInstance().rootUrl + value.editorUrl] != null)
				{
					_loader = _loadedPlugins[ToolConfig.getInstance().rootUrl + value.editorUrl];
					_toolBoxBody.addChild(_loader);
					
				}
					
					//else load the plugin SWF
				else
				{
					_loader = new SWFLoader();
					_loader.percentHeight = 100;
					_loader.percentWidth = 100;
					
					_pending = true;
					
					_toolBoxBody.addChild(_loadBar);
					
					_loader.addEventListener(ProgressEvent.PROGRESS, onPluginLoadProgress, false, 0, true);
					_loader.addEventListener(Event.COMPLETE, onPluginLoadComplete, false, 0, true);
					_loader.load(ToolConfig.getInstance().rootUrl + value.editorUrl);
				}
				
				_currentURL = value.editorUrl;
				
				
			}
			
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PRIVATE METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * init the SWFLoader when the creation is complete
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			_loadedPlugins = new Object();
			
			_loader = new SWFLoader();
			_loader.percentHeight = 100;
			_loader.percentWidth = 100;
			
			_toolBoxBody.setStyle("verticalAlign", "middle");
			_toolBoxBody.setStyle("horizontalAlign", "center");
			
			_toolBoxHeader.creationPolicy = ContainerCreationPolicy.ALL;
			
			_toolBoxBody.addChild(_loader);
			
			_toolboxReady = true;
			//set the default properties editor, for the case where the user already has selected components
			//before starting the wysiwyg
			if (_pendingEditor != null)
			{
				this.data = _pendingEditor;
			}
		}
		
		/**
		 * Update the progress bar
		 * 
		 * @param event the trigerred progress event
		 */ 
		private function onPluginLoadProgress(event:ProgressEvent):void
		{
			_loadBar.setProgress(event.bytesLoaded, event.bytesTotal);
		}
		
		/**
		 * When a plugin is done loading, stores it's SWFLoader to prevent unecessary loadings
		 * 
		 * @param event the triggered Complete event
		 */ 
		private function onPluginLoadComplete(event:Event):void
		{
			_pending = false;
			(event.target as SWFLoader).removeEventListener(Event.COMPLETE, onPluginLoadComplete);
			(event.target as SWFLoader).removeEventListener(ProgressEvent.PROGRESS, onPluginLoadComplete);
			_loadedPlugins[(event.target as SWFLoader).source] = _loader;
			_toolBoxBody.removeChild(_loadBar);
			_toolBoxBody.addChild(_loader);
		}
	}
}