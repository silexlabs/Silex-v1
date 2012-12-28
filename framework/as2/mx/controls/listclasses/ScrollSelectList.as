//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


import mx.controls.listclasses.DataProvider;
import mx.controls.listclasses.DataSelector;
import mx.core.ScrollView;

/**
* @tiptext change event
* @helpid 3234
*/
[Event("change")]
/**
* @tiptext itemRollOver event
* @helpid 3235
*/
[Event("itemRollOver")]
/**
* @tiptext itemRollOut event
* @helpid 3236
*/
[Event("itemRollOut")]

/*
* base class selectable lists of rows which support scrolling
*
* @private
*/


class mx.controls.listclasses.ScrollSelectList extends ScrollView
{

	// Initialize our class to "inherit" DataSelector methods.
	static var mixIt1 : Boolean = DataSelector.Initialize(mx.controls.listclasses.ScrollSelectList);
	static var mixIt2 : Boolean = DataProvider.Initialize(Array);

	// where the stack of rows goes.
	var CONTENTDEPTH : Number = 100;

	//::: Default Values of internal vars
	var __hPosition : Number = 0;
	var __rowRenderer : String = "SelectableRow";
	var __rowHeight : Number = 22;
	var __rowCount : Number = 0;
	var __labelField : String = "label";
	var __labelFunction : Function;
	var __iconField : String;
	var __iconFunction : Function;
	var __cellRenderer; // loosened type;
	var minScrollInterval = 30;


	// some vars for ... later
	var dropEnabled : Boolean = false;
	var dragEnabled : Boolean = false;

	// keep track of whether the control has been pressed
	var isPressed : Boolean;

	var className : String = "ScrollSelectList";


	// anything in this list of styles will trigger an updateControl
	var isRowStyle : Object = { styleName:true, backgroundColor:true, selectionColor:true, rollOverColor:true, selectionDisabledColor:true,
							backgroundDisabledColor:true, textColor:true, textSelectedColor:true, textRollOverColor:true,
							textDisabledColor:true, alternatingRowColors:true, defaultIcon:true
	};





	//::: Declarations
	var invLayoutContent : Boolean;
	var invRowHeight : Boolean;
	var invUpdateControl : Boolean;

	var roundUp = 0; // relaxed - used as both boolean and number
	var rows : Array;
	var topRowZ : Number;
	var baseRowZ : Number;
	var listContent : MovieClip;
	var tW : Number;
	var tH : Number;
	var layoutX : Number;
	var layoutY : Number;
	var lastPosition : Number;
	var lastSelected : Number;
	var propertyTable : Object;
	var changeFlag : Boolean;
	var dragScrolling;
	var scrollInterval : Number;
	var wasKeySelected : Boolean;


	// Props Mixed In from DataSelector

	var __dataProvider : Object;

 	/**
	* @helpid 3237
	* @tiptext The list of data to be used as a model
	*/
	var dataProvider : Object;

	var enabled : Boolean;
	var lastSelID : Number;
	var selectHolder : Number;
	var selectionDeleted : Boolean;
	var selected : Object;

	var createLabel : Function;
	var onMouseUp : Function;
	var __width : Number;

	var tempLabel : Object;

 // Functions Mixed in from DataSelector


 	var setDataProvider : Function;
	var getDataProvider : Function;

 	/**
	* @param index the index at which to add the item
	* @param label the label of the new item
	* @param data the data for the new item
	* @return the added item
	*
	* @helpid 3238
	* @tiptext Adds an item at the specified index
	*/
	var addItemAt : Function;

 	/**
	* @param label the label of the new item
	* @param data the data for the new item
	* @return the added item
	*
	* @helpid 3239
	* @tiptext Appends an item to the end of the list
	*/
	var addItem : Function;


	/**
	* @param index the index of the item to remove
	* @return the removed item
	*
	* @helpid 3240
	* @tiptext Removes the item at the specified index
	*/
	var removeItemAt : Function;


	/**
	* @helpid 3241
	* @tiptext Removes all items
	*/
	var removeAll : Function;


 	/**
	* @param index the index of the item to replace
	* @param label the label for the replacing item
	* @param data the data for the replacing item
	*
	* @helpid 3242
	* @tiptext Replaces the item at the specified index
	*/
	var replaceItemAt : Function;


 	/**
	* @param fieldName the field to sort on
	* @param order either "ASC" or "DESC"
	*
	* @helpid 3243
	* @tiptext Sorts the list by some field of each item
	*/
	var sortItemsBy : Function;


