//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.ComboBase;
import mx.controls.List;
import mx.core.UIObject;
import mx.effects.Tween;
import mx.managers.PopUpManager;

/**
* @tiptext change event
* @helpid 3066
*/
[Event("change")]
/**
* @tiptext open event
* @helpid 3067
*/
[Event("open")]
/**
* @tiptext close event
* @helpid 3365
*/
[Event("close")]
/**
* @tiptext enter event
* @helpid 3904
*/
[Event("enter")]
/**
* @tiptext itemRollOver event
* @helpid 3070
*/
[Event("itemRollOver")]
/**
* @tiptext itemRollOut event
* @helpid 3071
*/
[Event("itemRollOut")]
/**
* @tiptext scroll event
* @helpid 3072
*/
[Event("scroll")]

[TagName("ComboBox")]
[IconFile("ComboBox.png")]
[DataBindingInfo("acceptedTypes","{dataProvider: {label: &quot;String&quot;}}")]

/**
* ComboBox class
* - extends ComboBase
* - uses Popup class
* - adds a listbox inside a popup, and a mask
* @tiptext ComboBox provides the ability to select an option from a dropdown list
* @helpid 3073
*/

class mx.controls.ComboBox extends ComboBase
{
	//-- Initialization ----------------------------------------
	static var symbolName:String = "ComboBox";
	static var symbolOwner:Object = ComboBox;
	//#include "../core/ComponentVersion.as"

	var	clipParameters:Object = { labels:1, data:1, editable: 1, rowCount: 1, dropdownWidth: 1};
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(ComboBox.prototype.clipParameters, ComboBase.prototype.clipParameters);
	var   className : String = "ComboBox";

	var	__labels:Array;
	[Inspectable]
	var	data:Array;

	var	_showingDropdown:Boolean = false;
	var	__rowCount:Number = 5;
	var	__dropdownWidth:Number;
	var	__dropdown:MovieClip;
	var	mask:MovieClip;
	var	dropdownBorderStyle:String = undefined;
	var initializing = true;

	var	__labelField:String = "label";
	var	__labelFunction:Function;
 	var __selectedIndexOnDropdown:Number;
	var __initialSelectedIndexOnDropdown:Number;
	
	var	dispatchValueChangedEvent:Function;
	var	addItemAt:Function;

	[Bindable(param1="writeonly",type="DataProvider")]
	var	dataProvider:Array;

	var	length:Number;

	[Bindable("readonly")]
	[ChangeEvent("change")]
	var	selectedItem:Object;

	[Bindable]
	[ChangeEvent("change")]
	var	selectedIndex:Number;

	[Bindable("readonly")]
	[ChangeEvent("change")]
	var _inherited_value : String;

	var isPressed : Boolean;

	// used by button events
	var owner:Object; 
	
	var bInKeyDown : Boolean = false;

	//-- Constructor -----------------------------------------
	function ComboBox()
	{
	}

	//-- Creation (self)--------------------------------------
	function init() : Void
	{
		super.init();
	}

	//-- Creation (children) ---------------------------------
	function createChildren() : Void
	{
		super.createChildren();

		// Set our editable state to itself in order to force the onPress method to be set (if necessary).
		editable = editable;

		// Convert clip parameters (label and data) into a dataProvider.
		if (__labels.length > 0)
		{
			var dp = new Array();
			for (var i=0; i<labels.length;i++) {
				dp.addItem( {label:labels[i], data:data[i]} );
			}
			// Set this to overwrite the one set for Live Preview. Don't just addItem to the existing one.
			setDataProvider(dp);
		}

		// Set the dropdownWidth (and the width of the dropdown listbox). Make sure to pick up
		// the initClip parameter if defined. Otherwise, just use the width of the component.
		dropdownWidth = (typeof(__dropdownWidth) == "number") ? __dropdownWidth : __width;

		if (!_editable)
			selectedIndex = 0;

		initializing = false;
	}

	function onKillFocus(n) : Void
	{
		if(_showingDropdown && n != null)
			displayDropdown(false);
		super.onKillFocus();
	}

