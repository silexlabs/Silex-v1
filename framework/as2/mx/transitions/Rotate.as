//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Rotate extends Transition {

//#include "Version.as"

	public var type:Object = Rotate;
	public var className:String = "Rotate";
	
	private var _rotationFinal:Number;
	private var _degrees:Number = 360;
	//private var _ccw:Boolean;

	function Rotate (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	}

	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Rotate.init()");
		super.init (content, transParams, manager);
		if (this._rotationFinal==undefined) this._rotationFinal = this.manager.contentAppearance._rotation;
		if (transParams.degrees) this._degrees = transParams.degrees;
		// XOR: if ccw or direction (but not both) is true, need to invert the degrees
		if (transParams.ccw ^ this.direction) this._degrees *= -1;
	}
	
	private function _render (p:Number):Void {
		this._content._rotation = this._rotationFinal - this._degrees * (1-p);
	}

}

