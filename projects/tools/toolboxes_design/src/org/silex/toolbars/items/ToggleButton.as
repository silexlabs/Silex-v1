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
	public class ToggleButton extends Sprite
	{
		public var button:SimpleButton;
		
		public function ToggleButton() 
		{
			button = new buttonUp();
			addChild(button);
			button.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			if (button is buttonUp)
			{
				button.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				removeChild(button);
				button = new buttonDown();
				button.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				addChild(button);
			}
			else
			{
				button.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				removeChild(button);
				button = new buttonUp();
				button.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				addChild(button);
			}
		}
	}
}