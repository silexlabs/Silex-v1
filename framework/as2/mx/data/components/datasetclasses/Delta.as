//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.components.datasetclasses.DeltaItem;

/**
  The Delta interface provides access to the transfer object, collection, 
  and transfer object level changes. With this interface either a list of 
  just the changes to a transfer object or both changed and unchanged 
  values can be returned. 

  @tiptext	Contains list of changes to an item
  @helpid	1478
*/
interface mx.data.components.datasetclasses.Delta {
	/**
	  Adds the specified item to the delta item list or replaces an existing one found
	  with the same name.
	  
	  @param	item DeltaItem to add to the list
	  @tiptext	Adds the specified DeltaItem
	  @helpid	1479
	*/
	function addDeltaItem( d:DeltaItem ):Void;

	/**
	  Returns the unique ID for this delta.
	  
	  @return	Object containing the id which relates this delta back to the
	  			associated transfer object.
	  @tiptext	Returns the unique ID for this delta
	  @helpid	1480
	*/
	function getId():Object;

	/**
	  Returns the associated operation for this Delta. Valid values are
		<li>DeltaPacketConst.Added</li>
		<li>DeltaPacketConst.Removed</li>
		<li>DeltaPacketConst.Modified</li>
		
	  @return	Number indicating which operation occurred for this Delta.
	  @tiptext	Returns the associated operation
	  @helpid	1481
	*/
	function getOperation():Number;

	/**
	  Returns the list of changes for the associated transfer object.
	  
	  @return	Array of DeltaItems associated with this Delta
	  @tiptext	Returns list of DeltaItems for this Delta
	  @helpid	1482
	*/
	function getChangeList():Array;

	/**
	  Returns the DeltaItem with the specified name if it can be found in the list,
	  if the item can not be found null is returned
	  
	  @return	DeltaItem with the specified name or null if not found
	  @tiptext	Returns the named DeltaItem or null
	  @helpid	1483
	*/
	function getItemByName( name:String ):DeltaItem;

	/**
	  Returns the message associated with this Delta.
	  
	  @return	String containing the associated message or blank if not defined
	  @tiptext	Returns the associated message or blank
	  @helpid	1484
	*/
	function getMessage():String;

	/**
	  Returns the source object that this DeltaImpl has recorded changes for.
	  
	  @return	Object source of the changes
	  @tiptext	Returns original source object that was changed
	  @helpid	1485
	*/
	function getSource():Object;

	/**
	  Returns the associated DeltaPacket.

	  @return	Object DeltaPacket this Delta belongs to
	  @tiptext	Returns the associated DeltaPacket
	  @helpid	1486
	*/
	function getDeltaPacket():Object;

}