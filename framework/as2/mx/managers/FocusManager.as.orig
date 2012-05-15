//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;
import mx.core.UIComponent;
import mx.controls.SimpleButton;
import mx.managers.SystemManager;

/* new rules as of 5/4/03:
   -do not put a input textfield in a movieclip w/o making the movieclip
    a container (tabChildren = true, tabEnabled = false) and
	setting focusTextField to point to that textfield.
   -add custom drawFocus to your textfield so it draws focus
    around your component usually by calling _parent.drawFocus();
*/

/**
* Class for managing the focus on components.  Each top-level window has a focus manager.
*
* @helpid 3039
* @tiptext
*/
class mx.managers.FocusManager extends UIComponent
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "FocusManager";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.managers.FocusManager;

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "FocusManager";

	// true if no component has the focus
	var bNeedFocus:Boolean = false;

	// true if we should call drawFocus on the components.
	// when tabbing, this is true, when mousing, this is false
	var bDrawFocus:Boolean = false;

	// the top-level form that this focus manager is responsible for
	var form;

	// the object that last had focus
	var lastFocus:Object;
	// the object that was last tabbed to
	var lastTabFocus:Object;
	// the last object according to Selection
	var lastSelFocus:Object;

	// internal object that captures the tab key
	private var tabCapture:MovieClip;

	// used to make sure we don't find something in the search twice
	private var _searchKey:Number;

	// Note: lots of things are declared as Object because the thing with focus can be a TextField or a MovieClip

	// last thing that was focused (or parent of last thing if we've already searched its siblings)
	private var _lastTarget:Object;
	// first, last, next and previous nodes in the tree of objects based on z-order
	private var _firstNode:Object;
	private var _lastNode:Object;
	private var _nextNode:Object;
	private var _prevNode:Object;
	// first, last, next and previous nodes in the tree based on tab index
	private var _firstObj:Object;
	private var _lastObj:Object;
	private var _nextObj:Object;
	private var _prevObj:Object;
	// set when we find the lastTarget in the tree so we know the thing we just saw is the previous node
	private var _needPrev:Boolean;
	// set when we find the lastTarget in the tree so we know that the next thing we see is the next node
	private var _nextIsNext:Boolean;
	// constantly changes to mark the last thing we saw
	private var _lastx:Object;
	// a list of things at this tabIndex that we've already tabbed to so we can deal with multiple objects
	// at the same tabIndex before moving to the next one
	private var _foundList:Object;

	// last mouse position
	var lastMouse:Object;

	// pointer to the original defaultPushButton.  The actual default pushbutton changes if focus is given to another
	// pushbutton, but switches back to the original if focus is not on a button
	var __defaultPushButton:SimpleButton;
	// the current default pushbutton
	var defPushButton:SimpleButton;
	// TextArea and other components that want the enter key disable the focus manager's enter key handling
	var defaultPushButtonEnabled:Boolean = true;

	private var activated:Boolean = true;

/**
* get or set the original default pushbutton.  This may not be the actual button that is the default
*/
	function get defaultPushButton():SimpleButton
	{
		return __defaultPushButton;
	}
	function set defaultPushButton(x:SimpleButton)
	{
		if (x != __defaultPushButton)
		{
			__defaultPushButton.emphasized = false;
			__defaultPushButton = x;
			defPushButton = x;
			x.emphasized = true;
		}
	}

/**
* get the highest tab index currently used in this focus manager's form or subform
*
* @param o the form or subform
* @return Number the highest tab index currently used
*/
	function getMaxTabIndex(o:UIComponent):Number
	{
		var z:Number = 0;

		var i:String;
		for (i in o)
		{
			var x = o[i];
			if (x._parent == o)
			{
				if (x.tabIndex != undefined)
				{
					if (x.tabIndex > z)
						z = x.tabIndex;
				}
				if (x.tabChildren == true)
				{
					var y:Number = getMaxTabIndex(x);
					if (y > z)
						z = y;
				}
			}
		}
		return z;
	}

	// internal overridable calculation of the next tab index to use
	function getNextTabIndex(Void):Number
	{
		return getMaxTabIndex(form) + 1;
	}

