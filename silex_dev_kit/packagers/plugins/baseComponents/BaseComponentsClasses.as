/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * This class is used to build the library that includes all the baseComponents classes in a single SWF that can be preloaded.
 * imports are not enough, so actual references to the classes are needed.
 * */
class BaseComponentsClasses{
	//var asFramePlayer:org.silex.ui.players.AsFramePlayer;
	var asFrameBase:org.silex.ui.asframe.AsFrameBase;
	var asFrameCommunication:org.silex.ui.asframe.AsFrameCommunication;
	var audio:org.silex.ui.players.Audio;
	var image:org.silex.ui.players.Image;
	var playerBase:org.silex.ui.players.PlayerBase;
	var text:org.silex.ui.players.Text;
	var video:org.silex.ui.players.Video;
	
}