package org.silex.wysiwyg.ui.library
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.Responder;
	
	import mx.core.UIComponent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.io.RemotingConnection;
	import org.silex.wysiwyg.io.ToolConfig;

	public class WysiwygLibraryModel extends UIComponent
	{
		/**
		 * path to display
		 */ 
		private var _targetPath:String;
		
		/**
		 * path currently displayed
		 */ 
		private var _currentPath:String;
		
		/**
		 * 1 dimentionnal data provider containing all loaded info about folder and files
		 */
		private var _dataProvider:Array = new Array();
		
		/**
		 * a temp array to stock dataProvider to be sent to the LibraryList
		 */
		private var _tempDataProvider:Array = new Array();
		
		/**
		 * Count the calls that remains to the webservice
		 */ 
		private var _serviceCallCpt:int;
		
		/**
		 * an array that stores the splitted target path
		 */ 
		private var _targetPathArray:Array;
		
		/**
		 * an array conaining the extensions of the files to display to allow filtering
		 */ 
		private var _libraryFilters:Array;
		
		/**
		 * the url of the gateway, relative to the url of the swf
		 */ 
		private var _gatewayUrl:String;
		
		/**
		 * Determine if the library is currently loading data
		 */ 
		private var _pending:Boolean;
		
		/**
		 * the remoting connection object used to call the gateway
		 */ 
		private var _remotingConnection:RemotingConnection;
		
		/**
		 * the name of the service listing the folders
		 */ 
		public static const DATA_EXCHANGE_SERVICE_PATH:String = "data_exchange.listFolderContent"; 
		
		public function WysiwygLibraryModel()
		{
			_gatewayUrl =  ToolConfig.getInstance().gatewayPath;
			_targetPath = "";
			_remotingConnection = new RemotingConnection(_gatewayUrl);
			_remotingConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		/**
		 * compare the currentPath with the targetPath and may launch service calls if different
		 * 
		 * @param value the string data to be set
		 */ 
		public function set targetPath(value:String):void
		{
			value = cleanUpTargetPath(value);
			
			_targetPath = value;
			
			if (_targetPath != _currentPath)
			{	
				//initialise the service call
				setServiceCall(_targetPath);
			}
		}
		
		/**
		 * refreshes the library data
		 */ 
		public function refreshLibrary():void
		{
			setServiceCall(_targetPath);
		}
		
		public function set libraryFilters(value:Array):void
		{
			_dataProvider = [];
			
			_libraryFilters = value;
			
		}
		
		/**
		 * Set up services calls
		 * 
		 * @param targetPath the path that the library finder must display
		 */ 
		private function setServiceCall(targetPath:String):void
		{
			//if a call is in progress, close the connection
			if (_pending == true)
			{
				_remotingConnection.close();
				_remotingConnection = new RemotingConnection(_gatewayUrl);
			}
			
			_pending = true;
			
			_targetPathArray = new Array();
			_targetPathArray = targetPath.split("/");
			_currentPath = "";
			
			//reset the service call counter
			_serviceCallCpt = 0;
			
			//reset the temp data provider array
			_tempDataProvider = new Array();
			//start the calls to the recursive method getFolderContent()
			getFolderContent();
		}
		
		/**
		 * clean up the targer path string and returns it
		 */ 
		private function cleanUpTargetPath(value:String):String
		{
			//set the default path if the url is null or is absolut, as 
			//we can't browse it
			if (value == null || value.indexOf("http") == 0)
			{
				value = ToolConfig.getInstance().mediaFolderPath;
			}
			
			//remove all the "/" charachter from the end of the string
			//to prevent opening empty panels
			else
			{
				while (value.charAt(value.length-1) == "/")
				{
					value = value.substr(0, value.length-1);
				}
				
				while(value.charAt(0) == "/")
				{
					value = value.substr(1, value.length - 1);
				}
			}
			//if the value is an empty string, set the default library path
			if (value == "null" || value == null || value == "")
			{
				value = ToolConfig.getInstance().mediaFolderPath;
			}
			
			return value;
		}
		
		
		/**
		 * When all service calls have been made, flush the data
		 * in the library finder data provider
		 */ 
		private function setLibraryListDataProvider():void
		{	
			_pending == false;
			
			var objectData:Object = new Object();
			objectData.dataProviderArray = _tempDataProvider;
			objectData.targetPath = _targetPath;
			
			
			dispatchEvent(new PluginEvent(PluginEvent.DATA_CHANGED, objectData));
			
		}
		
		
		/**
		 * an event sent during the web service call
		 * 
		 * @param event the triggered NetStatusEvent
		 */ 
		private function onNetStatus(event:NetStatusEvent):void
		{
			trace (event.toString());
		}
		
		/**
		 * when the folder to add is a file, we must retrieve it's
		 * values from the last remoting call
		 */ 
		private function prepareFileInfo(currentPath:String):void
		{
			
			var fileData:Array = new Array();
			
			var fileName:String = currentPath.substr(currentPath.lastIndexOf("/")+1);
			var previousServiceCall:Array = _tempDataProvider[_tempDataProvider.length - 1];
			for (var i:int = 0; i<previousServiceCall.length; i++)
			{
				if (previousServiceCall[i] != null)
				{
					if (previousServiceCall[i]['item name'] == fileName)
					{
						fileData.push(previousServiceCall[i]);
						break;
					}
				}
				
			}
			
			fileData.path = currentPath;
			fileData['item type'] = "file";
			_tempDataProvider.push(fileData);
			setLibraryListDataProvider();
		}
		
		private function checkIsFile(path:String):Boolean
		{
			var flagIsFile:Boolean = false;
			var fileName:String = path.substr(path.lastIndexOf("/")+1);
			if (_tempDataProvider[_tempDataProvider.length - 1] != null)
			{
				var previousServiceCall:Array = _tempDataProvider[_tempDataProvider.length - 1];
				for (var i:int = 0; i<previousServiceCall.length; i++)
				{
					if (previousServiceCall[i] != null)
					{
						if (previousServiceCall[i]['item name'] == fileName)
						{
							if (previousServiceCall[i]['item type'] == "file")
							{
								flagIsFile = true;
							}
							break;
						}
					}
					
				}
			}
			
			return flagIsFile;
			
		}
		
		/**
		 * the responder to a succesful service call. Stores the data received
		 * then call the getFolderContent method to parse the next folder in the target path
		 * 
		 * @param event the received event object
		 */ 
		private function saveServiceCallResult(event:Object):void
		{
			event.path = _currentPath;
			event['item type'] = "folder";
			//push the data in the global array
			_dataProvider.push(event);
			
			//push the data in the temp array that will
			//be flushed when all service calls are made
			_tempDataProvider.push(event);
			
			getFolderContent();
		}
		
		/**
		 * called when the webservice call fails
		 * 
		 * @param fault the fault data
		 */
		private function getFolderResultCallBackFault(fault:Object):void
		{
			SilexAdminApi.getInstance().messages.addItem({
				text:resourceManager.getString(ToolConfig.getInstance().wysiwygLanguageBundleName, "LIBRARY_REMOTE_CALL_ERROR"),
				status:Messages.STATUS_ERROR,
				time:7000
				
			});
			
		}
		
		/**
		 * check if the folder content is already available may call the webservice to retrieve the missing data<br>
		 * or may dispatch a success event in order to call getFolderContentResultCallback 
		 * 
		 * @param targetPath the path to display
		 */ 
		private function getFolderContent():void
		{
			//if all service call haven't been made
			if (_serviceCallCpt < _targetPathArray.length)
			{
				var dataFlag:Boolean = false;
				
				//concatenate the the targetPathArray value to reconstruct
				//the folder path
				_currentPath += _targetPathArray[_serviceCallCpt];
				if (checkIsFile(_currentPath) == false )
				{
					_currentPath += "/";	
				}
				
				else
				{
					_serviceCallCpt++;
					prepareFileInfo(_currentPath);
					
					return;
				}
				
				
				
				_serviceCallCpt++;
				
				//The library no longer stores the loaded data so that it can be updated
				//when the user add media with the FTP client. Uncomment the following lines
				//to restore this functionnality
				
				//for this target path parse the stored data
				for (var j:int = 0; j< _dataProvider.length; j++)
				{
					//check if the data is already stored by comparing paths
					if (_dataProvider[j].path == _currentPath)
					{
						//if there is a match, use the stored data instead of making a service call
						_tempDataProvider.push(_dataProvider[j]);
						//the methods calls itself until the  number of service call  matches the number of folder that needs to be opened
						getFolderContent();
						dataFlag = true;
						break;
					}
				}
				//if dataFlag is false, the data hasn't been stored
				if (! dataFlag)
				{
					//call the web service
					var gatewayUrl:String = this._gatewayUrl ;
					
					
					var responder:Responder = new Responder(saveServiceCallResult, getFolderResultCallBackFault);
					
					_remotingConnection.call( DATA_EXCHANGE_SERVICE_PATH, responder, _currentPath, false, _libraryFilters);
					
				}
			}
				
				//else if all service call have been made, calls the method
				//that will set the data on the library finder
			else
			{
				setLibraryListDataProvider();
			}
		}
	}
}