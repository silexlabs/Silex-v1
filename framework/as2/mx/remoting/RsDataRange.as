//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  This class provides the RecordSet data fetcher with the methods needed to
  support paging.  The RsDataFetcher will create an instance of this class
  to provide the next range of records to fetch by the RecordSet.
*/
class mx.remoting.RsDataRange extends Object implements mx.data.DataRange {
	
	/**
	  Constructs and instance with the start and end range of records to
	  fetch from the server.
	  
	  @param	s Number containing the first record in the range to fetch
	  @param	e Number containing the last record in the range to fetch
	*/
	function RsDataRange( s:Number, e:Number ) {
		super();
		_start = s;
		_end = e;
	}
	
	function getStart() {
		return( _start );
	}
	
	function getEnd() {
		return( _end );
	}
	
	function setEnd( e ):Void {
		_end = e;
	}
	
	function setStart( s ):Void {
		_start = s;
	}
	
	private var _start:Number;
	private var _end:Number;
}