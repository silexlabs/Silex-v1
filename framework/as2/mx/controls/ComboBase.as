//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.listclasses.DataSelector;
import mx.controls.SimpleButton;
import mx.controls.TextInput;
import mx.core.UIComponent;
import mx.skins.RectBorder;

/*
		ComboBase
		EXTENDS UIComponent

		ComboBase consists of a dataProvider, a textfield and a button.
		The dataProvider and its API come courtesy of DataSelector.
		Subclasses can add a data picker (such as a pulldown).
*/

class mx.controls.ComboBase extends UIComponent
{
	// Initialize our class to "inherit" DataSelector methods.
	static var mixIt1 : Boolean = DataSelector.Initialize(mx.controls.ComboBase);
	// mixins from DataSelector
	var setDataProvider:Function;
	var getDataProvider:Function;
	var getLength:Function;
	var modelChanged:Function;
	var calcPreferredWidthFromData:Function;
	var calcPreferredHeightFromData:Function;
	var getSelectedIndex:Function;
	var getSelectedItem:Function;
	var getSelectedIndices:Function;
	var getSelectedItems:Function;
	var selectItem:Function;
	var isSelected:Function;
	var clearSelected:Function;
	var setSelectedIndex:Function;
	var setSelectedIndices:Function;
	var setSelectedItem:Function;

							 
	//-- Initialization ----------------------------------------
	static var symbolName:String = "ComboBase";
	static var symbolOwner:Object = ComboBase;
	//#include "../core/ComponentVersion.as"

	var	_editable:Boolean = false;

	var	downArrowUpName:String = "ComboDownArrowUp";
	var	downArrowDownName:String = "ComboDownArrowDown";
	var	downArrowOverName:String = "ComboDownArrowOver";
	var	downArrowDisabledName:String = "ComboDownArrowDisabled";
	var wrapDownArrowButton:Boolean = false;

	var	boundingBox_mc:Object;
	var	downArrow_mc:Object;
	var onDownArrow:Function;

	var oldOnKillFocus:Function;
	var oldOnSetFocus:Function;
	
	var __border:RectBorder;
	var	border_mc:RectBorder;
	var	text_mc:TextInput;

	var	trackAsMenuWas:Boolean;

	// Set ourselves up as a data selector.
	var	DSgetValue:Function = DataSelector.prototype.getValue;

// Props Mixed In from DataSelector

// TIPTEXT BLOCK -- PLEASE NOTE, REPLACE ~~ WITH * FOR THIS TO WORK

 	/**
	* @helpid 3050
	* @tiptext The list of data to be used as a model
	*/
	var dataProvider : Object;

 	/**
	* @param index the index at which to add the item
	* @param label the label of the new item
	* @param data the data for the new item
	* @return the added item
	*
	* @helpid 3051
	* @tiptext Adds an item at the specified index
	*/
	var addItemAt : Function;

 	/**
	* @param label the label of the new item
	* @param data the data for the new item
	* @return the added item
	*
	* @helpid 3052
	* @tiptext Appends an item to the end of the list
	*/
	var addItem : Function;

	/**
	* @param index the index of the item to remove
	* @return the removed item
	*
	* @helpid 3053
	* @tiptext Removes the item at the specified index
	*/
	var removeItemAt : Function;

	/**
	* @helpid 3054
	* @tiptext Removes all items
	*/
	var removeAll : Function;

 	/**
	* @param index the index of the item to replace
	* @param label the label for the replacing item
	* @param data the data for the replacing item
	*
	* @helpid 3055
	* @tiptext Replaces the item at the specified index
	*/
	var replaceItemAt : Function;

 	/**
	* @param fieldName the field to sort on
	* @param order either "ASC" or "DESC"
	*
	* @helpid 3056
	* @tiptext Sorts the list by some field of each item
	*/
	var sortItemsBy : Function;

 	/**
	* @param compareFunc a function to use for comparison
	*
	* @helpid 3057
	* @tiptext Sorts the list by using a compare function
	*/
	var sortItems : Function;

