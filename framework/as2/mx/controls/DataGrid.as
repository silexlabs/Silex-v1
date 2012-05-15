//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.gridclasses.DataGridColumn;
import mx.controls.gridclasses.DataGridRow;
import mx.controls.List;
import mx.effects.Tween;

[RequiresDataBinding(true)]
[IconFile("DataGrid.png")]
[InspectableList("multipleSelection","editable", "rowHeight")]
[DataBindingInfo("acceptedTypes","{dataProvider: &quot;String&quot;}")]

/**
* @tiptext Fired when a cell is pressed
* @helpid 3434
*/
[Event("cellPress")]
/**
* @tiptext Fired when a cell is edited
* @helpid 3435
*/
[Event("cellEdit")]
/**
* @tiptext Fired when a cell is focused
* @helpid 3436
*/
[Event("cellFocusIn")]
/**
* @tiptext Fired when a cell loses focus
* @helpid 3437
*/
[Event("cellFocusOut")]
/**
* @tiptext Fired when a column is stretched by the user
* @helpid 3438
*/
[Event("columnStretch")]
/**
* @tiptext Fired when a column header is clicked and then released by the user
* @helpid 3439
*/
[Event("headerRelease")]


/**
* DataGrid class
* - extends List
* @tiptext The DataGrid is a ListBox that can display more than one column.
* @helpid 3107
*/

class mx.controls.DataGrid extends List
{
	static var symbolOwner : Object = DataGrid;
	static var symbolName : String = "DataGrid";

	//#include "../core/ComponentVersion.as"

/**
* @private
* className for object
*/
	var className:String = "DataGrid";
	//::: Default values

/**
* @tiptext Determines whether the grid may be selected by the viewer.
* @helpid 3108
*/
	var selectable : Boolean = true;
/**
* @tiptext Determines whether the columns of the grid may be stretched by the viewer.
* @helpid 3109
*/
	var resizableColumns : Boolean = true;
	var __showHeaders : Boolean = true;
/**
* @tiptext Determines whether the columns of the DataGrid may be sorted by the viewer clicking on the headers.
* @helpid 3110
*/
	var sortableColumns : Boolean = true;

	var autoHScrollAble : Boolean = true;

    [Inspectable(defaultValue=false)]
	var editable : Boolean = false;
	var minColWidth : Number = 20;	// minimum width of a column
	var totColW : Number = 0;		// keep a running tally of the columns' total width
	var __rowRenderer : String = "DataGridRow";
	var __headerHeight : Number = 20;
	var hasDrawn : Boolean = false; // If the grid has finished its first drawing
	var minScrollInterval = 60; // slow down scrolling a little


	// ::: Constants for depths of assets
	// unless there are 5000 rows visible, this should hold.
	var HEADERDEPTH : Number = 5001;
	var LINEDEPTH : Number = 5000;
	var SORTARROWDEPTH : Number = 5500;
	var EDITORDEPTH : Number = 5002;
	var DISABLEDHEADERDEPTH : Number = 5003;
	var HEADERCELLDEPTH : Number = 4500;
	var HEADEROVERLAYDEPTH : Number = 4000;
	var SEPARATORDEPTH : Number = 5000;
	var STRETCHERDEPTH : Number = 1000;


	//::: Declarations

	var columns : Array; // the array of our DataGridColumns

	//::: Invalidation Flags. These control what action will be taken
	// in the "draw" method, after invalidation (see "function draw")
	var invInitHeaders : Boolean; // the header needs reinitializing
	var invDrawCols : Boolean;	// the columns need redrawing
	var invColChange : Boolean;	// the columns are different now (after an addColumn, etc).
	var invCheckCols : Boolean;	// the totColW might not be the same as the full display width
	var invSpaceColsEqually : Boolean; // the columns need to be equally spaced


	//:::Movie clip assets
	var lines_mc : MovieClip;		// the movie clip in which grid lines are drawn
	var header_mc : MovieClip;	// the container for the header assets
	var sortArrow : MovieClip;	// the arrow in the header that shows sort direction
	var cellEditor : MovieClip;		// usually an input field used for editing cells. Could also be custom.
	var editorMask : MovieClip; 	// cosmetic - a mask to sweep in the cellEditor
	var stretcher : MovieClip;		// the arrow cursor for stretching
	var stretchBar : MovieClip;	// the black/white lines for showing column stretch locations

	// ::: Storage Vars
	var sortIndex : Number;		// the index of the column being sorted on
	var sortDirection : String;		// the direction of that sort

	var headerCells : Array;		// the cells in the header
	var colX : Number;			// a tmp var to store the stretching col's X coord
	var oldWidth : Number;		// the last width - used to calc new column widths
	var editTween : Tween;		// a tween used to wipe the editorMask
	var __tabHandlerCache : Function;	// a place to store FocusManager's tabHandler before reassignment
	var dontEdit : Boolean;		// a flag to ensure that focus doesn't trigger editing.
	var __focusedCell : Object;	// storage for the focusedCell object

	// scoping tricks to quiet the compiler
	var column:DataGridColumn;
	var cell:Object;
	var asc:Boolean;
	var col:Object;
	var oldX:Number;
	var listOwner:Object;
	var activeGrid:Object;

	function DataGrid()
	{
	}


	function init()
	{
		super.init();
		invInitHeaders = true;
		columns = new Array();
	}



	//::: METHODS INHERITED FROM LIST


	/**
	* inherited from list - used to layout the rows inside the list
	* Here we extend it to accomodate the headerHeight, and to ensure that
	* if the width has changed, we draw more header background
	**/
	function layoutContent(x:Number,y:Number,tW:Number,tH:Number,dW:Number,dH:Number) : Void
	{
		var r = __rowCount;
		if (__showHeaders) {
			y+=__headerHeight;
			dH-=__headerHeight;
		}
		super.layoutContent(x,y,tW,tH,dW,dH);
		if (tW!=totColW) {
			drawHeaderBG();
		}
		if (__rowCount>r) {
			invDrawCols = true;
			invalidate();
		}
	}


	/**
	* inherited from list - used to layout a specific number of rows
	* Here we extend it to accomodate the headerHeight
	**/
	function setRowCount(rC:Number) : Void
	{
		if (isNaN(rC)) return;
		var o : Object = getViewMetrics();
		setSize(__width, __rowHeight*rC + o.top + o.bottom + __headerHeight*Number(__showHeaders));
	}

