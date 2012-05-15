//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


/*=======================
	DataSelector Decorator Class

DataSelector is a Decorator or mixin class, which
dynamically adds methods and properties to other
objects (typically the prototype of another class).
In this case, the functionality added is for interfacing
with both a dataProvider and a multiple-selection state.
This gets used in ComboBox and ScrollSelectList,
and should be useful for other classes wishing to
"inherit" this functionality.

========================== */

class mx.controls.listclasses.DataSelector extends Object
{

	/*   mixins is a template instance of DataSelector
		from which the methods/props will be copied to
		the receiving class.								*/
	static var mixins: DataSelector = new DataSelector();

	// a list of methods that will be mixed onto the target object
	static var mixinProps : Array = [ "setDataProvider", "getDataProvider",  "addItem", "addItemAt", "removeAll", "removeItemAt",
							 "replaceItemAt", "sortItemsBy", "sortItems", "getLength", "getItemAt", "modelChanged",
							 "calcPreferredWidthFromData", "calcPreferredHeightFromData", "getValue", "getSelectedIndex",
							 "getSelectedItem", "getSelectedIndices", "getSelectedItems", "selectItem", "isSelected",
							 "clearSelected", "setSelectedIndex", "setSelectedIndices"];


	// Applies methods and props to the object passed
	static function Initialize(obj) : Boolean
	{
		var m = mixinProps;
		var l = m.length;

		obj = Function(obj).prototype;
		for (var i=0; i<l; i++) {
			obj[m[i]] = mixins[m[i]];
		}

		// add getter/setter properties
		mixins.createProp(obj, "dataProvider", true);
		mixins.createProp(obj, "length", false);
		mixins.createProp(obj, "value", false);
		mixins.createProp(obj, "selectedIndex", true);
		mixins.createProp(obj, "selectedIndices", true);
		mixins.createProp(obj, "selectedItems", false);
		mixins.createProp(obj, "selectedItem", true);
		return true;
	}

	/*   dynamically adds Properties to the object passed,
		builds inline functions to be passed to addProperty	*/
	function createProp(obj : Object, propName:String, setter:Boolean) : Void
	{
		var p = propName.charAt(0).toUpperCase() + propName.substr(1);
		var s = null;
		var g = function(Void)
		{
			return this["get" + p]();
		};
		if (setter) {
			s = function(val)
			{
				this["set" + p](val);
			};
		}
		obj.addProperty(propName, g, s);

	}




	/* ===========================
		Note : All properties and methods below
		must be redeclared in the class that
		accepts the mixin. A template for declaring
		all of this can be found at the bottom of
		this file
	*/
	var __dataProvider : Object;

	var vPosition : Number;
	var __vPosition : Number;
	var __rowCount : Number;
	var multipleSelection : Boolean;
	var enabled : Boolean;
	var lastSelID : Number;
	var lastSelected;
	var selectionDeleted : Boolean;
	var selected : Object;

	var invUpdateControl : Boolean;

	var invalidate : Function;
	var createLabel : Function;
	var labelFunction : Function;
	var labelField : String;
	var updateControl : Function;
	var setVPosition : Function;
	var __width : Number;
	var _getTextFormat:Function;

	var tempLabel : Object;
	var rows : Object;
	var isDragScrolling : Boolean;


	//::: DATA MANAGEMENT APIs

	function setDataProvider(dP : Object) : Void
	{
		if (__vPosition!=0)
			setVPosition(0);
		clearSelected();

		// clear the association with the old dP
		__dataProvider.removeEventListener(this);

		__dataProvider = dP;


		dP.addEventListener("modelChanged", this);
        //support Cental LCDataProvider
        dP.addView(this);
		
		modelChanged({eventName:"updateAll"});
	}

	function getDataProvider(Void) : Object
	{
		return __dataProvider;
	}

	function addItemAt(index : Number, label, data) : Void
	{
		if (index<0 || !enabled) return;
		var dp = __dataProvider;
		if (dp==undefined) {
			dp = __dataProvider = new Array();
			dp.addEventListener("modelChanged", this);
			index = 0;		// in case it comes in as "undefined" from addItem.
		}
		if (typeof(label) == "object" || typeof(dp.getItemAt(0))=="string") {
			dp.addItemAt(index, label);
		} else {
			dp.addItemAt(index, {label:label, data:data});
		}
	}

	function addItem(label, data) : Void
	{
		addItemAt(__dataProvider.length, label, data);
	}

	function removeItemAt(index:Number) : Object
	{
		return __dataProvider.removeItemAt(index);
	}

	function removeAll(Void) : Void
	{
		__dataProvider.removeAll();
	}

	function replaceItemAt(index : Number, newLabel, newData) : Void
	{
		if (typeof(newLabel) == "object") {
			__dataProvider.replaceItemAt(index, newLabel);
		} else {
			__dataProvider.replaceItemAt(index, {label:newLabel, data:newData} );
		}
	}

