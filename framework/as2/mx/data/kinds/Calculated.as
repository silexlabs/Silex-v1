//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.kinds.Data;

/**
  This kind allows for psuedo schema on DataSets.  These properties of a transfer
  object dont exist on the actual server represenation, just locally on the client.
  
*/
class mx.data.kinds.Calculated extends Data {
	
	public var isCalculated:Boolean = true;
}