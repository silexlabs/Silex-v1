/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.adminApi.util.T;
import org.silex.core.Utils;

/**
 * This class listens for Keyboard event and dispatch them for the whole API if they are shortcut 
 */
class org.silex.adminApi.Shortcut
{
	/**
	 * the name of the target called on SilexAdminApi
	 */
	private static var TARGET_NAME:String = "shortcut";
	
	/**
	* the language from which the event has been dispatched
	*/ 
	private static var DISPATCH_FROM:String = "AS2";
	
	/**
	 * set the key listener
	 */
	public function Shortcut() 
	{	
		var keyListener:Object = new Object();
		keyListener.onKeyDown = Utils.createDelegate(this, onKeyDown);
		Key.addListener(keyListener);
	}
	
	/**
	 * listens for key event and call the method dispatching a shortcut event
	 * if at least one shortcut key is pressed
	 */
	private function onKeyDown():Void
	{
		if (Key.isDown(Key.CONTROL) || Key.isDown(Key.ALT) || Key.isDown(Key.DELETEKEY) || Key.isDown(Key.ESCAPE) || Key.isDown(Key.TAB)
		|| Key.isDown(Key.ENTER))
			{
				//T.y("Keyboard is a shortcut");
				this.dispatch( { keyCode:Key.getCode(), 
				asciiCode:Key.getAscii(), 
				useControl:Key.isDown(Key.CONTROL), 
				useAlt:Key.isDown(Key.ALT), 
				useShift:Key.isDown(Key.SHIFT),
				dispatchFrom:DISPATCH_FROM
				}); 
			}
		else	
		{
			//T.y("Keyboard event is not a shortcut");
		}
	}
	
	/**
	 * dispatch a shortcut event for the whole API (AS2, AS3 andd JS)
	 * 
	 * @param	shortcut the shortcut data to dispatch
	 */
	private function dispatch(shortcut:Object):Void
	{
		/*T.y("Keyboard shortcut detected. keyCode: " + shortcut.keyCode +
		" , asciiCode : " + shortcut.asciiCode +
		" , use control : " + shortcut.useControl +
		" , use Alt : " + shortcut.useAlt +
		" , use Shift : " + shortcut.useShift);*/
		
		var eventToDispatch:AdminApiEvent = new AdminApiEvent(AdminApiEvent.SHORTCUT_EVENT, TARGET_NAME, shortcut); 
		
		ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
	}
	
	/**
	 * listens for a SHORCUT_EVENT on the SilexAdminApi
	 * 
	 * @param	event
	 */
	private function onShortcutCallback(event:AdminApiEvent):Void
	{
		/*T.y("Keyboard shortcut recieved. keyCode: " + event.data.keyCode +
		" , asciiCode : " + event.data.asciiCode +
		" , use control : " + event.data.useControl +
		" , use Alt : " + event.data.useAlt +
		" , use Shift : " + event.data.useShift);*/
	}
	
}