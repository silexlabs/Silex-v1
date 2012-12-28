//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Zoom extends Transition {

//#include "Version.as"

	public var type:Object = Zoom;
	public var className:String = "Zoom";
	
	private var _xscaleFinal:Number;
	private var _yscaleFinal:Number;
	
	function Zoom (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	}

	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Zoom.init()");
		super.init (content, transParams, manager);
		this._xscaleFinal = this.manager.contentAppearance._xscale;
		this._yscaleFinal = this.manager.contentAppearance._yscale;
	}
	
	private function _render (p:Number):Void {
		if (p < 0) p = 0;
		this._content._xscale = p * this._xscaleFinal;
		this._content._yscale = p * this._yscaleFinal;
	}

}
