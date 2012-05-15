/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * debug / log function (abstraction layer)
 */
/**
 * Log constants
 */
var DEBUG_MODE = false;
var TRACE_ERROR = "error";
var TRACE_WARNING = "warning";
var TRACE_DEBUG = "debug";

function trace ($obj,$level,$className)
{
	if (DEBUG_MODE == true)
	{
		// default value for $className
		if (!$className) $className = "";

		if (typeof console != "undefined") 
		{
			try 
			{
				switch($level)
				{
					case TRACE_ERROR:
						console.error($className+" - ",$obj);
						break;
					case TRACE_WARNING:
						console.warning($className+" - ",$obj);
						break;
					default:
						console.log($className+" - ",$obj);
				}
			}
			catch(e)
			{
				alert("trace error "+e.toString());
			}
		}
	}
}
function delegate( that, thatMethod )
{
	return function()
	{
		return thatMethod.call(that);
	}
}
function decode_utf8( s )
{
	try{ s = decodeURIComponent( escape( s ) ); }
	catch(e){}
	return s;
}
function encode_utf8( string )
{
	return unescape( encodeURIComponent( string ) );
}