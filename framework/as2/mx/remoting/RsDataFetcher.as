//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.PageableList;
import mx.data.DataRange;
import mx.remoting.RsDataRange;

// ---------------------------------------------------
// RsDataFetcher -- helper class for the RecordSet
// this is an object that causes all the records
// to be fetched, one batch at a time
// ---------------------------------------------------

class mx.remoting.RsDataFetcher extends Object {
	
	function RsDataFetcher(pgRS:PageableList, increment:Number) {
		super();
		//trace("RsDataFetcher.constructor(" + RecordSet + ", " + increment + ")");
		mRecordSet = pgRS;
		mRecordSet.addEventListener("modelChanged", this);
		mIncrement = increment;
		mNextRecord = 0;
		mEnabled = true;
		doNext();
	}
	
	function disable():Void {
		mEnabled = false;
		//mRecordSet.removeEventListener( "modelChanged", this );
		//trace("RsDataFetcher disabled");
	}
	
	function doNext():Void {
		//trace("RsDataFetcher.doNext()");
		if (mEnabled) {
			while (true) {
				if (mNextRecord >= mRecordSet.getRemoteLength())	{
					//trace("RsDataFetcher done");
					return;
				}
		
				var range:DataRange = new RsDataRange( mNextRecord, mNextRecord + mIncrement - 1 );
				mHighestRequested = mRecordSet.requestRange( range );
				mNextRecord += mIncrement;
		
				if (mHighestRequested > 0) {
					//trace("RsDataFetcher request underway " + this.mHighestRequested);
					return;
				}
				//trace("RsDataFetcher.trying again");
			}
		}
	}		

	function modelChanged(eventObj:Object):Void	{
		//trace("RsDataFetcher.modelChanged( " + eventObj.eventName + "," + eventObj.firstItem + "," + eventObj.lastItem + "..." + this.mHighestRequested + ")");
		if ((eventObj.eventName == "updateItems") && 
			(eventObj.firstItem <= this.mHighestRequested) && 
			(eventObj.lastItem >= this.mHighestRequested))	{
			//trace("RsDataFetcher.request done. doing next");
			doNext();
		}
		
		if (eventObj.eventName == "allRows") {
			//trace("RsDataFetcher.allrows received");
			disable();
		}
	}
	
	private var mRecordSet:PageableList;
	private var mIncrement:Number;
	private var mNextRecord:Number;
	private var mEnabled:Boolean;
	private var mHighestRequested:Number;
}