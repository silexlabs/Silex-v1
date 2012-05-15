/*This file is part of Silex: RIA developement tool - see http://silex-ria.org/

Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html*/

package org.silex.wysiwyg.toolboxApi.interfaces
{

	/**
	 * an interface implemented by sub-application for the property Toolbox
	 */
	public interface IActionPlugin
	{
		/**
		 * sets the array of IProperty object to edit in the property toolbox sub-application
		 * 
		 * @param	propertiesArray the array of IProperty to set
		 */
		function setProperties(propertiesArray:Array):void;
		
		/**
		 * returns the array of modified IProperty
		 */
		function getProperties():Array;
	}
}