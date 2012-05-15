package org.silex.toolbars.items
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public class OpenHelp extends Sprite {

		public var button1:SimpleButton;
		
		public function OpenHelp() 
		{
			button1.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			navigateToURL(new URLRequest("http://community.silexlabs.org/silex/help/"));
			//ExternalInterface.call('openHelp');
		}
	}	
}
