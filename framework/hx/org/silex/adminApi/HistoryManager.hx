/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi;
import haxe.Log;
import org.silex.adminApi.undoableActions.IUndoableAction;
import org.silex.adminApi.undoableActions.UndoableActionBase;
import org.silex.adminApi.undoableActions.OpenSection;
import flash.Lib;

/**
 * This class stores and manages the undoable commands arrays. 
 * it is added to the SilexAdminApi 
 * so that it's method can be called in the form : 
 * SilexAdminApi.getInstance().historyManager.undo().
 */
class HistoryManager
{
	/**
	 * The array that will store the undoable commands pushed by 
	 * the ListedModelBase and ListedObjectBase objects when in undo mode.
	 */
	public var undoActions:Array<IUndoableAction>;
	
	/**
	 * The array that will store the undoable commands pushed 
	 * by the ListedModelBase and ListedObjectBase objects when in redo mode.
	 */
	public var redoActions:Array<IUndoableAction>;
	
	/**
	 * A flag determining if an undo is in progress.
	 */
	private var _undoPending:Bool;
	
	/**
	 * A flag determining if a redo is in progress
	 */
	private var _redoPending:Bool;
	
	/**
	 * Determine the maximum number of undo. Get it from silex config.
	 */
	private var _maxUndoLevel:Int;
	
	/**
	 * const for the history changed event
	 */
	private static var HISTORY_DATA_CHANGED:String = "historyDataChanged";
	
	/**
	 * the target for adminApiEvent
	 */
	private static var TARGET:String = "historyManager";
	
	public function new() 
	{
		_undoPending = false;
		_redoPending = false;
		_maxUndoLevel = Std.parseInt(Lib._global.getSilex().config.MAX_UNDO_LEVEL);
		undoActions = new Array<IUndoableAction>();
		redoActions = new Array<IUndoableAction>();
		
		var silexApplication:Dynamic = Lib._global.getSilex().application;
		silexApplication.addEventListener("openSection", onOpenSection);
	}
	
	/**
	 * executes the undo method of the undoableActions 
	 * of the undoActions array, starting from last, while 
	 * their frameStamp match. Pop each undone action. Dispatches a AdminAPIEvent.HISTORY_DATA_CHANGED event. 
	 * set _undoPending to false.
	 */
	public function undo():Void
	{

		if (undoActions.length > 0)
		{
			_undoPending = true;
			var refFrameStamp:Int = undoActions[undoActions.length - 1].getFrameStamp();
			
			do {
				undoActions[undoActions.length - 1].undo();
				
				undoActions.pop();
			}
			while (undoActions[undoActions.length - 1].getFrameStamp() == refFrameStamp);
			
			_undoPending = false;
			
			var eventToDispatch:Dynamic = untyped __new__(Lib._global.org.silex.adminApi.AdminApiEvent, HistoryManager.HISTORY_DATA_CHANGED, HistoryManager.TARGET, new Array());
			Lib._global.org.silex.adminApi.ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
		}
		
	}
	
	/**
	 * when the user navigates, flush the undo/redo data
	 * @param	event
	 */
	private function onOpenSection(event:Dynamic):Void
	{
		//this.addUndoableAction(new OpenSection(Lib._global.getSilex().deeplink.currentHashValue, event.sectionName));
		this.flush();
	}
	
	/**
	 * executes the redo method of the undoableActions of the redoActions array,
	 * starting from first while their frameStamp match.
	 * unshif each redone action. Dispatches a AdminAPIEvent.HISTORY_DATA_CHANGED event.
	 */
	public function redo():Void
	{

		if (redoActions.length > 0)
		{
			_redoPending = true;
			var refFrameStamp:Int = redoActions[redoActions.length - 1].getFrameStamp();
			do {
				redoActions[redoActions.length - 1].redo();
				
				redoActions.pop();
			}
			while (redoActions[redoActions.length - 1].getFrameStamp() == refFrameStamp);
			
			_redoPending = false;
			
			var eventToDispatch:Dynamic = untyped __new__(Lib._global.org.silex.adminApi.AdminApiEvent, HistoryManager.HISTORY_DATA_CHANGED, HistoryManager.TARGET, new Array());
			 Lib._global.org.silex.adminApi.ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
		}
		
	}
	
	/**
	 * empties the undoActions and redoActions array. 
	 * Dispatches a AdminAPIEvent.HISTORY_DATA_CHANGED event.
	 */
	public function flush():Void
	{
		undoActions = [];
		redoActions = [];
		var eventToDispatch:Dynamic = untyped __new__(Lib._global.org.silex.adminApi.AdminApiEvent, HistoryManager.HISTORY_DATA_CHANGED, HistoryManager.TARGET, new Array());
		Lib._global.org.silex.adminApi.ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
	}
	
	/**
	 * if _undoPending is false,
	 * push an object into the undoActions array, 
	 * (pop the array if undoActions length equals _maxLevel), 
	 * set it's frameStamp from the silex sequencer (named currentFrame) 
	 * and empties the redoActions array,
	 * else, add it to the redoActions Array and set it's frameStamp.  
	 * Dispatches a AdminAPIEvent.HISTORY_DATA_CHANGED event
	 * @param	undoableAction the undoableAction to add
	 */
	public function addUndoableAction(undoableAction:IUndoableAction):Void
	{
	
		if (_undoPending == false)
		{
		
			undoActions.push(undoableAction);
			if (_redoPending == false)
			{
				redoActions = [];
			}
			
			
			if (getUndo() > _maxUndoLevel)
			{
				undoActions.shift();
			}
		}
		
		else
		{
			redoActions.push(undoableAction);
		}
		var eventToDispatch:Dynamic = untyped __new__(Lib._global.org.silex.adminApi.AdminApiEvent, HistoryManager.HISTORY_DATA_CHANGED, HistoryManager.TARGET, new Array());
		Lib._global.org.silex.adminApi.ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
	}
	
	/**
	 * return the number of available undo
	 * @return the number of available undo
	 */
	public function getUndo():Int
	{
		var intIter:IntIter = new IntIter(0, undoActions.length);
		var referenceFrame:Int = 0;
		var undoNumber:Int = 0;
		for (i in intIter)
		{
			if (undoActions[i].getFrameStamp() > referenceFrame)
			{
				referenceFrame = undoActions[i].getFrameStamp();
				undoNumber++;
			}
		}
		
		return undoNumber;
	}
	
	/**
	 * return the number of available redo
	 * @return the number of available redo
	 */
	public function getRedo():Int
	{
		var intIter:IntIter = new IntIter(0, redoActions.length);
		var referenceFrame:Int = 0;
		var redoNumber:Int = 0;
		for (i in intIter)
		{
			if (redoActions[i].getFrameStamp() > referenceFrame)
			{
				referenceFrame = redoActions[i].getFrameStamp();
				redoNumber++;
			}
		}
		return redoNumber;
	}
	
}