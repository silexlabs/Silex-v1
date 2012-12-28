/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.undoableActions;
import haxe.Log;
import org.silex.adminApi.undoableActions.IUndoableAction;
import flash.Lib;

/**
 * This is a base base class inherited by all undoable actions.
 * Each undoable action has a timestamp used to undo/redo all the undoable
 * actions done at the same time together
 */
class UndoableActionBase implements IUndoableAction
{
	/**
	 * the N° of the frame where this object was added.
	 */
	private var _frameStamp:Int;
	
	
	private function new() 
	{
		_frameStamp = Std.parseInt(Lib._global.getSilex().sequencer.currentFrame);
	}
	
	/**
	 * undo a SilexAdminApi action. Default behaviour is to flush the history, so that unimplemented
	 * class does'nt mess with Silex.
	 */
	public function undo():Void
	{
		Lib._global.org.silex.adminApi.SilexAdminApi.getInstance().historyManager.flush();
	}
	
	/**
	 * redo a SilexAdminApi action
	 */
	public function redo():Void
	{
		Lib._global.org.silex.adminApi.SilexAdminApi.getInstance().historyManager.flush();
	}
	
	/**
	 * returns the frame stamp
	 */
	public function getFrameStamp():Int
	{
		return this._frameStamp;
	}
	
	
	
}