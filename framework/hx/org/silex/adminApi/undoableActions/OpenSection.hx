/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.undoableActions;
import flash.Lib;
import haxe.Log;

class OpenSection extends UndoableActionBase
{

	/**
	 * the name of the section to open
	 */
	private var _sectionName:String;
	
	/**
	 * the url of the current section
	 */
	private var _currentSection:String;
	
	public function new(currentSection:String, sectionName:String) 
	{
		super();
		this._currentSection = currentSection;
		this._sectionName = sectionName;
	}
}