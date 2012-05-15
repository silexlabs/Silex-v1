/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

@:native("logger") extern class LoggerExtern
{
	private function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/logger.php");
		null;
	}
	
	private var name : String;
	private var logHandle : Dynamic;
	private var filter : Dynamic;
	
	public function new(): Void;
	
	/**
	*  Returns the Log Level as a String.
	*/
	public function getLogLevel(loggerName : String) : String;
	/**
	*  Prints debug message.
	*/
	public function debug(message : Dynamic) : Void;
	/**
	*  Prints info message.
	*/
	public function info(message : Dynamic) : Void;
	/**
	*  Prints error message.
	*/
	public function err(message : Dynamic) : Void;
	/**
	*  Prints critical error message.
	*/
	public function crit(message : Dynamic) : Void;
	/**
	*  Prints alert message.
	*/
	public function alert(message : Dynamic) : Void;
	/**
	*  Prints emergency message.
	*/
	public function emerg(message : Dynamic) : Void;
}