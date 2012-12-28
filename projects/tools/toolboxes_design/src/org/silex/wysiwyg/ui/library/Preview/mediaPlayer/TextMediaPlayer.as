/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/


package org.silex.wysiwyg.ui.library.Preview.mediaPlayer
{
	import mx.controls.TextArea;
	
	/**
	 * the player used to display text
	 */
	public class TextMediaPlayer extends MediaPlayer
	{
		
		public function TextMediaPlayer() 
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function playMedia(textContent:String):void
		{
			_player = new TextArea();
			(_player as TextArea).text = textContent;
			setPlayerSize();
			addChild(_player);
		}
		
	}
	
}