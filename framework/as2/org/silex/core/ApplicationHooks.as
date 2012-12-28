/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * this class has the hook names for the Interpreter class
 * @see	org.silex.core.Interpreter
 * @author lex@silex.tv
 */
import org.silex.core.plugin.HookDescriber;

class org.silex.core.ApplicationHooks //later implements IHookable
{
	public static var _className:String = "org.silex.core.Application";
	/**
	 * constants for preload hook
	 */
	public static var PRELOAD:String = "preload";
	public static var PRELOAD_START_HOOK_UID:String =  _className + "." + PRELOAD + "." + HookDescriber.TYPE_START;
	public static var PRELOAD_END_HOOK_UID:String =  _className + "." + PRELOAD+ "." + HookDescriber.TYPE_END;
	/**
	 * constants for openSection hook
	 */
	public static var OPENSECTION:String = "openSection";
	public static var OPENSECTION_START_HOOK_UID:String =  _className + "." + OPENSECTION + "." + HookDescriber.TYPE_START;
	public static var OPENSECTION_END_HOOK_UID:String =  _className + "." + OPENSECTION+ "." + HookDescriber.TYPE_END;

	/**
	 * constants for openSection hook
	 */
	public static var LAYOUTINIT:String = "layoutInit";
	public static var LAYOUTINIT_START_HOOK_UID:String =  _className + "." + LAYOUTINIT + "." + HookDescriber.TYPE_START;
	public static var LAYOUTINIT_END_HOOK_UID:String =  _className + "." + LAYOUTINIT+ "." + HookDescriber.TYPE_END;
	
	/**
	 * constants for save hook
	 */
	public static var SAVE:String = "save";
	public static var SAVE_START_HOOK_UID:String =  _className + "." + SAVE + "." + HookDescriber.TYPE_START;
	public static var SAVE_END_HOOK_UID:String =  _className + "." + SAVE+ "." + HookDescriber.TYPE_END;
	
	/**
	 * constants for saveLayout hook
	 */
	public static var SAVE_LAYOUT:String = "saveLayout";
	public static var SAVE_LAYOUT_START_HOOK_UID:String =  _className + "." + SAVE_LAYOUT + "." + HookDescriber.TYPE_START;
	public static var SAVE_LAYOUT_END_HOOK_UID:String =  _className + "." + SAVE_LAYOUT + "." + HookDescriber.TYPE_END;	

	
}

