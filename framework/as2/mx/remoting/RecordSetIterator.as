//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.utils.Iterator;
import mx.remoting.RecordSet;

class mx.remoting.RecordSetIterator implements Iterator
{

//#include "RemotingComponentVersion.as"
/**
	Initialize the Iterator and maintain a link to it's RecordSet
	
	@param rec RecordSet to which this Iterator belongs.
*/	
	function RecordSetIterator(rec:RecordSet) 
	{
		_recordSet = rec;
		_cursor = 0;
	}

/**
	Returns true if this list iterator has more elements when traversing the list in the forward direction
	
	@return Boolean true if iteration has more items.
*/	
	function hasNext():Boolean 
	{
		return(_cursor < _recordSet.getLength());
	}	
	
/**
	Return the next item in the iteration and increment the cursor. Returns null if the 
	iteration has no more items.
	
	@return Object the next item in the Iteration.
*/	
	function next():Object 
	{
		return(_recordSet.getItemAt(_cursor++));
	}

	//internal pointer to RecordSet
	private var _recordSet:RecordSet;

	//internal pointer to current item in the iteration
	private var _cursor:Number;

}