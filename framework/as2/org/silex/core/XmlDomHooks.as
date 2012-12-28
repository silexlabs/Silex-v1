/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * @author Ariel Sommeria-klein http://arielsommeria.com
 */

import org.silex.core.plugin.HookDescriber;

class org.silex.core.XmlDomHooks
{
	public static var _className:String = "org.silex.core.XmlDom";
	public static var XML_TO_OBJ:String = "xmlToObj";
	public static var XML_TO_OBJ_START_HOOK_UID:String = _className + "." + XML_TO_OBJ + "." + HookDescriber.TYPE_START;
	public static var XML_TO_OBJ_END_HOOK_UID:String = _className + "." + XML_TO_OBJ + "." + HookDescriber.TYPE_END;

	
}