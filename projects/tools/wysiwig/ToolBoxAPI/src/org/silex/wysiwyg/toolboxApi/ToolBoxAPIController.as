package org.silex.wysiwyg.toolboxApi
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.toolboxApi.event.ToolBoxAPIEvent;
	
	/**
	 * this class exposes an API allowing a plugin to interact with the wysiwyg core.
	 */ 
	public class ToolBoxAPIController extends EventDispatcher
	{
		
		private static var _toolBoxApiController:ToolBoxAPIController;
		
		/**
		 * the url where the property editors are stored
		 */ 
		private var _propertyEditorsUrl:String;
		
		/**
		 * stores the data of the default editor
		 */ 
		private var _defaultEditor:Object;
		
		/**
		 * stores the uid of the selected add buttons
		 */ 
		private var _selectedAddButtonUid:String;
		
		/**
		 * an object storing the library params (component url, property to initialise
		 * and filters )
		 */ 
		private var _libraryParams:Object;
		
		/**
		 * stores all the skins data
		 */ 
		private var _skinsParams:Object;
		
		
		public function ToolBoxAPIController(target:IEventDispatcher=null)
		{
			super(target);
			_defaultEditor = new Object();
			
		}
		
		public static function getInstance():ToolBoxAPIController
		{
			if (_toolBoxApiController == null)
			{
				_toolBoxApiController = new ToolBoxAPIController();
			}
			return _toolBoxApiController;
		}
		
		
		/**
		 * dispatch a ToolBoxAPIEvent prompting the wysiwyg core to display a new editor
		 * 
		 * @param editorUrl the Url of the new editor swf to load
		 * @param description a description for the new editor
		 */ 
		public function loadEditor(editorUrl:String, description:String):void
		{
			var eventData:Object = new Object();
			eventData.editorUrl = editorUrl;
			eventData.description = description;
			
			dispatchEvent(new ToolBoxAPIEvent(ToolBoxAPIEvent.LOAD_EDITOR, eventData, true));
		}
		
		/**
		 * stores a default editor to be used when none other are specified
		 * 
		 * @param editorUrl the Url of the new plugin swf to store
		 * @param description a description for the new editor
		 */ 
		public function setAsDefault(editorUrl:String, description:String):void
		{
			_defaultEditor.editorUrl = editorUrl;
			_defaultEditor.description = description;
		}
		
		/**
		 * dispatch an event prompting the Wysiwyg to open the library to add media
		 * 
		 * @param data an object containing all the data to initialisie the library, among those :
		 * componentUrl : the url of the component to add
		 * initPtoperyName : the name of the property to initialise with the url of the selected media
		 * ex : for an Image component, the property to initialise is "url"
		 * filters : an array of string reprensenting the extension of the file to display
		 * in the library (.jpg, .png, .swf ...)
		 * 
		 */ 
		public function loadLibrary(data:Object):void
		{
			//we empty the selected button uid, as buttons opening the library are not toggle buttons
			_selectedAddButtonUid = "";
			
			_libraryParams = data;
			dispatchEvent(new ToolBoxAPIEvent(ToolBoxAPIEvent.LOAD_LIBRARY, _libraryParams, true));
		}
		
		/**
		 * dispatches an event prompting the wysiwyg tot open the skinnable component panel
		 * 
		 * @param data contains all the data to add a skinned component, among those : 
		 * skins : an array containing all of the available skins info (label, description, url and previewUrl). Each element
		 * represents a skin
		 */ 
		public function loadSkinnableComponent(data:Object):void
		{
			//we select the clicked button to toggle it's pressed state
			_selectedAddButtonUid = data.uid;
			_skinsParams = data;
			dispatchEvent(new ToolBoxAPIEvent(ToolBoxAPIEvent.LOAD_SKINNABLE_COMPONENT, data, true));
		}
		
		/**
		 * adds a new component then dispatch an event intercepted by the wysiwyg and the wysiwyg add component buttons
		 * used to regulate the toolbox stattes and the toggle state of the add buttons
		 * 
		 * @param data the data sent to add the components 
		 */ 
		public function loadComponent(data:Object):void
		{
			var initObj:Object = new Object();
			
			//we empty the selected button selection, as button simply loading component
			//are not toggle button
			_selectedAddButtonUid = "";
			SilexAdminApi.getInstance().components.addItem({metaData:data.componentUrl, 
				playerName:data.name, type:ComponentAddInfo.TYPE_COMPONENT, className:data.className,
			initObj:initObj});
			
			dispatchEvent(new ToolBoxAPIEvent(ToolBoxAPIEvent.LOAD_COMPONENT, null, true));
		}
		
		/**
		 * dispatches an event prompting the wysiwyg to display the library to let the user
		 * add a legacy component
		 * 
		 * @param data the params of the legacy component
		 */ 
		public function loadLegacyComponent(data:Object):void
		{
			dispatchEvent(new ToolBoxAPIEvent(ToolBoxAPIEvent.LOAD_LEGACY_COMPONENT, null, true));
		}
		
		/**
		 * refreshes the name of the targeted component in the component toolbox when the user
		 * edits the name of the component by dispatching an event for the wysiwyg
		 * 
		 * @param componentUid the uid of the component to update
		 * @param updatedName the new name of the component
		 */ 
		public function refreshComponentDisplayedName(componentUid:String, updatedName:String):void
		{
			dispatchEvent(new ToolBoxAPIEvent(ToolBoxAPIEvent.REFRESH_COMPONENT_NAME, {uid:componentUid, newName:updatedName}));
		}
		
		/**
		 * returns the parameters of the library
		 */ 
		public function get libraryParams():Object
		{
			return _libraryParams;
		}
		
		/**
		 * returns the parameters of the skins
		 */ 
		public function get skinsParams():Object
		{
			return _skinsParams;
		}
		
		/**
		 * returns the default editor
		 */ 
		public function getDefaultEditor():Object
		{
			return _defaultEditor;
		}
		
		/**
		 * returns the uid of the selected add button or an empty
		 * string if no button is selected
		 */ 
		public function get selectedAddButtonUid():String
		{
			return _selectedAddButtonUid;
		}
		
		
	}
}