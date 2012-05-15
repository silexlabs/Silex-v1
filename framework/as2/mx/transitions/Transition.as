//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/*
example of transition behavior code:

import mx.transitions.*;

TransitionManager.start( this, { type:mx.transitions.Iris,
                                 direction:Transition.IN,
                                 duration:2,
                                 easing:Strong.easeInOut,
                                 startPoint:5,
                                 shape:Iris.SQUARE } ); 
*/


import mx.events.EventDispatcher;
import mx.transitions.TransitionManager;
import mx.transitions.Tween;

class mx.transitions.Transition {

//#include "Version.as"

	public static var IN:Number = 0;
	public static var OUT:Number = 1;
	
	public var type:Object = Transition;
	public var className:String = "Transition";
	public var ID:Number;
	// these three methods will be mixed-in
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	
	private var _content:MovieClip;
	private var _manager:TransitionManager;
	private var _direction:Number = 0;
	private var _duration:Number = 2;
	private var _easing:Object;
	private var _progress:Number;
	private var _innerBounds:Object;
	private var _outerBounds:Object;
	private var _width:Number;
	private var _height:Number;
	private var _twn:Object;
	// decorate the class prototype with dispatcher methods (addEventListener(), etc.)
	private static var __mixinFED = EventDispatcher.initialize (Transition.prototype);
	

	/////////// GETTER/SETTER PROPERTIES

	function set manager (mgr:TransitionManager):Void {
		if (this._manager != undefined) {
			this.removeEventListener ("transitionInDone", this._manager);
			this.removeEventListener ("transitionOutDone", this._manager);
			this.removeEventListener ("transitionProgress", this._manager);
		}
		this._manager = mgr;
		this.addEventListener ("transitionInDone", this._manager);
		this.addEventListener ("transitionOutDone", this._manager);
		this.addEventListener ("transitionProgress", this._manager);
	}

	function get manager ():TransitionManager {
		return this._manager;
	}

	function set content (c:MovieClip):Void {
		if (typeof c=="movieclip") {
			this._content = c;
			this._twn.obj = c;
		}
	};
	
	function get content ():MovieClip {
		return this._content;
	};
	
	function set direction (direction:Number):Void {
		// direction is 0 for IN or 1 for OUT 
		this._direction = direction ? 1 : 0;
	};
	
	function get direction ():Number {
		return this._direction;
	};
	
	function set duration (d:Number):Void {
		if (d) {
			this._duration = d;
			this._twn.duration = d;
		}
	};
	
	function get duration ():Number {
		return this._duration;
	};
	
	function set easing (e:Object):Void {
		// if the function is the string name, evaluate to a reference
		if (typeof e == "string") e = eval(String(e));
		else if (e == undefined) e = this._noEase;
		this._easing = e;
		this._twn.easing = e;
	};
	
	function get easing ():Object {
		return this._easing;
	};
	
	// p is a number between 0 and 1 representing the state of the transition
	function set progress (p:Number):Void {
		// if the incoming progress is the same as the current progress, do nothing
		if (this._progress == p) return;
		this._progress = p;
		// transition-in goes from 0 to 1
		// transition-out goes from 1 to 0
		if (this._direction) {	
			this._render (1-p);
		} else {
			this._render (p);
		}
		this.dispatchEvent ({type:"transitionProgress", target:this, progress:p});
	};
	
	function get progress ():Number {
		return this._progress;
	};




	///////// CONSTRUCTOR
	/*
	transParams:
	- direction (0 or 1)
	- duration (seconds)
	- easing (an easing function)
	- additional parameters can be defined for individual transitions
	*/	