	function setRowHeight(rH:Number) : Void
	{
		__rowHeight = rH;
		if (hasDrawn) {
			super.setRowHeight(rH);
		}
	}


	/**
	* inherited from list - we're able to accomodate "auto" now.
	* extend it to make sure column widths stay in synch
	**/
	function setHScrollPolicy(policy:String) : Void
	{
		super.setHScrollPolicy(policy);
		invCheckCols = true;
		invalidate();
	}

	// inherited from list
	function setEnabled(v : Boolean) : Void
	{
		if (v==enabled) return;
		super.setEnabled(v);
		// enable/disable headers
		if (__showHeaders)
			enableHeader(v);
		// kill any active editor
		if (cellEditor._visible == true)
			disposeEditor();
		// make sure column backgrounds are drawn disabled
		invDrawCols = true;
		invalidate();
	}


	/**
	* inherited from list - catch any events from the model (see dataProvider spec)
	* optimize for editing one cell - also generateCols in cases where there are none.
	**/
	function modelChanged(eventObj:Object) : Void
	{
		if (eventObj.eventName == "updateField") {
			var index : Number = eventObj.firstItem;
			var itm : Object = __dataProvider.getItemAt(index);
			rows[index-__vPosition].drawRow(itm, getStateAt(index));
			return;
		} else if (eventObj.eventName == "schemaLoaded") {
			removeAllColumns();
		}
		if (columns.length==0) {
			generateCols();
		}
		super.modelChanged(eventObj);
	}


	// inherited from list - determine how to set up our srollbars
	function configureScrolling(Void) : Void
	{
		var o : Object = getViewMetrics();
		// the total viewable width
		var vWidth : Number = ( __hScrollPolicy!="off" ) ? __maxHPosition + __width - o.left - o.right : __width - o.left - o.right;

		var len : Number = __dataProvider.length;
		if (len==undefined) len = 0;
		if (__vPosition>Math.max(0,len-getRowCount()+roundUp)) {
			setVPosition( Math.max(0,Math.min(len-getRowCount()+roundUp, __vPosition)) );
		}

		// tell the scrollBars what to do, taking the headers into account
		setScrollProperties(vWidth, 1, len, __rowHeight, __headerHeight*Number(__showHeaders));
		if (oldVWidth!=vWidth)  {
			// redraw the rows at the right horiz size
			invLayoutContent = true;
		}
		oldVWidth = vWidth;
	}


	function setVPosition(pos:Number) : Void
	{
		if (cellEditor!=undefined) {
			disposeEditor();
		}
		super.setVPosition(pos);
	}


	// inherited from list
	function size(Void) : Void
	{

		if (hasDrawn!=true) {
			border_mc.setSize(__width, __height);
			return;
		}
		if (cellEditor!=undefined) {
			disposeEditor();
		}

		// calculate our max h pos based on column widths
		if (__hScrollPolicy!="off") {
			var totW : Number = 0;
			var len : Number = columns.length;
			for (var i=0; i<len; i++) {
				totW+=columns[i].__width;
			}
			var o = getViewMetrics();
			var disW = __width-o.left-o.right;
			setMaxHPosition(Math.max(totW-disW, 0));
			var d : Number = disW-totW;
			//fill in any extra space
			if (d > 0) {
				columns[len-1].__width += d;
			}
			//make sure we're within bounds
			setHPosition(Math.min(getMaxHPosition(), getHPosition()));
		}

		super.size();

		if (__hScrollPolicy=="off") {
			// redistribute the column widths proportionally
			var p : Array = new Array();
			var len : Number = columns.length;
			if (oldWidth==undefined) {
				oldWidth = displayWidth;
			}
			var tot : Number = 0;
			for (var i=0; i<len; i++) {
				tot += columns[i].__width = displayWidth * columns[i].__width / oldWidth;
			}
			if (tot!=displayWidth) {
				columns[columns.length-1].__width += displayWidth-tot;
			}
			totColW = numberOfCols = displayWidth;
		}

		oldWidth = displayWidth;
		// redraw what we need (right now, for better runtime sizing responsiveness)
		drawColumns();
		drawHeaderBG();
		invalidate();
	}


	/**
	* inherited from list - the most important method in the component. draw basically dispatches all
	* scheduled drawing work in the right sequence to get a properly rendered grid. Don't mess with the order!
	**/
	function draw()
	{
		// a rowHeight has changed. very expensive. running super.draw in here eats most of the
		// invalidation flags so by the next super.draw (below), there shouldn't be much work done.
		if (invRowHeight) {
			super.draw();
			// we need new headers
			invInitHeaders = true;
			// we need to redraw the columns (rowHeight disposes most everything);
			invDrawCols = true;
			delete cellEditor;
		}
		// draw new headers
		if (invInitHeaders) {
			initHeaders();
			// new headers often means a smaller drawing area for rows
			invLayoutContent = true;
		}
		// do all of list's drawing.
		super.draw();

		// if a dataProvider got set, it calls this to space columns after all is said
		if (invSpaceColsEqually) {
			delete invSpaceColsEqually;
			spaceColumnsEqually();
		}

		// a column has been added or removed.
		if (invColChange) {
			delete invColChange;
			if (hasDrawn) {
				// fix up the headers (may be redundant but it's unlikely to be so, cheap, and  necessary);
				initHeaders();
				// reset all the rows. Expensive! Possible optimization if we had bandwidth to spare
				initRows();
				// make sure to redraw the columns, below
				invDrawCols = true;
				// draw rows' content. Also expensive
				updateControl();
				// check the columns for over/underflow, below
				invCheckCols = true;
			}
		}

		// check to make sure columns aren't over/underflowing the view area
		if (invCheckCols) {
			if (totColW!=displayWidth) {
				// this'll take care of it!
				resizeColumn(columns.length-1, columns[columns.length-1].__width);
			}
			delete invCheckCols;
		}
		// column backgrounds and lines + header cell positions need updating
		if (invDrawCols) {
			drawColumns();
		}
		// some methods only take action if we've been through a draw cycle
		hasDrawn = true;
	}



