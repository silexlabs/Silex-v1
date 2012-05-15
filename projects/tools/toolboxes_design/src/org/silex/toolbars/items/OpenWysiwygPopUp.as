package org.silex.toolbars.items
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.WysiwygModel;
	
	public class OpenWysiwygPopUp extends Sprite {

		public var button:SimpleButton;
		
		public function OpenWysiwygPopUp() 
		{
			if (SilexAdminApi.getInstance().wysiwygModel.getToolBoxDisplayMode() == WysiwygModel.TOOLBOX_DISPLAY_MODE_POPUP)
			{
				button = new buttonDown();
			}
			
			else
			{
				button = new buttonUp();
			}
			
			SilexAdminApi.getInstance().wysiwygModel.addEventListener(WysiwygModel.EVENT_TOOL_BOX_DISPLAY_MODE_CHANGED, checkButtonState);
			SilexAdminApi.getInstance().wysiwygModel.addEventListener(WysiwygModel.EVENT_TOOL_BOX_VISIBILITY_CHANGED, checkButtonState);
			
			addChild(button);
			button.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
		}
		
		private function checkButtonState(event:AdminApiEvent):void
		{
			removeChild(button);
			if (SilexAdminApi.getInstance().wysiwygModel.getToolBoxDisplayMode() == WysiwygModel.TOOLBOX_DISPLAY_MODE_POPUP
			&& SilexAdminApi.getInstance().wysiwygModel.getToolBoxVisibility() == true)
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
				SilexAdminApi.getInstance().wysiwygModel.setToolBoxDisplayMode(WysiwygModel.TOOLBOX_DISPLAY_MODE_POPUP);
				SilexAdminApi.getInstance().wysiwygModel.setToolBoxVisibility(true);

		}
	}
	
}
