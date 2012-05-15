/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * this class has the hook names for the Layer class
 * @see	org.silex.core.Interpreter
 * @author lex@silex.tv
 */
import org.silex.core.plugin.HookDescriber;
class org.silex.ui.LayerHooks //later implements IHookable
{
	public static var _className:String = "org.silex.ui.Layer";
	/**
	 * constants for the hook
	 */
	public static var INIT:String = "init";
	public static var INIT_START_HOOK_UID:String =  _className + "." + INIT + "." + HookDescriber.TYPE_START;
	public static var INIT_END_HOOK_UID:String =  _className + "." + INIT+ "." + HookDescriber.TYPE_END;
	/**
	 * constants for the hook
	 */
	public static var REGISTER_PLAYER:String = "registerPlayer";
	public static var REGISTER_PLAYER_START_HOOK_UID:String =  _className + "." + REGISTER_PLAYER + "." + HookDescriber.TYPE_START;
	public static var REGISTER_PLAYER_END_HOOK_UID:String =  _className + "." + REGISTER_PLAYER+ "." + HookDescriber.TYPE_END;
	/**
	 * constants for the hook
	 */
	public static var ALL_PLAYERS_LOADED:String = "allPlayersLoaded";
	public static var ALL_PLAYERS_LOADED_START_HOOK_UID:String =  _className + "." + ALL_PLAYERS_LOADED + "." + HookDescriber.TYPE_START;
	public static var ALL_PLAYERS_LOADED_END_HOOK_UID:String =  _className + "." + ALL_PLAYERS_LOADED+ "." + HookDescriber.TYPE_END;
	/**
	 * constants for the hook
	 */
	public static var REFRESH:String = "refresh";
	public static var REFRESH_START_HOOK_UID:String =  _className + "." + REFRESH + "." + HookDescriber.TYPE_START;
	public static var REFRESH_END_HOOK_UID:String =  _className + "." + REFRESH + "." + HookDescriber.TYPE_END;
	
	/**
	 * constant for the http load error for a component
	 */
	public static var COMPONENT_LOAD_ERROR:String = "componentLoadError";
	
	public static var COMPONENT_SHOW_TOOLTIP:String = "componentShowToolTip";
	
	public static var COMPONENT_HIDE_TOOLTIP:String = "componentHideToolTip";
}