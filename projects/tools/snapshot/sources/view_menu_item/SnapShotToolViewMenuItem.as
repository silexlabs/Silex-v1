package
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class SnapShotToolViewMenuItem extends MovieClip
	{
		public var Btn:SimpleButton;
		
		public function SnapShotToolViewMenuItem()
		{
			Btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(event:MouseEvent):void
		{
			ExternalInterface.call('takeSnapshot');
		}
		
	}
	
}