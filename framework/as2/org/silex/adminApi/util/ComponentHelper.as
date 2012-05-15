/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.ui.UiBase;
import org.silex.adminApi.util.T;
import org.silex.adminApi.util.ClipFind;

/**
 * helper methods to access and manipulate components (not component load infos!)
 */

class org.silex.adminApi.util.ComponentHelper{
	
	/**
	 * find the component matching this uid
	 * */
	public static function getComponent(uid:String):UiBase{
		var split:Array = uid.split("/");
		var component:UiBase = UiBase(ClipFind.findClip(split));
		//T.y("getComponent : ", component);
		return component;
	}
	
	
	
	/**
	 * get a uid for a component
	 * note. Here we don't use _target on the component, because for some reason it doesn't return a complete path, but just "/main".
	 * so do String(component) to get it in dot notation, then convert it. hackish, but works
	 * 
	 * */
	public static function getComponentUid(component:UiBase):String{
		var dotNotation:String = String(component);
		var slashNotation:String = dotNotation.split(".").join("/");
		////T.y("component ", component, ", dotNotation : ", dotNotation, ", slashNotation : ", slashNotation);
		//T.y("getComponentUid : ", slashNotation); 
		return slashNotation;		
	}	


}