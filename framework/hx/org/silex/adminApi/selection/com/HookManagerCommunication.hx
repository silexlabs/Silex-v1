/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.com;
import flash.Lib;
import haxe.Log;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;
import org.silex.adminApi.selection.components.ComponentsManager;
import org.silex.adminApi.selection.ui.externs.UIsExtern;

/**
 * A singleton abstracting the access to the HookManager to separate DOM specific methods from the core
 * of the SelectionManager
 * @author Yannick DOMINGUEZ
 */
class HookManagerCommunication 
{
	////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * A hook called by the ui components when it is ready after loading
	 */
	private inline static var HOOK_UI_MANAGER_READY:String = "uisReady";
	
	////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The class instance returned by the singleton
	 */
	private static var _hookManagerCommunication:HookManagerCommunication;
	
	/**
	 * Signals when the SilexAdminApi is ready
	 */
	public var silexAdminApiReadyHookSignaler(default, null):Signaler<Void>;
	
	/**
	 * Signals when the UIManager is ready
	 */
	public var uiManagerReadyHookSignaler(default, null):Signaler<UIsExtern>;
	
	/**
	 * Signals when a component place holder is clicked
	 */
	public var componentPlaceHolderMouseDownSignaler(default, null):Signaler<String>;
	
	/**
	 * Signals when a non editable component place holder is clicked
	 */
	public var nonEditableComponentPlaceHolderMouseDownSignaler(default, null):Signaler<String>;
	
	/**
	 * Signals when a component place holder is rolled over
	 */
	public var componentPlaceHolderRollOverSignaler(default, null):Signaler<String>;
	
	/**
	 * Signals when a component place holder is rolled out
	 */
	public var componentPlaceHolderRollOutSignaler(default, null):Signaler<Void>;
	
	/**
	 * a reference to the component place holder click callback
	 */
	private var _componentPlaceHolderMouseDownDelegate:Dynamic->Void;
	
	/**
	 * a reference to the non editable component place holder click callback
	 */
	private var _nonEditableComponentPlaceHolderMouseDownDelegate:Dynamic->Void;
	
	/**
	 * a reference to the component place holder roll over callback
	 */
	private var _componentPlaceHolderRollOverDelegate:Dynamic->Void;
	
	/**
	 * a reference to the component place holder roll out callback
	 */
	private var _componentPlaceHolderRollOutDelegate:Dynamic->Void;
	
	/**
	 * a reference to the SilexAdminApi ready callback
	 */
	private var _adminApiReadyDelegate:Void->Void;
	
	/**
	 * a reference to the UIManager ready callback
	 */
	private var _uiManagerReadyDelegate:Dynamic->Void;
	
	/**
	 * A reference to the HookManager
	 */
	private var _hookManager:Dynamic;
	
	////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * initialise the signaler, then add hook for SilexAdminApi and UIManager ready
	 * events
	 */
	private function new() 
	{
		silexAdminApiReadyHookSignaler = new DirectSignaler(this);
		uiManagerReadyHookSignaler = new DirectSignaler(this);
		componentPlaceHolderRollOutSignaler = new DirectSignaler(this);
		componentPlaceHolderMouseDownSignaler = new DirectSignaler(this);
		componentPlaceHolderRollOverSignaler = new DirectSignaler(this);
		nonEditableComponentPlaceHolderMouseDownSignaler = new DirectSignaler(this);
		
		_hookManager = Lib._global.org.silex.core.plugin.HookManager.getInstance();
		
		_uiManagerReadyDelegate = onUIManagerReady;
		_adminApiReadyDelegate = onAdminApiReady;
		_componentPlaceHolderMouseDownDelegate = onComponentPlaceHolderMouseDown;
		_componentPlaceHolderRollOutDelegate = onComponentPlaceHolderRollOut;
		_componentPlaceHolderRollOverDelegate = onComponentPlaceHolderRollOver;
		_nonEditableComponentPlaceHolderMouseDownDelegate = onNonEditableComponentPlaceHolderMouseDown;
		
		_hookManager.addHook(Lib._global.org.silex.adminApi.SilexAdminApiHooks.ADMIN_API_LOAD_END_HOOK_UID, _adminApiReadyDelegate);
		_hookManager.addHook(HOOK_UI_MANAGER_READY, _uiManagerReadyDelegate);
		_hookManager.addHook(ComponentsManager.COMPONENT_PLACE_HOLDER_PRESS_HOOK, _componentPlaceHolderMouseDownDelegate);
		_hookManager.addHook(ComponentsManager.COMPONENT_PLACE_HOLDER_ROLL_OUT_HOOK, _componentPlaceHolderRollOutDelegate);
		_hookManager.addHook(ComponentsManager.COMPONENT_PLACE_HOLDER_ROLL_OVER_HOOK, _componentPlaceHolderRollOverDelegate);
		_hookManager.addHook(ComponentsManager.NON_EDITABLE_COMPONENT_PLACE_HOLDER_PRESS_HOOK, _nonEditableComponentPlaceHolderMouseDownDelegate);
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Returns the instantiated class instance and instantiate it
	 * if null
	 * @return the class intance
	 */
	public static function getInstance():HookManagerCommunication
	{
		if (_hookManagerCommunication == null)
		{
			_hookManagerCommunication = new HookManagerCommunication();
		}
		
		return _hookManagerCommunication;
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Signals when the UIManager is ready
	 * @param	event the hook event containing a reference to the ui components
	 */
	private function onUIManagerReady(event:Dynamic):Void
	{
		_hookManager.removeHook(HOOK_UI_MANAGER_READY, _uiManagerReadyDelegate);
		uiManagerReadyHookSignaler.dispatch(event.hookData);
	}
	
	/**
	 * Signals when SilexAdminApi is ready
	 */
	private function onAdminApiReady():Void
	{
		_hookManager.removeHook(Lib._global.org.silex.adminApi.SilexAdminApiHooks.ADMIN_API_LOAD_END_HOOK_UID, _adminApiReadyDelegate);
		silexAdminApiReadyHookSignaler.dispatch();
	}
	
	/**
	 * signal the component place holder mouse down
	 * @param	event contains the uid of the component
	 */
	private function onComponentPlaceHolderMouseDown(event:Dynamic):Void
	{
		componentPlaceHolderMouseDownSignaler.dispatch(event.hookData);
	}
	
	/**
	 * signal the non editable component place holder mouse down
	 * @param	event contains the uid of the component
	 */
	private function onNonEditableComponentPlaceHolderMouseDown(event:Dynamic):Void
	{
		nonEditableComponentPlaceHolderMouseDownSignaler.dispatch(event.hookData);
	}
	
	
	/**
	 * signal the component place holder roll over
	 * @param	event contains the uid of the component
	 */
	private function onComponentPlaceHolderRollOver(event:Dynamic):Void
	{
		componentPlaceHolderRollOverSignaler.dispatch(event.hookData);
	}
	
	/**
	 * signal the component place holder roll out
	 */
	private function onComponentPlaceHolderRollOut(event:Dynamic):Void
	{
		componentPlaceHolderRollOutSignaler.dispatch();
	}
	
}