//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.PixelDissolve extends Transition {

//#include "Version.as"

	public var type:Object = PixelDissolve;
	public var className:String = "PixelDissolve";
	
	private var _xSections:Number = 10;
	private var _ySections:Number = 10;
	private var _numSections:Number;
	private var _indices:Array;
	private var _mask:MovieClip;
	private var _innerMask:MovieClip;

	function PixelDissolve (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	};
	
	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("PixelDissolve.init()");
		super.init (content, transParams, manager);
		if (transParams.xSections) this._xSections = transParams.xSections;
		if (transParams.ySections) this._ySections = transParams.ySections;
		this._numSections = this._xSections * this._ySections;
		this._indices = new Array();
		var y:Number = this._ySections;
		while (y--) {
			var x:Number = this._xSections;
			while (x--) {
				this._indices[y*this._xSections+x] = {x:x, y:y};
			}
		}
		this._shuffleArray (this._indices);
		this._initMask();
	};
	
	function start ():Void {
		this._content.setMask (this._mask);
		super.start();
	}
	
	function cleanUp ():Void {
		// remove mask movie clip
		this._mask.removeMovieClip();
		super.cleanUp();
	}
	
	private function _initMask ():Void {
		var container:MovieClip = this._content;
		var depth:Number = this.getNextHighestDepthMC (container);

		var mask:MovieClip = this._mask = container.createEmptyMovieClip ("__mask_PixelDissolve_"+this.direction, depth );
		//mask._alpha = 0;
 		mask._visible = false;
		var innerMask:MovieClip = this._innerMask = this._mask.createEmptyMovieClip ("innerMask", 0);
		
		// draw initial standard 100x100 box
		innerMask.beginFill (0xFF0000);
		this.drawBox (innerMask, 0, 0, 100, 100);
		innerMask.endFill();
		
		var ib:Object = this._innerBounds;
		mask._x = ib.xMin;
		mask._y = ib.yMin;
		mask._width = ib.xMax - ib.xMin;
		mask._height = ib.yMax - ib.yMin;

	}
	
	private function _shuffleArray (a:Array):Void {
		for (var i=a.length-1; i>0; --i) {
		   var p = random(i+1);
		   if (p == i) continue;
		   var tmp = a[i];
		   a[i] = a[p];
		   a[p] = tmp;
		}
	}
	
	private function _render (p:Number):Void {
		if (p < 0) p = 0;
		if (p > 1) p = 1;
		var w:Number = 100/this._xSections;
		var h:Number = 100/this._ySections;
		var ind:Array = this._indices;
		var mask:MovieClip = this._innerMask;
		mask.clear();
		mask.beginFill (0xFF0000);
		var i:Number = Math.floor (p * this._numSections);
		while (i--) {
			this.drawBox (mask, ind[i].x*w, ind[i].y*h, w, h);
		}
		mask.endFill();
	};

}
