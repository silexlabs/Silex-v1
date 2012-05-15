package org.silex.wysiwyg.plugins.WysiwygPluginGroups 
{
	import flash.events.Event;
	
	/**
	 * This class extends Event to add a data array
	 * @author Raph
	 */
	public class FilesEvent extends Event 
	{
		public static const FILE_LOADED_FROM_SERVER:String = "File loaded correctly";
		public static const FILE_SENT_TO_SERVER:String = "File sent to server";
		
		public var data:Object = new Object();

		public function FilesEvent(type:String, data:Object, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}	
	}
}