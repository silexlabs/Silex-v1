/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.core.component;

/**
 * before everything was components, there were "players" which were either components or a "player" for a media type, such as image player
 * @author Ariel Sommeria-klein sommeria.ariel (at) gmail.com
 */

class LegacyPlayerTypes 
{

	public static inline var AUDIO:String = "Audio";
	public static inline var VIDEO:String = "Video";
	public static inline var IMAGE:String = "Image";
	public static inline var TEXT:String = "Text";
	public static inline var ASFRAME:String = "AsFrame";
	public static inline var COMPONENT:String = "Component";
	
	public static var playerType2ComponentClass:Hash<String> = initPlayerType2ComponentClass();
	public function new() 
	{
		
	}
	
	public static function initPlayerType2ComponentClass():Hash<String>
	{
		var ret:Hash<String> = new Hash<String>();
		ret.set(AUDIO, "org.silex.ui.players.Audio");
		ret.set(VIDEO, "org.silex.ui.players.Video");
		ret.set(IMAGE, "org.silex.ui.players.Image");
		ret.set(TEXT, "org.silex.ui.players.Text");
		ret.set(ASFRAME, "org.silex.ui.players.AsFramePlayer");
		return ret;
	}
	
}