	//-- Creation (dropdown) -----------------------------------
	function getDropdown() : Object
	{
		if (initializing)
			return undefined;

		if (!hasDropdown())
		{
			var o = new Object();
			o.styleName = this;
			if (dropdownBorderStyle != undefined)
				o.borderStyle = dropdownBorderStyle;
			o._visible = false;
			__dropdown = PopUpManager.createPopUp(this, List, false, o, true);
			// !!! Alert. Have to destroy the List Box's mask since we also
			// have a mask and masks inside masks don't work on Win XP. Player Bug.
			// Make sure this is done before calling super.createChildren().
			__dropdown.scroller.mask.removeMovieClip();
			// !!! End of Alert.

			// Set up a data provider in case one doesn't yet exist, so we can share it with the dropdown listbox.
			if (dataProvider == undefined)
				dataProvider = new Array();

			__dropdown.setDataProvider(dataProvider);
			__dropdown.selectMultiple = false;
			__dropdown.rowCount = __rowCount;
			__dropdown.selectedIndex = selectedIndex;
			__dropdown.vScrollPolicy = "auto";
//			__dropdown.borderStyle = "outset";
			__dropdown.labelField = __labelField;
			__dropdown.labelFunction = __labelFunction;
			__dropdown.owner = this;
			__dropdown.changeHandler = _changeHandler;
			__dropdown.scrollHandler = _scrollHandler;
			__dropdown.itemRollOverHandler = _itemRollOverHandler;
			__dropdown.itemRollOutHandler = _itemRollOutHandler;
			__dropdown.resizeHandler = _resizeHandler;
			__dropdown.mouseDownOutsideHandler = function(eventObj)
			{
 				o = this.owner;
 				var pt = new Object();
 				pt.x = o._root._xmouse;
 				pt.y = o._root._ymouse;
 				o._root.localToGlobal(pt);
 				if( o.hitTest(pt.x, pt.y, false) ) {
					// do nothing
				}
				else if (!this.wrapDownArrowButton && this.owner.downArrow_mc.hitTest(_root._xmouse, _root._ymouse, false)) {
					// do nothing
				}
				else {
 					o.displayDropdown(false);
				}
			};
			__dropdown.onTweenUpdate = function(v) { this._y = v; };
			__dropdown.setSize( __dropdownWidth, __dropdown.height );

			// Create the mask that keeps the dropdown listbox only visible below the textfield.
			createObject("BoundingBox", "mask",20);
			mask._y = border_mc.height;
			mask._width = __dropdownWidth;
			mask._height = __dropdown.height;
			mask._visible = false;
			__dropdown.setMask(mask);
		}

		return __dropdown;
	}

	//  :::  PUBLIC METHODS

	//-- Size ------------------------------------------------
	function setSize(w:Number, h:Number, noEvent) : Void
	{
		super.setSize(w, h, noEvent);
		__dropdownWidth = w;
		__dropdown.rowHeight = h;
		__dropdown.setSize(__dropdownWidth, __dropdown.height);
	}

	//-- Editable ---------------------------------------------
	function setEditable(e:Boolean) : Void
	{
		super.setEditable(e);
		if (e)
		{
			text_mc.setText( "" );
		}
		else
		{
			text_mc.setText( selectedLabel );
		}
	}

        [Inspectable(defaultValue="")]
	function get labels() : Array
	{
		// for live preview only
		return __labels;
	}
	function set labels(lbls : Array)
	{
		__labels = lbls;
		setDataProvider(lbls);		// Set this for Live Preview.
	}

	//-- LabelField ------------------------------------------
	function getLabelField():String
	{
		return __labelField;
	}

/**
* @tiptext The name of the field in dataProvider array objects to use as the label field
* @helpid 3074
*/
	function get labelField():String
	{
		return getLabelField();
	}

	function setLabelField(s:String):Void
	{
		__dropdown.labelField = __labelField = s;
		text_mc.setText(selectedLabel);
	}

	function set labelField(s:String):Void
	{
		setLabelField(s);
	}

	//-- Label Function -------------------------------------
	function getLabelFunction():Function
	{
		return __labelFunction;
	}

/**
* @tiptext A user-supplied function to run on each item to determine its label
* @helpid 3075
*/
	function get labelFunction():Function
	{
		return getLabelFunction();
	}

	function set labelFunction(f:Function):Void
	{
		__dropdown.labelFunction = __labelFunction = f;
		text_mc.setText(selectedLabel);
	}

