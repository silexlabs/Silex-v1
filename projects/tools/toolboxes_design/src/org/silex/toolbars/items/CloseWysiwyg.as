package org.silex.toolbars.items
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.WysiwygModel;
	
	public class CloseWysiwyg extends Sprite {

		public var button1:SimpleButton;
		
		public function CloseWysiwyg() 
		{
			button1.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			var wysiwygModel:WysiwygModel = SilexAdminApi.getInstance().wysiwygModel;
			wysiwygModel.setToolBoxVisibility(false);
		}
	}
	
}