	//::: DATA MANAGEMENT

/**
* @tiptext Edits a given field in the dataGrid
* @param index the index of the item to edit
* @param colName the name of the field to edit
* @param data the new data to put in the edited field
* @helpid 3440
*/
	function editField(index:Number, colName:String, data) : Void
	{
		__dataProvider.editField(index, colName, data);
	}




	//::: COLUMN MANAGEMENT


/**
* @tiptext The set of field names that will be displayed as columns.
* @helpid 3113
*/
	function get columnNames() : Array
	{
		return getColumnNames();
	}

	function set columnNames(w:Array)
	{
		setColumnNames(w);
	}


	function setColumnNames(tmpArray:Array) : Void
	{
		for (var i=0; i<tmpArray.length; i++) {
			addColumn(tmpArray[i]);
		}

	}

	function getColumnNames(Void) : Array
	{
		var tmpArray : Array = new Array();
		for (var i=0; i<columns.length; i++) {
			tmpArray[i] = columns[i].columnName;
		}
		return tmpArray;
	}



/**
* @tiptext Add a new column at the specified position in the DataGrid.
* @param index The index for the new column
* @param newCol The string name of the new column, or a DataGridColumn
* @return the new column
* @helpid 3114
*/
 	function addColumnAt(index:Number,newCol) : DataGridColumn
	{
		if (index<columns.length) {
			columns.splice(index, 0, "tmp");
		}
		var theCol = newCol;
		if (!(theCol instanceof DataGridColumn)) {
			theCol = new DataGridColumn(theCol);
		}
		columns[index] = theCol;
		theCol.colNum = index;
		// increment all right side columns' colNums
		for (var i=index+1; i<columns.length; i++) {
			columns[i].colNum++;
		}
		theCol.parentGrid = this;
		// keep a running tally of column widths
		totColW += theCol.width;

		// at draw time, deal with the fact a column was added
		invColChange = true;
		invalidate();
		return newCol;
	}

/**
* @tiptext Adds a new column to the end of the DataGrid.
* @param newCol The string name of the new column, or a DataGridColumn
* @return the new column
* @helpid 3115
*/
	function addColumn(newCol) : DataGridColumn
	{
		return addColumnAt(columns.length, newCol);
	}

/**
* @tiptext Removes the DataGridColumn instance at the given index.
* @param index The index of the column to remove
* @return the removed column
* @helpid 3116
*/
	function removeColumnAt(index:Number) : DataGridColumn
	{
		var tmp : DataGridColumn = columns[index];
		columns.splice(index,1);

		// keep the tally up to date
		totColW -= tmp.width;
		// decrement colNums to the right
		for (var i=index; i<columns.length; i++) {
			columns[i].colNum--;
		}
		// deal with rerendering at draw time
		invColChange = true;
		invalidate();
		return tmp;
	}

/**
* @tiptext Removes all DataGridColumns from the target DataGrid instance.
* @helpid 3117
*/
	function removeAllColumns(Void) : Void
	{
		totColW = 0;
		columns = new Array();
		// deal with rerendering at draw time
		invColChange = true;
		invalidate();
	}

/**
* @tiptext Gets the DataGridColumn instance at the given index.
* @param index the index of the column to retrieve
* @return the column
* @helpid 3118
*/
	function getColumnAt(index : Number) : DataGridColumn
	{
		return columns[index];
	}

/**
* @tiptext Gets the index of the DataGridColumn instance with the given name.
* @param name the name of the column whose index is desired
* @return the column index
* @helpid 3119
*/
	function getColumnIndex(name:String) : Number
	{
		for (var i=0; i<columns.length; i++) {
			if (columns[i].columnName==name) {
				return i;
			}
		}
	}


/**
* @tiptext The number of columns that are displayed.
* @helpid 3120
*/
	function get columnCount() : Number
	{
		return columns.length;
	}


/**
* @tiptext Reformat the grid so that columns are all the same size.
* @helpid 3121
*/
	function spaceColumnsEqually(Void) : Void
	{
		// Only to be used in hScrollPolicy="off"
		if (displayWidth == undefined) {
			// figure out the space we have
			var o : Object = getViewMetrics();
			displayWidth = __width-o.left-o.right;
		}

		var w : Number = Math.ceil(totalWidth / columns.length);
		for (var i=0; i<columns.length; i++) {
			// just set the numbers (__width) to avoid redraws
			columns[i].__width = w;
		}
		// update the tally
		totColW = totalWidth;
		// draw the columns later
		invDrawCols = true;
		invalidate();
	}


	// searches the dataProvider to determine columns
	function generateCols(Void) : Void
	{
		if (columns.length==0) {
			var cols : Array = __dataProvider.getColumnNames();
			if (cols==undefined) {
				// introspect the first item and use its fields
				var itmObj : Object = __dataProvider.getItemAt(0);
				for (var i in itmObj) {
					if (i!="__ID__") {
						addColumn(i);
					}
				}
			} else {
				// this is an old recordset - use its columns
				for (var i=0; i<cols.length; i++) {
					addColumn(cols[i]);
				}
			}
			// trigger a big ol' draw
			invSpaceColsEqually = true;
			invColChange = true;
			invCheckCols = true;
			invalidate();
		}
	}


