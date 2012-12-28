/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * @author Ariel Sommeria-klein http://arielsommeria.com
 */
import mx.events.EventDispatcher;
import org.silex.core.plugin.HookEvent;

class org.silex.core.plugin.HookManager extends EventDispatcher
{
	//TODO: multiple instances of plugins! plugins register statically for now
	
	private static var _instance:HookManager;

	public function HookManager() 
	{
	}
	
	public static function getInstance():HookManager {
		if (!_instance) {
			_instance = new HookManager();
		}
		return _instance;
		
	}
	/**
	 * call this function on init in a plugin to register a callback for a hook
	 * note: Remember to create a delegate from your callback(AS2 only), and keep a hold of it you want to remove it
	 * 
	 * @param	hookUid. The string name of the hook. Should be defined as a constant somewhere
	 * @param	callBack. 
	 */
	public function addHook(hookUid:String, handlerCallback:Function):Void {
		addEventListener(hookUid, handlerCallback);
	}
	
	/**
	 * call this function on removal of a plugin to unregister a callback for a hook
	 * note: use the delegate created for addHook (AS2 only)
	 * 
	 * @param	hookUid. The string name of the hook. Should be defined as a constant somewhere
	 * @param	callBack. 
	 */
	public function removeHook(hookUid:String, handlerCallback:Function):Void {
		removeEventListener(hookUid, handlerCallback);
	}
	
		
	/**
	 * the Silex core classes will call this method to call callbacks registered with the relevant hook
	 * @param	hookUid. the hook unique identifier.
	 * @param	hookData. The data. Depends on the hook type. If it's a start hook, the arguments. If it's an end hook, the return value
	 */
	public function callHooks(hookUid:String, hookData:Object):Void {
		var hookEvent:HookEvent = new HookEvent(hookUid, this, hookData);
		dispatchEvent(hookEvent);
		
	}
	
}