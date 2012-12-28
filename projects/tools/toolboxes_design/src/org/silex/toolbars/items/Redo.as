package org.silex.toolbars.items
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.HistoryManager;
	
	public class Redo extends Sprite {
		
		public var button:SimpleButton;
		
		public function Redo() 
		{
			button1.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			SilexAdminApi.getInstance().historyManager.redo();
		}
	}
	
}