	/**
	* If no hScrollBar, handles the compacting of other columns when a column has been set
	* to a specific size. Doesn't move anything, just calculates widths..
	* In the case of an hScrollBar, set a new maxHPosition
	**/
	function resizeColumn(col:Number, w:Number) : Void
	{
		// hScrollBar is present
		if (__hScrollPolicy=="on" || __hScrollPolicy=="auto") {

			// adjust the column's width
			columns[col].__width = w;
			// figure out our new size
			var totW : Number = 0;
			var len :Number = columns.length;
			for (var i=0; i<len; i++) {
				totW+=columns[i].__width;
			}
			// adjust the scrollBars
			setMaxHPosition(Math.max(totW-displayWidth, 0));
			var d : Number = displayWidth-totW;
			if (d > 0) {
				// compensate for underflow
				columns[len-1].__width += d;
			}
			// scroll back if we're out of bounds
			setHPosition(Math.min(getMaxHPosition(), getHPosition()));

			// draw the results later and get out
			invDrawCols = true;
			invalidate();
			return;
		}

		// hScrollBar isn't present.. this is more complicated
		// find the x pos of the column that changed
		var startX : Number = 0;
		for (var i=0; i<col; i++) {
			startX += columns[i].__width;
		}

		// we want all cols's new widths to the right of this to be in proportion
		// to what they were before the stretch.

		// get the original space to the right not taken up by the column
		var origSpace : Number = displayWidth + 2 - startX - columns[col].__width;

		// get the new space to the right not taken up by the column
		var newSpace : Number = displayWidth + 2 - startX - w;

		columns[col].__width = w;

		var len : Number = columns.length;
		//non-resizable columns don't count though
		for (var i=col+1; i<len; i++) {
			if (!columns[i].resizable) {
				newSpace-=columns[i].__width;
				origSpace-=columns[i].__width;
			}
		}

		var totX : Number = 0;
		// resize the columns to the right proportionally to what they were
		for (var i=col+1; i<len; i++) {
			if (columns[i].resizable) {
				columns[i].__width = columns[i].width * newSpace / origSpace;
				totX+=columns[i].__width;
			}
		}

		var overFlow : Number = 0;
		var filled : Boolean = false;
		// now it gets tricky. Go backwards from the rightmost column,
		// Deal with overflow/underflow/unusably small columns
		for (var i=len-1; i>=0; i--) {
			if (columns[i].resizable) {
				if (!filled) {
					// underflow - make sure the last column fills in the whole space it's got
					columns[i].__width += newSpace-totX;
					filled = true;
				}
				if (overFlow>0) {
					// overflow - if there's space that needs redistributing, shrink
					// columns when possible
					columns[i].__width-=overFlow;
					overFlow=0;
				}
				if (columns[i].__width<minColWidth) {
					// unusably small column - make the col's width minColW
					// and increase the buffer of width to be taken from other cols
					overFlow += minColWidth-columns[i].__width;
					columns[i].__width=minColWidth;
				}
			}
		}
		// redraw the columns later
		invDrawCols = true;
		invalidate();
	}



	// to be used any time the columns change width. Positions the cells, draws columns and lines.
	function drawColumns(Void) : Void
	{
		delete invDrawCols;
		var lines = lines_mc = listContent.createEmptyMovieClip("lines_mc", LINEDEPTH);

		var x : Number = 0.75; // start point for drawing v lines
		var oldX : Number = 1;
		var tmpHeight : Number = height - 1;
		var lineCol : Number = getStyle("vGridLineColor");
		var len : Number = columns.length;

		placeSortArrow();

		// traverse the columns, set the sizes, draw the column backgrounds
		for (var i=0; i<len; i++) {
			var col : DataGridColumn = columns[i];
			var prop : String = (enabled) ? "backgroundColor" : "backgroundDisabledColor";
			var bgCol : Number = col.getStyle(prop);
			x+=col.__width;

			//draw our vertical lines
			lines.moveTo(oldX,1);
			lines.lineStyle(0,lineCol,0);

			// prevent weird aliasing with floor
			var tmpX : Number = Math.floor(x);
			lines.lineTo(tmpX,1);

			if (i<columns.length-1 && getStyle("vGridLines")) {
				lines.lineStyle(0,lineCol,100);
			}
			lines.lineTo(tmpX,height);
			lines.lineStyle(0,lineCol,0);
			lines.lineTo(oldX, height);
			lines.lineTo(oldX,1);


			// position the header cells
			if (__showHeaders) {
				var cell = headerCells[i];
				cell._x = oldX + 2;
				// the press/rollOver overlay for the header cells
				cell.hO._x = oldX;
				cell.setSize(col.__width-5, Math.min(__headerHeight, cell.getPreferredHeight()));
				cell.hO._width = col.__width-2;
				cell.hO._height = __headerHeight;
				cell._y = (__headerHeight-cell._height) /2;
				// position the header separator
				header_mc["sep"+i]._x = x-2;
				// in case we're disabled, position the disable overlay as well
				listContent.disableHeader._width = totalWidth;
			}

			// go through the rows, ask them to add column backgrounds
			for (var j=0; j<__rowCount; j++) {
				if (i==0) {
					rows[j].colBG.clear();
				}
				var w : Number = col.__width;
				// draw the background for this col
				rows[j].drawCell(i, oldX, w, bgCol);
			}
			oldX = x;
		}

		// after that's all done, draw hGridlines if needed.
		if (getStyle("hGridLines")) {
			lines_mc.lineStyle(0, getStyle("hGridLineColor"));
			for (var i=1; i<__rowCount; i++) {
				lines_mc.moveTo(4, rows[i]._y);
				lines_mc.lineTo(totalWidth, rows[i]._y);
			}
		}

	}


	// ::: ROW MANAGEMENT

	// creates the rows' cells
	function initRows(Void) : Void
	{
		for (var i=0; i<__rowCount; i++) {
			rows[i].createCells();
		}
	}

	// catch events from the rows being pressed
	function onRowPress(rowIndex:Number) : Void
	{
		super.onRowPress(rowIndex);

		if (!enabled) return;
		var len : Number = columns.length;
		var row = rows[rowIndex];
		// fire cellPress event
		for (var i=0; i<len; i++) {
			var col : DataGridColumn = columns[i];
			var delta : Number = row._xmouse - row.cells[i]._x;
			if (delta>=0 && delta<col.__width) {
				dispatchEvent({type:"cellPress", columnIndex: i, view: this, itemIndex: rowIndex + __vPosition});
				return;
			}
		}
	}




	//::: COLUMN HEADER METHODS


/**
* @tiptext Determines whether the grid will show the column headers or not.
* @helpid 3111
*/
	function get showHeaders() : Boolean
	{
		return getShowHeaders();
	}

	function set showHeaders(w:Boolean)
	{
		setShowHeaders(w);
	}

	function setShowHeaders(b:Boolean) : Void
	{
		__showHeaders = b;
		// draw the results later
		invInitHeaders = true;
		invDrawCols = true;
		invalidate();
	}

	function getShowHeaders() : Boolean
	{
		return __showHeaders;
	}


/**
* @tiptext Specifies the height of the header bar of the grid.
* @helpid 3112
*/
	function get headerHeight() : Number
	{
		return getHeaderHeight();
	}

	function set headerHeight(w : Number)
	{
		setHeaderHeight(w);
	}

	function setHeaderHeight(h:Number) : Void
	{
		__headerHeight=h;
		// draw the results later
		invInitHeaders = true;
		invDrawCols = true;
		invalidate();
	}

