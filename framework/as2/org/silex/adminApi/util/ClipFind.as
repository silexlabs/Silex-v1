/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.util.T;
/**
 * helper class to find clips
 * */
class org.silex.adminApi.util.ClipFind
{
	
	/**
	 * gets a movieclip from a path. The path must be absolute(starting at _root)
	 * */
	public static function findClip(pathArray:Array):MovieClip{
		////T.y("ClipFind.findClip : ", pathArray);
		var ret:MovieClip = _root;
		var len:Number = pathArray.length;
		//note: skip first, because path is like "/layoutContainer/layoutContainer/layout0"
		for(var i: Number = 1; i < len; i++){
			var nextStepDownClipName:String = pathArray[i];
			////T.y("nextStepDownClipName : ", nextStepDownClipName);
			var nextDown:MovieClip = ret[nextStepDownClipName];
			if(nextDown){
				ret = nextDown;
			}else{
				//T.y("couldn't find ", nextStepDownClipName, " on ", ret);
				return null;
			}
		}
		////T.y("found ", ret);
		return ret;
	} 
	
		
}
