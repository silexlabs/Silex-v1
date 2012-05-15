/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import flash.display.MovieClip;

import mx.events.EventDispatcher;

import org.silex.adminApi.SilexAdminApi;

/**
 * the model for the wysiwyg. This is split between JS and AS2
 * Contains the AS2 part of the state for the wysiwyg, such as the scene border
 * */
class  org.silex.adminApi.WysiwygModel{
	private var _sceneBorderVisible:Boolean;
	
	private var _sceneBorder_mc:MovieClip;
	
	public function getSceneBorderVisible():Boolean{
		return _sceneBorderVisible;
	}
	
	public function setSceneBorderVisible(value:Boolean):void{
		if(_sceneBorderVisible != value){
			if(value){
				attachMovie("sceneBorder","sceneBorder_mc",getNextHighestDepth());
			}
		}
	}
	
}