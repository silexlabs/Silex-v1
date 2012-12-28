//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIComponent;
import mx.effects.Tween;

/*
* base class of selectable rows for lists
*
* @helpid 3262
* @tiptext
*/


class mx.controls.listclasses.SelectableRow extends UIComponent
{

	static var LOWEST_DEPTH : Number = -16384; // A constant (!) for the lowest authortime depth
	var state : String = "normal";

	var disabledColor : Number = 0xe8e8e8;

	//::: Declarations
	var item : Object;
	var highlight : MovieClip;
	var cell : Object;
	var owner : Object;
	var rowIndex : Number;
	var icon_mc : MovieClip;
	var backGround : MovieClip;
	var bGCol : Object;
	var clr : Number;
	var normalColor : Number = 0xffffff;
	var highlightColor : Number;

	var bGTween : Object;
	var isChangedToSelected : Boolean;
	var grandOwner : Object;
	var listOwner : Object;


	function SelectableRow()
	{

	}


	// ::: METHODS for EXTENDING


	// EXTEND this method to change the rendering of the content in an item (multiple cells, icons, etc)
	function setValue(itmObj : Object, state : String) : Void
	{
		var h = __height;
		var c = cell;
		var o = owner;
		var tmpText = itemToString(itmObj);
		if (c.getValue()!=tmpText) {
			c.setValue(tmpText, itmObj, state);
		}

		// in search of an icon
		var icon = o.getPropertiesAt(rowIndex + o.__vPosition).icon;
		if (icon==undefined) {
			icon = o.__iconFunction(itmObj);
			if (icon==undefined) {
				icon = itmObj[o.__iconField];
				if (icon==undefined) {
					icon = o.getStyle("defaultIcon");
				}
			}
		}
		var i = icon_mc;
		if (icon!=undefined && itmObj!=undefined) {
			i = createObject(icon, "icon_mc", 20);
			i._x = 2;
			i._y = (h - i._height) / 2;
			c._x = 4 + i._width;
		} else {
			i.removeMovieClip();
			c._x = 2;
		}
		var iconW = (i==undefined) ? 0 : i._width;
		c.setSize(__width-iconW, Math.min(h, c.getPreferredHeight()));
		c._y = (h - c._height)/2;
	}


	//  This is for adjusting the size of the highlight, its associated hit area, and the other contents
	// EXTEND this for more layout of other content types
	function size(Void) : Void
	{
		var b = backGround;
		var c = cell;
		var h = __height;
		var w = __width;
		var iconW = (icon_mc==undefined) ? 0 : icon_mc._width;
		c.setSize(w-iconW, Math.min(h, c.getPreferredHeight()));
		c._y = (h - c._height)/2;
		icon_mc._y = (h - icon_mc._height) / 2;

		b._x = 0;
		b._width =  w;
		b._height = h;
		drawRowFill(b, normalColor);
		drawRowFill(highlight, highlightColor);
	}

	function setCellRenderer(forceSizing:Boolean) : Void
	{
		var cR = owner.__cellRenderer;
		var cellX : Number;
		if (cell!=undefined) {
			cellX = cell._x;
			cell.removeMovieClip();
			cell.removeTextField();
		}
		var c : Object;
		if (cR==undefined) {
			c = cell = createLabel("cll", 0, {styleName : this});
			c.styleName = owner;
			c.selectable = false;
			c.tabEnabled = false;
			c.background = false;
			c.border = false;
		} else {
			if (typeof(cR)=="string") {
				c = cell = createObject(cR, "cll", 0, {styleName:this});
			} else {
				c = cell = createClassObject(cR, "cll", 0, {styleName:this});
			}
		}
		c.owner = this;
		c.listOwner = owner;
		c.getCellIndex = getCellIndex;
		c.getDataLabel = getDataLabel;
		if (cellX!=undefined) {
			c._x = cellX;
		}
		if (forceSizing)
			size();
	}

	// scoped to the cell. Any cell in the row will receive these methods.
	function getCellIndex(Void) : Object
	{
		return {columnIndex:0, itemIndex:this.owner.rowIndex+this.listOwner.__vPosition};
	}

	// scoped to the cell. Any cell in the row will receive these methods.
	function getDataLabel() : String
	{
		return this.listOwner.labelField;
	}


	// EXTEND to add more new data structures to class construction
	function init(Void):Void
	{
		super.init();
		tabEnabled = false;
	}

	// EXTEND this for putting in new list content
	function createChildren(Void) : Void
	{
		setCellRenderer(false);
		setupBG();
		setState(state, false);
	}


	// ::: PRIVATE METHODS


	// the overall method the list communicates with the rows with --  doesn't need to be extended
	function drawRow(itmObj : Object, state : String, transition : Boolean) : Void
	{
//		trace("selectable drawRow");
		item = itmObj;
		setState(state, transition);
		setValue(itmObj, state, transition);
	}

	// parses the item to return a display string
	function itemToString(itmObj : Object) : String
	{
		if (itmObj==undefined) return " ";

		
		var tmpLabel = owner.__labelFunction(itmObj);
		if (tmpLabel==undefined) {
			tmpLabel = (itmObj instanceof XMLNode) ? itmObj.attributes[owner.__labelField] : itmObj[owner.__labelField];
			if (tmpLabel==undefined) {
				tmpLabel = " ";
				if (typeof(itmObj)=="object") {
					for (var i in itmObj) {
						if (i!="__ID__") {
							tmpLabel = itmObj[i] + ", " + tmpLabel;
						}
					}
					tmpLabel = tmpLabel.substring(0,tmpLabel.length-2);
				} else {
					tmpLabel = itmObj;
				}
			}
		}
		return tmpLabel;
	}


