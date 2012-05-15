package org.silex.toolbars.items
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import org.silex.adminApi.SilexAdminApi;
	//import org.silex.adminApi.Shortcut;
	import org.silex.adminApi.listedObjects.Layout;
	
	public class Save extends Sprite {
		
		public var button:SimpleButton;

		/**
		 * A reference to the Silex Admin Api singleton
		 */ 
		protected var _silexAdminApi:SilexAdminApi;
		
		public function Save()
		{
			_silexAdminApi = SilexAdminApi.getInstance();
			button1.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			saveAllLayoutCallback();
		}	
			
		/**
		 *  calls the save layout method on SilexAdminAPI on all the layouts.
		 */ 
		private function saveAllLayoutCallback():void
		{
			var layouts:Vector.<Layout> = Vector.<Layout>(_silexAdminApi.layouts.getData()[0]);
			
			var layoutsLength:int = layouts.length;
			for (var i:int; i<layoutsLength; i++)
			{
				layouts[i].save();
			}
		}
	}
}
