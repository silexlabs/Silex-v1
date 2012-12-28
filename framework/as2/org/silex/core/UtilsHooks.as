/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * this class has the hook names for the Utils class
 * @see	org.silex.core.Utils
 * @author lex@silex.tv
 */
import org.silex.core.plugin.HookDescriber;

class org.silex.core.UtilsHooks //later implements IHookable
{
	public static var _className:String = "org.silex.core.Utils";
	public static var DIALOG:String = "dialogs";
	/**
	 * this hook has uid "org.silex.core.Utils.dialogs.start"<br/>
	 * it is called just before a dialog opens (alert, prompt, prompt password, confirm)<br/>
	 * you can change the default values, or the text of the dialogs in your callback<br/>
	 * your callback should have the same signature than the one of the dialog you are "listing" to, i.e. the same as Utils::prompt, Utils:alert, ...
	 */ 
	public static var DIALOG_START_HOOK_UID:String =  _className + "." + DIALOG + "." + HookDescriber.TYPE_START;
	/**
	 * this hook has uid "org.silex.core.Utils.dialogs.end"<br/>
	 * it is called just before a dialog closes (alert, prompt, prompt password, confirm)<br/>
	 * your callback should take 1 argument, which is an array of the values returned by the dialog: isOk for confirme, nothing for alert, login and pass for promp password, text for prompt<br />
	 * you can modify these returned values in your callback<br/>
	 */ 
	public static var DIALOG_END_HOOK_UID:String =  _className + "." + DIALOG + "." + HookDescriber.TYPE_END;

	
}