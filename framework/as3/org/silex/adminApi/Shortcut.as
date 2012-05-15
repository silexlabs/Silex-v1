/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	

	/**
	 * This class stores a reference to all the suscribed callbacks in AS3 and to the 
	 * shortcuts that triggers them. When a shortcut input is detected, 
	 * it browses the array searching for a match. If there is a match, it calls the callback. 
	 */ 
	public class Shortcut extends EventDispatcher
	{
		/**
		 * the ascii code of the escape key
		 */ 
		public static const ESCAPE_KEY:int = 27;
		
		/**
		 * the ascii code for the delete key
		 */ 
		public static const DELETE_KEY:int = 127;
		
		/**
		 * the ascii code for the enter key
		 */ 
		public static const ENTER_KEY:int = 13;
		
		/**
		 * the name of the target called on SilexAdminApi
		 */
		private static const TARGET_NAME:String = "shortcut";
		
		/**
		 * the language from which the event has been dispatched
		 */ 
		private static const DISPATCH_FROM:String = "AS3";
		
		/**
		 * this array stores the subscribed callback to shortcut input.
		 */ 
		private var _subscribers:Array;
		
		/**
		 * instantiate the subscriber array and listens for SHORCUT_EVENT
		 * on the API
		 */ 
		public function Shortcut()
		{
			_subscribers = new Array();
			this.addEventListener(AdminApiEvent.SHORTCUT_EVENT, onShortcutCallback);
		}
		
		/**
		 * browse through the _shortcutSubscriber array looking for a match to the shortcut object. Calls the callback if there is a match.
		 * 
		 * @param event the trigerred AdminApiEvent
		 */  
		private function onShortcutCallback(event:AdminApiEvent):void
		{
			for (var i:int = 0; i<_subscribers.length; i++)
			{
				//trace("loop in the callback array");
				//trace("keyCode : "+event.data.keyCode +" / "+_subscribers[i].keyCode );
				//trace("asciiCode : "+event.data.asciiCode +" / "+_subscribers[i].asciiCode );
				//trace("useControl : "+event.data.useControl +" / "+_subscribers[i].useControl );
				//trace("keyCode : "+event.data.keyCode +" / "+_subscribers[i].keyCode );
				
				//the object coming from the API need to be cast as int and Boolean
				//or else the test always fail
				if (int(event.data.asciiCode) == _subscribers[i].asciiCode ||
					int(event.data.keyCode) == _subscribers[i].keyCode)
				{
					if (String(event.data.useControl) == String(_subscribers[i].useControl)
						&& String(event.data.useShift) == String(_subscribers[i].useShift)
						&& String(event.data.useAlt) == String(_subscribers[i].useAlt))
						{
							(_subscribers[i].shortcutCallback as Function).call(NaN, event);
						}
				}
			}
		}
		
		/**
		 * push an object in the _shortcutSubscriber array containing a 
		 * reference to the callback and the conditions under which it must be called.
		 * 
		 * @param shortcutCallback the method to call when the event is trigerred
		 * @param keyCode the keyCode of the pressed key
		 * @param asciiCode the asciiCode of the pressed key
		 * @param useControl wheter the ctrl (or command on Mac) button was pressed
		 * @param useShift wheter the Shift button was pressed
		 * @param useAlt wheter the Alt button was pressed
		 * @description a description of the trigerred event
		 */
		public function suscribe(shortcutCallback:Function, keyCode:int, asciiCode:int, 
								 useControl:Boolean = false, useShift:Boolean = false, 
								 useAlt:Boolean = false, description:String = null):void
		{
			_subscribers.push({
				shortcutCallback:shortcutCallback, 
				keyCode:keyCode, 
				asciiCode:asciiCode, 
				useControl:useControl, 
				useShift:useShift,
				useAlt:useAlt,
				description:description
			});
		}
		
		/**
		 * remove a suscriber from the suscriber array
		 */
		public function unSuscribe(shortcutCallback:Function, keyCode:int, asciiCode:int, 
								 useControl:Boolean = false, useShift:Boolean = false, 
								 useAlt:Boolean = false, description:String = null):void
		{
			
			
			for (var i:int = 0; i < _subscribers.length; i++)
			{
				if (_subscribers[i].shortcutCallback == shortcutCallback
				&& _subscribers[i].keyCode == keyCode
				&& _subscribers[i].asciiCode == asciiCode
				&& _subscribers[i].useControl == useControl
				&& _subscribers[i].useShift == useShift
				&& _subscribers[i].useAlt == useAlt
				&& _subscribers[i].description == description )
				{
					_subscribers.splice(i, 1);
				}
			}
		}
		
		/**
		 * listens for key event and call the method dispatching a shortcut event
		 * if at least one shortcut key is pressed
		 * 
		 * @param event the trigerred KeyboardEvent
		 */ 
		public function onKeyDown(event:KeyboardEvent):void
		{
			//if one of the following key is pressed
			if (event.ctrlKey || event.altKey || event.charCode == DELETE_KEY || event.charCode == ESCAPE_KEY || event.charCode == ENTER_KEY)
			{
				dispatch( { keyCode:event.keyCode, 
					asciiCode:event.charCode, 
					useControl:event.ctrlKey, 
					useAlt:event.altKey, 
					useShift:event.shiftKey,
					dispatchFrom:DISPATCH_FROM
				}); 
			}
			
			else
			{
				//trace ("as3 Keyboard event is not a shortcut : "+event.keyCode);
			}
		}
		
		/**
		 * dispatch a shortcut event for the whole API (AS2, AS3 andd JS)
		 * 
		 * @param	shortcut the shortcut data to dispatch
		 */
		private function dispatch(shortcut:Object):void
		{
			var eventToDispatch:Object = new Object();
			eventToDispatch.type = AdminApiEvent.SHORTCUT_EVENT;
			eventToDispatch.targetName = TARGET_NAME;
			eventToDispatch.data = shortcut;
			
			ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
		}
	}
}