 	/**
	* @param compareFunc a function to use for comparison
	*
	* @helpid 3244
	* @tiptext Sorts the list by using a compare function
	*/
	var sortItems : Function;


 	/**
	* @helpid 3245
	* @tiptext Gets the number of items in the list
	*/
	var length : Number;
	var getLength : Function;


 	/**
	* @param index the index of the items to return
	* @return the item
	*
	* @helpid 3246
	* @tiptext Gets the item at the specified index
	*/
	var getItemAt : Function;

	//::: PRIVATE DATA MANAGEMENT METHODS


 	/**
	* catches model changed events from the dataProvider
	*
	* @private
	*
	*/
	var modelChanged : Function;
	var calcPreferredWidth : Function;

	//::: SELECTION METHODS


 	/**
	* @helpid 3247
	* @tiptext Gets the selected data (or label)
	*/
	var value : Object;
	var getValue : Function;


 	/**
	* @helpid 3248
	* @tiptext Gets or sets the selected index
	*/
	var selectedIndex : Number;
	var getSelectedIndex : Function;
	var setSelectedIndex : Function;


 	/**
	* @helpid 3249
	* @tiptext Gets or sets the selected indices
	*/
	var selectedIndices : Array;
	var getSelectedIndices : Function;
	var setSelectedIndices : Function;


	/**
	* @helpid 3250
	* @tiptext Gets the selected items
	*/
	var selectedItems : Array;
	var getSelectedItems : Function;


	/**
	* @helpid 3251
	* @tiptext Gets the selected item
	*/
	var selectedItem; // relaxed type - could be string but usually object
	var getSelectedItem : Function;

	// ::: PRIVATE SELECTION METHODS

	/**
	* bookkeeps the selection of one item
	*
	* @private
	*/
	var selectItem : Function;

	/**
	* returns true or false, depending on selection
	*
	* @private
	*/
	var isSelected : Function;

	/**
	* clears all selections, redraws list
	*
	* @private
	*/
	var clearSelected : Function;



	/**
	* @helpid 3252
	* @tiptext Determines whether or not the list is selectable
	*/
	var selectable : Boolean = true;

 	/**
	* @helpid 3253
	* @tiptext If true, multiple selection is allowed
	*/
     [Inspectable(defaultValue=false)]
	var multipleSelection : Boolean = false;





	function ScrollSelectList()
	{
	}





	//::: MAIN LAYOUT METHOD. Find a delta, make the adjustment to the number of rows, and their width

	function layoutContent(x : Number,y:Number,w:Number,h:Number) : Void
	{
//		trace("ScrollSelectList.layoutContent - x:" + x + " y:" + y + " w:" + w + " h:" + h );
		delete invLayoutContent;
		//if the rowHeight hasn't changed, we need to see if anything needs resizing
		var newCount = Math.ceil(h/__rowHeight);
		roundUp = ( h % __rowHeight != 0);
		var deltaRows = newCount-__rowCount;
		if (deltaRows<0) {
			//remove some rows
			for (var i=newCount; i<__rowCount; i++) {
				rows[i].removeMovieClip();
				delete rows[i];
			}
			topRowZ+=deltaRows;
		} else if (deltaRows>0) {
			// add some rows
			if (rows==undefined) {
				rows = new Array();
			}
			for (var i=__rowCount; i<newCount; i++) {
				var row = rows[i] = listContent.createObject(__rowRenderer, "listRow"+topRowZ++, topRowZ, {owner:this, styleName:this, rowIndex:i});
				row._x = x;
				row._y = Math.round(i*(__rowHeight) + y);
				row.setSize(w, __rowHeight);
				row.drawRow(__dataProvider.getItemAt(__vPosition+i), getStateAt(__vPosition+i));
				row.lastY = row._y;
			}
		}
		if (w!=tW) {
			var c = (deltaRows>0) ? __rowCount : newCount;
			for (var i=0; i<c; i++) {
				rows[i].setSize(w, __rowHeight);
			}
		}
		if (layoutX!=x || layoutY!=y) {
			for (var i=0; i<newCount; i++) {
				rows[i]._x = x;
				rows[i]._y = Math.round(i*(__rowHeight) + y);
			}
		}
		__rowCount = newCount;
		layoutX = x;
		layoutY = y;
		tW = w;
		tH = h;
	}


	function getRowHeight(Void) : Number
	{
		return __rowHeight;
	}

