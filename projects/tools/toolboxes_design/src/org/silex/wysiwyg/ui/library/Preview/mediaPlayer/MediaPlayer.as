/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/


package org.silex.wysiwyg.ui.library.Preview.mediaPlayer
{
	import flash.errors.IllegalOperationError;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.core.UIComponent;

	/**
	 * An abstract class overriden for each type of media that will be played
	 */
	public class MediaPlayer extends Canvas
	{
		/**
		 * a reference to the object that will play the media
		 */
		protected var _player:UIComponent;
		
		public function MediaPlayer() 
		{
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.setStyle("horizontalAlign", "center");
			this.setStyle("verticalAlign", "middle");
		}
		
		/**
		 * Instantiate the requested player and play the media
		 * 
		 * @param	mediaURL the url of the media that must be played
		 */
		public function playMedia(mediaURL:String):void
		{
			throw new IllegalOperationError("classe abstraite ne doit pas être instanciée");
		}
		
		/**
		 * stop the player
		 */
		public function stopMedia():void
		{
			//throw new IllegalOperationError("classe abstraite");
		}
		
		/**
		 * set the player size in th containing VBox
		 */
		protected function setPlayerSize():void
		{
			_player.percentHeight = 100;
			_player.percentWidth = 100;
		}
		
	}
	
}