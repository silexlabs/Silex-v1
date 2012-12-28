/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/


package org.silex.wysiwyg.ui.library.Preview.mediaPlayer
{
	import flash.events.Event;
	
	import mx.controls.Image;
	
	/**
	 * a player displaying bitmap images
	 */
	public class ImageMediaPlayer extends MediaPlayer
	{
		
		public function ImageMediaPlayer() 
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function playMedia(mediaURL:String):void
		{
			_player = new Image();
			
			_player.addEventListener(Event.COMPLETE, onLoadComplete);
			(_player as Image).scaleContent = false;
			(_player as Image).smoothBitmapContent = true;
			(_player as Image).percentHeight = 100;
			(_player as Image).percentWidth = 100;
			(_player as Image).setStyle("horizontalAlign", "center");
			(_player as Image).setStyle("verticalAlign", "middle");
			(_player as Image).source = mediaURL;
			setPlayerSize();
			addChild(_player);
		}
		
		/**
		 * When loading is complete, resize the image if it is bigger than the container
		 * @param	event the trigerred event
		 */
		private function onLoadComplete(event:Event):void
		{
			if ((event.target as Image).contentHeight > (event.target as Image).height 
				|| (event.target as Image).contentWidth > (event.target as Image).width)
			{
				(event.target as Image).scaleContent = true;
			}
		}
		
		
	}
	
}