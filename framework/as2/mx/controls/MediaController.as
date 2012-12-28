//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaDisplay;
import mx.controls.streamingmedia.Chrome;
import mx.controls.streamingmedia.LoadBar;
import mx.controls.streamingmedia.MiniPlayBar;
import mx.controls.streamingmedia.PlayBar;
import mx.controls.streamingmedia.ScreenAccommodator;
import mx.controls.streamingmedia.StreamingMediaConstants;
import mx.controls.streamingmedia.Tracer;
import mx.controls.streamingmedia.VolumeControl;
import mx.core.UIComponent;

[RequiresDataBinding(true)]
[IconFile("MediaController.png")]

// Event metadata a la C#
/**
 * @tiptext click event
 * @helpid 3481
 */
[Event("click")]
/**
 * @tiptext playheadChange event
 * @helpid 3484
 */
[Event("playheadChange")]
/**
 * @tiptext volume event
 * @helpid 3486
 */
[Event("volume")]

/**
 * @tiptext scrubbing event
 * @helpid
 */
[Event("scrubbing")]

/**
 * MediaController contains the playback controls for controlling
 * streaming media files.
 *
 * @author Andrew Guldman
 * @tiptext MediaController contains the playback controls for streaming media files
 * @helpid 3490
 */
class mx.controls.MediaController
extends UIComponent
{
	// This set of properties is for FUIComponent
	static var symbolName:String = "MediaController";
	static var symbolOwner:Object = mx.controls.MediaController;
	var	className:String = "MediaController";
//#include "../core/MediaComponentVersion.as"

	var clipParameters:Object =
	{
		controllerPolicy: "auto",
		horizontal: true,
		activePlayControl: "pause",
		backgroundStyle: "default"
	};


	// The rest of the properties do not pertain to FUIComponent
	/** The minimum width of the horizontal component */
	private static var MINIMUM_HORIZONTAL_WIDTH:Number = 202;
	/** The height of the closed control */
	private static var CLOSED_HORIZONTAL_HEIGHT:Number = 25;
	/** The minimum height of the open control */
	private static var MINIMUM_HORIZONTAL_OPEN_HEIGHT:Number = 63;
	/** The y-coordinate of the loadbar when the controller is closed */
	private static var LOADBAR_HORIZONTAL_CLOSED_Y:Number = 14;
	/** The y-coordinate of the loadbar when the controller is open */
	private static var LOADBAR_HORIZONTAL_OPEN_Y:Number = 24;

	/** The minimum height of the vertical component */
	private static var MINIMUM_VERTICAL_HEIGHT:Number = 202;
	/** The width of the closed vertical control */
	private static var CLOSED_VERTICAL_WIDTH:Number = 25;
	/** The minimum width of the open vertical control */
	private static var MINIMUM_VERTICAL_OPEN_WIDTH:Number = 80;
	/** The x-coordinate of the loadbar when the controller is closed */
	private static var LOADBAR_VERTICAL_CLOSED_X:Number = 14;
	/** The x-coordinate of the miniplaybar when the controller is closed */
	private static var MINIPLAYBAR_VERTICAL_CLOSED_X:Number = 8;

	/** Animation duration in ms */
//	private static var ANIMATION_TIME:Number = 1250;
	private static var ANIMATION_TIME:Number = 250;
	/** Delay before closing open controller on rollout */
	private static var CLOSE_DELAY:Number = 1000;
	/** Delay before opening closed controller on rollover */
	private static var OPEN_DELAY:Number = 100;
	/** The name of the XML file holding localized strings */
	private static var LOCALIZED_FILE:String = "streamingmediacontroller.xml";

	private static var H_BORDER:Number = 8;
	private static var V_BORDER:Number = 8;

	private var _deadPreview:MovieClip;
	/**
	 * Indicates how the controller behaves wrt mouse interaction.
	 * 3 allowable settings:
	 * on: always expanded
	 * off: always contracted (must be expanded programmatically)
	 * auto: initially contracted. expands when mouse rolls over,
	 *       contracts when mouse rolls off.
	 */
	private var _controllerPolicy:String;
	private var _horizontal:Boolean;
	/** The control buttons */
	private var _buttons:MovieClip;
	private var _loadBar:LoadBar;
	private var _playBar:PlayBar;
	private var _miniPlayBar:MiniPlayBar;
	private var _volumeControl:VolumeControl;
	/** Chrome */
	private var _chrome:Chrome;
	/** Allowable values are "none" and "default" */
	private var _backgroundStyle:String;

	/** Is the clip open? */
	private var _isOpen:Boolean;
	/** Was the mouse over the clip the last time we checked? */
	private var _priorMouseOver:Boolean;
	// Variables to facilitate animation between the open and closed states
	/** Start time in ms since movie started */
	private var _animationStart:Number;
	/** Animate open or closed? */
	private var _animationOpen:Boolean;
	/**
	 * The id of the interval used to close the controller.
	 */
	private var _closeId:Number;
	/**
	 * The id of the interval used to open the controller.
	 */
	private var _openId:Number;
	/**
	 * True to ignore rollovers and not animate. This is used to suppress
	 * animation when the mouse is over a full screen toggle control.
	 */
	private var _notAnimating:Boolean;
	/** Is animation active? */
	private var _animating:Boolean = false;
	/** Is the user listening for playhead move events? */
	private var _listenForPlayheadMoveEvent:Boolean;
	/** The initial active play control is either "play" or "pause" */
	private var _activePlayControl:String;
	/** Is the control playing? */
	private var _isPlaying:Boolean;
	/** The last volume that the control was set to. Between 0 and 100. */
	private var _volume:Number;
	/** The last play percentage */
	private var _playPercent:Number;
	/** The last play time, in seconds */
	private var _playTime:Number;
	/** The last load completion percentage */
	private var _loadPercent:Number;

	/** The localized strings */
	private var _strings:Object;

	/** Second chrome -- lets the controller animate the player's chrome */
	private var _secondChrome:Chrome;
	private var _secondChromeClosedHeight:Number;
	private var _secondChromeOpenHeight:Number;
	private var _secondChromeClosedWidth:Number;
	private var _secondChromeOpenWidth:Number;
	/** Animate it up or to the left */
	private var _secondChromeFixedEnd:Boolean;

	/**
	 * Move up or to the left when animating open.
	 * Vertical orientation -> open left.
	 * Horizontal orientation -> open up.
	 */
	private var _openUpOrLeft:Boolean;

	/** Is this component enabled? */
		// By default, the controller is enabled
	private var _enabled:Boolean = true;
	/** The controllerPolicy prior to being disabled */
	private var _priorPolicy:String;

	/**
	 * Should a click on the play button start play at the beginning of
	 * the media?
	 * Must be public because the PlayPauseButton class needs to update it.
	 */
	public var playAtBeginning:Boolean;

	/**
	 * The media type of the display component that most recently broadcast
	 * a progress event that was received by this controller.
	 * This is used to determine whether to disable the toEnd button.
	 */
	private var _lastProgressMediaType:String;

	public function get lastProgressMediaType():String
	{
		return _lastProgressMediaType;
	}

	/**
	 * The screen accommodator automatically enables and disables the
	 * component inside a screen.
	 */
	private var _screenAccommodator:ScreenAccommodator;


	/**
	 * Constructor
	 */
	public function MediaController()
	{
	}

	// The next group of functions is connected to FUIComponent and FUIObject

	/**
	 * Initialize the controller.
	 */
	function init(Void):Void
	{
		Tracer.trace("MediaController.init: start: policy=" + _controllerPolicy);
		// Initialize values as necessary
		initializeParameters();
		Tracer.trace("MediaController.init: after initializeParameters: policy=" + _controllerPolicy);

//		Tracer.trace("MediaController.init: " +
//			this._width + "x" + this._height + " at (" + this._x + "," + this._y + ")");

		// Read the size of the dead preview before calling super.init()
		// because that function sets _xscale and _yscale to 100.
		var piWidth:Number = this._width;
		var piHeight:Number = this._height;

//		Tracer.trace("MediaController.init: display vars " +
//			_displayWidth + "x" + _displayHeight + " at (" + this._x + "," + this._y + "), scale=" +
//			this._xscale + "x" + this._yscale);

		super.init();

//		Tracer.trace("MediaController.init: after super.init() " +
//			this.width + "x" + this.height + " at (" + this._x + "," + this._y + ")");

		if (_horizontal)
		{
//			Tracer.trace("MediaController.init: adjusting horizontal bounds");
			piWidth = Math.max(MINIMUM_HORIZONTAL_WIDTH, piWidth);
			piHeight = Math.max(MINIMUM_HORIZONTAL_OPEN_HEIGHT, piHeight);
		}
		else
		{
//			Tracer.trace("MediaController.init: adjusting vertical bounds");
			piWidth = Math.max(MINIMUM_VERTICAL_OPEN_WIDTH, piWidth);
			piHeight = Math.max(MINIMUM_VERTICAL_HEIGHT, piHeight);
		}
//		Tracer.trace("MediaController.init: after adjustment " +
//			piWidth + "x" + piHeight + " at (" + this._x + "," + this._y + ")");

		// Reset the width and height
		this.setSize(piWidth, piHeight, true);

		Tracer.trace("MediaController.init: after setSize " +
			this.width + "x" + this.height + " at (" + this._x + "," + this._y + ")");

		// Initialize the prior policy
		_priorPolicy = _controllerPolicy;

		// Create default strings to use while we wait for the localized
		// strings to load. We will also use these if the loading fails.
		createDefaultStrings();
		// Do *not* read localized string from an XML file. Always use the default strings.
		/*
		// Read the localized strings from the xml file
		var localized:XML = new XML();
		// Use casting to trick the compiler into allowing a custom property on the xml object
		Object(localized)._strings = this._strings;
		localized.onLoad = function(success)
		{
			if (success)
			{
				var mainNode:XMLNode;
				for (var mainIx:Number = 0; mainIx < this.childNodes.length; mainIx++)
				{
					if (this.childNodes[mainIx].nodeName == "localizedStrings")
					{
						mainNode = this.childNodes[mainIx];
						for (var strIx = 0; strIx < mainNode.childNodes.length; strIx++)
						{
							if (mainNode.childNodes[strIx].nodeName == "string")
							{
								this._strings[mainNode.childNodes[strIx].attributes.id] = mainNode.childNodes[strIx].attributes.value;
//								Tracer.trace(mainNode.childNodes[strIx].attributes.id + "=" + mainNode.childNodes[strIx].attributes.value);
							}
						}
						break;
					}
				}
			}
		};
		localized.load( LOCALIZED_FILE );
		*/

		// Confirm that properties were set
		Tracer.trace("MediaController.init: Initialized properties:");
		Tracer.trace("  controllerPolicy=" + _controllerPolicy);
		Tracer.trace("  horizontal=" + _horizontal);
		Tracer.trace("  activePlayControl=" + _activePlayControl);
		Tracer.trace("  backgroundStyle=" + _backgroundStyle);

		if (_controllerPolicy == "auto")
		{
			// For auto policy, close the controller, and listen for the
			// mouse to open it.
			_isOpen = false;
			_priorMouseOver = false;
			_closeId = null;
			_openId = null;
			// Listen for mouse events
			Mouse.addListener(this);
			this.gotoAndStop( getClosedFrameName() );
		}
		else if (_controllerPolicy == "on")
		{
			_isOpen = true;
			this.gotoAndStop( getOpenFrameName() );
		}
		else if (_controllerPolicy == "off")
		{
			_isOpen = false;
			this.gotoAndStop( getClosedFrameName() );
		}

		// Keep track of whether the controller is in play or pause mode
		// This seems backwards at first glance but isn't. The media is playing
		// if the pause button is displayed.
		this._isPlaying = (_activePlayControl == "pause");
//		Tracer.trace("  _isPlaying=" + _isPlaying);

		// Initialize playPercent and playTime to 0
		_playPercent = 0;
		_playTime = 0;

		// Read the initial volume from the constants file
		this._volume = StreamingMediaConstants.DEFAULT_VOLUME;

		// Initially open down or right
		setOpenUpOrLeft(false);

		// Listen for playheadMove events
		setListeningForPlayheadMoveEvent(true);

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;

		playAtBeginning = false;

		// Create a ScreenAccommodator to manage the interactions with screens,
		// if there are any. Keep a reference to it to ensure that it isn't
		// garbage collected
		_screenAccommodator = new ScreenAccommodator(this);

		// Draw the beasty
		this.redraw(true);
//		Tracer.trace("MediaController.init: after redraw " +
//			_displayWidth + "x" + _displayHeight + " at (" + this._x + "," + this._y + "), scale=" +
//			this._xscale + "x" + this._yscale);
	}

	/**
	 * Create default values for absent parameters
	 */
	private function initializeParameters():Void
	{
		if (horizontal == null)
		{
			horizontal = true;
		}
		if (controllerPolicy == null)
		{
			controllerPolicy = "auto";
		}
		if (backgroundStyle == null)
		{
			backgroundStyle = "default";
		}
		if (activePlayControl == null)
		{
			activePlayControl = "pause";
		}
	}

	private function getOpenFrameName():String
	{
		return (_horizontal ? "openHorizontal" : "openVertical" );
	}

	private function getClosedFrameName():String
	{
		return (_horizontal ? "closedHorizontal" : "closedVertical" );
	}

	/**
	 * @private
	 * initialize properties from clip parameters
	function initFromClipParameters(Void):Void
	{
//		Tracer.trace("MediaController.initFromClipParameters");
		super.initFromClipParameters();
	}
	 */

	/**
	 * @private
	 * create children objects
	function createChildren(Void):Void
	{
//		Tracer.trace("MediaController.createChildren");
		super.createChildren();
	}
	 */

	/**
	 * @private draw the object.  called by invalidation system
	 */
	function draw(Void):Void
	{
//		Tracer.trace("MediaController.draw: start " +
//			_displayWidth + "x" + _displayHeight + " at (" + this._x + "," + this._y + "), scale=" +
//			this._xscale + "x" + this._yscale);

		// Position and resize the (mini)playBar
		if (_isOpen)
		{
			this.gotoAndStop( getOpenFrameName() );
			_playBar.draw();
		}
		else
		{
			this.gotoAndStop( getClosedFrameName() );
			_miniPlayBar.draw();
		}

		// Position and resize the load bar
		_loadBar.draw();

		if (_horizontal)
		{
			positionControlsHorizontal();
		}
		else
		{
			positionControlsVertical();
		}

		this.drawChrome();
//		Tracer.trace("MediaController.draw: " + (_isOpen ? "open" : "closed" ) + " " + _displayWidth + "x" + _displayHeight + " at (" + this._x + "," + this._y + "), scale=" + this._xscale + "x" + this._yscale);
	}


	// The remaining functions are independent of FUIComponent and FUIObject


	private function positionControlsVertical():Void
	{
		if (_isOpen)
		{
			// Position the volume control. Centered at the bottom.
			this._volumeControl._x = (this.width - this._volumeControl._width) / 2;
			this._volumeControl._y = this.height - this._volumeControl._height - 8;

			// Position the buttons. Centered above the volume control.
			this._buttons._x = (this.width - this._buttons._width) / 2;
			this._buttons._y = this.height - this._buttons._height - this._volumeControl._height - 16;

			// Position the play bar. Center it.
			_playBar._x = (this.width - this._playBar._width) / 2;
			// Position the load bar. Schnoogle it up next to the play bar.
			_loadBar._x = _playBar._x + _playBar._width - 4;

//			Tracer.trace("buttons at (" + this._buttons._x + "," + this._buttons._y +
//				"), volume at (" + this._volumeControl._x + "," +
//				this._volumeControl._y + ")");
		}
		else
		{
			// Position the load bar and the miniplaybar
			_loadBar._x = LOADBAR_VERTICAL_CLOSED_X;
			_miniPlayBar._x = MINIPLAYBAR_VERTICAL_CLOSED_X;
		}
//		Tracer.trace("MediaController.positionControlsVertical: _loadBar._x=" + _loadBar._x);
	}



	private function positionControlsHorizontal():Void
	{
		if (_isOpen)
		{
			// Position the load bar
			_loadBar._y = LOADBAR_HORIZONTAL_OPEN_Y;

			// Position the buttons
			this._buttons._x = 8;
			this._buttons._y = this.height - this._buttons._height - 8;

			// Position the volume control
			this._volumeControl._x = this.width - this._volumeControl._width - 8;
			this._volumeControl._y = this.height - this._volumeControl._height - 8;

//			Tracer.trace("buttons at (" + this._buttons._x + "," + this._buttons._y +
//				"), volume at (" + this._volumeControl._x + "," +
//				this._volumeControl._y + ")");
		}
		else
		{
			// Position the load bar
			_loadBar._y = LOADBAR_HORIZONTAL_CLOSED_Y;
		}
	}

	/**
	 * Draw the chrome for the controller.
	 *
	 * @param width The width of the chrome. Optional. If not specified, then the
	 * appropriate standard open or closed width will be used.
	 * @param height The height of the chrome. Optional. If not specified, then the
	 * appropriate standard open or closed height will be used.
	 */
	private function drawChrome(wi:Number, he:Number):Void
	{
		if (wi == null)
		{
			if (_horizontal)
			{
				wi = width;
			}
			else
			{
				wi = ( _isOpen ? width : CLOSED_VERTICAL_WIDTH );
			}
		}

		if (he == null)
		{
			if (_horizontal)
			{
				he = ( _isOpen ? height : CLOSED_HORIZONTAL_HEIGHT );
			}
			else
			{
				he = height;
			}
		}

		_chrome.visible = (backgroundStyle == "default");
		_chrome.showToggles = false;
		_chrome.setSize(wi, he);
		_chrome.draw();
	}

	/**
	 * Add a second chrome to the control. This is used to allow the controller
	 * to animate the chrome of the player in auto mode.
	 */
	public function addSecondChrome(theChrome:Chrome,
		closedHeight:Number, openHeight:Number,
		closedWidth:Number, openWidth:Number, fixedEnd:Boolean):Void
	{
		_secondChrome = theChrome;
		_secondChromeClosedHeight = closedHeight;
		_secondChromeOpenHeight = openHeight;
		_secondChromeClosedWidth = closedWidth;
		_secondChromeOpenWidth = openWidth;
		_secondChromeFixedEnd = fixedEnd;
//		Tracer.trace("MediaController.addSecondChrome: (" + _secondChromeClosedHeight + " to " + _secondChromeOpenHeight + ") by (" + _secondChromeClosedWidth + " to " + _secondChromeOpenWidth + ") fixedEnd=" + _secondChromeFixedEnd);
	}

	/**
	 * Remove the second chrome instance from the controller.
	 */
	public function removeSecondChrome():Void
	{
		_secondChrome = null;
	}

	public function get expanded():Boolean
	{
		return _isOpen;
	}

	/**
	 * Manually monitor mouse movement. It would be nice to use the
	 * onRollOver and onRollOut functions but those will prevent mouse
	 * events from reaching the contained clips. No good. Instead
	 * we manually track mouse movement.
	 */
	public function onMouseMove():Void
	{
		// Track the mouse to know when the user rolls over or out
		var x:Number = _root._xmouse;
		var y:Number = _root._ymouse;
		var hit:Boolean = this.hitTest(x, y, true);
//		Tracer.trace("onMouseMove: mouse=(" + x + "," + y +
//			"), hit=" + hit + ", priorHit=" + _priorMouseOver);

		if ( (hit && (_closeId != null)) || isNotAnimating() )
		{
			// If the mouse is over the clip, don't close it.
			clearInterval(_closeId);
			_closeId = null;
		}
		if ( (!hit && (_openId != null)) || isNotAnimating() )
		{
			// If the mouse is not over the clip, don't open it.
			clearInterval(_openId);
			_openId = null;
		}

		if (hit && !_isOpen && (_controllerPolicy == "auto") && (_openId == null) && !isNotAnimating())
		{
			// The mouse just moved over the closed clip. Set the timer to expand.
			_openId = setInterval(this, "expand", OPEN_DELAY);
		}
		else if (!hit && _isOpen && (_controllerPolicy == "auto") && (_closeId == null) && !isNotAnimating())
		{
			// The mouse is off the clip and the clip is open but the
			// timer isn't ticking. Start it.
			_closeId = setInterval(this, "contract", CLOSE_DELAY);
		}
		_priorMouseOver = hit;
	}

	/**
	 * If policy is auto for this clip, expand the controller.
	 * Otherwise, do nothing. Unless forced.
	 */
	public function expand(force:Boolean):Void
	{
		// Clear the interval so this only happens once
		clearInterval(_openId);
		_openId = null;

		if ( (_controllerPolicy == "auto") || force)
		{
			_isOpen = true;
			_animationStart = getTimer();
			_animationOpen = true;
			_priorMouseOver = true;
			this.onEnterFrame = this.animate;
		}
	}

	/**
	 * If policy is auto for this clip, contract it. Otherwise, do nothing.
	 * Unless forced.
	 */
	public function contract(force:Boolean):Void
	{
		Tracer.trace("MediaController.contract: force=" + force +
			", animating=" + _animating + ", opening=" + _animationOpen);
		if (_animating && (!_animationOpen))
		{
			// We are already contracting. Do nothing.
			return;
		}

		// Clear the interval so this only happens once
		clearInterval(_closeId);
		_closeId = null;

		if ( (_controllerPolicy == "auto") || force)
		{
			_isOpen = false;
			_animationStart = getTimer();
			_animationOpen = false;
			_priorMouseOver = false;
			// Move to the "closed" frame
			this.gotoAndStop( getClosedFrameName() );
			// Call animate immediately so that the "closed" frame
			// is adjusted appropriately before it is displayed.
			this.animate();
			// Continue calling animate until the controller has closed.
			this.onEnterFrame = this.animate;
		}
	}

	/**
	 * Animate the transition. This is called as an onEnterFrame function.
	 */
	private function animate():Void
	{
		_animating = true;
		var elapsed:Number = getTimer() - _animationStart;
		var portion:Number = Math.min(1, elapsed / ANIMATION_TIME);
		Tracer.trace("MediaController.animate: _animationStart=" +
			_animationStart + ", elapsed=" + elapsed + ", portion=" +
			portion + ", ANIMATION_TIME=" + ANIMATION_TIME);

		// Make the chrome the proper size
		sizeMainChrome(portion);

		if (_secondChrome != null)
		{
			// Resize the second chrome
			sizeSecondChrome(portion);
		}

		// Move and size the load bar and miniplaybar
		animateBars(portion);

		if (elapsed >= ANIMATION_TIME || _global.isLivePreview)
		{
			animationDone();
		}
	}

	private function animationDone():Void
	{
		Tracer.trace("MediaController.animationDone");
		// We are done
		_animating = false;
		delete this.onEnterFrame;

		// Reset the load bar's completion percentage.
		// It gets mucked up when the load bar resizes.
		refreshBars();

		if (_animationOpen)
		{
			// Move to the "open" frame
			this.gotoAndStop( getOpenFrameName() );
		}
		else
		{
			// We have already moved to the "closed" frame
			//this.gotoAndStop("closed");
		}
		this.redraw(true);
	}

	/**
	 * Size the main chrome according to the portion parameter.
	 *
	 * @param portion A number between 0 and 1 (inclusive) indicating how far along
	 * the animation has progressed.
	 */
	private function sizeMainChrome(portion:Number):Void
	{
		var h:Number = height;
		var w:Number = width;

		if (_horizontal)
		{
			var piece:Number = (height - CLOSED_HORIZONTAL_HEIGHT) * portion;
			if (_animationOpen)
			{
				h = CLOSED_HORIZONTAL_HEIGHT + piece;
			}
			else
			{
				h = height - piece;
			}
		}
		else
		{
			var piece:Number = (width - CLOSED_VERTICAL_WIDTH) * portion;
			if (_animationOpen)
			{
				w = CLOSED_VERTICAL_WIDTH + piece;
			}
			else
			{
				w = width - piece;
			}
		}

		if (isOpenUpOrLeft())
		{
			// Move the entire controller up or left by the same amount that
			// the chrome has grown. (Or move down or right if the chrome has
			// shrunk.)
			var deltaX:Number = _chrome.width - w;
			var deltaY:Number = _chrome.height - h;
			this._x += deltaX;
			this._y += deltaY;
		}

		// Resize the main chrome
		this.drawChrome(w, h);
	}


	private function sizeSecondChrome(portion:Number):Void
	{
		var h:Number, w:Number, piece:Number;
		if (_horizontal)
		{
			w = _secondChromeClosedWidth;
			piece = (_secondChromeOpenHeight - _secondChromeClosedHeight) * portion;
			h = ( _animationOpen ? _secondChromeClosedHeight + piece : _secondChromeOpenHeight - piece );
			if (_secondChromeFixedEnd)
			{
				// Move the chrome left by the same amount that it grows (could be negative)
//				Tracer.trace("MediaController.sizeSecondChrome: y=" + _secondChrome._y + ", oldH=" +
//					_secondChrome.height + ", newH=" + h);
				_secondChrome._y = _secondChrome._y - h + _secondChrome.height;
			}
		}
		else
		{
			// For vertical, the open and closed height should be the same.
			// The choice of which to use is arbitrary.
			h = _secondChromeClosedHeight;
			piece = (_secondChromeOpenWidth - _secondChromeClosedWidth) * portion;
			w = ( _animationOpen ? _secondChromeClosedWidth + piece : _secondChromeOpenWidth - piece );
			if (_secondChromeFixedEnd)
			{
				// Move the chrome up by the same amount that it grows (could be negative)
//				Tracer.trace("MediaController.sizeSecondChrome: x=" + _secondChrome._x + ", oldW=" +
//					_secondChrome.width + ", newW=" + w);
				_secondChrome._x = _secondChrome._x - w + _secondChrome.width;
			}
		}
		_secondChrome.setSize(w, h);
		_secondChrome.draw();
	}


	/**
	 * Move and size the load and play bars during the opening and
	 * closing animations.
	 */
	private function animateBars(portion:Number):Void
	{
		var piece:Number;
		if (_horizontal)
		{
			// Horizontal orientation
			piece = (LOADBAR_HORIZONTAL_OPEN_Y - LOADBAR_HORIZONTAL_CLOSED_Y) * portion;
			var y:Number = ( _animationOpen ? LOADBAR_HORIZONTAL_CLOSED_Y + piece : LOADBAR_HORIZONTAL_OPEN_Y - piece );
			_loadBar._y = y;
		}
		else
		{
			// Vertical orientation
			// Move the mini play bar between the middle of the chrome and the closed position
			var middleChrome:Number = _chrome.width / 2;
			piece = (middleChrome - MINIPLAYBAR_VERTICAL_CLOSED_X) * portion;
			// Make sure that piece is positive or 0
			piece = Math.max(0, piece);
			var x:Number = (_animationOpen ? MINIPLAYBAR_VERTICAL_CLOSED_X + piece : middleChrome - piece);
//			Tracer.trace("Controller.animateBars: " + (_animationOpen ? "opening" : "closing") +
//				", middleChrome=" + middleChrome + ", piece=" + piece + ", x=" + x);
			_miniPlayBar._x = x;

			// Keep the load bar next to the miniplaybar
			_loadBar._x = _miniPlayBar._x + _miniPlayBar._width;

			// Adjust the height of the load bar and the miniplaybar
			var cH:Number = _loadBar.getClosedHeight();
			var oH:Number = _loadBar.getOpenHeight();
			piece = (cH - oH) * portion;
			var h:Number = (_animationOpen ? cH - piece : oH + piece);
			_loadBar.draw(h);
			_miniPlayBar.draw(h);
//			Tracer.trace("Controller.animateBars: " + (_animationOpen ? "opening" : "closing") +
//				", closedH=" + cH + ", openH=" + oH + ", portion=" + portion + ", piece=" + piece +
//				", h=" + h);
		}
	}

	public function getLoadBar():LoadBar
	{
		return _loadBar;
	}

	public function refreshBars():Void
	{
		Tracer.trace("MediaController.refreshBars: load=" + _loadPercent + ", play=" + _playPercent);
		_loadBar.setCompletionPercentage(_loadPercent);
		_playBar.setCompletionPercentage(_playPercent);
		_miniPlayBar.setCompletionPercentage(_playPercent);
	}

	/**
	 * This function is only for the internal use of the the controller.
	 * It is public so that subclips can access it.
	 */
	public function getLoadPercent():Number
	{
		return _loadPercent;
	}


	public function getMinimumOpenHeight():Number
	{
		var h:Number = (_horizontal ? MINIMUM_HORIZONTAL_OPEN_HEIGHT : MINIMUM_VERTICAL_HEIGHT);
		return h;
	}

	public function getMinimumClosedHeight():Number
	{
		var h:Number = (_horizontal ? CLOSED_HORIZONTAL_HEIGHT : MINIMUM_VERTICAL_HEIGHT);
		return h;
	}

	public function getMinimumOpenWidth():Number
	{
		var w:Number = (_horizontal ? MINIMUM_HORIZONTAL_WIDTH : MINIMUM_VERTICAL_OPEN_WIDTH);
		return w;
	}

	public function getMinimumClosedWidth():Number
	{
		var w:Number = (_horizontal ? MINIMUM_HORIZONTAL_WIDTH : CLOSED_VERTICAL_WIDTH);
		return w;
	}


	/**
	 * Indicates how the controller behaves wrt mouse interaction.
	 * 3 allowable settings:
	 * on: always expanded
	 * off: always contracted (must be expanded programmatically)
	 * auto: initially contracted. expands when mouse rolls over,
	 *       contracts when mouse rolls off.
	 * @tiptext Determines whether the controller only displays itself on mouse over
	 * @helpid 3458
	 */
	[Inspectable(enumeration="auto,on,off", defaultValue="auto")]
	public function get controllerPolicy():String
	{
		return _controllerPolicy;
	}

	public function set controllerPolicy(aPolicy:String):Void
	{
		Tracer.trace("MediaController.set controllerPolicy: old=" + _controllerPolicy + ", new=" + aPolicy);
		if (aPolicy == _controllerPolicy)
		{
			// No change. Don't do anything.
			return;
		}
		_controllerPolicy = aPolicy;
		if (_controllerPolicy == "on")
		{
			// Remove the mouse listener
			Mouse.removeListener(this);
			if (!_isOpen)
			{
				// Open the controller
				this.expand(true);
			}
		}
		else if (_controllerPolicy == "off")
		{
			// Remove the mouse listener
			Mouse.removeListener(this);
			if (_isOpen)
			{
				// Contract the controller
				Tracer.trace("MediaController.set controllerPolicy(off): about to call contract");
				this.contract(true);
			}
		}
		else if (_controllerPolicy == "auto")
		{
			_closeId = null;
			_openId = null;
			// Listen for mouse events
			Mouse.addListener(this);
			// Is the mouse currently over the controller?
			var hit:Boolean = this.hitTest(_root._xmouse, _root._ymouse, true);
			if (_isOpen && (!hit))
			{
				Tracer.trace("MediaController.set controllerPolicy(auto): about to call contract");
				this.contract();
			}
			else if ((!_isOpen) && hit)
			{
				this.expand();
			}
		}
		else
		{
			//throw new Error("The controller policy must be set to on, off, or auto");
		}
	}

	/**
	 * @tiptext Determines whether the controller will display itself vertically or horizontally
	 * @helpid 3461
	 */
	[Inspectable(defaultValue=true)]
	public function get horizontal():Boolean
	{
		return _horizontal;
	}
	public function set horizontal(isHoriz:Boolean):Void
	{
		if (isHoriz != _horizontal)
		{
			// A change was made
			_horizontal = isHoriz;
			// Swap dimensions
			var newW:Number = height;
			var newH:Number = width;
			// Make sure the minimum dimensions are met
			if (isHoriz)
			{
				newW = Math.max(newW, MINIMUM_HORIZONTAL_WIDTH);
				newH = Math.max(newH, MINIMUM_HORIZONTAL_OPEN_HEIGHT);
			}
			else
			{
				newW = Math.max(newW, MINIMUM_VERTICAL_OPEN_WIDTH);
				newH = Math.max(newH, MINIMUM_VERTICAL_HEIGHT);
			}
			setSize(newW, newH);

			this.invalidate();
		}
		else
		{
			// Change the property anyway
			_horizontal = isHoriz;
		}
	}


	/**
	 * @return The most recent volume setting
	 * @tiptext The volume setting in value range from 0 to 100
	 * @helpid 3468
	 */
	[ChangeEvent("volume")]
	[Bindable]
	public function get volume():Number
	{
		return _volume;
	}


	/**
	 * Set the volume that is displayed in the controller.
	 */
	public function set volume(vol:Number):Void
	{
		_volume = vol;
		// Update the controls
		_volumeControl.getHandle().setVolume(vol);
	}


	/**
	 * Should the component draw chrome?
	 * @tiptext Determines whether the Controller instance draws its chrome background
	 * @helpid 3454
	 */
	[Inspectable(enumeration="none,default", defaultValue="default")]
	public function get backgroundStyle():String
	{
		return _backgroundStyle;
	}
	public function set backgroundStyle(aStyle:String):Void
	{
		_backgroundStyle = aStyle;
		drawChrome();
	}

	/**
	 * Broadcast an event.
	 *
	 * @param eventType The type of event (play, stop, pause, etc)
	 * @param detailArg An additional parameter for the specific event type
	 */
	public function broadcastEvent(eventType:String, detailArg):Void
	{
//		Tracer.trace("Broadcasting " + eventType + " event");
		var ev:Object = { type: eventType, target: this, detail: detailArg };
		if (eventType == "volume")
		{
			// Record the most recent volume setting
			_volume = detailArg;
		}
		// Dispatch the event we have constructed
		dispatchEvent(ev);
	}

	/**
	 * Handle events for which the controller listens
	 */
	public function handleEvent(ev:Object):Void
	{
//		Tracer.trace("MediaController.handleEvent: type=" + ev.type);
		if (ev.type == "change")
		{
			// The media has moved. We should no longer automatically begin play at the
			// beginning of the file.
//			Tracer.trace("MediaController.handleEvent: playAtBeginning=false");
			playAtBeginning = false;
			if (isListeningForPlayheadMoveEvent())
			{
				handleChangeEvent(ev);
			}
		}
		else if (ev.type == "progress")
		{
			handleProgressEvent(ev);
		}
		else if (ev.type == "complete")
		{
			handleCompleteEvent(ev);
		}
		else if (ev.type == "scrubbing")
		{
			handleScrubbingEvent(ev);
		}
		else
		{
			handleUnrecognizedEvent(ev);
		}
	}


	/**
	 * @return True if the controller is listening for playhead move events.
	 * False if not.
	 */
	public function isListeningForPlayheadMoveEvent():Boolean
	{
		return _listenForPlayheadMoveEvent;
	}

	/**
	 * @return True if the controller is listening for playhead move events.
	 * False if not.
	 */
	public function setListeningForPlayheadMoveEvent(listen:Boolean):Void
	{
		_listenForPlayheadMoveEvent = listen;
	}

	public function isNotAnimating():Boolean
	{
		return _notAnimating;
	}
	public function setNotAnimating(still:Boolean):Void
	{
		_notAnimating = still;
	}


	/**
	 * The active play control must be either play or pause.
	 * It must be writable so it can be set by the properties inspector.
	 * It only pertains to the starting state of the component and should
	 * *not* be written under normal circumstances.
	 * @tiptext Determines what state the controller is in when it is loaded at runtime
	 * @helpid 3450
	 */
	[Inspectable(enumeration="pause,play", defaultValue="pause")]
	public function get activePlayControl():String
	{
		return _activePlayControl;
	}
	public function set activePlayControl(aControl:String):Void
	{
		_activePlayControl = aControl;
	}

	/**
	 * @return True if the control is playing; false if not.
	 */
    [ChangeEvent("change")]
    [Bindable]
    public function get playing():Boolean
    {
        return isPlaying();
    }

    public function set playing(playFlag:Boolean):Void
    {
        setPlaying(playFlag);
    }

	public function isPlaying():Boolean
	{
		return this._isPlaying;
	}
	public function setPlaying(playFlag:Boolean):Void
	{
//		Tracer.trace("Controller.setPlaying: " + playFlag);
		this._isPlaying = playFlag;
		// Cascade this to the playBar clip
		_playBar.setIsPlaying(playFlag);
		if (playFlag)
		{
			// Show the pause button
			this._buttons.playPauseButtons.showPauseButton();
		}
		else
		{
			// Show the play button
			this._buttons.playPauseButtons.showPlayButton();
		}
	}



	/**
	 * Handle a change event. Position the playbar to show the
	 * the current play position.
	 * Save the data in the controller so the playbar can subsequently
	 * be initialized properly.
	 */
	private function handleChangeEvent(ev:Object):Void
	{
		// The target of the event is a MediaDisplay object.
		// Get a reference to it
		var player:MediaDisplay = ev.target;
		// Ask it for the current playhead position
		_playTime = player.playheadTime;
		// Ask it for the total play length
		var total:Number = player.totalTime;
		_playPercent = 100 * _playTime / total;
		// Position the playbars accordingly
		if (_isOpen)
		{
			_playBar.setCompletionPercentage( _playPercent );
			_playBar.setTime( _playTime );
		}
		else
		{
//			Tracer.trace("MediaController.handleChangeEvent: setting miniplaybar % to " +
//				_playPercent);
			_miniPlayBar.setCompletionPercentage( _playPercent );
		}
	}

	/**
	 * Handle a progress event. Position the load bar to show the percentage
	 * of the media that has loaded.
	 */
	private function handleProgressEvent(ev:Object):Void
	{
		// The target of the event is a MediaDisplay/MediaPlayback object.

		//if RTMP, set load to 100%
		if (ev.target.isRtmp(ev.target.contentPath))
		{
			_loadPercent = 100;
		}
		else
		{
			// Ask it for the bytes loaded
			var curPos:Number = ev.target.bytesLoaded;
			// Ask it for the bytes total
			var total:Number = ev.target.bytesTotal;
			_loadPercent = 100 * curPos / total;
		}
//		Tracer.trace("handleProgressEvent: ev.target=" + ev.target + ", curPos=" + curPos + ", total=" + total + ", percent=" + _loadPercent);
		// Position the loadbar accordingly
		refreshBars();
		// Keep track of the media type of the display component
		_lastProgressMediaType = ev.target.mediaType;

		evaluateToEnd();
	}

	/**
	 * Enable or disable the toEnd button, as appropriate.
	 */
	public function evaluateToEnd():Void
	{
		if ( !_isOpen )
		{
			// Don't even bother. The button can't be enabled or disabled
			// if it doesn't exist.
			return;
		}

		var endOn:Boolean = false;
		if ( (_loadPercent >= 99) && this.enabled )
		{
			if (_lastProgressMediaType == "MP3")
			{
				endOn = true;
			}
			else if ( (_lastProgressMediaType == "FLV") && !StreamingMediaConstants.DISABLE_FLV_TOEND )
			{
				endOn = true;
			}
		}
		this._buttons.toEndButton.enabled = endOn;
	}

	/**
	 * Handle a complete event
	 */
	private function handleCompleteEvent(ev:Object):Void
	{
		// If we are currently scrubbing the media or animating, then ignore this event
		if (!isScrubbing() && !_animating)
		{
			// Update the textfields and progress bars to show it is done
			var d:MediaDisplay = ev.target;
			// Ask it for the total play length
			_playTime = d.totalTime;
			_playPercent = 100;
			// Position the playbars accordingly
			if (_isOpen)
			{
				_playBar.setCompletionPercentage( _playPercent );
				_playBar.setTime( _playTime );
			}
			else
			{
				_miniPlayBar.setCompletionPercentage( _playPercent );
			}

			// We are not playing any more
			this.setPlaying(false);
			// Set a flag indicating that the play should start at the
			// beginning when/if the play button is clicked
			Tracer.trace("MediaController.handleCompleteEvent: playAtBeginning=true");
			playAtBeginning = true;
		}
	}

	/**
	 * Handle a scrubbing event
	 */
	private function handleScrubbingEvent(ev:Object):Void
	{
		_listenForPlayheadMoveEvent = !ev.detail;
	}
	
	/**
	 * Handle an unrecognized event
	 */
	private function handleUnrecognizedEvent(ev:Object):Void
	{
		Tracer.trace("received an unrecognized event of type " + ev.type + " with target " + ev.target);
	}


	/**
	 * Create default localized strings to use (a) while loading occurs or
	 * (b) if loading fails.
	 */
	private function createDefaultStrings():Void
	{
		this._strings = new Object();
		this._strings.paused = "PAUSED";
		this._strings.streaming = "STREAMING";
	}

	/**
	 * @param The id of the string to retrieve
	 * @return The value of the string
	 */
	public function getLocalizedString(id:String):String
	{
		var value:String = this._strings[id];
//		Tracer.trace("MediaController.getLocalizedString: " + id + "=" + value);
		return value;
	}

	public function get playTime():Number
	{
		return _playTime;
	}
	public function set playTime(aTime:Number):Void
	{
		_playTime = aTime;
	}
	public function get playPercent():Number
	{
		return _playPercent;
	}
	public function set playPercent(aPercent:Number):Void
	{
		_playPercent = aPercent;
	}

	public function isOpenUpOrLeft():Boolean
	{
		return _openUpOrLeft;
	}
	public function setOpenUpOrLeft(is:Boolean):Void
	{
		_openUpOrLeft = is;
	}

	/**
	 * Associated this controller with a display. Set up the event listeners
	 * between the two.
	 * @tiptext Associates a controller instance with a given display instance
	 * @helpid 3471
	 */
	public function associateDisplay(d:MediaDisplay):Void
	{
		d.associateController(this);
	}

	public function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		super.setSize(w, h, noEvent);
		// Force a redraw
		this.invalidate();
	}

	public function get enabled():Boolean
	{
		return _enabled;
	}

	/**
	 * Enable or disable this component
	 */
	public function set enabled(is:Boolean):Void
	{
		Tracer.trace("MediaController.set enabled to " + is);
		_enabled = is;
		// Enable or disable the contained buttons
		this._buttons.toStartButton.enabled = is;
		this._buttons.toEndButton.enabled = is;
		this._buttons.playPauseButtons.enabled = is;
		this._volumeControl._muteButton.muteSimpleButton.enabled = is;
		this._volumeControl._loudButton.loudSimpleButton.enabled = is;
		// Enable or disable the playhead and volume thumbs
		this._playBar.enabled = is;
		this._volumeControl.getHandle().enabled = is;

		if (is)
		{
			if (_priorPolicy != null)
			{
				controllerPolicy = _priorPolicy;
			}
		}
		else
		{
			_priorPolicy = controllerPolicy;
			if (controllerPolicy == "auto")
			{
				controllerPolicy = "off";
			}
		}
	}

	/**
	 * Is the user scrubbing the media?
	 */
	public function isScrubbing():Boolean
	{
//		Tracer.trace("MediaController.isScrubbing=" + _playBar.isScrubbing());
		return _playBar.isScrubbing();
	}

}