	function getHeaderHeight(Void) : Number
	{
		return __headerHeight;
	}


	/**
	* lays out the header assets. Note the backGround is done later
	**/
	function initHeaders(Void) : Void
	{
		delete invInitHeaders;

		if (__showHeaders) {
			header_mc = listContent.createClassObject(mx.core.UIObject, "header_mc", HEADERDEPTH, {styleName:this});
			headerCells = new Array();
			for (var i=0; i<columns.length; i++) {
				var col : DataGridColumn = columns[i];
				var cell;
				var hR = col.__headerRenderer;
				if (hR==undefined) {
					// make a textField as cell
					cell = headerCells[i] = header_mc.createLabel("fHeaderCell"+i, HEADERCELLDEPTH+i);
					cell.selectable = false;
					cell.setStyle("styleName", col);
				} else {
					// use a headerRenderer
					if (typeof(hR)=="string")
						cell = headerCells[i] = header_mc.createObject(hR, "fHeaderCell"+i, HEADERCELLDEPTH+i, {styleName:col});
					else
						cell = headerCells[i] = header_mc.createClassObject(hR, "fHeaderCell"+i, HEADERCELLDEPTH+i, {styleName:col});
				}
				// give it text
				cell.setValue(col.headerText);
				// link the column to it
				col.headerCell = cell;
				// add a rollOver / press overlay
				var hO : MovieClip = header_mc.attachMovie("DataHeaderOverlay", "hO"+i, HEADEROVERLAYDEPTH+i);
				// link it to the cell, and vice-versa (for when the overlay gets pressed/released)
				cell.hO = hO;
				hO.cell = cell;
				// give the cell and overlay all the state info they need
				cell.column = hO.column = col;
				cell.asc = hO.asc = false;
				cell.owner = hO.owner = this;
				hO._alpha = 0;

				if (hO.column.sortable && hO.onPress==undefined) {
					// set up mouse events for the overlay
					hO.useHandCursor = false;
					hO.onRollOver = headerRollOver;
					hO.onRollOut = headerRollOut;
					hO.onPress = headerPress;
					hO.onRelease = headerRelease;
					hO.onReleaseOutside = headerUp;
					hO.headerUp = headerUp;
				}
				if (i<columns.length-1) {
					// add separators
					var sep : MovieClip = header_mc.attachMovie("DataHeaderSeperator", "sep"+i, SEPARATORDEPTH+i);
					sep._height = __headerHeight;
					if (col.resizable && resizableColumns) {
						// set up events for the separator (for stretching columns with them)
						sep.useHandCursor = false;
						sep.col = i;
						sep.owner = this;
						sep.onRollOver = showStretcher;
						sep.onPress = startSizing;
						sep.onRelease = sep.onReleaseOutside = stopSizing;
						sep.onRollOut = hideStretcher;
					}
				}
			}
			// draw the background
			drawHeaderBG();
		} else {
			header_mc.removeMovieClip();
		}
	}

	// makes all header cells take on their new style props
	function invalidateHeaderStyle(Void) : Void
	{
		var len : Number = columns.length;
		for(var i=0; i<len; i++) {
			var cell = headerCells[i];
			if (cell.stylecache != undefined)
			{
				delete cell.stylecache.tf;
			}
			delete cell.enabledColor;
			cell.invalidateStyle();
			cell.draw();
		}
	}

	// pretty self-explanatory. Use Drawing API
	function drawHeaderBG(Void) : Void
	{
		var mc : MovieClip = header_mc;
		mc.clear();
		var clr : Number = getStyle("headerColor");
		var o : Object = __viewMetrics;
		var tot : Number = Math.max(totalWidth, displayWidth+3);
		mc.moveTo(o.left,o.top);
		var matrix : Object = { matrixType : "box", x:0, y:0, w:tot, h:__headerHeight+1, r:Math.PI/2 };
		var colors : Array = [clr, clr, 0xffffff];
		var ratios : Array = [0, 60, 255];
		var alphas : Array = [100, 100, 100];
		mc.beginGradientFill("linear", colors, alphas, ratios, matrix);

		mc.lineStyle(0, 0x000000, 0);
		mc.lineTo(tot, o.top);
		mc.lineTo(tot, __headerHeight+1);
		mc.lineStyle(0, 0x000000, 100);
		mc.lineTo(o.left, __headerHeight+1);
		mc.lineStyle(0, 0x000000, 0);
		mc.endFill();
	}


	// place movie clip over the headers to disable them
	function enableHeader(v:Boolean) : Void
	{
		if (v) {
			listContent.disableHeader.removeMovieClip();
		} else {
			var disableHeader : MovieClip = listContent.attachMovie("DataHeaderOverlay", "disableHeader", DISABLEDHEADERDEPTH);
			disableHeader._width = totalWidth;
			disableHeader._height = __headerHeight;
			var c = new Color(disableHeader);
			c.setRGB(getStyle("backgroundDisabledColor"));
			disableHeader._alpha = 60;
		}
	}


	// does what you'd think...
	function placeSortArrow(Void) : Void
	{
		sortArrow.removeMovieClip();
		// if no column is being sorted on, return
		if (sortIndex==undefined) return;
		if (columns[sortIndex].__width - headerCells[sortIndex].getPreferredWidth()<= 20) return;

		sortArrow = header_mc.createObject("DataSortArrow", "sortArrow", SORTARROWDEPTH);
		var x : Number = layoutX;
		for (var i=0; i<=sortIndex; i++) {
			x += columns[i].__width;
		}
		var d = (sortDirection=="ASC") ;
		sortArrow._yscale = (d) ? -100 : 100;
		sortArrow._x = x - sortArrow._width - 8;

		sortArrow._y = (__headerHeight - sortArrow._height) / 2 + (d*sortArrow._height);
	}



	// ::: BEGIN METHODS SCOPED TO THE HEADER'S OVERLAY - OWNER IS GRID

	// scoped to overlay : draw the overlay with color
	function headerRollOver(Void) : Void
	{
		var o = this.owner; // the grid
		if (!o.enabled || o.cellEditor!=undefined || !o.sortableColumns || !this.column.sortable) return;
		var c = new Color(this);
		c.setRGB(o.getStyle("rollOverColor"));
		_alpha = 50;
	}

