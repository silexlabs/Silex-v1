//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.utils.Collection;
import mx.utils.Iterator;

/**
  The DeltaPacket interface provides access to the source component (e.g. DataSet) 
  and the collection of Delta created during modifications to the DataSet and its 
  transfer objects. 
  
  @tiptext	Contains collection of changes 
  @helpid	1473
*/
interface mx.data.components.datasetclasses.DeltaPacket extends Collection {
	
	/**
	  Returns configuration information that is specific to the implementation of
	  the DeltaPacket.  This method allows implementations of the DeltaPacket interface
	  to access custom information using this interface.
	  
	  @param	info Object containing information that only the implementation will
	  			understand
	  @return	Object contiaining the requested information
	  @tiptext 	Returns configuration information
	  @helpid	1572
	*/
	function getConfigInfo( info:Object ):Object;
	
	/**
	  Returns an iterator for this collection.
	  
	  @return	Iterator
	  @tiptext	Returns an iterator of the changes
	  @helpid	1474
	*/
	function getIterator():Iterator;

	/**
	  Returns the key information about this delta packet's items.  This information
	  is used during the resolve process between a component and the delta packet. 
	  
	  @return Object containing key property information for the items descibed in
	  			this delta packet.
	  tiptext Returns key information 
	*/
	function getKeyInfo():Object;

	/**
	  Returns the source of this DeltaPacket.
	  
	  @return	Object source of this DeltaPacket i.e. which DataSet did it come from.
	  @tiptext	Returns originating component
	  @helpid	1475
	*/
	function getSource():Object;

	/**
	  Returns the transaction ID of this DeltaPacket.
	  
	  @return	String transaction id for this delta packet
	  @tiptext	Returns associated transaction ID
	  @helpid	1476
	*/
	function getTransactionId():String;

	/**
	  Returns the date and time when this DeltaPacket was created.
	  
	  @return	Date containing the date and time this delta packet was created.
	  @tiptext	Returns the time stamp when the DeltaPacket was created
	  @helpid	1477
	*/
	function getTimestamp():Date;

	/**
	  Returns if the application of this delta packet should  be logged.
	  
	  @return	Boolean indicating if the changes of this packet should
	  			be logged when applied.
	  @tiptext	Returns true if changes are being logged
	  @helpid	1478
	*/
	function logChanges():Boolean;
}