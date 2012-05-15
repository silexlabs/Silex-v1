//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Iris extends Transition {

//#include "Version.as"

	public static var SQUARE:String = "SQUARE";
	public static var CIRCLE:String = "CIRCLE";

	public var type:Object = Iris;
	public var className:String = "Iris";
	
	private var _mask:MovieClip;
	private var _startPoint:Number = 5;
	private var _cornerMode:Boolean;
	private var _shape:String = "SQUARE";
	private var _maxDimension:Number;
	private var _minDimension:Number;
	private var _renderShape:Function;

	function Iris (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	};
	
	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Iris.init()");
		super.init (content, transParams, manager);
		if (transParams.startPoint) this._startPoint = transParams.startPoint;
		if (transParams.shape!=undefined) this._shape = transParams.shape;
		this._maxDimension = Math.max (this._width, this._height);
		this._minDimension = Math.min (this._width, this._height);
		
		
		// if _startPoint is an odd number, it's a corner
		if (this._startPoint % 2) {
			this._cornerMode = true;
		}
		// assign the render function dynamically based on shape choice
		if (this._shape == "SQUARE") {
			if (this._cornerMode) {
				this._render = this._renderSquareCorner;
			} else {
				this._render = this._renderSquareEdge;
			}
		} else if (this._shape == "CIRCLE") {
			this._render = this._renderCircle;
		}

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
		
		var mask:MovieClip = this._mask = container.createEmptyMovieClip ("__mask_Iris_"+this.direction, depth);
		//mask._alpha = 30;
		mask._visible = false;
		var ib:Object = this._innerBounds;
		
		switch (this._startPoint) {
			case 1:
			// top left
				mask._x = ib.xMin;
				mask._y = ib.yMin;
				break;
			case 4: 
			// left
				mask._x = ib.xMin;
				mask._y = (ib.yMin + ib.yMax) * .5;
				break;
			case 3:
			// top right
				mask._rotation = 90;
				mask._x = ib.xMax;
				mask._y = ib.yMin;
				break;
			case 2:
			// top center
				mask._rotation = 90;
				mask._x = (ib.xMin + ib.xMax) * .5;
				mask._y = ib.yMin;
				break;
			case 9:
			// bottom right
				mask._rotation = 180;
				mask._x = ib.xMax;
				mask._y = ib.yMax;
				break;
			case 6: 
			// right
				mask._rotation = 180;
				mask._x = ib.xMax;
				mask._y = (ib.yMin + ib.yMax) * .5;
				break;
			case 7:
			// bottom left
				mask._rotation = -90;
				mask._x = ib.xMin;
				mask._y = ib.yMax;
				break;
			case 8: 
			// bottom center
				mask._rotation = -90;
				mask._x = (ib.xMin + ib.xMax) * .5;
				mask._y = ib.yMax;
				break;
			case 5:
			// center
				mask._x = (ib.xMin + ib.xMax) * .5;
				mask._y = (ib.yMin + ib.yMax) * .5;
				break;
			default:
				break;
		}
	}

	// stub--dynamically overwritten by one of the other render methods 
	private function _render (p:Number):Void {}
	

	private function _renderCircle (p:Number):Void {
		var mask:MovieClip = this._mask;
		mask.clear();
		mask.beginFill (0xFF0000);
		
		if (this._startPoint == 5) {
			// iris from center
			var maxRadius:Number = .5 * Math.sqrt (this._width*this._width + this._height*this._height);
			this.drawCircle (mask, 0, 0, p*maxRadius);
		} else {
			if (this._cornerMode) {
				// iris from corner
				var maxRadius:Number = Math.sqrt (this._width*this._width + this._height*this._height);
				this._drawQuarterCircle (mask, p*maxRadius);
			} else {
				// iris from edge
				var maxRadius:Number;
				if (this._startPoint == 4 || this._startPoint == 6) {
					// half-circle from left or right edge
					maxRadius = Math.sqrt (this._width*this._width + .25*this._height*this._height);
				} else if (this._startPoint == 2 || this._startPoint == 8) {
					// half-circle from top or bottom edge
					maxRadius = Math.sqrt (.25*this._width*this._width + this._height*this._height);
				}
				this._drawHalfCircle (mask, p*maxRadius);  
			}
		}
		mask.endFill();
	}

	private function _drawQuarterCircle (mc:MovieClip, r:Number):Void {
		var x=0, y=0;
		mc.lineTo (r, 0);
		mc.curveTo (r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.curveTo (Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
	}
	
	private function _drawHalfCircle (mc:MovieClip, r:Number):Void {
		var x=0, y=0;
		mc.lineTo (0, -r);
		mc.curveTo (Math.tan(Math.PI/8)*r+x, -r+y, Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.curveTo (r+x, -Math.tan(Math.PI/8)*r+y, r+x, y);
		mc.curveTo (r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.curveTo (Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
		mc.lineTo (0, 0);
	}
	
	//this._maxDimension = Math.max (this._width, this._height);
	
	private function _renderSquareEdge (p:Number):Void {
		var mask = this._mask;
		mask.clear();
		mask.beginFill (0xFF0000);
		var s = this._startPoint;
		var w = p*this._width;
		var h = p*this._height;
		var z = p*this._maxDimension;
		if(s == 4 || s == 6){
			this.drawBox (mask, 0, -.5*h, w, h);
		}else if(this._height < this._width){
		  	this.drawBox (mask, 0, -.5*z, h, w); 
		}else{
		  	this.drawBox (mask, 0, -.5*z, z, z);
		}
		mask.endFill();
	}
	
	
	private function _renderSquareCorner (p:Number):Void {
		var mask = this._mask;
		mask.clear();
		mask.beginFill (0xFF0000);
		var s = this._startPoint;
		var w = p*this._width;
		var h = p*this._height;
		if (s == 5) {
			this.drawBox (mask, -.5*w, -.5*h, w, h);
		}else if(s == 3 || s == 7){
			this.drawBox (mask, 0, 0, h, w);
		} else {
			this.drawBox (mask, 0, 0, w, h);
		}
		mask.endFill();
	}
}


