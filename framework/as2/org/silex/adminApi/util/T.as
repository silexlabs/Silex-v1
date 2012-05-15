/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.util.ObjectDumper;

/**
 * class for tracing. Better for performance. Set DO_TRACE to false to disable //T.ts and speed up release
 * t function disects and //T.ts all arguments.
 * for example call //T.y("obj1", "obj1)
 * so that obj1 can be converted to a string by the t function
 * 
 * */
class org.silex.adminApi.util.T
{
	public static var DO_TRACE:Boolean = System.capabilities.isDebugger;
	
	public static function y():String{
		if (!DO_TRACE) {
			return "";
		}
		var out:String = "";
		if(arguments.length > 1){
			out = ObjectDumper.toString(arguments, true, true, true, 100000, 4);
		}else{
			out = arguments[0];
		}
		
		trace(out);
		return out;
		
	}
}