 	/**
	* @helpid 3058
	* @tiptext Gets the number of items in the list
	*/
	var length : Number;

 	/**
	* @param index the index of the items to return
	* @return the item
	*
	* @helpid 3059
	* @tiptext Gets the item at the specified index
	*/
	var getItemAt : Function;

 	/**
	* @helpid 3060
	* @tiptext Gets the selected data (or label)
	*/
	var value : Object;

	/**
	* @helpid 3061
	* @tiptext Gets or sets the selected index
	*/
	var selectedIndex : Number;

 	/**
	* @helpid 3062
	* @tiptext Gets or sets the selected indices
	*/
	var selectedIndices : Array;

	/**
	* @helpid 3063
	* @tiptext Returns the selected items
	*/
	var selectedItems : Array;

	/**
	* @helpid 3064
	* @tiptext Returns the selected item
	*/
	var selectedItem; // relaxed type - could be string but usually object

 	/**
	* @helpid 3065
	* @tiptext If true, multiple selection is allowed
	*/
	var multipleSelection : Boolean = false;



// END TIPTEXT BLOCK

	var __dataProvider : Object;
	var selected : Object;

 // Functions Mixed in from DataSelector

	//::: SELECTION METHODS

	var getValue : Function;

	//-- Constructor -----------------------------------------
	function ComboBase()
	{
		// Make sure we are using OUR getValue, not DataSelector's!
		getValue = _getValue;
	}

	//-- Creation (self)--------------------------------------
	function init():Void
	{
	//** 6a) call super.init().  This adds your StyleDeclaration (if nobody gave you one
	//       and sets initial values for width and height
		super.init();

		tabEnabled = !_editable;
		tabChildren = _editable;
		boundingBox_mc._visible = false;
		boundingBox_mc._width = this.boundingBox_mc._height = 0;
	}

	//-- Creation (children) ---------------------------------
	function createChildren():Void
	{
		var o = new Object();
		o.styleName = this;

		// arrow button
		if (downArrow_mc == undefined)
		{
			o.falseUpSkin = downArrowUpName;
			o.falseOverSkin = downArrowOverName;
			o.falseDownSkin = downArrowDownName;
			o.falseDisabledSkin = downArrowDisabledName;
			o.validateNow = true;
			o.tabEnabled = false;
			createClassObject(SimpleButton, "downArrow_mc", 19, o);
			downArrow_mc.buttonDownHandler = this.onDownArrow;
			downArrow_mc.useHandCursor = false;

			// Only start handling the button as a menu when first clicked,
			// so it doesn't interfere with other comboBox buttons. Stop
			// when the mouse is dragged out of the button, and restore when
			// dragged back in.
			downArrow_mc.onPressWas = downArrow_mc.onPress;
			downArrow_mc.onPress = function()
			{
				this.trackAsMenuWas = this.trackAsMenu;
				this.trackAsMenu = true;

				if (!this._editable)
					this._parent.text_mc.trackAsMenu = this.trackAsMenu;

				this.onPressWas();
			};
			downArrow_mc.onDragOutWas = downArrow_mc.onDragOut;
			downArrow_mc.onDragOut = function()
			{
				this.trackAsMenuWas = this.trackAsMenu;
				this.trackAsMenu = false;
				if (!this._editable)
					this._parent.text_mc.trackAsMenu = this.trackAsMenu;
				this.onDragOutWas();
			};
			downArrow_mc.onDragOverWas = downArrow_mc.onDragOver;
			downArrow_mc.onDragOver = function()
			{
				this.trackAsMenu = this.trackAsMenuWas;
				if (!this._editable)
					this._parent.text_mc.trackAsMenu = this.trackAsMenu;
				this.onDragOverWas();
			};
		}

		if (this.border_mc == undefined)
		{
			o.tabEnabled = false;
			createClassObject(_global.styles.rectBorderClass, "border_mc", 17, o);
			border_mc.move(0, 0);
			__border = border_mc;
		}

		o.borderStyle = "none";
		o.readOnly = !this._editable;
		o.tabEnabled = this._editable;
		if (text_mc == undefined)
		{
			createClassObject(TextInput, "text_mc", 18, o);
			text_mc.move(0, 0);
			text_mc.addEnterEvents();
			text_mc.enterHandler = _enterHandler;
			text_mc.changeHandler = _changeHandler;
			text_mc["oldOnSetFocus"] = text_mc.onSetFocus;
			text_mc.onSetFocus = function()
			{
				this.oldOnSetFocus();
				this._parent.onSetFocus();
			};

			// Don't show ESC characters in the text field.
			text_mc.restrict = "^\u001b";
		
			text_mc["oldOnKillFocus"] = text_mc.onKillFocus;
			text_mc.onKillFocus = function(n)
			{
				this.oldOnKillFocus(n);
				this._parent.onKillFocus(n);
			};
			text_mc.drawFocus = function(b)
			{
				this._parent.drawFocus(b);
			};
			delete text_mc.borderStyle;	// this seems to be necessary in order to have text_mc inherit this borderStyle.
		}
		focusTextField = text_mc;
		text_mc.owner = this;

		layoutChildren(__width, __height);
	}

