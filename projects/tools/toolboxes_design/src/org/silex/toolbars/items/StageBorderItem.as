package org.silex.toolbars.items
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	/**
	 * ...
	 * @author Raphael Harmel
	 */
	public class StageBorderItem extends ToggleButton
	{
		public function StageBorderItem() 
		{
			super();
		}
		
		override protected function mouseUpHandler(event:MouseEvent):void
		{
			ExternalInterface.call("toggleStageBorderVisibility");
			super.mouseUpHandler(event);
		}
		
	}

}