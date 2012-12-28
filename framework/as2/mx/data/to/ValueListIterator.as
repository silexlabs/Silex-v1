//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.utils.Iterator;

/**
  The ValueListIterator is an iterator for value list handler collection; it provides the cursoring 
  functionality within a transfer object collection.  How the traversal is performed is based entirely 
  on the sort assigned.
  
  @author	Jason Williams
*/
interface mx.data.to.ValueListIterator extends Iterator {
	
	function contains( item:Object ):Boolean;
	function first():Object;
	function find( propValues:Object ):Object;
	function findFirst( propValues:Object ):Object;
	function findLast( propValues:Object ):Object;
	function getFiltered():Boolean;
	function getFilterFunc():Function;
	function getLength():Number;
	function getCurrentItem():Object;
	function getCurrentItemIndex():Number;
	function getId():String;
	function getItemAt( index:Number ):Object;
	function getItemId( index:Number ):String;
	function getItemIndex( item:Object ):Number;
	function getSortInfo():Object;
	function hasPrevious():Boolean;
	function isEmpty():Boolean;
	function last():Object;
	function modelChanged( info:Object ):Boolean;
	function previous():Object;
	function removeRange():Void;
	function reset():Void;
	function setFiltered( value:Boolean ):Number;
	function setFilterFunc( func:Function ):Number;
	function setRange( startValues:Object, endValuess:Object):Void;
	function skip( offset:Number ):Object;
	function setSortOptions( order:Number ):Void;
	function sortOn( propList:Array, options:Number ):Void;
}