	function setRowHeight(v : Number) : Void
	{
		__rowHeight = v;
		invRowHeight = true;
		invalidate();
	}


	/**
	* @helpid 3254
	* @tiptext Gets or sets the height of the rows
	*/
     [Inspectable(defaultValue=20)]
	function get rowHeight():Number
	{
		return getRowHeight();
	}

	function set rowHeight(w):Void
	{
		setRowHeight(w);
	}


	function setRowCount(v : Number) : Void
	{
		__rowCount = v;
		// List will extend this.
	}

	function getRowCount(Void) : Number
	{
		var r = (__rowCount==0) ? Math.ceil(__height / __rowHeight) : __rowCount;
		return r;
	}


	/**
	* @helpid 3255
	* @tiptext Gets or sets the number of rows
	*/
	function get rowCount():Number
	{
		return getRowCount();
	}

	function set rowCount(w):Void
	{
		setRowCount(w);
	}

	function setEnabled(v : Boolean) : Void
	{
		super.setEnabled(v);
		invUpdateControl = true;
		invalidate();

	}

	function setCellRenderer(cR) : Void
	{
		__cellRenderer = cR;
		for (var i=0; i<rows.length; i++) {
			rows[i].setCellRenderer(true);
		}
		invUpdateControl = true;
		invalidate();
	}

	function set cellRenderer(cR)
	{
		setCellRenderer(cR);
	}

	/**
	* @helpid 3256
	* @tiptext Gets or sets the cellRenderer component for the rows
	*/
	function get cellRenderer()
	{
		return __cellRenderer;
	}

	//::: FIELD / FUNCTION METHODS

	// label

	/**
	* @helpid 3257
	* @tiptext The name of the field in dataProvider array objects to display as the label
	*/
	function set labelField(field) : Void
	{
		setLabelField(field);
	}

	function setLabelField(field:String) : Void
	{
		__labelField = field;
		invUpdateControl = true;
		invalidate();
	}

	function get labelField() : String
	{
		return __labelField;
	}


	/**
	* @helpid 3258
	* @tiptext A user-supplied function to run on each item to determine its label
	*/
	function set labelFunction(func) : Void
	{
		setLabelFunction(func);
	}

	function setLabelFunction(func:Function) : Void
	{
		__labelFunction = func;
		invUpdateControl = true;
		invalidate();
	}


	function get labelFunction() : Function
	{
		return __labelFunction;
	}


	//Icon

	/**
	* @helpid 3259
	* @tiptext The name of the field in dataProvider array objects to display as the icon
	*/
	function set iconField(field) : Void
	{
		setIconField(field);
	}

	function setIconField(field:String) : Void
	{
		__iconField = field;
		invUpdateControl = true;
		invalidate();
	}


	function get iconField() : String
	{
		return __iconField;
	}

	/**
	* @helpid 3260
	* @tiptext A user-supplied function to run on each item to determine its icon
	*/
	function set iconFunction(func) : Void
	{
		setIconFunction(func);
	}

	function setIconFunction(func:Function) : Void
	{
		__iconFunction = func;
		invUpdateControl = true;
		invalidate();
	}

	function get iconFunction() : Function
	{
		return __iconFunction;
	}




	//::: SCROLL METHODS
	// Move any rows that don't need rerendering
	// Move and Rerender any rows left over
	function setVPosition(pos : Number) : Void
	{
//		trace("SSL:VPosition" + pos);
		if (pos<0)
			return;

		// The following check is supposed to be used to make sure
		// that you cannot set some position to the top of the list,
		// if it means that stuff will be scrolled off the top, but
		// leave empty rows visible at the bottom of the list.
		//
		// It fails to do the correct thing when a tree has rows
		// scrolled off the top, but closing a visible disclosure
		// results in less than __rowCount items in the dataProvider.
		// In this case, we always want to be able to set the scroll
		// position to zero (so the first row is at the top of the list).
		//
		// We allow for this by always letting position 0 through,
		// and only checking against the length for positions > zero.
		if (pos > 0 &&  pos>(getLength()-__rowCount+roundUp))
			return;
		var deltaPos = pos - __vPosition;
		if (deltaPos==0) return;

		__vPosition=pos;

		var scrollUp = deltaPos>0;
		deltaPos = Math.abs(deltaPos);

		if (deltaPos>=__rowCount) {
			updateControl();
		} else {
			var tmpArray = new Array();
			var moveBlockLength = __rowCount-deltaPos;
			var moveBlockDistance = deltaPos*__rowHeight;
			var shuffleBlockDistance = moveBlockLength*__rowHeight;

			var inc = (scrollUp) ? 1 : -1;
			for (var i=0; i<__rowCount; i++) {
				if ( (i<deltaPos && scrollUp) || (i>=moveBlockLength && !scrollUp) ) {
					rows[i]._y += Math.round(inc*shuffleBlockDistance);
					var newRow = i + inc*moveBlockLength;
					var newItem = __vPosition + newRow;

					tmpArray[newRow] = rows[i];
					tmpArray[newRow].rowIndex = newRow;
					tmpArray[newRow].drawRow(__dataProvider.getItemAt(newItem), getStateAt(newItem), false);
				} else {

					rows[i]._y -= Math.round(inc*moveBlockDistance);
					var newRow = i - inc*deltaPos;
					tmpArray[newRow] = rows[i];
					tmpArray[newRow].rowIndex = newRow;
				}
			}
			rows = tmpArray;
			for (var i=0; i<__rowCount; i++) {
				rows[i].swapDepths(baseRowZ + i);
			}
		}
		lastPosition = pos;
		super.setVPosition(pos);
	}


