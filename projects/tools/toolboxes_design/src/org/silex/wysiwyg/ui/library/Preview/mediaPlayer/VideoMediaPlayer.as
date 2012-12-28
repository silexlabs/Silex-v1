/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/

package org.silex.wysiwyg.ui.library.Preview.mediaPlayer
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.mx_internal;
	
	import org.silex.wysiwyg.ui.library.Preview.mediaPlayer.preview_video_player.PreviewVideoPlayer;
	
	
	
	/**
	 * the player used to display video
	 */
	public class VideoMediaPlayer extends MediaPlayer
	{
		
		public function VideoMediaPlayer() 
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function playMedia(mediaURL:String):void
		{
			 
			_player = new PreviewVideoPlayer();
			(_player as PreviewVideoPlayer).source = mediaURL;

			setPlayerSize();
			addChild(_player);

		}
		
		/**
		 * @inheritDoc
		 */
		override public function stopMedia():void
		{
		//	(_player as VideoPlayer).stop();
		//	(_player as VideoPlayer).mx_internal::videoPlayer.clear();
		}
		
	}
	
}