	function Transition (content:MovieClip, transParams:Object, manager:TransitionManager) {
		// prevent the constructor from executing at the wrong time
		if (!arguments.length) return;
		this.init (content, transParams, manager);
	}
		
	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		this.content = content;
		this.direction = transParams.direction;
		this.duration = transParams.duration;
		this.easing = transParams.easing;
		this.manager = manager;
		this._innerBounds = this.manager._innerBounds;
		this._outerBounds = this.manager._outerBounds;
		this._width = this.manager._width;
		this._height = this.manager._height;
		this._resetTween();
	}	
	
	/////////// PUBLIC METHODS
	
	function toString ():String {
		return "[Transition " + this.className + "]";
	};
	
	function start ():Void {
		this.content._visible = true;
		this._twn.start();
	};
	
	function stop ():Void {
		this._twn.fforward();
		this._twn.stop();
	};
	
	// remove any movie clips, masks, etc. created by this transition
	function cleanUp ():Void {
		this.removeEventListener ("transitionInDone", this._manager);
		this.removeEventListener ("transitionOutDone", this._manager);
		this.removeEventListener ("transitionProgress", this._manager);
		this.stop();
	};

	
	// returns a depth number within a particular movie clip--the next highest available one
	// the MovieClip.getNextHighestDepth() is not available in Flash Player 6,
	// so this method uses a custom algorithm in that case
	function getNextHighestDepthMC (mc:MovieClip):Number {
		var maxDepth:Number = mc.getNextHighestDepth();
		if (maxDepth != undefined) {
			return maxDepth;
		} else {
			maxDepth = -1;
			var depth;
			var child; 
			for (var p in mc) {
				child = mc[p];
				if (typeof child=="movieclip" && child._parent==mc) {
					depth = child.getDepth();
					if (depth > maxDepth) maxDepth = depth;
				}
			}
			return maxDepth + 1;
		}
	}
	
	function drawBox (mc:MovieClip, x:Number, y:Number, w:Number, h:Number):Void {
		mc.moveTo (x, y);
		mc.lineTo (x+w, y);
		mc.lineTo (x+w, y+h);
		mc.lineTo (x, y+h);
		mc.lineTo (x, y);
	}

	function drawCircle (mc:MovieClip, x:Number, y:Number, r:Number):Void {
		mc.moveTo (x+r, y);
		mc.curveTo (r+x, Math.tan(Math.PI/8)*r+y, Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.curveTo (Math.tan(Math.PI/8)*r+x, r+y, x, r+y);
		mc.curveTo (-Math.tan(Math.PI/8)*r+x, r+y, -Math.sin(Math.PI/4)*r+x, Math.sin(Math.PI/4)*r+y);
		mc.curveTo (-r+x, Math.tan(Math.PI/8)*r+y, -r+x, y);
		mc.curveTo (-r+x, -Math.tan(Math.PI/8)*r+y, -Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.curveTo (-Math.tan(Math.PI/8)*r+x, -r+y, x, -r+y);
		mc.curveTo (Math.tan(Math.PI/8)*r+x, -r+y, Math.sin(Math.PI/4)*r+x, -Math.sin(Math.PI/4)*r+y);
		mc.curveTo (r+x, -Math.tan(Math.PI/8)*r+y, r+x, y);
	}
	
	
	/////////// PRIVATE METHODS
	
	// abstract method - to be overridden in subclasses
	private function _render (p:Number):Void {};
	
	private function _resetTween ():Void {
		// do clean-up of possibly existing tween
		this._twn.stop();
		this._twn.removeListener (this);
		this._twn = new Tween (this,
										   null, 
										   this.easing, 
										   0, 
										   1, 
										   this.duration,
										   true);
		// need to first stop the tween and THEN set the prop to avoid rendering glitches
		this._twn.stop();
		this._twn.prop = "progress";
		this._twn.addListener (this);	
	};
	
	private function _noEase (t:Number, b:Number, c:Number, d:Number):Number {
		return c*t/d + b;
	}
	
	
	/////////// EVENT HANDLERS
	
	// MX Broadcaster-style event that comes from an instance of mx.transitions.Tween
	function onMotionFinished (src:Object):Void {
		if (this.direction) {
			this.dispatchEvent ({type:"transitionOutDone", target:this});
		} else {
			this.dispatchEvent ({type:"transitionInDone", target:this});
		}
	};


}
