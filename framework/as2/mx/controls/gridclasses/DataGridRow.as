//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.gridclasses.DataGridColumn;
import mx.controls.listclasses.SelectableRow;

class mx.controls.gridclasses.DataGridRow extends SelectableRow
{

	//::: Declarations

	var cells : Array; // references to all the cells in the row
	var owner : Object; // the grid
	var colBG : MovieClip; // the movieClip that hold the color for the column
	var text : String;
	var textHeight : Number;

	// here just to make the compiler quiet
	var columnIndex:Number;
	var listOwner:Object;
	var wasPressed : Boolean; // keep track if a press happened before editing a cell

	function DataGridRow()
	{
	}

	// don't call super - just make the background and the column color clip
	function createChildren(Void) : Void
	{
		setupBG();
		colBG = createEmptyMovieClip("colbG_mc", LOWEST_DEPTH+1);
	}

	// start an array for our cells
	function init(Void) : Void
	{
		super.init();
		cells = new Array();
	}


	function size(Void) : Void
	{
		// if we've gained or lost a column, clear and relayout
		if (cells.length!=owner.columns.length) {
			createCells();
		}
		// size the background / highlights
		super.size();
	}


	// to be used when the columns change (add/remove)... a future optimization would only
	// do the delta of the work, but for fileSize concerns, brute force it.
	function createCells(Void) : Void
	{
		// start fresh
		clearCells();

		// for editability
		backGround.onRelease = startEditCell;

		var len : Number = owner.columns.length;


		// cycle over columns, add a cell for each
		for (var i=0; i<len; i++) {
			var col : DataGridColumn = owner.columns[i];
			var cR = col.__cellRenderer;
			// if we have a cellRenderer defined for the column, use it
			if (cR!=undefined) {
				// decide if it's a LinkID or a class def
				if (typeof(cR)=="string")
					var cell = cells[i] = createObject(cR, "fCell"+i, 2+i, { styleName:col });
				else
					var cell = cells[i] = createClassObject(cR, "fCell"+i, 2+i, { styleName:col });
			} else {
				// since no cellRenderer is defined, we just use labels (which implement the cellRenderer API)
				var cell = cells[i] = createLabel("fCell"+i, 2+i);
				cell.styleName = col;
				// make the label look like a cell
				cell.selectable = false;
				cell.backGround = false;
				cell.border = false;
				cell._visible = false;
				cell.getPreferredHeight = cellGetPreferredHeight;
			}
			// give the cell info about where it is
			cell.listOwner = owner;
			cell.columnIndex = i;
			cell.owner = this;
			cell.getCellIndex = getCellIndex;
			cell.getDataLabel = getDataLabel;
		}
	}

	function cellGetPreferredHeight()
	{
		var oldText = this.text;
		this.text = "^g_p";
		this.draw();
		var tH = this.textHeight + 4;
		this.text = oldText;
		return tH;

	}

	//scoped to the cell - gives cellEditors a reference point (part of the cellRenderer API)
	function getCellIndex(Void) : Object
	{
		return {columnIndex:this.columnIndex, itemIndex:this.owner.rowIndex+this.listOwner.__vPosition};
	}

	//scoped to the cell - gives cellEditors a label for their field in a dataProvider item (part of the cellRenderer API)
	function getDataLabel() : String
	{
		return this.listOwner.columns[this.columnIndex].columnName;
	}

	// remove all cells
	function clearCells()
	{
		for (var i=0; i<cells.length; i++) {
			cells[i].removeTextField();
			cells[i].removeMovieClip();
		}
		cells.splice(0);
	}

	// handles putting the object field values in the cells.
	function setValue(itmObj, state, transition)
	{
		var colArray = owner.columns;
		var len = colArray.length;

		for (var i=0; i<len; i++) {
			var cell = cells[i];
			var col = colArray[i];
			// check if the column's labelFunction comes up with something
			var fieldVal = col.__labelFunction(itmObj);
			if (fieldVal==undefined)
				fieldVal = (itmObj instanceof XMLNode) ? itmObj.attributes[col.columnName] : itmObj[col.columnName];

			if (fieldVal==undefined) fieldVal = " ";
			// put the text in the cell
			cell.setValue(fieldVal, itmObj, state);
			// size and place the cell so it's centered vertically in the row
//			cell.setSize(col.__width-2, Math.min(__height, cell.getPreferredHeight()));
//			cell._y = (__height-cell._height)/2;
		}
	}

