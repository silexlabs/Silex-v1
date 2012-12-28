//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.styles.CSSStyleDeclaration;

/**
* DataGridColumn class
* - extends CSSStyleDeclaration
* @tiptext DataGridColumns are special style constructs for setting the display of a column in a DataGrid
* @helpid 3500
*/
class mx.controls.gridclasses.DataGridColumn extends CSSStyleDeclaration
{
	//::: Default Values

/**
* @tiptext Whether or not cells in the column can be edited
* @helpid 3502
*/
	var editable : Boolean = true;
/**
* @tiptext Whether or not the header of the column can be clicked to sort
* @helpid 3503
*/
	var sortable : Boolean = true;
/**
* @tiptext Whether or not the column can be stretched by the user
* @helpid 3504
*/
	var resizable : Boolean = true;
/**
* @tiptext Whether or not the column will automatically sort when the header is released
* @helpid 3505
*/
	var sortOnHeaderRelease : Boolean = true;

	var __width : Number = 50;

	//::: Declarations

/**
* @tiptext The name of the column (read-only)
* @helpid 3506
*/
	var columnName : String;

	var parentGrid : mx.controls.DataGrid;
	var colNum : Number;
	var headerCell : Object;
	var __header : String;
	var __headerRenderer; // could be a string or a class
	var __cellRenderer;  // could be a string or a class
	var __labelFunction : Function;
	var styleName;
	var headerStyle : CSSStyleDeclaration = _global.styles.dataGridStyles;


	function DataGridColumn(colName : String)
	{
		columnName = colName;
		headerText = colName;
	}


/**
* @tiptext The width of the column
* @helpid 3507
*/
	function get width() : Number
	{
		return __width;
	}

	function set width(w : Number)
	{
		// remove any queued equal spacing commands
		delete parentGrid.invSpaceColsEqually;
		if (parentGrid!=undefined && parentGrid.hasDrawn) {
			// if there's a grid that's drawn, resize it's column
			var oldVal = resizable;
			// anchor this column to not accept any overflow width for accurate sizing
			resizable = false;
			parentGrid.resizeColumn(colNum, w);
			resizable = oldVal;
		} else {
			// otherwise, just store the size
			__width = w;
		}
	}


/**
* @tiptext The text at the top of the column
* @helpid 3508
*/
	function set headerText(h:String)
	{
		__header = h;
		headerCell.setValue(h);
	}

	function get headerText()
	{
		return (__header==undefined) ? columnName : __header;
	}


/**
* @tiptext The class to use for the cells of this column
* @helpid 3509
*/
	function set cellRenderer(cR)
	{
		__cellRenderer = cR;
		// this is expensive... but unless set after init (not recommended), ok.
		parentGrid.invColChange = true;
		parentGrid.invalidate();
	}

	function get cellRenderer() : String
	{
		return __cellRenderer;
	}


/**
* @tiptext The class to use for the cells of the header of this column
* @helpid 3510
*/
	function set headerRenderer(hS)
	{
		__headerRenderer = hS;
		// rebuild the headers
		parentGrid.invInitHeaders = true;
		parentGrid.invalidate();
	}

	function get headerRenderer() : String
	{
		return __headerRenderer;
	}


/**
* @tiptext A function to use in determining the text displayed in this column
* @helpid 3511
*/
	function set labelFunction(f : Function)
	{
		__labelFunction = f;
		parentGrid.invUpdateControl = true;
		parentGrid.invalidate();
	}

	function get labelFunction() : Function
	{
		return __labelFunction;
	}


/**
* Since DataGridColumn is a subclass of CSSStyleDeclaration, we extend getStyle to redirect
* its lookup of a style to allow nested styleNames (a column can have a styleName CSSStyleDec).
* As well, reroute lookup through the grid itself
*/
	function getStyle(prop:String)
	{
		var v = this[prop];
		if (v==undefined) {
			// if the column has a CSSStyleDec associated with it, look for the value there
			if (styleName!=undefined) {
				if (styleName instanceof CSSStyleDeclaration) {
					v = styleName.getStyle(prop);
				} else {
					v = _global.styles[styleName].getStyle(prop);
				}
			}
			// if we haven't found anything, or we found a global/class default value
			// (unless it's backgroundColor, which we always try to lookup on ourselves)
			if ((v==undefined || v==_global.style[prop] || v==_global.styles[parentGrid.className][prop]) && prop!="backgroundColor") {
				v = parentGrid.getStyle(prop);
			}
		}
		return v;
	}


/**
* Tricky business. Change the way textFields in this column lookup their text properties to make sure
* they check the column, the column and grid's headerStyle (if necessary), and then the grid.
*/
	function __getTextFormat(tf:TextFormat, bAll:Boolean, fieldInst):Boolean
	{
		var t : Boolean;
		// if we're a header cell
		if (parentGrid.header_mc[fieldInst._name]!=undefined) {
			// lookup in the headerStyle of the column
			t = getStyle("headerStyle").__getTextFormat(tf, bAll, fieldInst);
			if (t!=false) {
				// if there's still more text styles to find, look on the grid's headerStyle
				t = parentGrid.getStyle("headerStyle").__getTextFormat(tf, bAll, fieldInst);
			}
			// if we found all text styles, stop looking
			if (t==false)
				return t;

		}
		// if this column has a styleSheet
		if (styleName!=undefined) {
			var s = (typeof(styleName)=="string") ? _global.styles[styleName] : styleName;
			// find the text styles on that sheet
			t = s.__getTextFormat(tf, bAll);
			// if we found them all, stop looking
			if (!t)
				return t;
		}
		// look for the styles up the chain
		t = super.__getTextFormat(tf, bAll, fieldInst);
		if (t) {
			// find more styles on the grid if we're not done
			return parentGrid.__getTextFormat(tf, bAll);
		} else {
			// otherwise, stop looking
			return t;
		}
	}
}