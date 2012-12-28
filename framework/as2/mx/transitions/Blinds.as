//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Blinds extends Transition {

//#include "Version.as"

	public var type:Object = Blinds;
	public var className:String = "Blinds";
	
	private var _numStrips:Number = 10;
	private var _dimension:Number;
	private var _mask:MovieClip;
	private var _innerMask:MovieClip;

	function Blinds (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	};
	
	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Blinds.init()");
		super.init (content, transParams, manager);
		this._dimension = (transParams.dimension) ? 1 : 0;
		if (transParams.numStrips) this._numStrips = transParams.numStrips;
		this._initMask();
	};
	
	function start ():Void {
		this._content.setMask (this._mask);
		super.start();
	}
	
	function cleanUp ():Void {
		this._mask.removeMovieClip();
		super.cleanUp();
	}
	
	private function _initMask ():Void {
		var container:MovieClip = this._content;
		var depth:Number = this.getNextHighestDepthMC (container);
		var mask:MovieClip = this._mask = container.createEmptyMovieClip ("__mask_Blinds_"+this.direction, depth);
		mask._visible = false;
		var innerMask:MovieClip = this._innerMask = this._mask.createEmptyMovieClip ("innerMask", 0);
		innerMask._x = innerMask._y = 50;
		if (this._dimension) innerMask._rotation = -90;
		
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
	
	private function _render (p:Number):Void {
		var h:Number = 100/this._numStrips;
		var s:Number = p * h;
		var mask:MovieClip = this._innerMask;
		mask.clear();
		var i:Number = this._numStrips;
		mask.beginFill (0xFF0000);
		while (i--) {
			this.drawBox (mask, -50, i*h - 50, 100, s);
		}
		mask.endFill();
	};

}