	// scoped to overlay : turn off the overlay color
	function headerRollOut(Void) : Void
	{
		_alpha = 0;
	}

	// scoped to overlay : Color the overlay, move the cell
	function headerPress(Void) : Void
	{
		var o = this.owner; // the grid
		if (!this.column.sortable || !o.sortableColumns || !o.enabled) return;
		this.cell._x+=1;
		this.cell._y+=1;
		var c = new Color(this);
		c.setRGB(o.getStyle("selectionColor"));
		_alpha = 100;

	}

	// scoped to overlay : turn off the overlay color, move the cell back
	function headerUp(Void) : Void
	{
		if (!this.column.sortable || !this.owner.sortableColumns || !this.owner.enabled) return;
		_alpha = 0;
		this.cell._x-=1;
		this.cell._y-=1;

	}

	// scoped to overlay : Do the sort!
	function headerRelease(Void) : Void
	{
		var o = this.owner; // the grid
		var c : DataGridColumn = this.column;
		if (!c.sortable || !o.sortableColumns || !o.enabled) return;

		headerUp();
		this.asc = !this.asc;
		var dir : String = (this.asc) ? "ASC" : "DESC";

		// set the grid's sortIndex
		o.sortIndex = o.getColumnIndex(c.columnName);
		o.sortDirection = dir;

		o.placeSortArrow();
		// do the sort if we're allowed to
		if (c.sortOnHeaderRelease) {
			o.sortItemsBy(c.columnName, dir);
		}
		// dispatch the event
		o.dispatchEvent({type:"headerRelease", view: o, columnIndex: o.getColumnIndex(c.columnName)});
		o.dontEdit = true;
	}
	//::: END METHODS SCOPED TO HEADER OVERLAY



	//::: METHODS FOR STRETCHABLE COLUMNS :::


	// determine if a column is stretchable
	function isStretchable(col:Number) : Boolean
	{
		var b = true;
		if (!resizableColumns) {
			b = false;
		} else if (!columns[col].resizable) {
			b = false;
		} else if (col==columns.length-2 && !columns[col+1].resizable) {
			b = false;
		}
		return b;
	}



	//::: BEGIN METHODS SCOPED TO THE HEADER'S SEPARATOR


	//scoped to header seperator - shows the stretcher mouse cursor
	function showStretcher(Void) : Void
	{
		var o = this.owner; // the grid
		if (!o.isStretchable(this.col) || !o.enabled || o.cellEditor!=undefined) {
			return;
		}
		// hide the mouse, attach and show the cursor
		Mouse.hide();
		if (o.stretcher==undefined) {
			o.attachMovie("cursorStretch", "stretcher", o.STRETCHERDEPTH);
		}
		// place the cursor at the mouse
		o.stretcher._x = o._xmouse;
		o.stretcher._y = o._ymouse;
		o.stretcher._visible = true;

		// add a mouseMove to the grid to get the cursor to follow the mouse
		o.onMouseMove = function()
		{
			this.stretcher._x = this._xmouse;
			this.stretcher._y = this._ymouse;
			updateAfterEvent();
		};
	}

	/**
	*scoped to header seperator - shows the stretchBar that indicates where
	* a column stretch will leave the column's right side
	**/
	function startSizing(Void) : Void
	{
		var o = this.owner; // the grid
		if (!o.isStretchable(this.col) || !o.enabled) {
			return;
		}
		o.pressFocus();
		// make the bar, synch to the mouse
		o.attachMovie("DataStretchBar", "stretchBar", 999);
		o.stretchBar._height = o.height;
		o.stretchBar._x = o._xmouse;
		// store the original X for the right hand side of the column
		// we'll use it later to get the column width difference
		this.oldX = o.stretchBar._x;
		o.colX = this.oldX - o.columns[this.col].width;
		// keep the bar in synch with the mouse
		o.onMouseMove = function()
		{
			this.stretcher._x = this._xmouse;
			this.stretcher._y = this._ymouse;
			this.stretchBar._x = Math.max(this._xmouse, this.colX + this.minColWidth);
			// restrict the movement of the bar if no hScroller
			if (this.__hScrollPolicy=="off")
				this.stretchBar._x = Math.min(this.stretchBar._x, this.displayWidth-this.minColWidth);
			updateAfterEvent();

		};
	}

	/**
	*scoped to header seperator - releases the stretchBar, determines
	* how much to resize the column.
	**/
	function stopSizing(Void) : Void
	{
		var o = this.owner; // the grid
		var c = this.col; // column index of the separator
		if (!o.isStretchable(c) || !o.enabled) {
			return;
		}
		// kill the bar and cursor
		o.stretchBar._visible = false;
		onRollOut();
		// resize the column
		var widthChange = o.stretchBar._x - this.oldX;
		o.resizeColumn(c, o.columns[c].width+widthChange);
		// event
		o.dispatchEvent({type:"columnStretch", columnIndex:c});

	}

	// scoped to the header separator - get rid of the cursor and any mouseMove listening
	function hideStretcher(Void) : Void
	{
		this.owner.stretcher._visible = false;
		delete this.owner.onMouseMove;
		Mouse.show();
	}

	//::: END METHODS SCOPED TO THE HEADER SEPARATOR


// ::: EDITABILITY CODE FOR DataGrid

/**
* @tiptext Defines (or returns) the cell currently in focus.
* @helpid 3123
*/
	function set focusedCell(obj: Object)
	{
		setFocusedCell(obj);
	}

	function get focusedCell() : Object
	{
		return __focusedCell;
	}

