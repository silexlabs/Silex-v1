/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
*  interface for dom converters.
*  used to convert specific property names to generic property names and vice versa
* @author Ariel Sommeria-klein http://arielsommeria.com
*  */

package org.silex.core.component;

interface IDomConverter{
	
	/**
	 * Use this function to get the specific property name from the property generic name.
	 * @param	name
	 * @return String
	 */
	function genericPropertyNameToSpecific(name:String):String;

	/**
	 * Use this function to get the generic property name from the specific property name.
	 * @param 	name
	 * @return String
	 */	
	function specificPropertyNameToGeneric(name:String):String;
}