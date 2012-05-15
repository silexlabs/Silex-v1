//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

interface mx.data.PageableList extends mx.data.PageableData {
	function addItem( item:Object ):Void;
	function addItemAt( index:Number, item:Object ):Void;
	function clear():Void;
	function contains( item:Object ):Boolean;
	function getItemAt( index:Number ):Object;
	//function getIterator():Iterator;
	function getLength():Number;
	function getLocalLength():Number;
	function getRemoteLength():Number;
	function isEmpty():Boolean;
	function isLocal():Boolean;
	function removeItemAt( index:Number ):Object;
	function replaceItemAt( index:Number, item:Object ):Void;
}