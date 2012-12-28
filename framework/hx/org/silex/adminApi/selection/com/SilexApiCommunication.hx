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
import org.silex.adminApi.selection.utils.Structures;

/**
 * A singleton abstracting the access to SilexApi to separate DOM specific methods from the core
 * of the SelectionManager
 * @author Yannick DOMINGUEZ
 */
class SilexApiCommunication 
{
	////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The event dispatched by SilexApi when the background is clicked
	 */
	private static var BACKGROUND_PRESS_EVENT:String = "onBgPress";
	
	/**
	 * The event dispatched by silexApi when the stage is resized
	 */
	private static var STAGE_RESIZE_EVENT:String = "resize";
	
	/**
	 * The event dispatched by SilexApi when the user logs out
	 */
	private static var LOGOUT_EVENT:String = "logout";
	
	/**
	 * The event dispatched by SilexApi when the user logs in
	 */
	private static var LOGIN_EVENT:String = "loginSuccess";
	
	////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Signal a stage resize
	 */
	public var silexApiResizeSignaler(default, null):Signaler<Void>;
	
	/**
	 * Signal a background click
	 */
	public var silexApiBackgroundMouseDownSignaler(default, null):Signaler<Void>;
	
	/**
	 * Signal the user log out
	 */
	public var silexApiLogOutSignaler(default, null):Signaler<Void>;
	
	/**
	 * Signal the user log in
	 */
	public var silexApiLogInSignaler(default, null):Signaler<Void>;
	
	/**
	 * A reference to SilexApi
	 */
	private var _silexApi:Dynamic;
	
	/**
	 * The class instance returned by the Singleton
	 */
	private static var _silexApiCommunication:SilexApiCommunication;
	
	////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Initialise the signaler and listen to resize and background
	 * mouse down event on SilexApi
	 */
	private function new() 
	{
		silexApiResizeSignaler = new DirectSignaler(this);
		silexApiBackgroundMouseDownSignaler = new DirectSignaler(this);
		silexApiLogOutSignaler = new DirectSignaler(this);
		silexApiLogInSignaler = new DirectSignaler(this);
		
		_silexApi = Lib._global.getSilex();
		
		_silexApi.application.addEventListener(BACKGROUND_PRESS_EVENT, onBackgroundMouseDown);
		_silexApi.application.addEventListener(STAGE_RESIZE_EVENT, onStageResize);
		_silexApi.authentication.addEventListener(LOGOUT_EVENT, onLogOut);
		_silexApi.authentication.addEventListener(LOGIN_EVENT, onLogIn);
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Return the instantiated class and instantiate it if null
	 * @return the instantiated class
	 */
	public static function getInstance():SilexApiCommunication
	{
		if (_silexApiCommunication == null)
		{
			_silexApiCommunication = new SilexApiCommunication();
		}
		return _silexApiCommunication;
	}
	
	/**
	 * Return the X scale of the silex scene
	 * @return the X scale of Silex scene
	 */
	public function getSilexXScale():Float
	{
		return (Std.parseInt(_silexApi.application.sceneRect.right) - Std.parseInt(_silexApi.application.sceneRect.left)) / Std.parseInt(_silexApi.config.layoutStageWidth) ;
	}
	
	/**
	 * Return the Y scale of the silex scene
	 * @return the Y scale of Silex scene
	 */
	public function getSilexYScale():Float
	{
		return (Std.parseInt(_silexApi.application.sceneRect.bottom) - Std.parseInt(_silexApi.application.sceneRect.top)) / Std.parseInt(_silexApi.config.layoutStageHeight);
	}
	
	/**
	 * Return the bounds of the Silex scene
	 * @return the bounds of the silex scene
	 */
	public function getSilexSceneBounds():ComponentBounds
	{
		return {
			left:Std.parseInt(_silexApi.application.sceneRect.left),
			right:Std.parseInt(_silexApi.application.sceneRect.right),
			top:Std.parseInt(_silexApi.application.sceneRect.top),
			bottom:Std.parseInt(_silexApi.application.sceneRect.bottom)
		}
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * when the background is clicked, dispatch a signal
	 */
	private function onBackgroundMouseDown():Void
	{
		silexApiBackgroundMouseDownSignaler.dispatch();
	}
	
	/**
	 * when the stage is resized, dispatch a signal
	 */
	private function onStageResize():Void
	{
		silexApiResizeSignaler.dispatch();
	}
	
	/**
	 * When the user logs out, dispatch a signal
	 */
	private function onLogOut():Void
	{
		silexApiLogOutSignaler.dispatch();
	}
	
	/**
	 * When the user logs in, dispatch a signal
	 */
	private function onLogIn():Void
	{
		silexApiLogInSignaler.dispatch();
	}
	
	
	
}