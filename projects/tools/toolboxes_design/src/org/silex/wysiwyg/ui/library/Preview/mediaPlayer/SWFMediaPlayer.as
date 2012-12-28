/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/


package org.silex.wysiwyg.ui.library.Preview.mediaPlayer
{
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.controls.SWFLoader;
	import mx.core.UIComponent;
	
	/**
	 * the player used to display SWF media
	 */
	public class SWFMediaPlayer extends MediaPlayer
	{
		public static const AVM1_MOVIE:String = "avm1Movie";
		
		public static const AVM2_MOVIE:String = "avm2Movie";
		
		public function SWFMediaPlayer() 
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function playMedia(mediaURL:String):void
		{
			_player = new SWFLoader();
			
			_player.addEventListener(Event.COMPLETE, onLoadComplete);
			(_player as SWFLoader).smoothBitmapContent = true;
			(_player as SWFLoader).percentHeight = 100;
			(_player as SWFLoader).percentWidth = 100;
			(_player as SWFLoader).setStyle("horizontalAlign", "center");
			(_player as SWFLoader).setStyle("verticalAlign", "middle");
			(_player as SWFLoader).source = mediaURL;
			setPlayerSize();
			addChild(_player);
		}
		

		
		/**
		 * When loading is complete, resize the image if it is bigger than the container
		 * @param	event the trigerred event
		 */
		private function onLoadComplete(event:Event):void
		{
			if ((event.target as SWFLoader).contentHeight > (event.target as SWFLoader).height 
				|| (event.target as SWFLoader).contentWidth > (event.target as SWFLoader).width)
			{
				(event.target as SWFLoader).scaleContent = true;
			}
			
			var loadedContent:DisplayObject = (event.target as SWFLoader).content;
			
			if (loadedContent is AVM1Movie)
			{
				dispatchEvent(new Event(AVM1_MOVIE));
			}
			
			else
			{
				dispatchEvent(new Event(AVM2_MOVIE));
			}
			
			var loaderMask:UIComponent = new UIComponent();
			loaderMask.graphics.beginFill(0xFF0000, 1);
			loaderMask.graphics.drawRect(0,0, (event.target as SWFLoader).width, (event.target as SWFLoader).height);
			loaderMask.graphics.endFill();
			
			addChild(loaderMask);
			(event.target as SWFLoader).mask = loaderMask;
		}
	}
	
}