	//-- Selected Item --------------------------------------
	function setSelectedItem(v) : Void
	{
		// Tricky stuff going on here.
		// Our super is ComboBase, but it doesn't have a setSelectedIndex method.
		// Instead, since DataSelector is a "mix-in" class to ComboBox, our
		// prototype chain shows DataSelector.setSelectedIndex linked to the
		// prototype of ComboBox, so it appears as our superclass method.
		super.setSelectedItem(v);

		// Tell the dropdown listbox to update its selectedItem.
		__dropdown.selectedItem = v;

		// Set the text of the edit field.
		text_mc.setText(selectedLabel);
	}

	//-- Selected Index -------------------------------------
	function setSelectedIndex(v:Number) : Void
	{
		// Tricky stuff going on here.
		// Our super is ComboBase, but it doesn't have a setSelectedIndex method.
		// Instead, since DataSelector is a "mix-in" class to ComboBox, our
		// prototype chain shows DataSelector.setSelectedIndex linked to the
		// prototype of ComboBox, so it appears as our superclass method.
		super.setSelectedIndex(v);

		// Tell the dropdown listbox to update its selectedItem.
		__dropdown.selectedIndex = v;

		if (v != undefined)
			// Set the text of the edit field.
			text_mc.setText(selectedLabel);

		// Send a valueChanged event, which is used by the data model
		dispatchValueChangedEvent(getValue());
	}

	//-- Row Count ------------------------------------------
	function setRowCount(count:Number) : Void
	{
		if (isNaN(count)) return;
		__rowCount = count;
		__dropdown.setRowCount(count);
	}

	[Inspectable(defaultValue=5)]
/**
* @tiptext The maximum number of rows visible in the dropdown list
* @helpid 3076
*/
	function get rowCount() : Number
	{
		return Math.max(1, Math.min(length, __rowCount));
	}

	function set rowCount(v:Number) : Void
	{
		setRowCount(v);
	}

	//-- Dropdown Width -------------------------------------
	function setDropdownWidth(w:Number) : Void
	{
		__dropdownWidth = w;
		__dropdown.setSize(w, __dropdown.height);
	}

/**
* @tiptext Width limit (in pixels) of the Popup containing the dropdown list
* @helpid 3077
*/
	function get dropdownWidth() : Number
	{
		return __dropdownWidth;
	}

	function set dropdownWidth(v:Number) : Void
	{
		setDropdownWidth(v);
	}

	//-- Dropdown  ---------------------------------------------
/**
* @tiptext Returns a reference to the List component contained by the Combo Box
* @helpid 3078
*/
	function get dropdown() : Object
	{
		return getDropdown();
	}

	//-- Data Provider ---------------------------------------
	function setDataProvider(dp:Array)
	{
		super.setDataProvider(dp);
		__dropdown.setDataProvider(dp);

		if (!_editable)
			selectedIndex = 0;
	}

	//-- Open -----------------------------------------------
/**
* @tiptext Opens the dropdown list
* @helpid 3079
*/
	function open() : Void
	{
		displayDropdown(true);
	}

	//-- Close -----------------------------------------------
/**
* @tiptext Closes the dropdown list
* @helpid 3080
*/
	function close() : Void
	{
		displayDropdown(false);
	}

//  :::  PROTECTED METHODS

	//-- Selected Label --------------------------------------
	function get selectedLabel() : String
	{
		var item = selectedItem;

		if (item == undefined)
			return "";
		else if (labelFunction != undefined)
			return labelFunction(item);
		else if (typeof(item) != "object")
			return item;
		else if (item[labelField] != undefined)
			return item[labelField];
		else if (item.label != undefined)
			return item.label;
	    else
	    {
	        //written to match SelectableRow.itemToString
            var tmpLabel=" ";
            for (var i in item) {
                if (i!="__ID__") {
                    tmpLabel = item[i] + ", " + tmpLabel;
                }
            }
            tmpLabel = tmpLabel.substring(0,tmpLabel.length-3);
            return tmpLabel;
	    }
	}

	//-- Has Dropdown ---------------------------------------
	function hasDropdown() : Boolean
	{
		return (__dropdown != undefined && __dropdown.valueOf() != undefined);
	}

	//-- Tween End (show) ----------------------------------
	function tweenEndShow(value:Number) : Void
	{
		_y = value;
		isPressed= true;
 		owner.dispatchEvent({type:"open", target:owner});
	}

	//-- Tween End (hide) -----------------------------------
	function tweenEndHide(value : Number) : Void
	{
		_y = value;
		visible = false;
 		owner.dispatchEvent({type:"close", target:owner});
	}

