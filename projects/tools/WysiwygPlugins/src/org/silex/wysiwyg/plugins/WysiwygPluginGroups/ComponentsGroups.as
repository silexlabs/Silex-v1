/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/*
 * @author: RapH
 * @date: 2011-02-23
 * @description: this package is used to store multiple components on a server file
 * 
 */
package org.silex.wysiwyg.plugins.WysiwygPluginGroups
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.silex.wysiwyg.plugins.WysiwygPluginGroups.ComponentCopier;
	import org.silex.wysiwyg.plugins.WysiwygPluginGroups.FilesUtils;

	//public class ComponentsGroups extends Sprite {
	public class ComponentsGroups extends Sprite {

		private var file:FilesUtils = new FilesUtils();

		/**
		 * Called when class is instanciated
		 */
		/*public function ComponentsGroups() 
		{
			loadButton.addEventListener(MouseEvent.MOUSE_DOWN, loadButtonMouseDownHandler);
			saveButton.addEventListener(MouseEvent.MOUSE_DOWN, saveButtonMouseDownHandler);
		}*/
		
		/**
		 * Callback when loadButton is pressed
		 * @param	event
		 */
		public function load(groupName:String):void
		{
			// Add Event Listener to listen when the file has been loaded from server
			file.addEventListener(FilesEvent.FILE_LOADED_FROM_SERVER, pasteToScene);
			// Get components from corresponding server file and copy it into ComponentCopier's copiedComponents variable
			file.readFromServer("group");
		}
		
		/**
		 * Handler when saveButton is pressed
		 * @param	event
		 */
		public function save(groupName:String):void
		{
			// Copy selected components 
			ComponentCopier.getInstance().copy();
			if (ComponentCopier.getInstance().areItemsCopied() == true) {
				trace("composants copiés");
			} else {
				trace("composants non copiés");
			}
			
			var buffer:Array = ComponentCopier.getInstance().copiedComponents;

			// Add Event Listener to listen if the file has been stored correctly by the server
			file.addEventListener(FilesEvent.FILE_SENT_TO_SERVER, responseStatus);
			// Send copied components to server for storage
			//file.sendToServer("group", ComponentCopier.getInstance().copiedComponents);
			file.sendToServer(groupName, ComponentCopier.getInstance().copiedComponents);
		}
		/**
		 * Paste server file's content to scene 
		 * @param	event
		 */
		private function pasteToScene(event:FilesEvent):void
		{
			(event.currentTarget as FilesUtils).removeEventListener(FilesEvent.FILE_LOADED_FROM_SERVER, pasteToScene);
			// Store data from server file into buffer variable
			var buffer:Array = event.data.fileContent as Array;

			// Copy data from buffer to ComponentCopier's copiedComponents buffer variable
			ComponentCopier.getInstance().copiedComponents = buffer;

			// Paste the buffer to silex stage
			ComponentCopier.getInstance().paste();
			trace("components copied on the scene");
			ExternalInterface.call('popupMessage("Groupe Chargé")');
		}
		
		private function responseStatus(event:FilesEvent):void
		{
			(event.currentTarget as FilesUtils).removeEventListener(FilesEvent.FILE_SENT_TO_SERVER, responseStatus);
			ExternalInterface.call('popupMessage',event.data.message);
		}
	}
}
