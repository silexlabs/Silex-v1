/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * 
 * @author Ariel Sommeria-klein http://arielsommeria.com
 */
class org.silex.core.plugin.HookDescriber {
	
	public static var TYPE_START:String = "START";
	public static var TYPE_END:String = "END";
	
	/**
	 * design notes:
	 * getters would be nice, but bad for performance. maybe later
	 */
	
	//the name with which it will be stored and refered to.  by convention the next 3 fields concatenated
	public var refName:String;	
	//one of the types defined above
	public var type:Number;	 
	
	public function Hook(refName:String, type:Number) {
		this.refName = refName;
		this.type = type;
	}
	
	public function toString():String {
		return refName;
	}
	
}