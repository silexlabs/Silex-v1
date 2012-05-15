/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.RichTextList;
import org.oof.lists.cellRenderers.DraggableRichTextCellRenderer;
import org.oof.lists.ListRow;

import mx.transitions.Tween;
import mx.transitions.easing.*;

/** This list is like a normal rich text list, except that you can reorder the elements by drag and drop
 * note: this only works with vertical, one dimensional lists with fixed row dimensions for now
 * @author Ariel Sommeria-klein
 * */
class org.oof.lists.ReorderableRichTextList extends RichTextList{
	//easing functions
	static var EASING_FUNC_BACK:String = "back";
	static var EASING_FUNC_BOUNCE:String = "bounce";
	static var EASING_FUNC_ELASTIC:String = "elastic";
	static var EASING_FUNC_NONE:String = "none";
	static var EASING_FUNC_REGULAR:String = "regular";
	static var EASING_FUNC_STRONG:String = "strong";
	
	//easing types 
	static var EASING_TYPE_NONE:String = "none";
	static var EASING_TYPE_IN:String = "in";
	static var EASING_TYPE_OUT:String = "out";
	static var EASING_TYPE_IN_OUT:String = "inOut";
   /** 
   * Group: internal
   * */	
   //properties
	private var _swapDuration:Number = 0;
	private var _swapEasingFunctionName:String = null;
	private var _swapEasingType:String = null;
	
	//associative array storing the tweens being executed
	private var _swapTweens:Object = null;
	
	//delegates
    private var _onCellRendererStartDragDelegate:Function;
    private var _onCellRendererStopDragDelegate:Function;
    private var _onCellRendererDragDelegate:Function;
	private var _onSwapTweenFinishedDelegate:Function;
	
	function ReorderableRichTextList(){
		super();
		_className = "org.oof.lists.ReorderableRichTextList";
		typeArray.push("org.oof.lists.ReorderableRichTextList");
		_onCellRendererStartDragDelegate = Delegate.create(this, onCellRendererStartDrag);
		_onCellRendererStopDragDelegate = Delegate.create(this, onCellRendererStopDrag);
		_onCellRendererDragDelegate = Delegate.create(this, onCellRendererDrag);
		_swapTweens = new Object();
		_onSwapTweenFinishedDelegate = Delegate.create(this, onSwapTweenFinished);
	}
	
	/**
	* method to create a cell renderer. This is a separate method so that it can be overridden in a derived class
	*/
	private function createCellRenderer(row:ListRow, placeInRow:Number, initObj:Object):MovieClip{
		var ret:MovieClip = super.createCellRenderer(row, placeInRow, initObj);
		ret.addEventListener(DraggableRichTextCellRenderer.START_DRAG_EVENT, _onCellRendererStartDragDelegate);
		return ret;
		
	}

	/**
	* method to destroy a cell renderer. Use it also when removing a row! 
	* This is a separate method so that it can be overridden in a derived class
	*/
	private function destroyCellRenderer(renderer:MovieClip):Void{
		renderer.removeEventListener(DraggableRichTextCellRenderer.START_DRAG_EVENT, _onCellRendererStartDragDelegate);
		renderer.removeEventListener(DraggableRichTextCellRenderer.STOP_DRAG_EVENT, _onCellRendererStopDragDelegate);
		renderer.removeEventListener(DraggableRichTextCellRenderer.DRAG_EVENT, _onCellRendererDragDelegate);
		super.destroyCellRenderer(renderer);
	}	
	
