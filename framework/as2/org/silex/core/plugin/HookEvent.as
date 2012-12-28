/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * ...
 * @author Ariel Sommeria-klein http://arielsommeria.com
 */
class org.silex.core.plugin.HookEvent
{
	private var _type:String;
	private var _target:Object; //not very useful as such, just for future AS3 compatibility
	private var _hookData:Object;
	public function HookEvent(eventType:String, eventTarget:Object, eventHookData:Object) 
	{
		_type = eventType;
		_target = eventTarget;
		_hookData = eventHookData;
	}
	
	public function get type():String {
		return _type;
	}
	
	public function get target():Object {
		return _target;
	}
	
	public function get hookData():Object {
		return _hookData;
	}
	
}