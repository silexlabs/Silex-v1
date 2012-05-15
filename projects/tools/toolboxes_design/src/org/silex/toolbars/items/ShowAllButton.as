package org.silex.toolbars.items
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.PublicationModel;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.WysiwygModel;
	
	public class ShowAllButton extends Sprite {

		public var button:SimpleButton;
		
		public function ShowAllButton() 
		{
			if (SilexAdminApi.getInstance().publicationModel.getScaleMode() == PublicationModel.SHOW_ALL)
			{
				button = new buttonDown();
			}
			
			else
			{
				button = new buttonUp();
			}
			
			SilexAdminApi.getInstance().publicationModel.addEventListener(PublicationModel.EVENT_SCALE_MODE_CHANGED, checkButtonState);
			
			addChild(button);
			button.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
		}
		
		private function checkButtonState(event:AdminApiEvent):void
		{
			removeChild(button);
			if (SilexAdminApi.getInstance().publicationModel.getScaleMode() == PublicationModel.SHOW_ALL)
			{
				button = new buttonDown();
			}
			
			else
			{
				button = new buttonUp();
			}
			
			addChild(button);
			button.addEventListener(MouseEvent.MOUSE_DOWN, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
				SilexAdminApi.getInstance().publicationModel.setScaleMode(PublicationModel.SHOW_ALL);

		}
	}
	
}
