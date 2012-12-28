/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginGroups
{
	import flash.display.Loader;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.net.*;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import org.silex.wysiwyg.plugins.WysiwygPluginGroups.FilesEvent;
	
	/**
	 * Class to handle writing, updating and deleting a file on the server
	 * @author	Raphael Harmel
	 * @date	2011-02-25
	 */
	public class FilesUtils extends EventDispatcher
	{
		// Server file needed informations
		private const PLUGIN_DIR = 'plugins/groups/';
		private const GROUPS_DIR = 'groups/';
		private const GROUPS_FILE_EXTENSION = '.sx';
		// Server file handling the file system access
		private const SERVER_FILE_SYSTEM_ACCESS:String = "files_utils.php";
		// URLLoader instanciation
		var loader:URLLoader = new URLLoader();  
		
		/**
		 * This function sends a file to a server
		 * @param	file:		the file name
		 * @param	content:	the content of the file
		 */
		public function sendToServer(file:String, content:Array):void
		{
			// URLRequest setting using post in binary mode
			var request:URLRequest = new URLRequest(PLUGIN_DIR + SERVER_FILE_SYSTEM_ACCESS + "?file=" + file + GROUPS_FILE_EXTENSION);
			request.method = URLRequestMethod.POST;
			request.contentType = 'application/octet-stream';

			var byteArrayData:ByteArray = new ByteArray();
			byteArrayData.writeObject(content);
			request.data = byteArrayData;

			// URLLoader setting
			var loader:URLLoader = new URLLoader();
			// URLLoaderDataFormat needs to be set to VARIABLE so flash can understand easily server response.
			// Possible issue as data is sent as byteArrayData and received as BINARY
			//loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			try {
				// URLLoader load complete Handler creation
				loader.addEventListener(Event.COMPLETE, fileLoadedToServer);
				// Send and load the data to specified URL
				loader.load(request);
			} catch (error:SecurityError) {
				// dispatch security error
				dispatchEvent(new FilesEvent(FilesEvent.FILE_SENT_TO_SERVER, {message:'A Security Error has occurred'}));
			}
			
			byteArrayData.position = 0; // Necessary
			
			var object:Object = byteArrayData.readObject();
		}
		
		/**
		 * This function reads a file from a server
		 * @param	file:	the file name
		 */
		public function readFromServer(file:String):void
		{
			// File path to read construction
			var request:URLRequest = new URLRequest(PLUGIN_DIR + GROUPS_DIR + file + GROUPS_FILE_EXTENSION);
			
			// URLLoader instanciation
			//var loader:URLLoader = new URLLoader();  
			
			// URLLoader dataFormat setting to BINARY
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			// URLLoader load complete Handler creation
			loader.addEventListener(Event.COMPLETE, fileLoadedFromServer); 
			
			// File server loading
			loader.load(request);

		}
		
		// URLLoader load complete Handler
		private function fileLoadedToServer(event:Event):void {
			// Remove Handler
			(event.currentTarget as URLLoader).removeEventListener(Event.COMPLETE, fileLoadedToServer); 
			// Checks server response and output corresponding message
			// In case server response is ok
			if(event.currentTarget.data.phpStatus=='ok')
			{
				dispatchEvent(new FilesEvent(FilesEvent.FILE_SENT_TO_SERVER, {message:event.currentTarget.data.message}));
			}
			// In case server response is ko
			else
			{
				// ***do unsuccessful mail sent actions here***
				dispatchEvent(new FilesEvent(FilesEvent.FILE_SENT_TO_SERVER, {message:"Error :\n" + event.currentTarget.data.message}));
			}
		}

		/**
		 * Callback when file is loaded from server
		 */
		private function fileLoadedFromServer(event:Event):void
		{
			// Remove handler
			(event.currentTarget as URLLoader).removeEventListener(Event.COMPLETE, fileLoadedFromServer); 
			
			// Stores data from file into contentByteArray
			var contentByteArray:ByteArray = URLLoader(event.target).data;
			//contentByteArray.position = 0; // Not necessary
			
			// Convert to Array
			var serverFileContent:Array = contentByteArray.readObject();
			
			// Dispatch event containing data from file stored as array			
			dispatchEvent(new FilesEvent(FilesEvent.FILE_LOADED_FROM_SERVER, {fileContent:serverFileContent}));
		}

	}
}