	function onKillFocus():Void
	{
		super.onKillFocus();
		Key.removeListener(text_mc);
		getFocusManager().defaultPushButtonEnabled = true;
	}

	function onSetFocus():Void
	{
		super.onSetFocus();
		getFocusManager().defaultPushButtonEnabled = false;
		Key.addListener(text_mc);
	}

	//  :::  PUBLIC METHODS

	function setFocus():Void
	{
		if (_editable)
			Selection.setFocus(text_mc);
		else
			Selection.setFocus(this);
	}

	//-- Set Size ---------------------------------------------
	/**
	* @tiptext Sets the size
	* @helpid 3409
	*/
	function setSize(w:Number, h:Number, noEvent):Void
	{
		super.setSize(w, (h == undefined) ? height : h, noEvent);
	}

	//-- Enabled ---------------------------------------------
	function setEnabled(enabledFlag:Boolean):Void
	{
		super.setEnabled(enabledFlag);
		downArrow_mc.enabled = enabledFlag;
		text_mc.enabled = enabledFlag;
	}

	//-- Editable ---------------------------------------------
	//   regsiter the editable setter with a proxy function to avoid
	//	 a bug in Player 6.0 that doesn't allow overrides of getters and setters
	function setEditable(e:Boolean):Void
	{
		_editable = e;
		if(wrapDownArrowButton == false){
			if (e)
			{
				border_mc.borderStyle = "inset";
				text_mc.borderStyle = "inset";
				symbolName = "ComboBox";
				invalidateStyle();
			}
			else
			{
				border_mc.borderStyle = "comboNonEdit";
				text_mc.borderStyle = "dropDown";
				symbolName = "DropDown";
				invalidateStyle();
			}
		}
		tabEnabled = !e;
		tabChildren = e;
		text_mc.tabEnabled = e;

		if (e)
		{
			// Editable ComboBox uses the textField just like the button.
			delete text_mc.onPress;
			delete text_mc.onRelease;
			delete text_mc.onReleaseOutside;
			delete text_mc.onDragOut;
			delete text_mc.onDragOver;
			delete text_mc.onRollOver;
			delete text_mc.onRollOut;
		}
		else
		{
			// Trap all mouse actions on the textfield and feed them to the button
			text_mc.onPress = function () {
				this._parent.downArrow_mc.onPress();
			};
			text_mc.onRelease = function() {
				this._parent.downArrow_mc.onRelease();
			};
			text_mc.onReleaseOutside = function() {
				this._parent.downArrow_mc.onReleaseOutside();
			};
			text_mc.onDragOut = function() {
				this._parent.downArrow_mc.onDragOut();
			};
			text_mc.onDragOver = function() {
				this._parent.downArrow_mc.onDragOver();
			};
			text_mc.onRollOver = function() {
				this._parent.downArrow_mc.onRollOver();
			};
			text_mc.onRollOut = function() {
				this._parent.downArrow_mc.onRollOut();
			};

			text_mc.useHandCursor = false;
		}
	}

/**
* true if the component is editable
*
* @tiptext	If true, the ComboBox is editable
* @helpid 3903
*/
	[Inspectable(defaultValue=false)]
	function get editable():Boolean
	{
		return _editable;
	}
	function set editable(e:Boolean):Void
	{
		setEditable(e);
	}

