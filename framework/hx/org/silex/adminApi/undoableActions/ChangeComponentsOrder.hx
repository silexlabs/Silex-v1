/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.undoableActions;
import flash.Lib;
import haxe.Log;

class ChangeComponentsOrder extends UndoableActionBase
{
	private var _uids:Array<String>;
	
	public function new(componentsUid:Array<Array<Dynamic>>) 
	{
		super();
		this._uids = new Array();
		var intIter:IntIter = new IntIter(0, componentsUid[0].length);
		
		for (i in intIter)
		{
			this._uids.push(componentsUid[0][i].uid);
		}
	}
	
	override public function undo():Void
	{
		Lib._global.org.silex.adminApi.SilexAdminApi.getInstance().components.changeOrder(this._uids);
	}
	
	override public function redo():Void
	{
		Lib._global.org.silex.adminApi.SilexAdminApi.getInstance().components.changeOrder(this._uids);
	}
	
}