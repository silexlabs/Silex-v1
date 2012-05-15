//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.utils.Iterator;

interface mx.utils.Collection
{
	function addItem(item:Object):Boolean;
	function clear():Void;
	function contains(item:Object):Boolean;
	function isEmpty():Boolean;
	function getIterator():Iterator;
	function getLength():Number;
	function getItemAt( index:Number ):Object;
	function removeItem(item:Object):Boolean;
}