	// focus a cell in the grid - harder than it looks
	function setFocusedCell(coord:Object, broadCast) : Void
	{
		if (!enabled || !editable) return;

		// allow setting of undefined to dispose cell editor
		if (coord==undefined && cellEditor!=undefined) {
			disposeEditor();
			return;
		}
		// get all details for the cell to be focused.
		var index : Number = coord.itemIndex;
		var colIdx : Number = coord.columnIndex;
		if (index==undefined) index = 0;
		if (colIdx==undefined) colIdx = 0;
		var colName :String = columns[colIdx].columnName;



		// scroll so the cell is in view
		if (__vPosition>index) {
			setVPosition(index);
		} else {
			var delt = index-__vPosition-__rowCount+roundUp+1;
			if (delt>0) {
				setVPosition(__vPosition+delt);
			}
		}

		// get the actual references for the column, row, and cell
		var col : DataGridColumn = columns[colIdx];
		var row : DataGridRow = rows[index-__vPosition];
		var cell = row.cells[colIdx];

		// scroll so the cell is in view (cont'd)
		if (cell._x>__hPosition+displayWidth || cell._x<__hPosition) {
			setHPosition(cell._x);
		}


		// try to get the right data for editing
		var editText = __dataProvider.getEditingData(index, colName);
		if (editText==undefined)
			editText = __dataProvider.getItemAt(index)[colName];
		if (editText==undefined)
			editText=" ";

		// isCellEditor is part of the cellRenderer interface. It allows the cell itself to do the editing
		if (cell.isCellEditor!=true) {
			// if this isn't implemented, use an input control as editor
			if (cellEditor==undefined) {
				cellEditor = listContent.createClassObject(mx.controls.TextInput, "editor_mc", EDITORDEPTH, {styleName:col, listOwner:this});
			}
			// give it the right size, look and placement
			cellEditor.backgroundColor = 0xffffff;
			cellEditor._visible = true;
			cellEditor.setSize(col.__width, __rowHeight+2);
			cellEditor._x = cell._x-1;
			cellEditor.text = editText;

			// set up a mask for our cute little wipe effect for the editor
			editorMask = listContent.attachMovie("BoundingBox", "editorMask", 60001, {_alpha:0});
			cellEditor.setMask(editorMask);
			editorMask._width = cellEditor.width;
			editorMask._height = cellEditor.height;
			editorMask._y = cellEditor._y = row._y-1;
			editorMask._x = cellEditor._x-editorMask._width;
			// start the wipe - see onTweenUpdate/end for the results
			editTween = new mx.effects.Tween(this, cellEditor._x-editorMask._width, cellEditor._x, 150);

		} else {
			// if the cell is a cellEditor, we'll use it
			cellEditor = cell;
			cellEditor.setValue(editText, __dataProvider.getItemAt(index));
		}

		// set focus to the cellEditor. It is now essentially in control of input until the Mouse
		// is clicked away, or ESC/ENTER/TAB are hit
		var fM = getFocusManager();
		fM.setFocus(cellEditor);
		fM.defaultPushButtonEnabled = false;

		if (cell.isCellEditor!=true) {
			// only for text input - tends to scroll after focused, so we scroll it back
			cellEditor.hPosition = 0;
 			cellEditor.redraw();			// This makes sure that the text is in the label TextField, so setSelection will always work.
 			Selection.setSelection(0, cellEditor.length);
		}
		// store the value
		__focusedCell = coord;

		// tricky business. Steal the focusManager's method of catching tabs,
		// and replace it with our own, which will do *our* bidding <nefarious laughter>.
		if (__tabHandlerCache == undefined)
		{
			__tabHandlerCache = fM.tabHandler;
			fM.tabHandler = tabHandler;
		}

		// give the fM a reference to us (our tabHandler needs it)
		fM.activeGrid = this;

		// listen for keyStrokes on the cellEditor (which lets the grid supervise for ESC/ENTER)
		cellEditor.addEventListener("keyDown", this.editorKeyDown);

		// broadcast the focus event
		if (broadCast) {
			dispatchEvent({type:"cellFocusIn", itemIndex: index, columnIndex: colIdx});
		}
	}

	// the grid listens for mouseDowns.
	function onMouseDown(Void) : Void
	{
		 // If you click away from an editable cell, then we need to store the new value and dispose it
		if (cellEditor._visible && !cellEditor.hitTest(_root._xmouse, _root._ymouse)) {
			editCell();
		}
		// If you've clicked on the scrollBars, the grid gets focused. But it shouldn't pop up a cell editor
		if (vScroller.hitTest(_root._xmouse, _root._ymouse) || hScroller.hitTest(_root._xmouse, _root._ymouse) || header_mc.hitTest(_root._xmouse, _root._ymouse)) {
			dontEdit = true;
		}
	}

	// Scoped to the cell editor. listOwner is the grid
	function editorKeyDown(Void) : Void
	{
		// ESC just kills the editor, no new data
		if (Key.isDown(Key.ESCAPE)) {
			this.listOwner.disposeEditor();
 		} else if (Key.isDown(Key.ENTER) && Key.getCode() != 229) {
   			// Enter edits the cell, moves down a row
 			// The 229 keyCode is for IME compatability. When entering an IME expression,
 			// the enter key is down, but the keyCode is 229 instead of the enter key code.
 			// Thanks to Yukari for this little trick...
			this.listOwner.editCell();
			this.listOwner.findNextEnterCell();
		}
	}

	/**
	* scoped to the FocusManager. How fun!! activeGrid is the grid in question
	* tabHandler is focusManager's method for catching the TAB. We replace it
	* with this when the grid gets focus, and restore it to normal afterwards. This method
	* should only be active while there is a focused cellEditor in the grid (or tabbing will break!).
	**/
	function tabHandler(Void) : Void
	{
		// assume we start at the top left
		var itemIndex : Number = -1;
		var colIndex : Number = -1;
		var g = this.activeGrid;
		// unless there was a last focusedCell
		if (g.__focusedCell!=undefined) {
			itemIndex = g.__focusedCell.itemIndex;
			colIndex = g.__focusedCell.columnIndex;
		}
		// store the edited data, dispose the editor
		g.editCell();
		// find the next cell to focus
		g.findNextCell(itemIndex, colIndex);
	}


	// find the next cell down from the currently edited cell, and focus it.
	function findNextEnterCell(Void) : Void
	{
		// modify direction with SHIFT (up or down)
		var incr : Number = (Key.isDown(Key.SHIFT)) ? -1 : 1;
		var newIndex : Number = __focusedCell.itemIndex + incr;
		// only move if we're within range
		if (newIndex<getLength() && newIndex>=0) {
			__focusedCell.itemIndex = newIndex;
		}
		setFocusedCell(__focusedCell, true);
	}