	private function getSwapEasingFunction():Function{
		var easeLib:Object = null; //not sure how to type this
		switch(_swapEasingFunctionName){
			case EASING_FUNC_BACK:
				easeLib = Back;
				break;
			case EASING_FUNC_BOUNCE:
				easeLib = Bounce;
				break;
			case EASING_FUNC_ELASTIC:
				easeLib = Elastic;
				break;
			case EASING_FUNC_NONE:
				easeLib = None;
				break;
			case EASING_FUNC_REGULAR:
				easeLib = Regular;
				break;
			case EASING_FUNC_STRONG:
				easeLib = Strong;
				break;
			default:
				easeLib = Regular;
				break;			
		}
		
		switch(_swapEasingType){
			case EASING_TYPE_NONE:
				return None.easeNone;			
			case EASING_TYPE_IN:
				return easeLib.easeIn;			
			case EASING_TYPE_OUT:
				return easeLib.easeOut;			
			case EASING_TYPE_IN_OUT:
				return easeLib.easeInOut;			
			default:
				return easeLib.easeInOut;			
		}
		
	}
	
	
	private function onCellRendererStartDrag(event:Object):Void{
		var renderer:DraggableRichTextCellRenderer = event.target;
		renderer.addEventListener(DraggableRichTextCellRenderer.STOP_DRAG_EVENT, _onCellRendererStopDragDelegate);
		renderer.addEventListener(DraggableRichTextCellRenderer.DRAG_EVENT, _onCellRendererDragDelegate);
		var containingRow:MovieClip = renderer._parent;
		//if anim still running on containing row, stop it.
		var swapTweenStillRunning:Tween = _swapTweens[containingRow];
		if(swapTweenStillRunning){
			swapTweenStillRunning.stop();
			_swapTweens[containingRow] = null;
		}
		//bring row containing dragged cell over all other rows. Find highest and swap depths with it.
		var highestRow:MovieClip = null;
		var highestRowDepth = -16383; //min depth. would be nice to have a constant for this?
		for(var i:Number = _rows.length; i--> 0;){
			var row:ListRow = _rows[i];
			var rowDepth:Number = row.getDepth();
			if(rowDepth > highestRowDepth){
				highestRow = row;
				highestRowDepth = rowDepth;
			}
		}
		if(highestRow && containingRow && (highestRow != containingRow)){
			containingRow.swapDepths(highestRow);
		}
//		var highestSibling:MovieClip = getInstanceAtDepth(
	}
	
	private function canPositionRow(row:ListRow):Boolean{
		var swapTweenStillRunning:Tween = _swapTweens[row];
		if(swapTweenStillRunning){
			return false;
		}else{
			return true;
		}
	}

	private function onCellRendererStopDrag(event:Object):Void{
		var renderer:DraggableRichTextCellRenderer = event.target;
		renderer.removeEventListener(DraggableRichTextCellRenderer.STOP_DRAG_EVENT, _onCellRendererStopDragDelegate);
		renderer.removeEventListener(DraggableRichTextCellRenderer.DRAG_EVENT, _onCellRendererDragDelegate);
		refreshRowsAndCells();
		dispatch({type:DraggableRichTextCellRenderer.STOP_DRAG_EVENT, target:this});
	}
	
	private function onSwapTweenFinished():Void{
		//sweep _swapTweens for old tween objects to unreference
		for(var key:String in _swapTweens){
			var tween:Tween = _swapTweens[key];
			if(tween.time == tween.duration){
				_swapTweens[key] = null;
			}
		}
	}
	