	//-- Value -----------------------------------------------
	function _getValue()
	{
		return (_editable) ? text_mc.getText() : DSgetValue();
	}

	//-- Draw ------------------------------------------------
	//** 9) create an draw method.  Most of the time, all you'll need to do
	//		is force a layout of your objects
	function draw():Void
	{
		downArrow_mc.draw();
		border_mc.draw();
	}

	//-- Size -------------------------------------------------
	//** 10) replace your setSize with an size()
	// stretches the track, creates + positions arrows
	function size():Void
	{
		layoutChildren(__width, __height);
	}

	//-- Theme ----------------------------------------------
	//** 11) create a setTheme function
	function setTheme(t:String):Void
	{
		downArrowUpName =  t + "downArrow" + "Up_mc";
		downArrowDownName =  t + "downArrow" + "Down_mc";
		downArrowDisabledName =  t + "downArrow" + "Disabled_mc";
	}

	//-- Text -------------------------------------------------
    /**
    * @tiptext Gets (and sets, if editable is true) the contents of the text field
    * @helpid 3407
    */
	function get text():String
	{
		return text_mc.getText();
	}
	function set text(t:String):Void
	{
		setText(t);
	}

	function setText(t:String):Void
	{
		text_mc.setText(t);
	}

	//-- Text Field -------------------------------------------
	// Getter to return the textfield. Read-only, so no setter.
    /**
    * @tiptext  A reference to the TextInput component
    * @helpid 3408
    */
	function get textField()
	{
		return text_mc;
	}
	
 	
 	/**
 	* List of characters to allow.
 	*
 	* @tiptext The set of characters that may be entered into the ComboBase
 	* @helpid ???
 	*/
 	[Inspectable(category="Limits",verbose=1)]
 	[ChangeEvent("restrictChanged")]
 	function get restrict():String
 	{
 		return text_mc.restrict;
 	}
 	
 	function set restrict(w:String) 
 	{
 		text_mc.restrict = w;
 		// No need to dispatch an event because the text_mc will fire the event
 	}

	//  ::: PRIVATE METHODS

	//-- Invalidate Style -------------------------------------
	function invalidateStyle():Void
	{
		downArrow_mc.invalidateStyle();
		text_mc.invalidateStyle();
		border_mc.invalidateStyle();
	}

	function layoutChildren(w:Number, h:Number):Void
	{
		//changed this to support Halo Theme for the down arrow
		if (downArrow_mc == undefined)
			return;

		if (wrapDownArrowButton){
			var vM = border_mc.borderMetrics;
			downArrow_mc._width = downArrow_mc._height = h - vM.top - vM.bottom;
			downArrow_mc.move( w - downArrow_mc._width - vM.right, vM.top );
			border_mc.setSize(w, h);
			text_mc.setSize(w - downArrow_mc._width, h);
		}else{
			downArrow_mc.move( w - downArrow_mc._width, 0 );
			border_mc.setSize(w - downArrow_mc.width, h);
			text_mc.setSize(w - downArrow_mc._width, h);
			downArrow_mc._height = height;
		}
	}

	//-- Change Handler -------------------------------------
	function _changeHandler(obj) : Void
	{
	}

	//-- Enter Handler ---------------------------------------
	function _enterHandler(obj) : Void
	{
		var o = this._parent; // 'this' is the pulldown; 'o' is the combobox
		obj.target = o;
		o.dispatchEvent(obj);
	}

/**
* tab order when using tab key to navigate
*
* @tiptext tabIndex of the component
* @helpid 3198
*/
  	function get tabIndex():Number
  	{
    	return text_mc.tabIndex;
  	}

  	function set tabIndex(w:Number):Void
  	{
    	text_mc.tabIndex=w;
  	}
	
}
