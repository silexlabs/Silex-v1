//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/*=======================
        DataProvider Decorator Object
	 Meant for applying the DataProvider API to Array.prototype. Ensures all Arrays
	 are able to be manipulated by "getItemAt", etc, and can broadcast changes to views.
*/

import mx.events.EventDispatcher;

class mx.controls.listclasses.DataProvider extends Object
{


	// ::: BEGIN MIXIN BLOCK ::: All code here is for mixing in methods onto Array.

	static var mixinProps : Array = ["addView", "addItem", "addItemAt", "removeAll", "removeItemAt",
							"replaceItemAt", "getItemAt", "getItemID", "sortItemsBy", "sortItems",
							"updateViews", "addItemsAt", "removeItemsAt", "getEditingData", "editField"];


	//make sure we have a link to the package we depend on at static time
	static var evtDipatcher = mx.events.EventDispatcher;

	/**
	* @private
	* For decorating other class prototypes with the DataProvider API
	*
	* @param obj the object whose prototype will be initialized
	*/
	static function Initialize(obj:Object) : Boolean
	{
		var m = mixinProps;
		var l = m.length;

		// take all methods/props from our template object and put them on the prototype.
		obj = Function(obj).prototype;
		for (var i=0; i<l; i++) {
			obj[m[i]] = mixins[m[i]];
			_global.ASSetPropFlags(obj, m[i],1);
		}

		// add ability to broadcast events.
		EventDispatcher.initialize(obj);
		_global.ASSetPropFlags(obj, "addEventListener",1);
		_global.ASSetPropFlags(obj, "removeEventListener",1);
		_global.ASSetPropFlags(obj, "dispatchEvent",1);
		_global.ASSetPropFlags(obj, "dispatchQueue",1);


		//::: Adds a "lazy" Unique ID facility to all objects.
		Object.prototype.LargestID = 0;
		Object.prototype.getID = function()
		{
			if (this.__ID__==undefined) {
				this.__ID__ = Object.prototype.LargestID++;
				_global.ASSetPropFlags(this, "__ID__",1);
			}
			return this.__ID__;
		};
		_global.ASSetPropFlags(Object.prototype, "LargestID",1);
		_global.ASSetPropFlags(Object.prototype, "getID",1);

		return true;
	}


	// Template instance of DataProvider, from which we'll copy our methods/props.
	static var mixins: DataProvider = new DataProvider();

	// ::: END MIXIN BLOCK ::: All code below is for class definition.

	// inherent properties of array
	var length : Number;
	var splice : Function;
	var slice : Function;
	var sortOn : Function;
	var reverse : Function;
	var sort : Function;

	/**
	* @private
	* For adding views to the model
	*/
	var addEventListener : Function;
	var dispatchEvent : Function;

	function DataProvider(obj)
	{
	}


	/*
	* add an item someplace in the array
	*
	* @tiptext Adds an item at the specified index
	* @helpid 3210
	* @param index location in the array to insert
	* @param value the item to add
	*/
	function addItemAt(index : Number, value) : Void
	{
		if (index<length) {
			splice(index, 0, value);
		} else if (index>length) {
			trace("Cannot add an item past the end of the DataProvider");
			return;
		}
		this[index] = value;

		updateViews( "addItems", index, index);
	}


	/*
	* add an item to the end of the array
	*
	* @tiptext Appends an item to the end of the array
	* @helpid 3211
	* @param value the item to add (relaxed type for strings / objects)
	*/
	function addItem(value) : Void
	{
		addItemAt(length, value);
	}


	/**
	* @private
	* For adding several items to the array
	*
	* @param index the location for the items to be inserted
	* @param newItems the array of new items to add
	*/
	function addItemsAt(index : Number, newItems : Array) : Void
	{
		index = Math.min(length, index);
		newItems.unshift(index, 0);
		splice.apply(this, newItems);
		newItems.splice(0, 2);
		updateViews( "addItems", index, index+newItems.length-1 );
	}


