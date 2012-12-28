/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.core.Api;
import org.silex.adminApi.util.T;
import org.silex.link.HaxeLink;
/**
 * model for the publication. accessed through silex admin api
 * */
class org.silex.adminApi.PublicationModel
{
	
	static private var _silexPtr:Api = null;	

	public static var SHOW_ALL:String = "showAll";
	
	public static var NO_SCALE:String = "noScale";
	
	public static var SCROLL:String = "scroll";
	
	public static var PIXEL:String = "pixel";
	
	public static var EVENT_SCALE_MODE_CHANGED:String = "eventScaleModeChanged";
	
	private static var TARGET_NAME:String = "publicationModel";
	
	/**
	 * this function is used intensively, so store a static pointer to it for performance
	 * */
	private static var base64EncodeFunction:Function = HaxeLink.getHxContext().haxe.BaseCode.encode;
	
	public function PublicationModel()
	{
		_silexPtr = _global.getSilex(this);
		
		
	}
	
	public function revealAccessors(target:String):String
	{
		return _silexPtr.utils.revealAccessors(target);
	}
	
	public function getEmbeddedFonts():Array{
		return _silexPtr.config.embeddedFont;
	}
	
	public function setScaleMode(scaleMode:String):Void
	{
		_silexPtr.config.scaleMode = scaleMode;
		_silexPtr.application.resetSilexWindowSize();
		_silexPtr.application.stageResize();
		
		var eventToDispatch:AdminApiEvent = new AdminApiEvent(EVENT_SCALE_MODE_CHANGED, TARGET_NAME, null); 
		
		ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
	}
	
	public function getScaleMode():String
	{
		return _silexPtr.config.scaleMode;
	}
	
	/**
	 * return all the config of Silex
	 * @return
	 */
	public function getConf():Object
	{
		var res:Object = new Object();
		
		for (var key:String in _silexPtr.config)
		{
			if (typeof(_silexPtr.config[key] ) == "string")
			{
				var newKey:String = base64EncodeFunction(key, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
				res[newKey] = _silexPtr.config[key];
			}
			
		}
		
		return res;
	}
}