	/**
	* @param index the index of the item to modify
	* @param obj the property values of the item
	*
	* @helpid 3261
	* @tiptext Set properties of individual items
	*/
	function setPropertiesAt(index : Number, obj : Object) : Void
	{
		var id = __dataProvider.getItemID(index);
		if (id==undefined) return;
		if (propertyTable==undefined) {
			propertyTable = new Object();
		}
		propertyTable[id] = obj;
		rows[index-__vPosition].drawRow(__dataProvider.getItemAt(index), getStateAt(index));
	}

	function getPropertiesAt(index : Number) : Object
	{
		var id = __dataProvider.getItemID(index);
		if (id==undefined) return undefined;
		return propertyTable[id];
	}

 	function getPropertiesOf(obj : Object) : Object
 	{
 		var id = obj.getID();
 		if (id==undefined) return undefined;
 		return propertyTable[id];
 	}
 

	function getStyle(styleProp:String)
	{
		var v = super.getStyle(styleProp);
		var c = mx.styles.StyleManager.colorNames[v];
		if (c!=undefined) v = c;

		return v;
	}


	/**
	* refresh all rows (use sparingly!)
	*
	* @private
	*/
	function updateControl(Void) : Void
	{
//			trace("ssl.updateControl");
//		trace(__rowCount);
		for (var i=0; i<__rowCount; i++) {
//			trace("must be here!");
			rows[i].drawRow(__dataProvider.getItemAt(i+__vPosition), getStateAt(i+__vPosition));
		}
		delete invUpdateControl;
	}


	// figures out the state of a given item
	function getStateAt(index : Number) : String
	{
		return (isSelected(index) ? "selected" : "normal");
	}


	// used to fire a selection driven from user interaction, and update the display
 	function selectRow(rowIndex : Number, transition : Boolean, allowChangeEvent : Boolean) : Void
	{
		if (!selectable) return;
		var itemIndex = __vPosition + rowIndex;
		var item = __dataProvider.getItemAt(itemIndex);
		var row = rows[rowIndex];
		if (item==undefined) return;

		if (transition==undefined)
			transition = true;

		if (allowChangeEvent == undefined)
 	        allowChangeEvent = wasKeySelected;
		// begin multiple selection cases
		// we'll start by assuming the selection has changed
		changeFlag = true;

		if ( ( !multipleSelection && !Key.isDown(Key.CONTROL) ) || ( !Key.isDown(Key.SHIFT) && !Key.isDown(Key.CONTROL) ) )  {
			// Case one : just a plain old click
			//Clear all other selections, this is a single click

			clearSelected(transition);
			selectItem(itemIndex, true);
			lastSelected = itemIndex;
//			row.drawRow(getItemAt(itemIndex), getStateAt(itemIndex), transition);
			row.drawRow(row.item, getStateAt(itemIndex), transition);
		}
		else if ( Key.isDown(Key.SHIFT) && multipleSelection) {
			// case two : a click, with multiple selection on and SHIFT down.
			if (lastSelected==undefined) {
				lastSelected=itemIndex;
			}
			var incr = (lastSelected<itemIndex) ? 1 : -1;
			clearSelected(false);
			for (var i=lastSelected; i!=itemIndex; i+=incr) {
				selectItem(i, true);
				if (i>=__vPosition && i<__vPosition+__rowCount) {
					rows[i-__vPosition].drawRow(rows[i-__vPosition].item, "selected", false);
				}
			}
			selectItem(itemIndex, true);
			row.drawRow(row.item, "selected", transition);
		}
		else if (Key.isDown(Key.CONTROL)) {
			// case three : CTRL is down
			var selectedFlag = isSelected(itemIndex);
			if (!multipleSelection || wasKeySelected) {
				clearSelected(transition);
			}
			if (!(!multipleSelection && selectedFlag)) {
				selectItem(itemIndex, !selectedFlag);
				var state = !selectedFlag ? "selected" : "normal";
				row.drawRow(row.item, state, transition);
			}
			lastSelected=itemIndex;
		}
 		if (allowChangeEvent)
			dispatchEvent({type:"change"});
		delete wasKeySelected;
	}


