//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Fly extends Transition {

//#include "Version.as"

	public var type:Object = Fly;
	public var className:String = "Fly";
	
	private var _startPoint:Number = 4;
	private var _xFinal:Number;
	private var _yFinal:Number;
	private var _xInitial:Number;
	private var _yInitial:Number;
	private var _stagePoints:Object;

	function Fly (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	}

	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Fly.init()");
		super.init (content, transParams, manager);
		if (transParams.startPoint) this._startPoint = transParams.startPoint;
	
		this._xFinal = this.manager.contentAppearance._x;
		this._yFinal = this.manager.contentAppearance._y;
		// we need to temporarily switch the Stage to "showAll" mode, so store old Stage mode
		var oldStageScaleMode:String = Stage.scaleMode;
		Stage.scaleMode = "showAll";
		
		// define cardinal points like telephone keypad:
		// 1 2 3
		// 4 5 7
		// 7 8 9
		var sp:Object = this._stagePoints = {};
		sp[1] = {x:0, y:0};
		sp[2] = {x:0, y:0};
		sp[3] = {x:Stage.width, y:0};
		sp[4] = {x:0, y:0};
		sp[5] = {x:Stage.width/2, y:Stage.height/2};
		sp[6] = {x:Stage.width, y:0};
		sp[7] = {x:0, y:Stage.height};
		sp[8] = {x:0, y:Stage.height};
		sp[9] = {x:Stage.width, y:Stage.height};
		
		// map coordinates from global space to content's parent's space
		for (var i in sp) {
			this._content._parent.globalToLocal (sp[i]);
		}
		
		// shift values to adjust for symbols with registration points not at top-left
		var ib = this._innerBounds; // _innerBounds comes from Transition superclass
		sp[1].x -= ib.xMax;
		sp[1].y -= ib.yMax;
		
		sp[2].x = this.manager.contentAppearance._x;
		sp[2].y -= ib.yMax;
		
		sp[3].x -= ib.xMin;
		sp[3].y -= ib.yMax;
		
		sp[4].x -= ib.xMax;
		sp[4].y = this.manager.contentAppearance._y;
		
		sp[5].x -= (ib.xMax+ib.xMin)/2; // center x
		sp[5].y -= (ib.yMax+ib.yMin)/2; // center y
		
		sp[6].x -= ib.xMin;
		sp[6].y = this.manager.contentAppearance._y;
		
		sp[7].x -= ib.xMax;
		sp[7].y -= ib.yMin;
		
		sp[8].x = this.manager.contentAppearance._x;
		sp[8].y -= ib.yMin;
		
		sp[9].x -= ib.xMin;
		sp[9].y -= ib.yMin;
		
		this._xInitial = this._stagePoints[this._startPoint].x;
		this._yInitial = this._stagePoints[this._startPoint].y;
		// restore Stage to original scale mode
		Stage.scaleMode = oldStageScaleMode;
	}
	
	private function _render (p:Number):Void {
		this._content._x = this._xFinal + (this._xInitial-this._xFinal) * (1-p);
		this._content._y = this._yFinal + (this._yInitial-this._yFinal) * (1-p);
	}

}