	/**
	* @private
	* For removing several items from the Array views to the model
	*
	* @param index the location of the items to remove
	* @param len the number of items to remove
	*/
	function removeItemsAt(index : Number, len : Number) : Void
	{
		var itemIDs = new Array();
		for (var i=0; i<len; i++) {
			itemIDs.push(getItemID(index+i));
		}
		var oldItems = splice(index, len);
		//updateViews( "removeItems", index, index+len, oldItems, itemIDs );
		dispatchEvent({type:"modelChanged", eventName:"removeItems",
					  		firstItem:index, lastItem:index+len-1,
							removedItems:oldItems, removedIDs:itemIDs});
	}


	/**
	* remove the item at the specified location
	*
	* @tiptext Removes the item at the specified index
	* @helpid 3212
	* @param index the location of the item to remove
	* @return the item being deleted - relaxed return type for string / object
	*/
	function removeItemAt(index : Number)
	{
		var ret = this[index];
		removeItemsAt(index, 1);
		return ret;
	}


	/**
	* remove the item at the specified location - relaxed return type for string / object
	*
	* @tiptext Removes all items
	* @helpid 3213
	* @param index the location of the item to remove
	*/
	function removeAll(Void) : Void
	{
		splice(0);
		updateViews("removeItems", 0, length-1);
	}


	/**
	* remove the item at the specified location - relaxed return type for string / object
	*
	* @tiptext Replaces the item at the specified index
	* @helpid 3214
	* @param index the location of the item to remove
	*/
	function replaceItemAt(index : Number, itemObj) : Void
	{
		if (index<0 || index>=length) {
			return;
		}
		var tmpID = getItemID(index);
		this[index] = itemObj;
		this[index].__ID__ = tmpID;
		updateViews( "updateItems", index, index );
	}


	/**
	* returns the item at the specified location - relaxed return type for string / object
	*
	* @tiptext Gets the item at the specified index
	* @helpid 3215
	* @param index the location of the item to return
	* @return the item at the location
	*/
	function getItemAt(index : Number)
	{
		return this[index];
	}


	/**
	* @private
	* For getting a Unique ID for every item
	*
	* @param index the location of the item
	*/
	function getItemID(index : Number) : Number
	{
		var i = this[index];
		if (typeof(i)!="object" && i!=undefined) {
			return index;
		} else {
			return i.getID();
		}
	}


	/**
	* Sorts the list of items - relaxed parameter types for overloading
	*
	* @tiptext Sorts the array by some field of each item
	* @helpid 3216
	* @param fieldName the field (or array of fieldNames) upon which to sort
	* @param order either "asc" or "desc", or the options accepted by Array.sort
	*/
	function sortItemsBy(fieldName, order) : Void
	{
		// old "asc" or "desc"
		if (typeof(order)=="string") {
			sortOn(fieldName);
			if (order.toUpperCase()=="DESC") {
				reverse();
			}
		} else {
			sortOn(fieldName, order);
		}
		updateViews( "sort" );
	}


	/**
	* Sorts the list of items - relaxed parameter types for overloading
	*
	* @tiptext Sorts the array by using a compare function
	* @helpid 3217
	* @param compareFunc - the function to use for comparing items
	* @param optionFlags the options accepted by Array.sort
	*/
	function sortItems(compareFunc, optionFlags) : Void
	{
		sort(compareFunc, optionFlags);
		updateViews( "sort" );
	}


	/**
	* @private
	* Edits one field
	*
	* @param index the index of the item
	* @param fieldName the name of the field to edit
	* @param newData the new data for the field
	*/
	function editField(index : Number, fieldName : String, newData) : Void
	{
		this[index][fieldName] = newData;
//		updateViews( "updateField", index, index, undefined, undefined, fieldName );
		dispatchEvent({type:"modelChanged", eventName:"updateField",
					  		firstItem:index, lastItem:index, fieldName:fieldName});
	}


	/**
	* @private
	* Gets data in a user-editable format - relaxed return type
	*
	* @param index the index of the item
	* @param fieldName the name of the field to edit
	*/
	function getEditingData(index : Number, fieldName : String)
	{
		return this[index][fieldName];

	}


	/**
	* @private
	* takes a generic object, makes it into an event, and dispatches it
	*
	* @param eventObj the object to dispatch
	*/
	function updateViews(event, first, last) : Void
	{
		this.dispatchEvent({type:"modelChanged", eventName: event, firstItem:first, lastItem:last});
	}

}
