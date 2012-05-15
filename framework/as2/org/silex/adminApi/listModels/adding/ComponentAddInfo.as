/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.util.T;
/**
 * pass this to add item on Components
 * */
class org.silex.adminApi.listModels.adding.ComponentAddInfo
{
	public static var TYPE_AUDIO:String = "Audio";
	public static var TYPE_VIDEO:String = "Video";
	public static var TYPE_IMAGE:String = "Image";
	public static var TYPE_TEXT:String = "Text";
	public static var TYPE_FRAMED_LOCATION:String = "FramedLocation";
	public static var TYPE_FRAMED_EMBEDDED_OBJECT:String = "FramedEmbeddedObject";
	public static var TYPE_FRAMED_HTML_TEXT:String = "FramedHtmlText";
	public static var TYPE_COMPONENT:String = "Component";
	
	/**
	 * the name of the player, that will appear in the component list and that will be used for reference in actions
	 * */
	public var playerName:String;
	
	/**
	 * the className of the added component, used to retrieve it's descriptor
	 */
	public var className:String;
	
	/**
	 * type of component. see consts above
	 * */
	public var type:String;
	
	/**
	 * meta data. For audio, video, image the url. For framed info the html
	 * 
	 * */
	public var metaData:String;
	
	/**
	 * an object overriding a component's properties default values
	 */
	public var initObj:Object;
	
	
	
	/**
	 * addItem receives an untyped object. Check it and build a typed ComponentAddInfo with this method
	 * note: the metaData field is optional
	 * */
	public static function createFromUntyped(obj:Object):ComponentAddInfo{
		var ret:ComponentAddInfo = new ComponentAddInfo();
		if(!obj.playerName){
			//T.y("buildComponentAddInfo fail, no playerName in ",obj);
			return null;
		}
		
		ret.playerName = obj.playerName;
		
		if(!obj.type){ 
			//T.y("buildComponentAddInfo fail, no type",obj);
			return null;
		}
		//check type is known
		switch(obj.type){
			case ComponentAddInfo.TYPE_AUDIO:
			case ComponentAddInfo.TYPE_VIDEO:
			case ComponentAddInfo.TYPE_IMAGE:
			case ComponentAddInfo.TYPE_TEXT:
			case ComponentAddInfo.TYPE_COMPONENT:
			case ComponentAddInfo.TYPE_FRAMED_LOCATION:
			case ComponentAddInfo.TYPE_FRAMED_EMBEDDED_OBJECT:
			case ComponentAddInfo.TYPE_FRAMED_HTML_TEXT:
			break;
			default:
				//T.y("buildComponentAddInfo fail, unknown type: ", obj.type, " in : " ,obj);
				return null;
				
		}		
		ret.type = obj.type;
		
		ret.metaData = obj.metaData;
		
		ret.initObj = obj.initObj;
		
		ret.className = obj.className;
		
		return ret;
		
		
	}
		
}
