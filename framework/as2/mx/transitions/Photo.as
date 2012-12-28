//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.Transition;
import mx.transitions.TransitionManager;

class mx.transitions.Photo extends Transition {

//#include "Version.as"

	public var type:Object = Photo;
	public var className:String = "Photo";

	private var _alphaFinal:Number;
	private var _colorControl:Color;
	
	function Photo (content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init (content, transParams, manager);
	};

	function init (content:MovieClip, transParams:Object, manager:TransitionManager):Void {
		super.init (content, transParams, manager);
		this._alphaFinal = this.manager.contentAppearance._alpha;
		this._colorControl = new Color (this._content);
	};
	
	private function _render (p:Number):Void {
		var s1:Number = .8;
		var s2:Number = .9;
		var t:Object = {};
		var bright:Number = 0;
		if (p <= s1) {
			this._content._alpha = this._alphaFinal * (p/s1);
		} else {
			this._content._alpha = this._alphaFinal;
			if (p <= s2) {
				bright = (p-s1)/(s2-s1) * 256;
			} else {
				bright = (1-(p-s2)/(1-s2)) * 256;
			}
		}
		t.rb = t.gb = t.bb = bright;
		this._colorControl.setTransform (t);
	};

}
