//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.containers.ScrollPane;

class mx.controls.streamingmedia.config.CuePointList
extends MovieClip
{
	private var _cuePoints:Array;
	private var _scroller:ScrollPane;
	
	public function CuePointList()
	{
		init();
	}
	
	private function init():Void
	{
		_cuePoints = new Array();
		_scroller = ScrollPane(_parent);
//		Tracer.trace("CuePointList.init: _scroller=" + _scroller);
	}
	
	public function setData(d:Array):Void
	{
		var row:Array;
		for (var ix:Number = 0; ix < d.length; ix++)
		{
			row = d[ix];
//			Tracer.trace("CuePointList.setData: name=" + row[0] + ", seconds=" + row[1]);
			addCuePoint( row[0], row[1], ix );
		}
	}
	
	public function addCuePoint(name:String, seconds:Number, row:Number):Void
	{
		// Validate parameters
		if (name == null)
			name = "";
		if (seconds == null)
			seconds = 0;
		if (row == null)
			throw new Error("ERROR: The cue point must have a valid row number");
		
		var priorHeight:Number = this._height;
		var depth:Number = this.getNextHighestDepth();
		var initObj:Object = { name:name, seconds:seconds, row:row };
//		Tracer.trace("CuePointList.addCuePoint: initObj=" + initObj.name + ", " + initObj.seconds + ", " + initObj.row);
		this.attachMovie("CuePoint", "cp" + depth, depth, initObj);
		var cp:MovieClip = this["cp" + depth];
		cp._y = priorHeight;
		_cuePoints.push(cp);
		// The invalidate call shows or hides the scroll bar as appropriate.
		_scroller.invalidate();
		
//		Tracer.trace("CuePointList.addCuePoint: Added cuePoint " + cp.toString() + 
//			", depth " + depth + ", y=" + cp._y);
	}
	
	/**
	 * Delete the last cue point
	 */
	public function deleteCuePoint():Void
	{
		// Get the last index number
		var ix:Number = _cuePoints.length - 1;
		// Remove the movie clip
		_cuePoints[ix].removeMovieClip();
		// Remove the row from the array
		_cuePoints.splice(ix, 1);
		// The invalidate call shows or hides the scroll bar as appropriate.
		_scroller.invalidate();
	}

	public function updateCuePointDisplay():Void
	{
		for (var ix:Number = 0; ix < _cuePoints.length; ix++)
		{
			_cuePoints[ix].updateDisplay();
		}
	}
}