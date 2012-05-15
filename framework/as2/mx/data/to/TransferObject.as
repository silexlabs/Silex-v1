//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  Defines what is needed for an object to conform to the DataSet's implementation
  of the ValueList pattern.
*/
interface mx.data.to.TransferObject {
	function clone():Object;
	function getPropertyData():Object;
	function setPropertyData( propData:Object ):Void;
}