/**
* get the next unique tab index to use on this form
*/
	function get nextTabIndex():Number
	{
		 return getNextTabIndex();
	}

	function FocusManager()
	{
	}

	// the focus manager stays off screen.  If the stage resizes, the focus manager must move as well
	function relocate(Void):Void
	{
		var s:Object = SystemManager.screen;
		move(s.x - 1, s.y - 1);
	}

	// initialize variables and make sure we aren't also a tabstop
	function init(Void):Void
	{
		super.init();

		tabEnabled = false;

		// make ourselves small and transparent
		// we can't be invisible else we won't get keystrokes.
		_width = _height = 1;
		_x = _y = -1;
		_alpha = 0;

		_parent.focusManager = this;// this property name is reserved in the parent
		_parent.tabChildren = true;	// make sure parent is a container
		_parent.tabEnabled = false;	// make sure parent is a container
		

		// our immediate parent is the form
		form = _parent;
		_parent.addEventListener("hide", this);
		_parent.addEventListener("reveal", this);

		// make sure the system manager is running so it can tell us about
		// mouse clicks and stage size changes
		SystemManager.init();
		SystemManager.addFocusManager(form);

		tabCapture.tabIndex = 0;

		// watch for changes to enabled
		watch("enabled", enabledChanged);

		Selection.addListener(this);

		lastMouse = new Object();
		_global.ASSetPropFlags(_parent, "focusManager",1);
		_global.ASSetPropFlags(_parent, "tabChildren",1);
		_global.ASSetPropFlags(_parent, "tabEnabled",1);
	}

	// a FocusManager has an internal tabKey capture mechanism that is enabled by setting its TabIndex to undefined or not
	function enabledChanged(id:String, oldValue:Boolean, newValue:Boolean):Boolean
	{
		// trace(this + ".enabled set to " + newValue);
		_visible = newValue;
		return newValue;
	}

	// the SystemManager manages activation of forms if more than one is visible at the same time
	function activate(Void):Void
	{
		// trace("activating: " + this + ", lastFocus = " + lastFocus);
		// listen for enter key for default pushbutton
		Key.addListener(this);
		// listen for focus changes
		// Selection.addListener(this);
		// listen for tab keys
		activated = _visible = true;
		// restore focus to the last control that had it if there was one
		if (lastFocus != undefined)
		{
			bNeedFocus = true;
			// restore focus if mouse is not down.  this means that we probably
			// got called due to handleEvent firing.
			if (!SystemManager.isMouseDown)
			{
				doLater(this, "restoreFocus");
			}
		}
	}

	// the SystemManager manages activation of forms if more than one is visible at the same time
	function deactivate(Void):Void
	{
		// trace("deactivating: " + this);
		Key.removeListener(this);
		//Selection.removeListener(this);
		activated = _visible = false;
		var o = getSelectionFocus();
		var f = getActualFocus(o);
		if (isOurFocus(f))
		{
			lastSelFocus = o;
			lastFocus = f;
		}
		// trace("lastFocus = " + lastFocus);
		// flush any pending work
		cancelAllDoLaters();
	}

	function isOurFocus(o:Object):Boolean
	{
		if (o.focusManager == this)
			return true;

		// see if it is in our focus ring
		while (o != undefined)
		{
			// it isn't if it has a focusManager of its own
			if (o.focusManager != undefined)
			{
				return false;
			}
			// it is if its parentage is our parent
			if (o._parent == _parent)
			{
				return true;
			}
			o = o._parent;
		}
		return false;
	}

	// if you were in a textfield and clicked somewhere other than a textfield,
	// the player sets focus automatically to null.
	// we take note of this and if focus doesn't end up
	// in a movieclip, we set focus back to the textfield.
	function onSetFocus(o:Object, n:Object):Void
	{
		// trace("o = " + o + " n = " + n + " f = " + getFocus());
		if (n == null)
		{
			if (activated)
				bNeedFocus = true;
		}
		else
		{
			// focus is somewhere it should be
			var f = getFocus();
			if (isOurFocus(f))
			{
				bNeedFocus = false;
				lastFocus = f;
				lastSelFocus = n;
			}
		}
	}

	// not only do we restore focus back to the last thing that had it
	// but if it is a textfield, we also restore the selection
	function restoreFocus(Void):Void
	{
		// trace(this + " restoreFocus " + lastFocus);
		var hscroll = lastSelFocus.hscroll;
		if (hscroll != undefined)
		{
			var vscroll = lastSelFocus.scroll;
			var bg = lastSelFocus.background;
		}
		lastFocus.setFocus();
		// we reset a couple of fields onto the Selection object
		var currentSelection:Object = Selection;
		Selection.setSelection(currentSelection.lastBeginIndex, currentSelection.lastEndIndex);
		if (hscroll != undefined)
		{
			lastSelFocus.scroll = vscroll;
			lastSelFocus.hscroll = hscroll;
			lastSelFocus.background = bg;
		}
	}

	// tell the system manager that we're going bye-bye
	function onUnload(Void):Void
	{
		SystemManager.removeFocusManager(form);
	}

