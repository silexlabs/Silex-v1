package org.silex.wysiwyg.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.utils.URLUtil;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listedObjects.Message;
	import org.silex.adminApi.listedObjects.Tool;
	import org.silex.wysiwyg.io.ToolConfig;
	
	/**
	 * This classes abstract upload of files to the Silex server using Silex PHP upload script
	 * and Flash FileReference class
	 */ 
	public class FileUploader extends UIComponent
	{
		/////*/*/*/*/*/*/*/*/*/*/
		// CONSTANTS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * the folder to which upload the file
		 */ 
		private static const FOLDER_GET_PARAM_KEY:String = "folder";
		
		/**
		 * the path leading to the upload folder
		 */ 
		private static const FOLDER_ROOT_GET_PARAM_KEY:String = "rootFolder";
		
		/**
		 * the name of the file to upload
		 */ 
		private static const FILE_NAME_GET_PARAM_KEY:String = "name";
		
		/**
		 * the id of the PHP session, used to restore the session
		 */ 
		private static const SESSION_ID_GET_PARAM:String = "session_id";
		
		
		/////*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * the fileReference that will be used to browse and the user computer and upload
		 * the file to the server
		 */ 
		private var _fileReference:FileReference;
		
		/////*/*/*/*/*/*/*/*/*/*/
		// CONSTRUCTOR
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Instantiate the file reference
		 */ 
		public function FileUploader()
		{
			_fileReference = new FileReference();
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// PUBLIC METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Opens a native browse window on the user, allowing
		 * him to chose one file to upload, filtered by extension
		 * 
		 * @param filters an array of extensions to filter
		 */ 
		public function browse(filters:Array):void
		{
			_fileReference.addEventListener(Event.SELECT, onFileSelect);
			_fileReference.addEventListener(Event.CANCEL, onFileSelectCancel);
			_fileReference.browse(filters);
		}
		
		/**
		 * Upload a file on the server using the silex upload script, display an info 
		 * message
		 * 
		 * @param folderName the name of the folder in which to upload the selected file
		 * @param rootFolder the relative path leading to the target folder ex: "media/" or "skins/"
		 */ 
		public function upload(folderName:String, rootFolder:String):void
		{
			_fileReference.addEventListener(Event.COMPLETE, onUploadComplete);
			_fileReference.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_fileReference.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorEvent);
			
			//display a start message
			var uploadStartMessage:Message = new Message();
			uploadStartMessage.text = resourceManager.getString('WYSIWYG', 'INFO_UPLOAD_START');
			uploadStartMessage.time = 5000;
			uploadStartMessage.status = Messages.STATUS_INFO;
			SilexAdminApi.getInstance().messages.addItem(uploadStartMessage);
			
			//set up the request url with the GET parameters
			//used by the upload script :
			//folder = the folder name
			//name = the name of the uploaded file with extension
			//rootFolder = the path leading to the folder
			var urlReq:URLRequest = new URLRequest();
			urlReq.url = ToolConfig.getInstance().rootUrl+ 
				ToolConfig.getInstance().uploadScriptPath+
				"?"+FOLDER_GET_PARAM_KEY+"="
				+escape(folderName+"/")
				+"&"+FILE_NAME_GET_PARAM_KEY+"="
				+escape(_fileReference.name)
				+"&"+FOLDER_ROOT_GET_PARAM_KEY+"="+escape(rootFolder)
				+"&"+SESSION_ID_GET_PARAM+"="+ToolConfig.getInstance().session_id;
			urlReq.method = URLRequestMethod.POST;
			
			//upload the previously selected file
			_fileReference.upload(urlReq);
		}
		
		/**
		 * return the name of the selected file with it's extension
		 * @return ex : "mySelectedFile.swf"
		 */ 
		public function getSelectedFileName():String
		{
			return _fileReference.name;
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// CALLBACK METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Called when the user close the native browse window without selecting
		 * a file, remove all of the seelction listeners
		 * 
		 * @param event triggered on cancel
		 */ 
		private function onFileSelectCancel(event:Event):void
		{
			removeSelectionListeners();
		}
		
		/**
		 * Called when the user selects a file, relays the event
		 * then remove the seelction listeners
		 * 
		 * @param event triggered on select
		 */ 
		private function onFileSelect(event:Event):void
		{
			removeSelectionListeners();
			dispatchEvent(event);
		}
		
		/**
		 * Called when the upload succeded, relay the event
		 * then remove all of the upload listeners. Display a success message
		 * 
		 * @param event triggered on upload success
		 */ 
		private function onUploadComplete(event:Event):void
		{
			dispatchEvent(event);
			
			//display a success message
			var uploadCompleteMessage:Message = new Message();
			uploadCompleteMessage.text = resourceManager.getString('WYSIWYG', 'INFO_UPLOAD_COMPLETE');
			uploadCompleteMessage.time = 5000;
			uploadCompleteMessage.status = Messages.STATUS_INFO;
			SilexAdminApi.getInstance().messages.addItem(uploadCompleteMessage);
			
			removeUploadListeners();
		}
		
		/**
		 * Called when the upload failed due to an http error, relay the event, display an 
		 * error message, then remove listeners
		 */ 
		private function onHttpStatus(event:HTTPStatusEvent):void
		{
			displayErrorMessage();
			dispatchEvent(event);
			removeUploadListeners();
		}
		
		/**
		 * Called when the upload failed due to an IO error, relay the event, display an 
		 * error message, then remove listeners
		 */ 
		private function onIOErrorEvent(event:IOErrorEvent):void
		{
			displayErrorMessage();
			dispatchEvent(event);
			removeUploadListeners();
		}
		
		/////*/*/*/*/*/*/*/*/*/*/
		// PRIVATE METHODS
		/////*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Display an error message when upload fails
		 */ 
		private function displayErrorMessage():void
		{
			var uploadFailedMessage:Message = new Message();
			uploadFailedMessage.text = resourceManager.getString('WYSIWYG', 'ERROR_FILE_UPLOAD_FAILED');
			uploadFailedMessage.time = 5000;
			uploadFailedMessage.status = Messages.STATUS_ERROR;
			SilexAdminApi.getInstance().messages.addItem(uploadFailedMessage);
		}
		
		/**
		 * remove the browse events listeners
		 */ 
		private function removeSelectionListeners():void
		{
			_fileReference.removeEventListener(Event.SELECT, onFileSelect);
			_fileReference.removeEventListener(Event.CANCEL, onFileSelectCancel);
		}
		
		/**
		 * remove the upload events listeners
		 */ 
		private function removeUploadListeners():void
		{
			_fileReference.removeEventListener(Event.COMPLETE, onUploadComplete);
			_fileReference.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			_fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorEvent);
		}
	}
}