	// interval function that scrolls the list up or down if the mouse goes above or below the list
	function dragScroll(Void) : Void
	{
		clearInterval(dragScrolling);
		if (_ymouse<0) {
			setVPosition(__vPosition-1);
			selectRow(0, false);
			var d = Math.min(0-_ymouse-30, 0);
			// quadratic relation between distance and scroll speed
			scrollInterval = 0.593*d*d + 1 + minScrollInterval;
			dragScrolling = setInterval(this, "dragScroll", scrollInterval);
			dispatchEvent({type:"scroll", direction:"vertical", position:__vPosition});

		}
		else if (_ymouse>__height) {

			var vPos = __vPosition;
			setVPosition(__vPosition+1);
			if (vPos!=__vPosition)
				selectRow(__rowCount-1-roundUp, false);
			var d = Math.min(_ymouse - __height-30, 0);
			scrollInterval = 0.593*d*d + 1 + minScrollInterval;
			dragScrolling = setInterval(this, "dragScroll", scrollInterval);
			dispatchEvent({type:"scroll", direction:"vertical", position:__vPosition});
		} else {
			dragScrolling = setInterval(this, "dragScroll", 15);
		}
		updateAfterEvent();
	}

	// catches mouse releases in or outside the list, fires change if appropriate
	function __onMouseUp(Void) : Void
	{
		clearInterval(dragScrolling);
		delete dragScrolling;
		delete dragScrolling;
		delete isPressed;
		delete onMouseUp;
		if (!selectable) return;

		if (changeFlag) {
			dispatchEvent({type:"change"});

		}
		delete changeFlag;
	}


	//::: KEY Support

	// Move selection up or down by increments Note this is for keyboard Support only.. no clicks!
	function moveSelBy(incr : Number) : Void
	{
		if (!selectable) {
			setVPosition(__vPosition+incr);
			return;
		}
		var curIndex = getSelectedIndex();
		if (curIndex == undefined) {
			curIndex = -1;
		}
		var newIndex = curIndex + incr;
		newIndex = Math.max(0, newIndex);
		newIndex = Math.min(getLength()-1, newIndex);
		if (newIndex==curIndex) {
			return;
		}
		if (curIndex<__vPosition || curIndex>=__vPosition + __rowCount) {
			setVPosition(curIndex);
		}
		if (newIndex>=__vPosition+__rowCount-roundUp || newIndex<__vPosition) {
			setVPosition(__vPosition+incr);
		}
		wasKeySelected = true;
		selectRow(newIndex-__vPosition, false);
	}

	// takes keystrokes and maps them to selection movement increments
	function keyDown(e:Object) : Void
	{
		if (selectable) {
			if (findInputText()) return;
		}
		if (e.code == Key.DOWN) {
			moveSelBy(1);
		} else if (e.code == Key.UP) {
			moveSelBy(-1);
		} else if (e.code == Key.PGDN) {
			if (selectable) {
				var curIndex = getSelectedIndex();
				if (curIndex==undefined) curIndex=0;
				setVPosition(curIndex);
			}
			moveSelBy(__rowCount-1 - roundUp);
		} else if (e.code == Key.PGUP) {
			if (selectable) {
				var curIndex = getSelectedIndex();
				if (curIndex==undefined) curIndex=0;
				setVPosition(curIndex);
			}
			moveSelBy(1-__rowCount + roundUp);
		} else if (e.code == Key.HOME) {
			moveSelBy(-__dataProvider.length);
		} else if (e.code == Key.END) {
			moveSelBy(__dataProvider.length);
		}
	}