	// Don't extend this. Sets up the hit area
	function setupBG(Void) : Void
	{
		var b = backGround = createEmptyMovieClip("bG_mc", LOWEST_DEPTH);
		drawRowFill(b, normalColor);

		highlight = createEmptyMovieClip("tran_mc", LOWEST_DEPTH+10);
		b.owner = this;
		b.grandOwner = owner;
		b.onPress = bGOnPress;
		b.onRelease = bGOnRelease;
		b.onRollOver = bGOnRollOver;
		b.onRollOut = bGOnRollOut;
		b.onDragOver = bGOnDragOver;
		b.onDragOut = bGOnDragOut;
		b.useHandCursor = false;
		b.trackAsMenu = true;
		b.drawRect = this.drawRect;
		highlight.drawRect = this.drawRect;
	}

	// draws selections and rollover highlights
	function drawRowFill(mc : MovieClip, newClr : Number) : Void
	{
		mc.clear();
		mc.beginFill(newClr);

		mc.drawRect(1, 0, __width, __height);
		mc.endFill();
		mc._width = __width;
		mc._height = __height;

	}

	// state comes in 3 flavors :
	//	"selected", "highlighted", "normal"
	// this draws the highlight and shouldn't be EXTENDED
	function setState(newState : String, transition : Boolean) : Void
	{
		var h = highlight;
		var b = backGround;
		var ht = __height;
		var o = owner;
		if (!o.enabled)
		{
			if (newState=="selected" || state=="selected")
			{
				highlightColor = o.getStyle("selectionDisabledColor");
				drawRowFill(h, highlightColor);
				h._visible = true;
				h._y = 0;
				h._height = ht;
			}
			else
			{
				h._visible = false;
				normalColor = o.getStyle("backgroundDisabledColor");

				drawRowFill(b, normalColor);

			}
			cell.__enabled = false;
			cell.setColor(o.getStyle("disabledColor"));
		}
		else // enabled
		{
			cell.__enabled = true;
			if (transition && (newState==state || (newState=="highlighted" && state=="selected")))
			{
				isChangedToSelected = true;
				return;
			}
			var dur = o.getStyle("selectionDuration");
			var textCol = 0x000000;
			if ( isChangedToSelected && newState=="selected")  transition=false;
			var bTween = (transition && dur!=0);
			if (newState=="normal")
			{
				textCol = o.getStyle("color");
				normalColor = getNormalColor();
				drawRowFill(b, normalColor);

				if (bTween)
				{
					dur /= 2;
					h._height = ht;
					h._width = __width;
					h._y = 0;
					bGTween = new Tween(this, ht+2, ht*0.2, dur, 5);
				}
				else
					h._visible = false;
				delete isChangedToSelected;

			}
			else
			{
				highlightColor = o.getStyle(newState=="highlighted" ? "rollOverColor" : "selectionColor");

				drawRowFill(h, highlightColor);
				h._visible = true;
				textCol = o.getStyle(newState=="highlighted" ? "textRollOverColor" : "textSelectedColor");
				if (bTween)
				{
					h._height = ht * 0.5;
					h._y = (ht-h._height)/2;
					bGTween = new Tween(this, h._height, ht+2, dur, 5);
					var tmp = o.getStyle("selectionEasing");
					if (tmp!=undefined)
					{
						bGTween.easingEquation = tmp;
					}
				}
				else
				{
					h._y = 0;
					h._height = ht;
				}
			}
			cell.setColor(textCol);
		}

		state = newState;
	}

	function onTweenUpdate(val : Number) : Void
	{
		highlight._height = val;
		highlight._y = (__height-val)/2;
	}

	function onTweenEnd(val : Number) : Void
	{
		onTweenUpdate(val);
		highlight._visible = (state!="normal");
	}


	// Gets the color of normal backgrounds
	function getNormalColor(Void) : Number
	{
		var col;
		var o = owner;
		if ( !owner.enabled ) {
			col = o.getStyle("backgroundDisabledColor");
		} else {
			var itemIndex = rowIndex + o.__vPosition;
 			if (rowIndex==undefined) {
 				col = o.getPropertiesOf(item).backgroundColor;
 			} else {
 				col = o.getPropertiesAt(itemIndex).backgroundColor;
 			}
			if (col==undefined) {
				var colArray = o.getStyle("alternatingRowColors");
				if (colArray==undefined) {
					col = o.getStyle("backgroundColor");
				} else {
					col = colArray[itemIndex%colArray.length];
				}
			}
		}
		return col;
	}
	
	function invalidateStyle(propName:String):Void
	{
		cell.invalidateStyle(propName);
		super.invalidateStyle(propName);
	}

	//::: METHODS SCOPED TO THE backGround. No touching!
	function bGOnPress(Void) : Void
	{
		grandOwner.pressFocus();
		grandOwner.onRowPress(owner.rowIndex);
	}

	function bGOnRelease(Void) : Void
	{
		grandOwner.releaseFocus();
		grandOwner.onRowRelease(owner.rowIndex);
	}

	function bGOnRollOver(Void) : Void
	{
		grandOwner.onRowRollOver(owner.rowIndex);
	}

	function bGOnRollOut(Void) : Void
	{
		grandOwner.onRowRollOut(owner.rowIndex);
	}

	function bGOnDragOver(Void) : Void
	{
		grandOwner.onRowDragOver(owner.rowIndex);
	}

	function bGOnDragOut(Void) : Void
	{
		grandOwner.onRowDragOut(owner.rowIndex);
	}
	//::: END METHODS SCOPED TO backGround
}