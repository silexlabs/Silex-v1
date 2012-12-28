//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


/**
  The DataSetError is thrown whenever there is an unrecoverable problem with an operation on the dataset.
  
  @author	Jason Williams
*/
class mx.data.components.datasetclasses.DataSetError extends Error {
	
	function DataSetError( msg:String ) {
		super( msg );
	}
	
	function toString():String {
		return( message );
	}
}