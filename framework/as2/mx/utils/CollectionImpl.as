//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


import mx.utils.Collection;
import mx.utils.Iterator;
import mx.utils.IteratorImpl;

/**
  Helper class used to manage a collection of objects. This class is similar to the Java
	Collection interface.  Developers can extend this class to create new Collection types
	that provide additional functionality such as ordering and sorting.
*/ 
class mx.utils.CollectionImpl extends Object implements Collection {

	/**
		Initialize the Collection.
	*/	
	function CollectionImpl() {
		super();
		_items = new Array();
	}

	/**
		Adds a new item to the end of the Collection.
		
		@param item Object to be added to the Collection. If item is Null it will not be added to
		the Collection.
		@return Boolean true if the Collection was changed as a result of the operation.
	*/	
	function addItem(item:Object):Boolean {
		var result:Boolean = false;
		if (item !=null ) {
			_items.push(item);
			result = true;
		} 
		return(result);
	}

	/**
		Removes all items from the Collection.
	*/	
	function clear():Void {
		_items = new Array();
	}
	
	/**
		Returns true if this Collection contains the specified item.
		
		@param item Object whose presence in this collection is to be tested. 
		@return Boolean true if this collection contains the specified item.
	*/	
	public function contains(item:Object):Boolean {
		return(internalGetItem(item)>-1);
	}

	/**
		Returns an item within the Collection using it's index.
		
		@param index location of item within the Collection.
		@return Object reference to item.
	*/	
	function getItemAt(index:Number):Object {
		return(_items[index]);
	}

	/**
		Returns an iterator over the elements in this collection. There are no guarantees concerning 
		the order in which the elements are returned (unless this collection is an instance of some 
		class that provides a guarantee). 
		
		@return Iterator object that is used to iterate through the collection.
	*/	
	function getIterator():Iterator {
		return(new IteratorImpl(this));
	}

	/**
		Returns the current length
	
		@return Number value reflecting the number of items in this Collection.
	*/	
	public function getLength():Number {
		return( _items.length );
	}

	/**
		Returns true if the Collection is empty.
		
		@return Boolean true if Collection is empty.
	*/	
	function isEmpty():Boolean {
		return(_items.length == 0);
	}

	/**
		Removes a single item from the Collection.  Returns false if item is not found.
		
		@param item reference to Collection item to be removed from Collection
		@return Boolean true if item is found and successfully removed.  False if item is not found.
	*/	
	function removeItem(item:Object):Boolean {
		var result:Boolean = false;
		var itemIndex:Number = internalGetItem(item);
		if (itemIndex>-1) {
			_items.splice(itemIndex,1);
			result = true;
		}
		return(result);
	}
	
	// ---- private members -----
	
	/**
		Finds an item within the Collection and returns it's index.
		
		@private
		@param item reference to Collection item to be found
		@return Number location of item within the Collection.
	*/	
	private function internalGetItem(item:Object):Number {
		var result:Number = -1;
		for (var i=0; i<_items.length; i++) {
			if (_items[i] == item) {
				result = i;
				break;
			}
		}
		return(result); 
	}

	private var _items:Array;

}
