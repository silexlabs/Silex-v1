//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Squeeze extends Transition {

//#include "Version.as"

	public var type:Object = Squeeze;
	public var className:String = "Squeeze";
	
	private var _scaleProp:String;
	private var _scaleFinal:Number;
	

	function Squeeze (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	}
	

	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		//trace ("Squeeze.init()");
		super.init (content, transParams, manager);
		if (transParams.dimension) {
			this._scaleProp = "_yscale";
			this._scaleFinal = this.manager.contentAppearance._yscale;
		} else {
			this._scaleProp = "_xscale";
			this._scaleFinal = this.manager.contentAppearance._xscale;
		}
	}
	
	private function _render (p:Number):Void {
		if (p <= 0){ p = 0;
		  this._content._visible = false;
		}else{
		  this._content._visible = true;
		}
		this._content[this._scaleProp] = p * this._scaleFinal;
	}

}