	//-- Display Dropdown ------------------------------------
	function displayDropdown(show:Boolean) : Void
	{
		if (show == _showingDropdown)
			return;

		// subclasses may extend to do pre-processing before the dropdown is displayed
		// or override to implement special display behavior
		var point = new Object();
		point.x = 0;
		point.y = height;
		localToGlobal(point);

		if (show) {
 			// Store the selectedIndex temporarily so we can tell 
 			// if the value changed when the dropdown is closed
 			__selectedIndexOnDropdown = selectedIndex;	
			__initialSelectedIndexOnDropdown = selectedIndex; 
			getDropdown();
			
			var dd = __dropdown;
			dd.isPressed = true;
			dd.rowCount = rowCount;	// Don't show more lines than there is data for in the dropdown.
			dd.visible = show;
 			dd._parent.globalToLocal(point);
			dd.onTweenEnd = tweenEndShow;
			var	initVal;
			var	endVal;
			if (point.y + dd.height > Stage.height)
			{
				// Dropdown will go below the bottom of the stage and be clipped.
				// Instead, have it grow up. Position the mask above, too.
				initVal = point.y - height;
				endVal = initVal - dd.height;
				mask._y =  -dd.height;
			}
			else
			{
				initVal = point.y - dd.height;
				endVal = point.y;
				mask._y = border_mc.height;
			}
			var sel = dd.selectedIndex;
			if (sel==undefined) sel = 0;
			var pos = dd.vPosition;
//			if (sel>pos+dd.rowCount || sel < pos) {
				pos = sel-1;
				pos = Math.min( Math.max(pos,0) , dd.length-dd.rowCount);
				dd.vPosition = pos;
//			}
			// This move probably isn't necessary. Most likely we can depend on the
			// first call to the tweenUpdate method to set the _y value correctly.
			dd.move(point.x, initVal);
			dd.tween = new Tween(__dropdown, initVal, endVal, getStyle("openDuration"));
		}
		else {
 			__dropdown._parent.globalToLocal(point);
			delete __dropdown.dragScrolling;
			__dropdown.onTweenEnd = tweenEndHide;
			__dropdown.tween = new Tween(__dropdown, __dropdown._y, point.y-__dropdown.height, getStyle("openDuration"));
			if (__initialSelectedIndexOnDropdown!=selectedIndex)
				dispatchChangeEvent(undefined,__initialSelectedIndexOnDropdown, selectedIndex);
		}

		var ease = getStyle("openEasing");
		if (ease!= undefined)
			__dropdown.tween.easingEquation = ease;

		_showingDropdown = show;

	}

	//  :::  PRIVATE METHODS

	//-- On Down Arrow -------------------------------------
	function onDownArrow() : Void
	{
		// the down arrow should always toggle the visibility of the dropdown
		_parent.displayDropdown(!_parent._showingDropdown);
	}

	//-- On Key Down ---------------------------------------
	function keyDown(e:Object) : Void
	{
		if (e.ctrlKey && e.code == Key.DOWN)
		{
			displayDropdown(true);
		}
		else if (e.ctrlKey && e.code == Key.UP)
		{
			displayDropdown(false);
 			dispatchChangeEvent(undefined,__selectedIndexOnDropdown,selectedIndex);
		}
		
		else if (e.code == Key.ESCAPE)
		{
			displayDropdown(false);
		}
		else if (e.code == Key.ENTER)
		{
			if (_showingDropdown)
			{
				selectedIndex = __dropdown.selectedIndex;
				displayDropdown(false);
			}
		}
		else
		{
			if (!_editable || e.code == Key.UP || e.code == Key.DOWN || e.code == Key.PGUP || e.code == Key.PGDN)
			{
				selectedIndex = 0 + selectedIndex;

				// Make sure we know we are handling a keyDown, so if the dropdown
				// sends out a "change" event (like when an up-arrow or down-arrow
				// changes the selection) we know not to close the dropdown.
				bInKeyDown = true;
				var	dd = dropdown;
				dd.keyDown(e);
				bInKeyDown = false;
				
				selectedIndex  = __dropdown.selectedIndex;
			}
		}
	}

	//-- Invalidate Style -------------------------------------
	function invalidateStyle(styleProp:String) : Void
	{
		__dropdown.invalidateStyle(styleProp);
		super.invalidateStyle(styleProp);
	}

