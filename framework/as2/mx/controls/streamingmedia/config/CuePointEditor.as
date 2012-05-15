//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.containers.ScrollPane;
import mx.controls.Label;
import mx.controls.streamingmedia.config.CuePointList;
import mx.controls.streamingmedia.config.MediaConfig;


class mx.controls.streamingmedia.config.CuePointEditor
extends MovieClip
{
	/** The scroll pane */
	private var _scroller:ScrollPane;

	/** Text labels */
	private var cuePointsLabel:Label;
	private var nameLabel:Label;
	private var positionLabel:Label;
	
	/** The visible list of cue points */
	private var _list:CuePointList;
	/**
	 * The cue point data. An array of arrays. The second array has 
	 * two elements: first is name, second is time in seconds.
	 */
	private var _data:Array;
	
	public function CuePointEditor()
	{
		init();
	}
	
	private function init():Void
	{
		// Register itself
		MediaConfig.cuePointEditor = this;
		
		_data = new Array();
		// Populate the data array
		var x:Object = _root.xch;
		consolidateData( x.initCuePointNames, x.initCuePointTimes );
	}

	/**
	 * Initialize after the child objects have initialized.
	 */
	private function initOnFrame1():Void
	{
		_list = CuePointList(_scroller.spContentHolder);
		_list.setData(_data);
//		Tracer.trace("list=" + _list + ", type=" + typeof(_list));

		var bigSsName:String = MediaConfig.createStyleSheet("big");
		cuePointsLabel.setStyle("styleName", bigSsName);
	}
	
	public function addNewCuePoint():Void
	{
		var row:Array = [ "", 0 ];
		_data.push(row);
		_list.addCuePoint( "", 0, _data.length - 1 );
	}
	
	/**
	 * Delete the last cue point in the list.
	 */
	public function deleteCuePoint():Void
	{
		// Get the index of the last cue point
		var ix:Number = _data.length - 1;
		// Remove it from the data array
		_data.splice(ix, 1);
		// Ask the list the delete the visual representation of the last cue point
		_list.deleteCuePoint();

		// Push the changes to the xch object
		var nameTime:Array = separateData();
		var x:Object = _root.xch;
		x.initCuePointNames = nameTime[0];
		x.initCuePointTimes = nameTime[1];
	}
	
	/**
	 * Update the data array and push the data to the xch object
	 */
	public function updateRow(row:Number, name:String, seconds:Number):Void
	{
		// Update the _data array
		var newRow:Array = [ name, seconds ];
		_data[row] = newRow;
//		Tracer.trace("CuePointEditor.updateRow: Row " + row + " updated to " + _data[row]);
		// Push the data to the xch object
		// Create separate name and time arrays
		var nameTime:Array = separateData();
		var x:Object = _root.xch;
		x.initCuePointNames = nameTime[0];
		x.initCuePointTimes = nameTime[1];
	}

	public function updateCuePointDisplay():Void
	{
		_list.updateCuePointDisplay();
	}

	private function consolidateData(names:Array, times:Array):Void
	{
		_data.length = Math.min( names.length, times.length );
		var row:Array;
		for (var ix:Number = 0; ( (ix < names.length) && (ix < times.length) ); ix++)
		{
			row = [ names[ix], times[ix] ];
			_data[ix] = row;
//			Tracer.trace("CuePointEditor.consolidateData: adding row: " + row);
		}
	}
	
	private function separateData():Array
	{
		var names:Array = new Array(_data.length);
		var times:Array = new Array(_data.length);

		for (var ix:Number = 0; ix < _data.length; ix++)
		{
			names[ix] = _data[ix][0];
			times[ix] = _data[ix][1];
		}
		
		var both:Array = [ names, times ];
		return both;
	}
}