/**
* set the focus to an object.  Recommended instead of using Selection object
* @param the object to receive focus
*
* @tiptext
* @helpid 3040
*/
	function setFocus(o:Object):Void
	{
		if (o == null)
			Selection.setFocus(null);
		else
		{
			if (o.setFocus == undefined)
			{
				Selection.setFocus(o);
			}
			else
			{
				o.setFocus();
			}
		}
	}

	// a component may set focus to an internal object that doesn't have tabIndex, etc.  We
	// need to find out what component owns this internal object
	function getActualFocus(o:Object):Object
	{
		var p:MovieClip = o._parent;
		while (p != undefined)
		{
			if (p.focusTextField != undefined)
			{
			 	while (p.focusTextField != undefined)
				{
					o = p;
					p = p._parent;
					if (p == undefined)
						return undefined; // should never get here.  top level windows can't have focusable textfields
					if (p.focusTextField == undefined)
						return o;		// things that wrap textfields have tabEnabled == false;
				}
			}
			if (p.tabEnabled != true)	// containers must have tabEnabled == false
			{							// accordion has tabEnabled = true, but wraps each
										// pane in a view with tabEnabled = false;
				return o;
			}
			o = p;
			p = o._parent;
		}
		// tab was set somewhere else
		return undefined;
	}

	function getSelectionFocus():Object
	{
		var m:String = Selection.getFocus();
		var o:Object = eval(m);
		return o;
	}

