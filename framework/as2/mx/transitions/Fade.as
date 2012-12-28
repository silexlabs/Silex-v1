//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Fade extends Transition {

//#include "Version.as"

	public var type:Object = Fade;
	public var className:String = "Fade";

	private var _alphaFinal:Number;
	
	function Fade (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	}

	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		super.init (content, transParams, manager);
		this._alphaFinal = this.manager.contentAppearance._alpha;
	}
	
	private function _render (p:Number):Void {
		this._content._alpha = this._alphaFinal * p;
	}

}
