//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Wipe extends Transition {

//#include "Version.as"

	public var type:Object = Wipe;
	public var className:String = "Wipe";
	
	private var _mask:MovieClip;
	private var _innerMask:MovieClip;
	private var _startPoint:Number = 4;
	private var _cornerMode:Boolean;

	function Wipe (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	};
	
	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Wipe.init()");
		super.init (content, transParams, manager);
		if (transParams.startPoint) this._startPoint = transParams.startPoint;
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
		var mask:MovieClip = this._mask = container.createEmptyMovieClip ("__mask_Wipe_"+this.direction, depth);
															 
		var innerMask:MovieClip = this._innerMask = this._mask.createEmptyMovieClip ("innerMask", 0);
		innerMask._x = innerMask._y = 50;
		//mask._alpha = 30;
		mask._visible = false;
		
		innerMask.beginFill (0xFF0000);
		this.drawBox (innerMask, -50, -50, 100, 100);
		innerMask.endFill();
		
		switch (this._startPoint) {
			case 3:
			case 2: 
				innerMask._rotation = 90;
				break;
			case 1:
			case 4: 
				innerMask._rotation = 0;
				break;
			case 9:
			case 6: 
				innerMask._rotation = 180;
				break;
			case 7:
			case 8: 
				innerMask._rotation = -90;
				break;
			default:
				break;
		}
		
		// if _startPoint is an odd number it's a corner
		if (this._startPoint % 2) {
			this._cornerMode = true;
		}
		
		var ib:Object = this._innerBounds;
		mask._x = ib.xMin;
		mask._y = ib.yMin;
		mask._width = ib.xMax - ib.xMin;
		mask._height = ib.yMax - ib.yMin;
	}
	
	private function _render (p:Number):Void {
		//trace ("Wipe.render(): " + p);
		this._innerMask.clear();
		this._innerMask.beginFill (0xFF0000);
		if (this._cornerMode) {
			this._drawSlant (this._innerMask, p);
		} else {
			this.drawBox (this._innerMask, -50, -50, p*100, 100);
		}
		this._innerMask.endFill();
	};
	
	private function _drawSlant (mc:MovieClip, p:Number):Void {
		mc.moveTo (-50, -50);
		if (p <= .5) {
			mc.lineTo (200*(p-.25), -50);
			mc.lineTo (-50, 200*(p-.25));
		} else {
			mc.lineTo (50, -50);
			mc.lineTo (50, 200*(p-.75));
			mc.lineTo (200*(p-.75), 50);
			mc.lineTo (-50, 50);
		}
		mc.lineTo (-50, -50);
	}

}