	private function onCellRendererDrag(event:Object):Void{
		var cell:DraggableRichTextCellRenderer = event.target;
		if(!cell){
			return;
		}
		var draggedCellItemIndex:Number = cell.getCellIndex().itemIndex;
		
		//limit the drag to the space in the list.
		//commented, doesn't work!
/*		if(draggedCellItemIndex == 0){
			//don't go above list
			if(cell.y < 0){
				cell.move(cell.x, 0);
			}
		}else if(draggedCellItemIndex == __dataProvider.length - 1){
			//don't go below list
			if(cell.y > 0){
				cell.move(cell.x, 0);
			}
		}
*/
		var cellToSwapWithIndex:Number = -1;
		if(!_isHorizontal){
			if((cell._y >= _fixedRowHeight  * 0.5) && (draggedCellItemIndex < __dataProvider.length - 1)){
				cellToSwapWithIndex = draggedCellItemIndex + 1;
			}else if((cell._y <=  - _fixedRowHeight  * 0.5)  && (draggedCellItemIndex > 0)){
				cellToSwapWithIndex = draggedCellItemIndex - 1;
			}
		}
		
		if(cellToSwapWithIndex > -1){
			//update model
			var draggedCellData:Object = __dataProvider[draggedCellItemIndex];
			__dataProvider[draggedCellItemIndex] = __dataProvider[cellToSwapWithIndex];
			__dataProvider[cellToSwapWithIndex] = draggedCellData;
			
			//update view. with one dimensional list, act directly on rows
			var rowToSwapWith:ListRow = _rows[cellToSwapWithIndex];
			var rowContainingDraggedCell:ListRow = _rows[draggedCellItemIndex];
			var yDiffForSwappedRow:Number = _fixedRowHeight * (draggedCellItemIndex - cellToSwapWithIndex);
			var swapTweenStillRunning:Tween = _swapTweens[rowToSwapWith];
			var newSwapTweenFinishVal:Number = rowToSwapWith._y + yDiffForSwappedRow;
			if(swapTweenStillRunning){
				newSwapTweenFinishVal += swapTweenStillRunning.finish - swapTweenStillRunning.position;
				swapTweenStillRunning.stop();
				
			}
			var swapTween:Tween = new Tween(rowToSwapWith, "_y", getSwapEasingFunction(), rowToSwapWith._y, newSwapTweenFinishVal, _swapDuration, true);
			swapTween.onMotionFinished = _onSwapTweenFinishedDelegate;
			_swapTweens[rowToSwapWith] = swapTween;
			rowContainingDraggedCell._y -= yDiffForSwappedRow;
			cell._y += yDiffForSwappedRow;
			
			//update rows in _rows array and their respective itemIndexes
			rowToSwapWith.itemIndex = draggedCellItemIndex;
			_rows[draggedCellItemIndex] = rowToSwapWith;
			rowContainingDraggedCell.itemIndex = cellToSwapWithIndex;
			_rows[cellToSwapWithIndex] = rowContainingDraggedCell;
			
			//update instance names. Not strictly necessary but useful to maintain relevant names. 
			//If we don't do it, we end up with 2 cells with the same data sometimes
			var tempName:String = rowToSwapWith._name;
			rowToSwapWith._name = rowContainingDraggedCell._name;
			rowContainingDraggedCell._name = tempName;
			//update swap tweens references
			var tempTween:Object = _swapTweens[rowToSwapWith];
			_swapTweens[rowToSwapWith] = _swapTweens[rowContainingDraggedCell];
			_swapTweens[rowContainingDraggedCell] = tempTween;
								
			dispatch({type:"change", target:this});
			
		}
		
		
	}
	
   /**
    * group: inspectable properties
    * */

	/**
	* property: swapDuration
	* */
	/** function set swapDuration
	* @param val(Number)
	* @returns void
	*/
	[Inspectable(name = "swap animation duration (s)", type = Number, defaultValue = 0.5)]
	public function set swapDuration(val:Number){
		_swapDuration = val;
	}

	/** function get swapDuration
	* @returns Number
	*/
	function get swapDuration():Number{
		return _swapDuration;
	}
	
	/**
	* property: swapEasingFunctionName
	* */
	/** function set swapEasingFunctionName
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name = "swap easing function", type = String)]
	public function set swapEasingFunctionName(val:String){
		//would be nice if it appeared as an enumeration in the property inspector, but I can't get it to work
		_swapEasingFunctionName = val;
	}

	/** function get swapEasingFunctionName
	* @returns String
	*/
	function get swapEasingFunctionName():String{
		return _swapEasingFunctionName;
	}
	
	/**
	* property: swapEasingType
	* */
	/** function set swapEasingType
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name = "swap easing type", type = String)]
	public function set swapEasingType(val:String){
		//would be nice if it appeared as an enumeration in the property inspector, but I can't get it to work
		_swapEasingType = val;
	}

	/** function get swapEasingType
	* @returns String
	*/
	function get swapEasingType():String{
		return _swapEasingType;
	}
	
	
	
}