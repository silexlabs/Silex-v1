//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.MediaPlayback;
import mx.controls.streamingmedia.FullScreenToggleControl;
import mx.controls.streamingmedia.Tracer;
import mx.core.ScrollView;

/**
 * FullScreenToggle toggles the display of the streaming media player between 
 * normal and fullscreen.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.FullScreenToggle
extends MovieClip
{
	/** Is the display in full screen mode? */
	private var _isFull:Boolean;

	/** The player with which this toggler is associated */
	private var _player:MediaPlayback;

	private var _maximize:FullScreenToggleControl;
	private var _minimize:FullScreenToggleControl;

	/** Original position of the player control */
	private var _originalPlayerX:Number;
	private var _originalPlayerY:Number;
	private var _originalPlayerWidth:Number;
	private var _originalPlayerHeight:Number;

	/** Was autosize originally on? */
	private var _originalAutosize:Boolean;

	/** Wait an extra frame before sizing bars */
	private var _waited:Boolean;

	/**
	 * Constructor
	 */
	public function FullScreenToggle()
	{
		this.init();
	}

	private function init()
	{
		// Navigate the _parent hierarchy looking for a player
		_player = MediaPlayback(this._parent._parent);

		// Display is in normal mode to start
		_isFull = false;
//		Tracer.trace("FullScreenToggle.init: " + _originalPlayerWidth + "x" + 
//			_originalPlayerHeight + " @ (" + _originalPlayerX + "," + 
//			_originalPlayerY + ")");

		this.setEnabled(_player.enabled);
	}

	/**
	 * @return True if the display is full screen; false if not.
	 */
	public function isFullScreen():Boolean
	{
		return _isFull;
	}

	/**
	 * Make the display full screen. If the component is contained in a 
	 * ScrollView it will be displayed in the ScrollView.
	 *
	 * @param noAction True: don't act on the player. False: do.
	 */
	public function displayFull(noAction:Boolean):Void
	{
		this.gotoAndStop("big");
		_isFull = true;

		if (!noAction)
		{
			// Remember prior settings
			_originalPlayerX = this._player._x;
			_originalPlayerY = this._player._y;
			_originalPlayerWidth = _player.width;
			_originalPlayerHeight = _player.height;
			_originalAutosize = _player.autoSize;

			// We need to contract the controller if it is open and in auto policy.
			// If we don't do this, then the controller will be incorrectly
			// open and may be positioned incorrectly, depending on the control 
			// position.
			var c:MediaController = _player.getController();
			if ( (c.controllerPolicy == "auto") && c.expanded)
			{
				Tracer.trace("FullScreenToggle.displayFull: about to call contract");
				c.contract();
			}
			c.setNotAnimating(false);
			
			// Expand the player to fill the stage.
			// Turn autosize off so the video will be as big as possible.
			// The aspectRatio property is respected and left as is.
			_player.autoSize = false;

			// Size the player to fill the screen
			var info:Object = getContainerInfo();
			_player.setSize(info.width, info.height);

			var scr = mx.managers.SystemManager.screen;
			if (info.origin)
			{
				// Take into account the fact that the stage origin may be offset
				Tracer.trace("FullScreenToggle.displayFull: scr=(" + scr.x + "," + scr.y + ")");
				_player._x = scr.x;
				_player._y = scr.y;
			}

			// Move the player to the origin of the stage
			var bounds:Object = _player.getBounds(info.container);
			Tracer.trace("FullScreenToggle.displayFull: bounds=(" + bounds.xMin + "," + bounds.yMin + ")");
			if (info.origin)
			{
				_player._x += scr.x;
				_player._y += scr.y;
			}
			else
			{
				_player._x += info.x;
				_player._y += info.y;
			}
			_player._x -= bounds.xMin;
			_player._y -= bounds.yMin;

			// Update the load and play bars, after the resizing has happened
			this._waited = false;
			this.onEnterFrame = this.delayedBarRefresh;

			// Make sure all the other toggles are in the same state
			var others:Array = getOtherToggles();
			for (var ix:Number = 0; ix < others.length; ix++)
			{
				others[ix].displayFull(true);
			}
		}

	}

	/**
	 * Determine if the player is contained in a ScrollView. If so, then
	 * compile the information necessary to expand it to fill the scroll view.
	 * If not, then provide the information to expand it to fill the
	 * entire Flash stage.
	 *
	 * @return An object with the following properties:
	 * container: The clip which will be filled
	 * width: The target width of the zoomed player
	 * height: The target height of the zoomed player
	 * x: The x-coordinate at which the playback should be placed
	 * y: The y-coordinate at which the playback should be placed
	 * origin: Boolean -- position at the stage origin
	 */
	private function getContainerInfo():Object
	{
		var info:Object;
		var container:MovieClip = getScrollViewAncestor(_player);
		if (container == null)
		{
			// Zoom to fill _root
			var scr = mx.managers.SystemManager.screen;
			info = { container: _root, 
				width: scr.width, height: scr.height, x: 0, y: 0, origin: true };
		}
		else
		{
			// Zoom to fill the ScrollView
			var metrics:Object = container.getViewMetrics();
			info = { container: container, 
				width: container.width - metrics.left - metrics.right, 
				height: container.height - metrics.top - metrics.bottom, 
				x: metrics.left,
				y: metrics.top,
				origin: false };
		}

		return info;
	}

	private function getScrollViewAncestor(anMC:MovieClip):ScrollView
	{
		var sv:ScrollView;
		if (anMC == _root)
		{
			// No go. We are done.
			sv = null;
		}
		else if (anMC instanceof ScrollView)
		{
			// We found one. We are done.
			sv = ScrollView(anMC);
		}
		else
		{
			// Recursively move up the containership hierarchy
			sv = getScrollViewAncestor(anMC._parent);
		}

		return sv;
	}


	private function delayedBarRefresh():Void
	{
		if (!_waited)
		{
			_waited = true;
		}
		else
		{
			delete this.onEnterFrame;
			_player.getController().refreshBars();
		}
	}

	/**
	 * Make the display normal.
	 *
	 * @param noAction True: don't act on the player. False: do.
	 */
	public function displayNormal(noAction:Boolean):Void
	{
		this.gotoAndStop("small");
		_isFull = false;

		if (!noAction)
		{
			// We need to contract the controller if it is open and in auto policy.
			// If we don't do this, then the controller will be incorrectly
			// open and may be positioned incorrectly, depending on the control 
			// position.
			var c:MediaController = _player.getController();
			if ( (c.controllerPolicy == "auto") && c.expanded)
			{
				Tracer.trace("FullScreenToggle.displayNormal: about to call contract");
				c.contract();
			}
			c.setNotAnimating(false);

			// Contract the player
			_player.autoSize = _originalAutosize;
			_player.setSize(_originalPlayerWidth, _originalPlayerHeight);
			_player._x = _originalPlayerX;
			_player._y = _originalPlayerY;
//			Tracer.trace("FullScreenToggle.displayNormal: size=" + 
//				_player.getDisplayWidth() + "x" + _player.getDisplayHeight() + " @ (" +
//				_player._x + "," + _player._y + ")");

			// Update the load and play bars, after the resizing has happened
			this._waited = false;
			this.onEnterFrame = this.delayedBarRefresh;

			// Make sure all the other toggles are in the same state
			var others:Array = getOtherToggles();
			for (var ix:Number = 0; ix < others.length; ix++)
			{
				others[ix].displayNormal(true);
			}
		}

	}


	/**
	 * Toggle the display between full screen and normal mode.
	 */
	public function toggleDisplay():Void
	{
		if (_isFull)
		{
			displayNormal();
		}
		else
		{
			displayFull();
		}
	}

	/**
	 * @return All the toggles (including itself)
	 */
	private function getAllToggles():Array
	{
		return _parent.getAllToggles();
	}

	/**
	 * @return All the toggles except itself
	 */
	private function getOtherToggles():Array
	{
		var others:Array = getAllToggles();
		for (var ix:Number = 0; ix < others.length; ix++)
		{
			if (others[ix] == this)
			{
				// Pitch ourself
				others.splice(ix, 1);
				break;
			}
		}
		
		return others;
	}

	public function getPlayer():MediaPlayback
	{
		return _player;
	}

	public function getEnabled():Boolean
	{
		return _player.enabled;
	}

	public function setEnabled(is:Boolean):Void
	{
		Tracer.trace("FullScreenToggle.setEnabled: " + is);
		_maximize.setEnabled(is);
		_minimize.setEnabled(is);
	}

}
