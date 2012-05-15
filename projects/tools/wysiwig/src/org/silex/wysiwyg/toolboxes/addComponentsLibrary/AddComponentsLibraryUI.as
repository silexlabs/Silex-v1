/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.addComponentsLibrary
{
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	import org.silex.wysiwyg.utils.StringOperation;
	
	/**
	 * the UI of the toolbox used to add media (image, video, sound) components. This classes
	 * acts as the controller between the 3 parts of the toolbox (header, body, footer)
	 */ 
	public class AddComponentsLibraryUI extends StdUI
	{
		
		/**
		 * instantiate the 3 parts and add an event for the end of the creation of the toolbox
		 */ 
		public function AddComponentsLibraryUI()
		{
		
			_toolBoxBodyClass = AddComponentsLibraryUIBody;
			_toolBoxHeaderClass = AddComponentsLibraryHeader;
			_toolBoxFooterClass = AddComponentsLibraryUIFooter;
			
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * When the toolbox creation is complete, add listener on the different parts. 
		 * For the header, listens for change in the media filter (the type of media displayed) and for
		 * the selection of a media using the textInput. In the body listens for the user selection of a media
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			_toolBoxHeader.addEventListener(ToolsEvent.LIST_CHANGE, onFilterListChange);
			_toolBoxHeader.addEventListener(ToolsEvent.CHOOSE_MEDIA, onChooseMedia);
			_toolBoxBody.addEventListener(ToolsEvent.CHOOSE_MEDIA, onChooseMedia);
		}
		
		/**
		 * When the filters selection changes in the header, sets the new set of filter on the library
		 * then refresh it
		 */ 
		private function onFilterListChange(event:ToolsEvent):void
		{
			(_toolBoxBody as AddComponentsLibraryUIBody).libraryFilters = event.data as Array;
			(_toolBoxBody as AddComponentsLibraryUIBody).refreshLibrary();
		}
		
		/**
		 * sets the data on the library header and body. The transmitted object contains the list of filters to use.
		 * Sets them on the library then open the library at the default media path
		 * 
		 * @param value the array of filters to set on the library (sent as a string coming from
		 * the descriptors)
		 */ 
		override public function set data(value:Object):void
		{

			var filters:Array = value.filters.split(",");
			
			(_toolBoxHeader as AddComponentsLibraryHeader).libraryFilters = filters;
			(_toolBoxBody as AddComponentsLibraryUIBody).libraryFilters = filters;
			(_toolBoxBody as AddComponentsLibraryUIBody).targetPath = ToolConfig.getInstance().mediaFolderPath;
		}
		
		/**
		 * When the user choosed a media sent an event that will prompt the wysiwyg to add a new component
		 * 
		 * @param event the dispatched containing the url of the new media component to add
		 */ 
		private function onChooseMedia(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.CHOOSE_MEDIA, event.data, true));
		}
	}
}