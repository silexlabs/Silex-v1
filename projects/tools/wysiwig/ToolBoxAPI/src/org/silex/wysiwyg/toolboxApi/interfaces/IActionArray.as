/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/

package org.silex.wysiwyg.toolboxApi.interfaces
{
	
	/**
	 * An interface implemented by class who needs to wrap an array of Action object
	 */
	public interface IActionArray
	{
		/**
		 * returns all the Action objects of the array
		 */
		function get actionArray():Array;
		
		/**
		 * returns the name of the component who owns the array of Action
		 */
		function get componentName():String;
		
		/**
		 * concatenates all the Action object functionName, modifiers and parameters
		 * in a string where each line is an action
		 * 
		 * @param value the String to set
		 */
		function set actionString(value:String):void;
		
		/**
		 * returns the string of actions
		 */
		function get actionString():String;
		
		/**
		 * Creates an Action object and adds it to the array
		 * 
		 * @param	modifier the modifier of the action
		 * @param	functionName the function name of the new action 
		 * @param	parameters the parameters of the new action
		 */
		function addAction(modifier:String, functionName:String, parameters:Array):void;
		
		/**
		 * empties the array of action
		 */
		function resetActionArray():void;
		
		/**
		 * sets the array of modified action which will replace the current array
		 * of action
		 * 
		 * @param value the array to set
		 */
		function set newActionArray(value:Array):void
		
		/**
		 * returns the new array of action
		 */
		function get newActionArray():Array;
	}
}