	function sortItemsBy(fieldName, order) : Void
	{
		lastSelID = __dataProvider.getItemID(lastSelected);
		__dataProvider.sortItemsBy(fieldName, order);
	}

	function sortItems(compareFunc, order) : Void
	{
		lastSelID = __dataProvider.getItemID(lastSelected);
		__dataProvider.sortItems(compareFunc, order);
	}


	function getLength(Void) : Number
	{
		return __dataProvider.length;
	}


	function getItemAt(index : Number) : Object
	{
		return __dataProvider.getItemAt(index);
	}


	//::: PRIVATE DATA MANAGEMENT METHOD


	// ModelChanged catches all events broadcast from the model (see dataProvider.as)
	function modelChanged(eventObj:Object)
	{

		var firstItem = eventObj.firstItem;
		var lastItem = eventObj.lastItem;

		var event = eventObj.eventName;

		//-!! backwards compatible special-case for old recordset
		if (event==undefined) {
			event = eventObj.event;
			firstItem = eventObj.firstRow;
			lastItem = eventObj.lastRow;
			if (event=="addRows") {
				event = eventObj.eventName = "addItems";
			}
			else if (event=="deleteRows")
				event = eventObj.eventName = "removeItems";
			else if (event=="updateRows")
				event = eventObj.eventName = "updateItems";
		}

		// added items - manage selections by incrementing indices
		if (event=="addItems") {
			for (var i in selected) {
				var ind = selected[i];
				if (ind!=undefined && ind>=firstItem) {
					selected[i]+=lastItem-firstItem+1;
				}
			}
		// removed items - manage selections by decrementing and deleting indices
		} else if (event=="removeItems") {
			if (__dataProvider.length==0) {
				delete selected;
			} else {
				var removedIDs = eventObj.removedIDs;
				var len = removedIDs.length;
				for (var i=0; i<len; i++) {
					var id = removedIDs[i];
					if (selected[id]!=undefined) {
						delete selected[id];
					}
				}

				for (var i in selected) {
					if (selected[i]>=firstItem) {
						selected[i]-=lastItem-firstItem+1;
					}
				}
			}
		} else if (event=="sort") {
			// rehash selections
			if (typeof(__dataProvider.getItemAt(0))!="object") {
				delete selected;
			} else {
				var len = __dataProvider.length;
				for (var i = 0; i<len; i++) {
					if (isSelected(i)) {
						var id = __dataProvider.getItemID(i);
						if (id == lastSelID) {
							lastSelected = i;
						}
						selected[id] = i;
					}
				}

			}
		} else if (event=="filterModel") {
			setVPosition(0);
		}

		invUpdateControl = true;
		invalidate();
	}


	//::: SELECTION METHODS

	function getValue(Void) : Object
	{
		var item = getSelectedItem();
		if (typeof(item)!="object") return item;
		return (item.data==undefined) ? item.label : item.data;
	}


	function getSelectedIndex(Void) : Number
	{
		for (var uniqueID in selected) {
			var tmpInd = selected[uniqueID];
			if (tmpInd!=undefined) {
				return tmpInd;
			}
		}
	}

	// Sets the indices specified
	function setSelectedIndex(index : Number) : Void
	{
		if (index>=0 && index<__dataProvider.length && enabled) {
			delete selected;
			selectItem(index, true);
			lastSelected = index;
			invUpdateControl = true;
			invalidate();
		} else if (index==undefined) {
			// clear Selection
			clearSelected();
		}
	}


	function getSelectedIndices(Void) : Array
	{
		var tmpArray = new Array();
		for (var i in selected) {
			tmpArray.push(selected[i]);
		}
		tmpArray.reverse();
		return (tmpArray.length>0) ? tmpArray : undefined;
	}

	function setSelectedIndices(indexArray : Array) : Void
	{
		if (multipleSelection!=true) return;
		delete selected;
		for (var i=0; i<indexArray.length; i++) {
			var iA = indexArray[i];
			if (iA>=0 && iA<__dataProvider.length) {
				selectItem(iA, true);
			}
		}
		invUpdateControl = true;
		updateControl();
	}

	function getSelectedItems(Void) : Array
	{
		var indices = getSelectedIndices();
		var tmpArray= new Array();
		for (var i=0; i<indices.length; i++) {
			tmpArray.push(getItemAt(indices[i]));
		}
		return (tmpArray.length>0) ? tmpArray : undefined;
	}

	function getSelectedItem(Void) : Object
	{
		return __dataProvider.getItemAt(getSelectedIndex());
	}


	// ::: PRIVATE SELECTION METHODS

	// selectItem manages the object bookkeeping that stores the fact an item is selected or not
	// not to be confused with selectRow, which is used to actually fire a selection and update the display
	function selectItem(index : Number, selectedFlag : Boolean) : Void
	{
		if (selected==undefined) {
			selected = new Object();
		}
		var ID = __dataProvider.getItemID(index);
		if (ID==undefined) return;
		if (selectedFlag && !isSelected(index)) {
			selected[ID] = index;
		}
		else if (!selectedFlag) {
			delete selected[ID];
		}
	}

