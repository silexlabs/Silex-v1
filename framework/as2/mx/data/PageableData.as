//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.DataRange;

interface mx.data.PageableData {
	function addEventListener( event:String, listener ):Void;
	function initialize( info:Object ):Void;
	function requestRange( range: DataRange ):Number;
	function removeEventListener( event:String, listener ):Void;
}