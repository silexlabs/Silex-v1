package org.silex.wysiwyg.toolboxApi.event
{
	import flash.events.Event;
	
	/**
	 * This class dispatch ToolBoxAPI related event.
	 */ 
	public class ToolBoxAPIEvent extends Event
	{
		/**
		 * an object storing data related to the dispatched event
		 */ 
		public var data:Object;
		
		
		/**
		 * an event dispatched when the editor of the wysiwyg changes.
		 */ 
		public static const LOAD_EDITOR:String = "loadEditor";
		
		/**
		 * an event dispatched when the library must be loaded to add media to the scene
		 */ 
		public static const LOAD_LIBRARY:String = "loadLibrary";
		
		/**
		 * an event dispatched when the user wants to add a skinnable component (like a RichTextList)
		 */ 
		public static const LOAD_SKINNABLE_COMPONENT:String = "loadSkinnableComponent";
		
		/**
		 * an event dispateched when the user wants to add a simple component (like an XMLConnector)
		 */ 
		public static const LOAD_COMPONENT:String = "loadComponent";
		
		/**
		 * an event dispateched when the user wants to add a legacy component (old editable properties component
		 * without a descriptor)
		 */ 
		public static const LOAD_LEGACY_COMPONENT:String = "loadLegacyComponent";
		
		/**
		 * dispatched when the name of a component is edited and needs to be refreshed in the components toolbox
		 */ 
		public static const REFRESH_COMPONENT_NAME:String = "refreshComponentName";
		
		public function ToolBoxAPIEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}