	function isSelected(index) : Boolean
	{
		var id = __dataProvider.getItemID(index);
		if (id==undefined) return false;
		return (selected[id]!=undefined);
	}

	function clearSelected(transition:Boolean) : Void
	{
		var count = 0;
		for (var uniqueID in selected) {
			var index = selected[uniqueID];
			if (index!=undefined && __vPosition<=index && index<__vPosition+__rowCount) {
				rows[index-__vPosition].drawRow(rows[index-__vPosition].item, "normal", (transition && count%3==0));
			}
			count++;
		}
		delete selected;
	}


}


/* MIXIN TEMPLATE

// Props Mixed In from DataSelector

// TIPTEXT BLOCK -- PLEASE NOTE, REPLACE ~~ WITH * FOR THIS TO WORK

 	/**
	* @helpid 3218
	* @tiptext the list of data to be used as a model
	~~/
	var dataProvider : Object;

 	/**
	* @param index the index at which to add the item
	* @param label the label of the new item
	* @param data the data for the new item
	* @return the added item
	*
	* @helpid 3219
	* @tiptext adds an item to the list
	~~/
	var addItemAt : Function;

 	/**
	* @param label the label of the new item
	* @param data the data for the new item
	* @return the added item
	*
	* @helpid 3220
	* @tiptext adds an item to the end of the list
	~~/
	var addItem : Function;

	/**
	* @param index the index of the item to remove
	* @return the removed item
	*
	* @helpid 3221
	* @tiptext removes an item from the list
	~~/
	var removeItemAt : Function;

	/**
	* @helpid 3222
	* @tiptext removes all items from the list
	~~/
	var removeAll : Function;

 	/**
	* @param index the index of the item to replace
	* @param label the label for the replacing item
	* @param data the data for the replacing item
	*
	* @helpid 3223
	* @tiptext adds an item to the list
	~~/
	var replaceItemAt : Function;

 	/**
	* @param fieldName the field to sort on
	* @param order either "ASC" or "DESC"
	*
	* @helpid 3224
	* @tiptext sorts the list by some field of each item
	~~/
	var sortItemsBy : Function;

 	/**
	* @param compareFunc a function to use for comparison
	*
	* @helpid 3225
	* @tiptext sorts the list by using a compare function
	~~/
	var sortItems : Function;

 	/**
	* @helpid 3226
	* @tiptext the length of the list in items
	~~/
	var length : Number;

 	/**
	* @param index the index of the items to return
	* @return the item
	*
	* @helpid 3227
	* @tiptext returns the item at the requested index
	~~/
	var getItemAt : Function;

 	/**
	* @helpid 3228
	* @tiptext returns the selected data (or label)
	~~/
	var value : Object;

	/**
	* @helpid 3229
	* @tiptext returns or sets the selected index
	~~/
	var selectedIndex : Number;

 	/**
	* @helpid 3230
	* @tiptext returns or sets the selected indices
	~~/
	var selectedIndices : Array;

	/**
	* @helpid 3231
	* @tiptext returns the selected items
	~~/
	var selectedItems : Array;

	/**
	* @helpid 3232
	* @tiptext returns the selected item
	~~/
	var selectedItem; // relaxed type - could be string but usually object

 	/**
	* @helpid 3233
	* @tiptext allows the control to have multiple selected items
	~~/
	var multipleSelection : Boolean = false;



// END TIPTEXT BLOCK

	var __dataProvider : Object;
	var vPosition : Number;
	var __rowCount : Number;
	var enabled : Boolean;
	var lastSelID : Number;
	var lastSelected;
	var selected : Object;

	var invUpdateControl : Boolean;

	var invalidate : Function;
	var createLabel : Function;
	var labelFunction : Function;
	var labelField : String;
	var updateControl : Function;
	var __width : Number;

	var tempLabel : Object;
	var rows : Object;
	var isDragScrolling : Boolean;

 // Functions Mixed in from DataSelector

 	var setDataProvider : Function;
	var getDataProvider : Function;
	var getLength : Function;

	//::: PRIVATE DATA MANAGEMENT METHOD

	var modelChanged : Function;
	var calcPreferredWidthFromData : Function;
	var calcPreferredHeightFromData : Function;

	//::: SELECTION METHODS

	var getValue : Function;
	var getSelectedIndex : Function;
	var setSelectedIndex : Function;
	var getSelectedIndices : Function;
	var setSelectedIndices : Function;
	var getSelectedItems : Function;
	var getSelectedItem : Function;

	// ::: PRIVATE SELECTION METHODS

	var selectItem : Function;
	var isSelected : Function;
	var clearSelected : Function;

*/
