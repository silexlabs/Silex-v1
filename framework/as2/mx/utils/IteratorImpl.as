//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.utils.Collection;
import mx.utils.Iterator;

class mx.utils.IteratorImpl implements Iterator {

/**
	Initialize the Iterator and maintain a link to it's Collection
	
	@param coll Collection to which this Iterator belongs.
*/	
	function IteratorImpl(coll:Collection) {
		_collection = coll;
		_cursor = 0;
	}

/**
	Returns true if the iteration has more items.
	
	@return Boolean true if iteration has more items.
*/	
	function hasNext():Boolean {
		return(_cursor < _collection.getLength());
	}	
	
/**
	Return the next item in the iteration and increment the cursor. Returns null if the 
	iteration has no more items.
	
	@return Object the next item in the Iteration.
*/	
	function next():Object {
		return(_collection.getItemAt(_cursor++));
	}	

	//internal pointer to Collection
	private var _collection:Collection;

	//internal pointer to current item in the iteration
	private var _cursor:Number;

}