package org.silex.wysiwyg.toolboxes.addComponents.componentsButtons
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * This is a custom toggle button class compiled by a an external FLA
	 */ 
	public class MaskedSimpleButton extends MovieClip
	{
		/**
		 * the masked clip in which to load the button icon
		 */ 
		public var maskedClip:MovieClip;
		
		/**
		 * determin if the button toggle state is on
		 */ 
		private var _toggle:Boolean;
		
		/**
		 * retrieve the masked clip movieClip from the FLA graphical asset
		 * then set listeners on the mouse
		 */ 
		public function MaskedSimpleButton()
		{
			super();
			this.stop();
			this.maskedClip = this.getChildByName("maskedClip") as MovieClip;
			
			this.addEventListener(MouseEvent.ROLL_OVER, onMouseEvent);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
		}
		
		/**
		 * Set the right state for the button based on the mouse interaction
		 * In the FLA, each frame is a different button state
		 */ 
		private function onMouseEvent(event:MouseEvent):void
		{
			if (_toggle == true)
			{
				this.gotoAndStop(3);
			}
			
			else
			{
				switch(event.type)
				{
					case MouseEvent.MOUSE_UP:
					case MouseEvent.ROLL_OVER:
						this.gotoAndStop(2);
					break;
					
					case MouseEvent.ROLL_OUT:
						this.gotoAndStop(1);
					break;
					
					case MouseEvent.MOUSE_DOWN:
						this.gotoAndStop(3);
					break;
					
					default:
						this.gotoAndStop(1);
					break;	
				}
			}
		}
		
		
		/**
		 * activate/desactivate the toggle state of the button
		 * 
		 * @param value the value of the toggle
		 */ 
		public function set toggle(value:Boolean):void
		{
			_toggle = value;
			if (_toggle == true)
			{
				this.gotoAndStop(3);
			}
			
			else
			{
				this.gotoAndStop(1);
			}
		}
	}
}