/**
* get the component that current has the focus.  Recommended instead of using Selection object
* because it will tell you which component.  Selection might return a subobject in that component
* @return the object that has focus
*
* @tiptext
* @helpid 3041
*/
	function getFocus(Void):Object
	{
		var o:Object = getSelectionFocus();
		return getActualFocus(o);
	}


	// instead of caching and updating the tab list, we simply scan for them on each Tab key.  There seems to be
	// enough time to run this calculation
	// @param p the node in the tree to search
	// @param index the tabindex of the last focused item in case there's another item with the same tabindex
	// @param groupName groupname of the last focused item so we won't tab to other things in that group
	// @param dir true if Tab, false if shift-Tab
	// @param lookup true if we're not at the top level and need to search the parents as well
	// @param firstChild true if we haven't found the first child yet
	function walkTree(p:MovieClip, index:Number, groupName:String, dir:Boolean, lookup:Boolean, firstChild:Boolean):Void
	{
		// trace("walking " + p);

		var firsttime:Boolean = true;
		var i:String;
		for (i in p)
		{
			var x = p[i];
			// if it is a child of p and is enabled, visible and has tabEnabled or is a button...
			if (x._parent == p && x.enabled != false && x._visible != false &&
				(x.tabEnabled == true ||
				(x.tabEnabled != false && (x.onPress != undefined || x.onRelease != undefined || x.onReleaseOutside != undefined ||
				x.onDragOut != undefined || x.onDragOver != undefined || x.onRollOver != undefined || x.onRollOut != undefined || (x instanceof TextField)))))
			{
				// skip if we've already seen it
				if (x._searchKey == _searchKey)
					continue;

				// mark it as seen
				x._searchKey = _searchKey;
				// trace("considering " + x);

				// this first section handles the xxxNode variables which are related to position in the tree

				if (x != _lastTarget)
				{
					if ((x.groupName != undefined || groupName != undefined) && x.groupName == groupName)
					{
						// you are not a candidate if you had the same groupname as the lasttarget
						continue;
					}
					// if this is an unselectable textfield, pass
					if ((x instanceof TextField) && x.selectable == false)
						continue;

					if (firsttime ||
								(x.groupName != undefined && x.groupName == _firstNode.groupName && x.selected == true))
					{
						// otherwise, if this is the first time through the loop, remember this as the first thing
						// we saw.  The tree walk will keep setting this until it actually points to the first thing
						// in the tree.
						if (firstChild)
						{
							_firstNode = x;
							// trace("setting firstNode to " + x);
							firstChild = false;
						}
						// don't reset firsttime just yet, it is needed at the end of the loop
					}

					// if we need to save the next thing we see
					if (_nextIsNext == true)
					{
						if ((x.groupName != undefined && x.groupName == _nextNode.groupName && x.selected == true) ||
							(_nextNode == undefined && (x.groupName == undefined || x.groupName != undefined && x.groupName != groupName)))
						// save it
						{
							// trace("setting nextNode to " + x);
							_nextNode = x;
						}
					}
					// remember this as the last thing we've seen if it is a candidate
					if (x.groupName == undefined || groupName != x.groupName)
					{
						if (_lastx.groupName != undefined && x.groupName == _lastx.groupName && _lastx.selected == true);
						else
						{
							// trace("setting lastx to " + x);
							_lastx = x;
						}
				}	}
				else // we found the last focused object in the tree
				{
					// mark us as needing to remember the next thing we see, and no longer needing the previous thing
					// trace("found last focused, setting prevNode to " + _lastx);
					_prevNode = _lastx;
					_needPrev = false;
					_nextIsNext = true;
				}

				// the second section deals with items with tabindexes
				if (x.tabIndex != undefined)
				{
					// if the tabindex matches...
					if (x.tabIndex == index)
					{
						// if we haven't visited this one before, this is the new best candidate
						if (_foundList[x._name] == undefined)
						{
							if (_needPrev)
							{
								// trace("setting prevObj to " + x);
								_prevObj = x;
								_needPrev = false;
							}
							// trace("setting nextObj to " + x);
							_nextObj = x;
						}
					}
					// otherwise, track the lowest next tabindex we find
					if (dir && x.tabIndex > index)
					{
						// replace it if it has a lower tabindex and one of them has no groupname or different groupnames
						// if the both have groupnames and the new candidate is selected or has a lower tabIndex
						if (_nextObj == undefined ||
							(_nextObj.tabIndex > x.tabIndex && (x.groupName == undefined || _nextObj.groupName == undefined || x.groupName != _nextObj.groupName)) ||
							(_nextObj.groupName != undefined && _nextObj.groupName == x.groupName && _nextObj.selected != true &&
								(x.selected == true || _nextObj.tabIndex > x.tabIndex)))
						{
							// trace("setting nextObj to " + x);
							_nextObj = x;
						}
					}
					// or the highest if we're going backwards
					else if (!dir && x.tabIndex < index)
					{
						if (_prevObj == undefined ||
							(_prevObj.tabIndex < x.tabIndex && (x.groupName == undefined || _prevObj.groupName == undefined || x.groupName != _prevObj.groupName)) ||
							(_prevObj.groupName != undefined && _prevObj.groupName == x.groupName && _prevObj.selected != true &&
								(x.selected == true || _prevObj.tabIndex < x.tabIndex)))
						{
							// trace("setting prevObj to " + x);
							_prevObj = x;
						}
					}
					// also look for the lowest number
					if (_firstObj == undefined ||
						(x.tabIndex < _firstObj.tabIndex && (x.groupName == undefined || _firstObj.groupName == undefined || x.groupName != _firstObj.groupName)) ||
						(_firstObj.groupName != undefined && _firstObj.groupName == x.groupName && _firstObj.selected != true &&
								(x.selected == true || x.tabIndex < _firstObj.tabIndex)))
					{
						// trace("setting firstObj to " + x);
						_firstObj = x;
					}
					// and the highest number
					if (_lastObj == undefined ||
						(x.tabIndex > _lastObj.tabIndex && (x.groupName == undefined || _lastObj.groupName == undefined || x.groupName != _lastObj.groupName)) ||
						(_lastObj.groupName != undefined && _lastObj.groupName == x.groupName && _lastObj.selected != true &&
								(x.selected == true || x.tabIndex > _lastObj.tabIndex)))
					{
						// trace("setting lastObj to " + x);
						_lastObj = x;
					}
				}

				// if there's children look in there
				if (x.tabChildren)
				{
					getTabCandidateFromChildren(x, index, groupName, dir, firsttime && firstChild)
				}
				// this goes down here so it can be used in child calls
				firsttime = false;
			}
			else if (x._parent == p && x.tabChildren == true && x._visible != false)
			{
				if (x == _lastTarget)
				{
					// don't look in here if we've already looked here
					if (x._searchKey == _searchKey)
						continue;

					// mark it as having been seen
					x._searchKey = _searchKey;

  					if (_prevNode == undefined)
  					{
						// trace("found lastTarget: " + x);
						// only override if _lastx isn't a descendant of lasttarget
						// otherwise we're still looking up the tree
						var n = _lastx;
						var bIsChild = false;
						while (n != undefined)
						{
							if (n == x)
							{
								bIsChild = true;
								break;
							}
							n = n._parent;
						}
						if (bIsChild == false)
						{
							// trace("setting prevNode to " + _lastx);
							_prevNode = _lastx;
						}
  					}
  					// mark us as needing to remember the next thing we see, and no longer needing the previous thing
  					_needPrev = false;
					if (_nextNode == undefined)
						_nextIsNext = true;
				}
				else if (!(x.focusManager != undefined && x.focusManager._parent == x))
				{
					// don't look in here if we've already looked here
					if (x._searchKey == _searchKey)
						continue;

					// mark it as having been seen
					x._searchKey = _searchKey;

					// don't look inside if it has its own focus manager
					getTabCandidateFromChildren(x, index, groupName, dir, firsttime && firstChild)
				}
				// this goes down here so it can be used in child calls
				firsttime = false;
			}
		}
		// remember this as the last thing we've seen.  The tree walk will keep
		// resetting this until it actually points to the last thing.
		_lastNode = _lastx;

		if (lookup)
		{
			// look upward in the tree
			if (p._parent != undefined)
			{
				if (p != _parent)
				{
					if (_prevNode == undefined && dir)
					{
						_needPrev = true;
					}
					else if (_nextNode == undefined && !dir)
					{
						_nextIsNext = false;
					}
					_lastTarget = _lastTarget._parent;
					// trace("changing lastTarget to " + _lastTarget);
					getTabCandidate(p._parent, index, groupName, dir, true);
				}
			}
		}
	}

	// for some object o, search its parent for the next tab candidate
	function getTabCandidate(o:MovieClip, index:Number, groupName:String, dir:Boolean, firstChild:Boolean):Void
	{
		var p:MovieClip;
		var lookup:Boolean = true;
		if (o == _parent)
		{
			p = o;
			lookup = false;
		}
		else
		{
			p = o._parent;
			if (p == undefined)
			{
				p = o;
				lookup = false;
			}
		}

		walkTree(p, index, groupName, dir, lookup, firstChild);
	}

	// for some object o, search its children for the next tab candidate
	function getTabCandidateFromChildren(o:MovieClip, index:Number, groupName:String, dir:Boolean, firstChild:Boolean):Void
	{
		walkTree(o, index, groupName, dir, false, firstChild);
	}

	// figure out which focus manager is responsible for this object
	function getFocusManagerFromObject(o:Object):Object
	{
		while (o != undefined)
		{
			if (o.focusManager != undefined)
				return o.focusManager;
			o = o._parent;
		}
		return undefined;
	}

	// this gets called when the tab key is hit
	function tabHandler(Void):Void
	{
		bDrawFocus = true;

		// trace("tabHandled by " + this);
		// get the object that has the focus
		var o:Object = getSelectionFocus();
		// trace("focus was at " + o);
		// find out of this is a valid object in or scheme or find the parent that is
		var p:Object = getActualFocus(o);
		if (p != o)
		{
			// use our focus concepts
			o = p;
		}
		if (getFocusManagerFromObject(o) != this)
			o == undefined;

		// trace("actual focus is " + o);
		if (o == undefined)
		{
			o = form;
			// trace("using form " + o);
		}
		else
		{
			// if someone switches focus manually, need
			// to reset this table
			if (o.tabIndex != undefined)
			{
				if (_foundList != undefined || _foundList.tabIndex != o.tabIndex)
				{
					_foundList = new Object();
					_foundList.tabIndex = o.tabIndex;
				}
				_foundList[o._name] = o;
			}
		}

		var dir:Boolean = Key.isDown(Key.SHIFT) != true;

		// reset the search variables
		_searchKey = getTimer();	// use this value as a uniqueness check as to whether we visited this
										// control already.  Some controls are found twice becuase they have
										// two references to them.
		_needPrev = true;
		_nextIsNext = false;
		_lastx = undefined;
		_firstNode = undefined;
		_lastNode = undefined;
		_nextNode = undefined;
		_prevNode = undefined;
		_firstObj = undefined;
		_lastObj = undefined;
		_nextObj = undefined;
		_prevObj = undefined;
		_lastTarget = o;

		// look through all the children
		var caster = o; // o can be a movieclip or textfield so we stuff it in an untyped variable to get past typechecking
		getTabCandidate(caster, (o.tabIndex == undefined) ? 0 : o.tabIndex, o.groupName, dir, true);

		var x:Object = undefined;

		// now figure out which thing should get the tab
		if (dir)
		{
			if (_nextObj != undefined)
				x = _nextObj;
			else
				x = _firstObj;
		}
		else
		{
			if (_prevObj != undefined)
				x = _prevObj;
			else
				x = _lastObj;
		}
		if (x.tabIndex != o.tabIndex)
		{
			_foundList = new Object();
			_foundList.tabIndex = x.tabIndex;
			_foundList[x._name] = x;
		}
		else
		{
			if (_foundList == undefined)
			{
				_foundList = new Object();
				_foundList.tabIndex = x.tabIndex;
			}
			_foundList[x._name] = x;
		}

		if (x == undefined)
		{
			// didn't find an index so use tree search
			// the tree is actually built backwards so
			// the variable names appear switched
			if (dir == false)
			{
				if (_nextNode != undefined)
					x = _nextNode;
				else
					x = _firstNode;
			}
			else
			{
				if (_prevNode == undefined || o == form)
					x = _lastNode;
				else
					x = _prevNode;
			}
		}


		// trace("WINNER = " + x);
		if (x == undefined) return;

		lastTabFocus = x;

		setFocus(x);
		// handle default pushbutton here
		if (x.emphasized != undefined)
		{
			if (defPushButton != undefined)
			{
				var o:SimpleButton = defPushButton;
				defPushButton = SimpleButton(x);
				o.emphasized = false;
				x.emphasized = true;
			}
		}
		else
		{
			if (defPushButton != undefined && defPushButton != __defaultPushButton)
			{
				var o:SimpleButton = defPushButton;
				defPushButton = __defaultPushButton;
				o.emphasized = false;
				__defaultPushButton.emphasized = true;
			}
		}
	}

	// watch for Enter key
	function onKeyDown(Void):Void
	{
		SystemManager.idleFrames = 0;
		if (defaultPushButtonEnabled)
		{
			if (Key.getCode() == Key.ENTER)
			{
				if (defaultPushButton != undefined)
				{
					doLater(this, "sendDefaultPushButtonEvent");
				}
			}
		}
	}

