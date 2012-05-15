/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.addComponents
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	import org.silex.wysiwyg.utils.FileUploader;
	
	/**
	 * Acts as a controller for the different parts of the AddComponnents toolbox.
	 * Instantiate the part and update the body data when the toolbox is updated.
	 * Manages skins upload on the server via an instance of the FileUploader classes
	 */ 
	public class AddComponentsUI extends StdUI
	{
		/////*/*/*/*/*/*/*/*/*/*/
		// CONSTANTS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * the name of the function upload skin, set as a static, to be 
		 * accessible from outside of this
		 * class
		 */ 
		public static const FUNC_UPLOAD_SKIN:String = "uploadSkin";
		
		/////*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * the FileUploader instance abstracting file upload
		 */ 
		private var _fileUploader:FileUploader;
		
		/**
		 * Stores the data of the component whose skins are currently
		 * being updated/overwritten
		 */ 
		private var _uploadedComponentToolItem:Object;
		
		/////*/*/*/*/*/*/*/*/*/*/
		// CONSTRUCTOR & INIT
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Instantiate each toolbox part and the file uploader instance
		 */ 
		public function AddComponentsUI()
		{
			_toolBoxBodyClass = AddComponentsUIBody;
			_toolBoxHeaderClass = AddComponentsUIHeader;
			_toolBoxFooterClass = AddComponentsUIFooter;
			
			_fileUploader = new FileUploader();
			
			super();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * listen for uplopad skin event, dispatched when the user clicks on the upload
		 * skin button in the toolbox body
		 * 
		 * @param event the triggered Flex Event
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			_toolBoxBody.addEventListener(ToolsEvent.UPLOAD_SKIN, onSkinBrowse);
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// PUBLIC METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * set and launch a skin file upload
		 * 
		 *  @param overwrite wether the uploaded skin must overwrite an existing one or must
		 * 	be pushed into the skins array
		 */ 
		public function uploadSkin(overwrite:Boolean = false):void
		{
			trace("upload skin");
			//disable the upload skin button while an upload is in progress
			(_toolBoxBody as AddComponentsUIBody).setSkinUpload(false);
			
			//add listener for success and error events
			//we set a different callback if the skin must overwrite another one
			if (overwrite == false)
			{
				_fileUploader.addEventListener(Event.COMPLETE, onUploadComplete);
			}
			else
			{
				_fileUploader.addEventListener(Event.COMPLETE, onUploadCompleteOverWrite);
			}
			
			_fileUploader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_fileUploader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			//set the name of the folder in which to upload the file, from the last part
			//of the fully qualified class name of the component
			var componentSkinsUID:String = (_uploadedComponentToolItem.className as String).substr((_uploadedComponentToolItem.className as String).lastIndexOf(".")+1);
			
			_fileUploader.upload(componentSkinsUID, ToolConfig.getInstance().skinsFolderPath);
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// BROWSE CALLBACK METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * When the user wants to start browsing for a file, listen for select and 
		 * cancel events than start the browsing
		 */ 
		private function onSkinBrowse(event:ToolsEvent):void
		{
			event.stopPropagation();
			
			_fileUploader.addEventListener(Event.SELECT, onFileSelect);
			_fileUploader.addEventListener(Event.CANCEL, onFileSelectCancel);
			
			//only display ".swf" files in the native browsing window
			_fileUploader.browse([new FileFilter("skin","*.swf")]);
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// FILE SELECTION CALLBACK METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * When the user selects a skin to upload, either
		 * upload it or ask for a confirmation from the user if uploading
		 * the skin will overwrite another skin
		 */ 
		private function onFileSelect(event:Event):void
		{
			removeSelectionListeners();
			var selectedFileName:String = _fileUploader.getSelectedFileName();
			
			var skins:Array = data.skins as Array;
			
			//check if a skin already has the same name as the selected skin file
			var flagFileAlreadyExist:Boolean = false;
			for (var i:int = 0; i<skins.length; i++)
			{
				if (skins[i].label == selectedFileName)
				{
					flagFileAlreadyExist = true;
				}
			}
			
			//stores the current skinnable component data to prevent errors in case
			//of the user switching to another skinnable component while the upload is in
			//progress
			_uploadedComponentToolItem = data;
			
			//if the selected file has the same as another skin, dispatch an event
			//prompting the wysiwyg to display a confirm box
			if (flagFileAlreadyExist == true)
			{
				dispatchEvent(new ToolsEvent(ToolsEvent.OVERWRITE_SKIN));
			}
			//else, start the upload of the skin
			else
			{
				uploadSkin();
			}
		}
		
		/**
		 * If the user cancels the skin selection, remove
		 * the listeners
		 */ 
		private function onFileSelectCancel(event:Event):void
		{
			removeSelectionListeners();
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// UPLOAD CALLBACK METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Called when the upload fails, remove listeners and reactivate
		 * the upload skin button
		 */ 
		private function onIOError(event:IOErrorEvent):void
		{
			(_toolBoxBody as AddComponentsUIBody).setSkinUpload(true);
			removeUploadListeners();
		}
	
		/**
		 * Called when the upload fails, remove listeners and reactivate
		 * the upload skin button
		 */ 
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			(_toolBoxBody as AddComponentsUIBody).setSkinUpload(true);
			removeUploadListeners();
		}
		
		/**
		 * When the upload succeeds, reactivate upload skin button, then add
		 * a new skin and refresh the component tool item data so that the new skin instantly
		 * appears in the skin panel
		 */ 
		private function onUploadComplete(event:Event):void
		{
			removeUploadListeners();
			(_toolBoxBody as AddComponentsUIBody).setSkinUpload(true);
			var skins:Array = _uploadedComponentToolItem.skins as Array;
			skins.push(getNewSkin());
			updateComponentSkins(skins);
		}
		
		/**
		 * Same as "onUploadComplete" but overwrite an old skin with the new skin
		 * instead of just pushing it in the skins array
		 */ 
		private function onUploadCompleteOverWrite(event:Event):void
		{
			removeUploadListeners();
			(_toolBoxBody as AddComponentsUIBody).setSkinUpload(true);
			var skins:Array = _uploadedComponentToolItem.skins as Array;
			
			var newSkin:Object = getNewSkin();
			
			//when the old skin with the same label is found,
			//replace it
			for (var i:int = 0; i<skins.length; i++)
			{
				if (skins[i].label == newSkin.label)
				{
					skins[i] = newSkin;
				}
			}
			
			updateComponentSkins(skins);
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// PRIVATE METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Create a new skin from the component skin UID.
		 * Uploaded skin have no description and they take for name the name of their files
		 * minus their extension which is always .swf
		 */ 
		private function getNewSkin():Object
		{
			var ComponentSkinUID:String = getComponentSkinUID();
			
			var skinLabel:String = (_fileUploader.getSelectedFileName()).replace(".swf", "");
			
			return {
				label:skinLabel,
				description:"",
				url:ToolConfig.getInstance().skinsFolderPath+ComponentSkinUID+"/"+_fileUploader.getSelectedFileName()};
		}
		
		/**
		 * update the current component skins array then update it's value on the SilexAdminApi
		 * by adding it (when the SilexAdminApi detects the already existing too; item, it overwrite it's value
		 * such as it's skins, then dispatches an event listened by the wysiwyg that will refresh the skinPanel,
		 * making the new skin appear)
		 * 
		 * @param skins the updated skins array
		 */ 
		private function updateComponentSkins(skins:Array):void
		{
			trace("update component skins");
			_uploadedComponentToolItem.skins = skins;
			SilexAdminApi.getInstance().toolBarItems.addItem(_uploadedComponentToolItem);
		}
		
		/**
		 * Return the current component skin UID, consisiting
		 * of the last part of the component class name
		 */ 
		private function getComponentSkinUID():String
		{
			return (_uploadedComponentToolItem.className as String).substr((_uploadedComponentToolItem.className as String).lastIndexOf(".")+1);
		}
		
		/**
		 * remove the selection listeners
		 */ 
		private function removeSelectionListeners():void
		{
			_fileUploader.removeEventListener(Event.SELECT, onFileSelect);
			_fileUploader.removeEventListener(Event.CANCEL, onFileSelectCancel);
		}
		
		/**
		 * remove the upload listeners
		 */ 
		private function removeUploadListeners():void
		{
			_fileUploader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_fileUploader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_fileUploader.removeEventListener(Event.COMPLETE, onUploadComplete);
			_fileUploader.removeEventListener(Event.COMPLETE, onUploadCompleteOverWrite);
		}

	}
}