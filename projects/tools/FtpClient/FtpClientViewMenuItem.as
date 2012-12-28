package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	
	public class FtpClientViewMenuItem extends Sprite {

		public var button1:SimpleButton;
		
		public function FtpClientViewMenuItem() 
		{
			button1.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			ExternalInterface.call("openFtp");
		}
	}
	
}