	// draw a background for this cell (for use in coloring the background of columns,
	// see grid.drawColumns for usage
	private function drawCell (cellNum, xPos, w, bgCol)
	{
		var cell = this.cells[cellNum];
		cell._x = xPos;
		cell._visible = true;
		cell.setSize(w-2, Math.min(__height, cell.getPreferredHeight()));
		if(cell.__height == undefined) {
			cell._y = (__height-cell._height)/2;
		}else{
			cell._y = (__height-cell.__height)/2;
		}
		if (bgCol!=undefined) {
			var x = Math.floor(xPos-2);
			var x2 = Math.floor(x+w);
			colBG.moveTo(x,0);
			colBG.beginFill(bgCol);
			colBG.lineStyle(0,0,0);
			colBG.lineTo(x2, 0);
			colBG.lineTo(x2, __height);
			colBG.lineTo(x, __height);
			colBG.endFill();
		}
	}

	// extended this method to color all cells' enabled/disabled/rollOver/selected color
	function setState(newState : String, transition : Boolean) : Void
	{
		var cols = owner.columns;
		var len = cols.length;
		if (newState!="normal" || !owner.enabled) {
			var colr;
			if (!owner.enabled) {
				colr = owner.getStyle("disabledColor");
			} else if (newState=="highlighted") {
				colr = owner.getStyle("textRollOverColor");
			} else if (newState=="selected") {
				colr = owner.getStyle("textSelectedColor");
			}
			for (var i=0; i<len; i++) {
				cells[i].setColor(colr);
				cells[i].__enabled = owner.enabled;
			}
		} else {
			for (var i=0; i<len; i++) {
				cells[i].setColor(cols[i].getStyle("color"));
				cells[i].__enabled = owner.enabled;
			}
		}
		super.setState(newState, transition);
	}


//::: EDITABILITY

	// scoped to the background - owner is the row
	// find the cell that needs editing on release of the row
	function startEditCell()
	{
		var grid = grandOwner;
		grid.dontEdit = true;
		grid.releaseFocus();
		delete grid.dontEdit;

		if (grid.enabled && grid.editable && owner.item!=undefined) {
			var len = owner.cells.length;
			for (var i=0; i<len; i++) {
				// search through all columns, find the one whose bounds the mouse is within
				var col = grid.columns[i];
				// assume this a non-editable col for now, and focus shouldn't start editing
				if (col.editable) {
					// if the column is editable, set focus to it.
					var delta = owner._xmouse - owner.cells[i]._x;
					if (delta>=0 && delta<col.__width) {

						var index = owner.rowIndex + grid.__vPosition;
						grid.setFocusedCell( { itemIndex : index, columnIndex : i }, true);

						// tricky business : all this focus work interrupts row selection, so if it's needed, fire the mouse clicks manually
						if (wasPressed!=true) {
							onPress();
							grid.onMouseUp();
						}
						delete wasPressed;
						// remove some grid functions around scrolling - we just want cell focus
						clearInterval(grid.dragScrolling);
						delete grid.onMouseUp;
						return;
					}
				}
			}
		}
	}

	function bGOnPress(Void) : Void
	{
		wasPressed = true;
		grandOwner.pressFocus();
		grandOwner.onRowPress(owner.rowIndex);
	}


	// route style changes to our cells
	function notifyStyleChangeInChildren(sheetName:String, styleProp:String, newValue):Void
	{
		var colArray = owner.columns;
		var len = cells.length;
		for (var i=0; i<len; i++) {
			var cell = cells[i];
			if (cell.stylecache != undefined)
			{
				delete cell.stylecache.tf;
			}
			delete cell.enabledColor;
			cell.invalidateStyle(styleProp);
		}
	}

}