	function changeTextStyleInChildren(styleProp:String):Void
	{
		if (dropdown.stylecache != undefined)
		{
			delete dropdown.stylecache[styleProp];
			delete dropdown.stylecache.tf;
		}
		__dropdown.changeTextStyleInChildren(styleProp);
		super.changeTextStyleInChildren(styleProp);
	}

	//-- Makes sure colors percolate to the list. -------------------------------------
	function changeColorStyleInChildren(sheetName :String, styleProp:String, newValue) : Void
	{
		if (dropdown.stylecache != undefined)
		{
			delete dropdown.stylecache[styleProp];
			delete dropdown.stylecache.tf;
		}
		__dropdown.changeColorStyleInChildren(sheetName, styleProp, newValue);
		super.changeColorStyleInChildren(sheetName, styleProp, newValue);
	}

	function notifyStyleChangeInChildren(sheetName:String, styleProp:String, newValue) :Void
	{
		if (dropdown.stylecache != undefined)
		{
			delete dropdown.stylecache[styleProp];
			delete dropdown.stylecache.tf;
		}
		__dropdown.notifyStyleChangeInChildren(sheetName, styleProp, newValue);
		super.notifyStyleChangeInChildren(sheetName, styleProp, newValue);
	}

	//-- Destructor ------------------------------------------
	function onUnload() : Void
	{
		__dropdown.removeMovieClip();
	}

	//PRIVATE EVENT HANDLERS

	//-- Resize Handler -------------------------------------
	function _resizeHandler() : Void
	{
		var o = this.owner;
		o.mask._width = width;
		o.mask._height = height;
	}

	//-- Change Handler ------------------------------------
	function _changeHandler(obj) : Void
	{
		var o = this.owner; // 'this' is the dropdown; 'o' is the combobox
 		var prevValue = o.selectedIndex;
		obj.target = o;

		if (this == this.owner.text_mc)
		{
			o.selectedIndex = undefined;
			o.dispatchChangeEvent(obj,-1,-2); // Force a change event to be dispatched
		}
		else
		{
			// This assignment will also assign the label to the text field. See setSelectedIndex().
			o.selectedIndex = selectedIndex;
			// If this was generated by the dropdown as a result of a keystroke, it is
			// likely a Page-Up or Page-Down, or Arrow-Up or Arrow-Down. If the selection
			// changes due to a keystroke, we leave the dropdown displayed. If it changes
			// as a result of a mouse selection, we close the dropdown.
 			if (!o._showingDropdown)
 			{
 				o.dispatchChangeEvent(obj,prevValue, o.selectedIndex);
 			} else if (!o.bInKeyDown) {
				o.displayDropdown(false);
 				//o.dispatchChangeEvent(obj,-1, o.selectedIndex);
 				
 			}
		}
		//o.dispatchEvent(obj);
	}

	//-- Scroll Handler --------------------------------------
	function _scrollHandler(obj) : Void
	{
		var o = this.owner;
		obj.target = o;
		o.dispatchEvent(obj);
	}

	//-- Item Roll Over Handler -----------------------------
	function _itemRollOverHandler(obj) : Void
	{
		var o = this.owner;
		obj.target = o;
		o.dispatchEvent(obj);
	}

	//-- Item Roll Out Handler ------------------------------
	function _itemRollOutHandler(obj) : Void
	{
		var o = this.owner;
		obj.target = o;
		o.dispatchEvent(obj);
	}

	function modelChanged(eventObj:Object) : Void
	{
		super.modelChanged(eventObj);

		if (0 == __dataProvider.length)
		{
			// Special case: Empty dataProvider. Text Field should be empty.
			text_mc.setText("");
			delete selected;
		}
		else if (__dataProvider.length == (eventObj.lastItem-eventObj.firstItem+1) && eventObj.eventName == "addItems")
		{
			// Special case: Adding the first item. Select it.
			selectedIndex = 0;
		}
	}
 	
 	function dispatchChangeEvent(obj,prevValue,newValue)
 	{
 		var eventObj:Object;
 		//trace(obj.type + "   "  + prevValue + "    " + newValue);
 		if (prevValue != newValue)
 		{
 			if (obj != undefined && obj.type == "change")
 			{
 				eventObj = obj;
 			} 
 			else 
 			{
 				eventObj = {type:"change"};
 			}
 			
 			//eventObj.prevValue = prevValue;
 			//eventObj.newValue = newValue;
 			
 			dispatchEvent(eventObj);
 		}
 	}
 	
 	private static var ButtonDependency = mx.controls.Button;
}
