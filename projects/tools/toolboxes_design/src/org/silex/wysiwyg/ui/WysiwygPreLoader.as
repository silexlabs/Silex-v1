/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/

package org.silex.wysiwyg.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;
	
	/**
	 * the preloader used by the wysiwyg and view menu
	 */
	public class WysiwygPreLoader extends DownloadProgressBar
	{
		/**
		 * embed an asset from the wysiwyg FLA
		 */
		[Embed(source="../../../../../src/wysiwyg_toolboxes_style.swf", symbol="ProgressIndeterminateSkin")]
		public var loadingGraphic:Class;
		
		/**
		 * the movieclip that will contain the loading bar
		 */
		public var loaderGraphics:MovieClip; 
		
		/**
		 * instantiate the loading bar and adds it to the display list
		 */
		public function WysiwygPreLoader():void
		{
			super();
			loaderGraphics = new loadingGraphic();
			addChild(loaderGraphics);
			loaderGraphics.gotoAndStop(0);
		}
		
		/**
		 * set listeners on the preloader
		 */
		public override function set preloader(preloader:Sprite):void
		{
			preloader.addEventListener(ProgressEvent.PROGRESS, onSWFDownloadProgress);
			preloader.addEventListener(Event.COMPLETE, onSWFDownloadComplete);
			preloader.addEventListener(FlexEvent.INIT_PROGRESS, onFlexInitProgress);
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, onFlexInitComplete);
			
			centerPreloader();
		}	
		
		/**
		 * center the loader loaderGraphics in the window
		 */
		private function centerPreloader():void
		{
			x = (stageWidth / 2) - (this.width / 2);
			y = (stageHeight / 2) - (this.height / 2);
		}
		
		/**
		 * update the loader on progress event
		 * 
		 * @param	event the trigerred Progress event
		 */
		private function onSWFDownloadProgress(event:ProgressEvent):void
		{
			var t:Number = event.bytesTotal;
			var l:Number = event.bytesLoaded;
			var p:Number = Math.round((l/t) * 19);
			var pForAmount:int = Math.floor(p * 5);
			loaderGraphics.gotoAndStop(p);
	
		}
		
		/**
		 * When the loading is complete go to the end of the animation
		 * 
		 * @param	event the trigerred complete event
		 */
		private function onSWFDownloadComplete(event:Event):void
		{
			loaderGraphics.gotoAndStop(100);
		}
		
		/**
		 * When the loading is complete go to the end of the animation
		 * 
		 * @param	event the trigerred complete event
		 */
		private function onFlexInitProgress(event:FlexEvent):void
		{
			//loaderGraphics.gotoAndStop(100);
		}
		
		/**
		 * init the application
		 * 
		 * @param	event the trigerred FlexEvent
		 */
		private function onFlexInitComplete(event:FlexEvent):void
		{
			loaderGraphics.gotoAndStop(100);
			dispatchEvent( new Event(Event.COMPLETE));
		}
	}

}