	// does ascii lookup to see if it's time to find an item
	function findInputText(Void) : Boolean
	{

		var tmpCode = Key.getAscii();
		if (tmpCode>=33 && tmpCode<=126) {
			findString(String.fromCharCode(tmpCode));
			return true;
		}
	}

	// finds an item in the list based on a string and moves the selection to it
	function findString(str : String) : Void
	{
		if (__dataProvider.length==0) return;

		var curIndex = getSelectedIndex();
		if (curIndex==undefined) curIndex=0;
		var jump = 0;
		for (var i=curIndex+1; i!=curIndex; i++) {
			var itmStr = __dataProvider.getItemAt(i);
			if (itmStr instanceof XMLNode) {
				itmStr = itmStr.attributes[__labelField];
			} else if (typeof(itmStr)!="string") {
				itmStr = String(itmStr[__labelField]);
			}

			itmStr = itmStr.substring(0,str.length);
			if (str==itmStr || str.toUpperCase()==itmStr.toUpperCase()) {
				jump = i - curIndex;
				break;
			}
			if (i>=getLength()-1) {
				i=-1;
			}
		}
		if (jump!=0) {
			moveSelBy(jump);
		}
	}


	//::: PRIVATE INTERACTION METHODS
	// all the below catch mouse events from the rows

	function onRowPress(rowIndex : Number) : Void
	{
		if (!enabled) return;
		isPressed = true;
		dragScrolling = setInterval(this, "dragScroll", 15);
		onMouseUp = __onMouseUp;
		if (!selectable) return;

		selectRow(rowIndex);
	}

	function onRowRelease(rowIndex : Number) : Void
	{
	}

	function onRowRollOver(rowIndex : Number) : Void
	{
		if (!enabled) return;
//		var itm = __dataProvider.getItemAt(rowIndex+__vPosition);
		var itm = rows[rowIndex].item;
		if (getStyle("useRollOver") && itm!=undefined) {
			rows[rowIndex].drawRow(itm, "highlighted", false);
		}
		dispatchEvent({type:"itemRollOver", index: rowIndex+__vPosition});

	}

	function onRowRollOut(rowIndex : Number) : Void
	{
		if (!enabled) return;
		if (getStyle("useRollOver")) {
//			rows[rowIndex].drawRow(__dataProvider.getItemAt(rowIndex+__vPosition), getStateAt(rowIndex+__vPosition), false);
			rows[rowIndex].drawRow(rows[rowIndex].item, getStateAt(rowIndex+__vPosition), false);
		}
		dispatchEvent({type:"itemRollOut", index: rowIndex+__vPosition});

	}

	function onRowDragOver(rowIndex : Number) : Void
	{
		if (!enabled || isPressed!=true || !selectable) return;
		if (dropEnabled) {

		} else {
			if (dragScrolling) {
				selectRow(rowIndex, false);
			} else {
				onMouseUp = __onMouseUp;
				onRowPress(rowIndex);
			}
		}
	}

	function onRowDragOut(rowIndex : Number) : Void
	{

		if (!enabled) return;
		if (dragEnabled) {

		} else {
			onRowRollOut(rowIndex);
		}
	}


	//::: PRIVATE CONSTRUCTION METHODS

	function init(Void) : Void
	{
		super.init();
		tabEnabled = true;
		tabChildren = false;
		if (__dataProvider==undefined) {
			__dataProvider = new Array();
			__dataProvider.addEventListener("modelChanged", this);
		}

		baseRowZ = topRowZ = 10;
	}

	function createChildren(Void) : Void
	{
		super.createChildren();
		listContent = createEmptyMovieClip("content_mc", CONTENTDEPTH);
		invLayoutContent = true;
		invalidate();
	}


	function draw(Void) : Void
	{
		if (invRowHeight) {
			delete invRowHeight;
			__rowCount = 0;
			listContent.removeMovieClip();
			listContent = createEmptyMovieClip("content_mc", CONTENTDEPTH);

		}
		if (invUpdateControl) {
			updateControl();
		}
		border_mc.draw();
	}


	function invalidateStyle(propName : String) : Void
	{
		if (isRowStyle[propName]) {
			invUpdateControl = true;
			invalidate();
		}
		else
			for (var i=0; i<__rowCount; i++) {
				rows[i].invalidateStyle(propName);
		}
	super.invalidateStyle(propName);
	}

	static var SelectableRowDependency = mx.controls.listclasses.SelectableRow;
}