	/**
	* find the next cell for the grid to TAB to (back or forth). If the cell to be focused
	* falls out of range (the end or beggining of the grid) then move focus outside the grid.
	**/
	function findNextCell(index:Number, colIndex:Number) : Void
	{
		// start at the top if nothing else
		if (index==undefined) {
			index = colIndex = -1;
		}
		var found = false;
		var incr = (Key.isDown(Key.SHIFT)) ? -1 : 1;

		// cycle till we find something worth focusing, or the end of the grid
		while (!found) {
			// go to next column
			colIndex+=incr;
			if (colIndex>=columns.length || colIndex<0) {
				// if we fall off the end of the columns, wrap around
				colIndex = (colIndex<0) ? columns.length : 0;
				// and increment/decrement the row index
				index+=incr;
				if (index>=getLength() || index<0) {
					// if we've fallen off the rows, we need to leave the grid. get rid of the editor
					if(getFocusManager().activeGrid!=undefined)
						disposeEditor();
					// we need to set focus to the grid before moving on (focusManager thing)
					// make sure the grid does pop into editing when we do so.
					__focusedCell = null;
					dontEdit = true;
					Selection.setFocus(this);
					delete dontEdit;
					// disposeEditor should have restored focusManager's tabHandler.
					// use it to move focus on to the next thing.
					getFocusManager().tabHandler();
					return;
				}
			}
			// if we find an editable column, move to it
			if (columns[colIndex].editable) {
				found = true;
				if (__tabHandlerCache!=undefined) {
					// get rid of the current editor
					disposeEditor();
				}
				//go to our new cell
				setFocusedCell({itemIndex:index, columnIndex:colIndex}, true);
			}
		}
	}


	// when the grid gets focus, focus a cell
	function onSetFocus(Void) : Void
	{
		super.onSetFocus();
		// look out for dontEdit, which is the exception to when to focus an editor
		if (editable && dontEdit!=true) {
			// start somewhere
			if (__focusedCell==undefined) {
				__focusedCell = {itemIndex:0, columnIndex:0};
			}
			// if the focusedCell is valid, focus it, otherwise find one
			if (columns[__focusedCell.columnIndex].editable==true) {
				setFocusedCell(__focusedCell, true);
			} else {
				findNextCell(__focusedCell.itemIndex, __focusedCell.columnIndex);
			}
		}
		delete dontEdit;
	}

	// Tween methods for the wipe effect on the editor
	function onTweenUpdate(val)
	{
		editorMask._x = val;
	}
	function onTweenEnd(val)
	{
		editorMask._x = val;
		cellEditor.setMask(undefined);
		editorMask.removeMovieClip();
	}


	/**
	* Pretty important method. Get rid of all the baggage we're lugging as part of
	* the cellEditor setup. This includes the keyListener, restoring the focusManager
	* to its pristine state, removing the editor, and firing the focus out event
	**/
	function disposeEditor(Void) : Void
	{
		cellEditor.removeEventListener("keyDown", this.editorKeyDown);
		dispatchEvent({type:"cellFocusOut", itemIndex: __focusedCell.itemIndex, columnIndex:__focusedCell.columnIndex});
		if (cellEditor.isCellEditor!=true)
			cellEditor._visible = false;
		var fM = getFocusManager();
		if (__tabHandlerCache != undefined)
		{
			fM.tabHandler = __tabHandlerCache;
			delete __tabHandlerCache;
		}
		fM.defaultPushButtonEnabled = true;

		// if the click was on the grid, give focus back to the grid
		if (border_mc.hitTest(_root._xmouse, _root._ymouse) && !vScroller.hitTest(_root._xmouse, _root._ymouse) && !hScroller.hitTest(_root._xmouse, _root._ymouse)) {
			dontEdit = true;
			releaseFocus();
			delete dontEdit;
		}
		delete cellEditor;
		delete fM.activeGrid;
	}


	/**
	* Take the stuff from the cellEditor, and store it in the dataProvider. Dispose
	* Fire the edit event (including the old value of the cell), and dispose the editor
	**/
	function editCell()
	{
		var index = __focusedCell.itemIndex;
		var colName = columns[__focusedCell.columnIndex].columnName;

//		var oldData = __dataProvider.getItemAt(index)[colName];

		var oldData = __dataProvider.getEditingData(index, colName);
		if (oldData==undefined)
			oldData = __dataProvider.getItemAt(index)[colName];

		var newData = (cellEditor.isCellEditor) ? cellEditor.getValue() : cellEditor.text;

		if (oldData!=newData) {
			editField(index, colName, newData);
			dispatchEvent({type:"cellEdit", itemIndex: index, columnIndex: __focusedCell.columnIndex, oldValue:oldData});
		}
		disposeEditor();
	}


	// catch style changes and route them to the right spot
	function invalidateStyle(propName : String) : Void
	{
		if (propName=="headerColor" || propName=="styleName") {
			drawHeaderBG();
		}
		if (propName=="hGridLines" || propName=="hGridLineColor" || propName=="vGridLines" || propName=="vGridLineColor" || propName=="styleName" || propName=="backgroundColor") {
			invDrawCols = true;
			invalidate();
		}
		if (mx.styles.StyleManager.TextStyleMap[propName] != undefined) {
			super.changeTextStyleInChildren(propName);
		}
		if (propName=="styleName" || propName=="headerStyle") {
			invalidateHeaderStyle();
		}
		super.invalidateStyle(propName);
	}

	// catch styles changing from styleSheets and route them
	function notifyStyleChangeInChildren(sheetName:String, styleProp:String, newValue):Void
	{

		if (styleProp=="headerStyle") {
			invalidateHeaderStyle();
		}
		if (sheetName!=undefined) {
			// check our columns to see if it was one of the columns' style that changed
			for (var i=0; i<columns.length; i++) {
				if (sheetName==columns[i].styleName) {
					invalidateStyle(styleProp);
					// column style changes (ie. text) affects our rows
					for (var j=0; j<rows.length; j++) {
						rows[j].notifyStyleChangeInChildren(sheetName, styleProp, newValue);
					}
				}
			}
		}
		super.notifyStyleChangeInChildren(sheetName, styleProp, newValue);
	}


	[Bindable(param1="writeonly",type="DataProvider")]
	var	_inherited_dataProvider:Array;

	[Bindable("readonly")]
	[ChangeEvent("change")]
	var	_inherited_selectedItem:Object;

	[Bindable]
	[ChangeEvent("change")]
	var	_inherited_selectedIndex:Number;

}