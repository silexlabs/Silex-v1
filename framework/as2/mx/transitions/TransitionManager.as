//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.events.EventDispatcher;
import mx.transitions.Transition;

class mx.transitions.TransitionManager {

//#include "Version.as"

	static var IDCount:Number = 0;
	
	public var type:Object = TransitionManager;
	public var className:String = "TransitionManager";
	// these three methods will be mixed-in
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	
	private var _content:MovieClip;
	private var _transitions:Object;
	public var _innerBounds:Object;
	public var _outerBounds:Object;
	public var _width:Number;
	public var _height:Number;
	private var _contentAppearance:Object;
	private var _visualPropList:Object = {
		_x:null,
		_y:null,
		_xscale:null,
		_yscale:null,
		_alpha:null,
		_rotation:null	
	};
	private var _triggerEvent:String;
	
	// decorate the class prototype with dispatcher methods (addEventListener(), etc.)
	private static var __mixinFED = EventDispatcher.initialize (TransitionManager.prototype);
	
	
	//////////// GETTERS/SETTERS

	function set content (c:MovieClip):Void {
		// first unsubscribe old content from events
		this.removeEventListener ("allTransitionsInDone", this._content);
		this.removeEventListener ("allTransitionsOutDone", this._content);
		this._content = c;
		this.saveContentAppearance();
		this.addEventListener ("allTransitionsInDone", this._content);
		this.addEventListener ("allTransitionsOutDone", this._content);
	}

	function get content ():MovieClip {
		return this._content;
	}

	// this was changed from get transitions() to get transitionsList()
	// because hitting compile error	
	function get transitionsList ():Object {
		return this._transitions;
	}

	function get numTransitions ():Number {
		var n:Number = 0;
		for (var i in this._transitions) n++;
		return n;
	}
	
	function get numInTransitions ():Number {
		var n:Number = 0;
		var ts:Object = this._transitions;
		for (var i in ts) if (!ts[i].direction) n++;
		return n;
	}

	function get numOutTransitions ():Number {
		var n:Number = 0;
		var ts:Object = this._transitions;
		for (var i in ts) if (ts[i].direction) n++;
		return n;
	}

	function get contentAppearance ():Object {
		return this._contentAppearance;
	}

	////////// STATIC METHODS
	
	static function start (content:MovieClip, transParams:Object):Transition {
		// create a transition manager as needed
		if (content.__transitionManager == undefined) {
			content.__transitionManager = new TransitionManager (content);
		}
		// Make some assumptions about the event that is trigging this
		// transition.  Behavior/actionscript can override this by
		// setting _triggerEvent after calling start().
		if (transParams.direction == 1)
			content.__transitionManager._triggerEvent = "hide";
		else
			content.__transitionManager._triggerEvent = "reveal";
		return content.__transitionManager.startTransition (transParams);
	}	
	
	
	///////// CONSTRUCTOR

	function TransitionManager (content:MovieClip) {
		this.content = content;
		this._transitions = {};
	}	

	///////// PUBLIC METHODS
	
	// start a transition specified by the parameters
	// if a matching transition already exists, that transition is removed
	// then a new transition is created and started
	function startTransition (transParams:Object):Transition {
		// look for an existing transition that matches the supplied params
		// remove the transition that matches
		this.removeTransition (this.findTransition (transParams));
		var theConstructor:Function = transParams.type;
		var t:Transition = new theConstructor (this._content, transParams, this);
		this.addTransition (t);
		t.start();
		return t;
	}

	function addTransition (trans:Transition):Transition {
		trans.ID = ++mx.transitions.TransitionManager.IDCount;
		this._transitions[trans.ID] = trans;
		return trans;
	}
	
	function removeTransition (trans:Transition):Boolean {
		if (this._transitions[trans.ID] == undefined) return false;
		trans.cleanUp();
		return delete this._transitions[trans.ID];
	}

	
	function findTransition (transParams:Object):Transition {
		// go through the params and find the corresponding transition if it exists
		var t:Transition;
		for (var i in this._transitions) {
			t = this._transitions[i];
			if (t.type == transParams.type) {
				return t;
			}
		}
		return undefined;
	}

	function removeAllTransitions ():Void {
		for (var i in this._transitions) {
			this._transitions[i].cleanUp();
			this.removeTransition (this._transitions[i]);
		}
	}

	
	function saveContentAppearance ():Void {
		var c:MovieClip = this._content;
		if (this._contentAppearance == undefined) {
			var a:Object = this._contentAppearance = {};
			for (var i in this._visualPropList) {
				a[i] = c[i];			
			}
			a.colorTransform = (new Color(c)).getTransform();
		}
		this._innerBounds = c.getBounds (targetPath(c));
		this._outerBounds = c.getBounds (targetPath(c._parent));
		this._width = c._width;
		this._height = c._height;
		
	}

	function restoreContentAppearance ():Void {
		var c:MovieClip = this._content;
		var a:Object = this._contentAppearance;
		for (var i in this._visualPropList) {
			c[i] = a[i];			
		}
		(new Color(c)).setTransform (a.colorTransform);
	}

	///////// EVENT HANDLERS

	// event from a Transition instance
	function transitionInDone (e:Object):Void {
		this.removeTransition (e.target);
		if (this.numInTransitions == 0) {
			var wasVisible:Boolean;
			wasVisible = this._content._visible;

			if ((_triggerEvent == "hide") || (_triggerEvent == "hideChild")) {
				this._content._visible = false;
			}
			if (wasVisible) {
				// Fix bug 58135
				// Don't send allTransitionsInDone if content was
				// hidden before the transitions actually finished.
				this.dispatchEvent ({type:"allTransitionsInDone", target:this});
			}
		}
	}

	// event from a Transition instance
	function transitionOutDone (e:Object):Void {
		this.removeTransition (e.target);
		if (this.numOutTransitions == 0) {
			// return content to its original _x, _xscale, _rotation, etc.
			this.restoreContentAppearance();

			var wasVisible:Boolean;
			wasVisible = this._content._visible;

			// hide the content when all out transitions are done
			if (wasVisible && ((_triggerEvent == "hide") || (_triggerEvent == "hideChild"))) {
				this._content._visible = false;
			}
			updateAfterEvent();

			if (wasVisible)  {
				// Fix bug 58135
				// Don't send allTransitionsOutDone if content was
				// hidden before the transitions actually finished.
				this.dispatchEvent ({type:"allTransitionsOutDone", target:this});
			}
		}
	}
	
	function toString ():String {
		return "[TransitionManager]";
	}
	
}