/**
* can be called to fake the system into thinking the enter key was pressed.
*/
	function sendDefaultPushButtonEvent(Void):Void
	{
		// trace(defPushButton);
		defPushButton.dispatchEvent({type:"click"});
	}

	// figure out which component got moused
	function getMousedComponentFromChildren(x:Number, y:Number, o:Object):Object
	{
		// if we steal focus in mouseDown or mouseUp, we halt processing
		// of button events like onPress and onRelease which messes up
		// button handling.  This algorithm has to match the way the Player
		// works

		// find the hit object
		for (var i in o)
		{
			var j = o[i];
			if (j._visible && j.enabled && j._parent == o && j._searchKey != _searchKey)
			{
				j._searchKey = _searchKey;
				if (j.hitTest(x, y, true))
				{
					// if has button methods, it gets the hit
					// do we need the other methods as well? (onRollOver)
					if (j.onPress != undefined || j.onRelease != undefined)
						return j;
					var k = getMousedComponentFromChildren(x, y, j);
					if (k != undefined)
						return k;
					return j;
				}
			}
		}
		return undefined;
	}

	// this gets called a frame after any buttons have had a chance to
	// set focus to the correct component.  Note that mouseActivate
	// gets called too soon in the debugger because it does
	// constant updating of the screen so you must debug
	// this logic using trace statements and no debugger
	function mouseActivate(Void):Void
	{
		// trace("mouseActivate");
		// if we clicked in a textfield, the player automatically sets focus
		// there so we don't have to do anything
		if (!bNeedFocus) return;

		_searchKey = getTimer();

		// find out what got clicked
		var x:Object = getMousedComponentFromChildren(lastMouse.x, lastMouse.y, form);
		// trace(x + " got moused");

		// if it is a UIComponent it must play by the rules and set focus in ReleaseFocus
		if (x instanceof UIComponent)
			return;

		// if we get here we didn't click on a v2 button so give focus
		// to the appropriate object
		x = findFocusFromObject(x);
		// trace(x + " gets focus");

		// same object
		// trace(lastFocus);
		if (x == lastFocus) return;

		if (x == undefined)
		{
			// trace("restoreFocus");
			doLater(this, "restoreFocus");
			return;
		}

		// trace("set focus from mouseActivate");
		var hscroll = x.hscroll;
		if (hscroll != undefined)
		{
			var vscroll = x.scroll;
			var bg = x.background;
		}
		setFocus(x);
		// we reset a couple of fields onto the Selection object
		var currentSelection:Object = Selection;
		Selection.setSelection(currentSelection.lastBeginIndex, currentSelection.lastEndIndex);
		if (hscroll != undefined)
		{
			x.scroll = vscroll;
			x.hscroll = hscroll;
			x.background = bg;
		}
	}

	// called by the SystemManager when the mouse is clicked.
	function _onMouseDown(Void):Void
	{
		bDrawFocus = false;
		if (lastFocus != undefined)
			lastFocus.drawFocus(false);

		SystemManager.idleFrames = 0;
		// trace("_onMouseDown handled by " + this);
		// trace("focusManager.visible = " + _visible);
		// when you click outside a textfield, the textfield loses
		// focus.  We must catch the last state of the selection
		// before the player takes away focus.
		var currentSelection:Object = Selection;
		currentSelection.lastBeginIndex = Selection.getBeginIndex();
		currentSelection.lastEndIndex = Selection.getEndIndex();

		// next we save away the mouse position and wait for mouse up
		lastMouse.x = _root._xmouse;
		lastMouse.y = _root._ymouse;
		_root.localToGlobal(lastMouse);
	}

	// on mouse up, we wait a frame to see if the player moves the focus to another
	// textfield or not
	function onMouseUp(Void):Void
	{
		// only do this if activated
		if (_visible)
			doLater(this, "mouseActivate");
	}

	function handleEvent(e:Object)
	{
		// trace("handleEvent: " + this);
		if (e.type == "reveal")
			SystemManager.activate(form);
		else
		{
			SystemManager.deactivate(form);
		}
	}

	static var initialized:Boolean = false;
	static function enableFocusManagement():Void
	{
		if (!initialized)
		{
			initialized = true;
			Object.registerClass("FocusManager", FocusManager);
			if (_root.focusManager == undefined)
				_root.createClassObject(FocusManager, "focusManager", mx.managers.DepthManager.highestDepth--);
				
		}
	}
 	static var UIObjectExtensionsDependency = mx.core.ext.UIObjectExtensions;
}
