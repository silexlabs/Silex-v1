/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * a copy of  mx.data.binding.ObjectDumper class. use for debug only!
 * */

class org.silex.adminApi.util.ObjectDumper
{	
	public static function toString(obj, showFunctions, showUndefined, showXMLstructures, maxLineLength, indent)
	{
		var od = new org.silex.adminApi.util.ObjectDumper();
		if (maxLineLength == undefined)
		{
			maxLineLength = 100;
		}		
		if (indent == undefined) indent = 0;
		return od.realToString(obj, showFunctions, showUndefined, showXMLstructures, maxLineLength, indent);
	}
	
	private function ObjectDumper()
	{
		this.inProgress = new Array();
	}
	
	var inProgress;
	
	private function realToString(obj, showFunctions, showUndefined, showXMLstructures, maxLineLength, indent)
	{
		for (var x = 0; x < this.inProgress.length; x++)
		{
			if (this.inProgress[x] == obj) return "***";
		}
		this.inProgress.push(obj);
		
		indent ++;
		var t = typeof(obj);
		////T.y("<<<" + t + ">>>");
		var result;
		
		if ((obj instanceof XMLNode) && (showXMLstructures != true))
		{
			result = obj.toString();
		}
		else if (obj instanceof Date)
		{
			result = obj.toString();
		}
		else if (t == "object")
		{
			var nameList = new Array();
			if (obj instanceof Array)
			{
				result = "["; // "Array" + ":";
				for (var i = 0; i < obj.length; i++)
				{
					nameList.push(i);
				}
			}
			else
			{
				result = "{"; // "Object" + ":";
				for (var i in obj)
				{
					nameList.push(i);
				}
				nameList.sort();
			}
			
			//if (obj.length == undefined) //T.y("obj.length undefined");
			//if (obj.length == null) //T.y("obj.length null");
			//if (obj.length == 0) //T.y("obj.length 0");
			////T.y("namelist length " + nameList.length + ", obj.length " + obj.length);		
			var sep = "";
			for (var j = 0; j < nameList.length; j++)
			{
				var val = obj[nameList[j]];
				
				var show = true;
				if (typeof(val) == "function") show = (showFunctions == true);
				if (typeof(val) == "undefined") show = (showUndefined == true);
				
				if (show)
				{
					result += sep;
					if (!(obj instanceof Array))
						result += nameList[j] + ": ";
					result +=
						realToString(val, showFunctions, showUndefined, showXMLstructures, maxLineLength, indent);
					sep = ", `";
				}
			}
			if (obj instanceof Array)
				result += "]";
			else
				result += "}";
		}
		else if (t == "function")
		{
			result = "function";
		}
		else if (t == "string")
		{
			result = "\"" + obj + "\"";
		}
		else
		{
			result = String(obj);
		}
		
		if (result == "undefined") result = "-";
		this.inProgress.pop();
		return org.silex.adminApi.util.ObjectDumper.replaceAll(result, "`", (result.length < maxLineLength) ? "" : ("\n" + doIndent(indent)));
	}
	
	public static function replaceAll (str : String, from: String, to: String)
	{
		var chunks = str.split(from);
		var result = "";
		var sep = "";
		for (var i = 0; i < chunks.length; i++)
		{
			result += sep + chunks[i];
			sep = to;
		}
		return result;
	}
	
	private function doIndent(indent)
	{
		var result = "";
		for (var i = 0; i < indent; i ++)
		{
			result += "     ";
		}
		return result;
	}
}
