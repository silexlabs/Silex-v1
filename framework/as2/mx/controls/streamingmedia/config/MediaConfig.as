//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.containers.ScrollPane;
import mx.controls.streamingmedia.config.CuePointEditor;
import mx.styles.CSSStyleDeclaration;

/**
 * This is a singleton class whose static members dictate the configuration
 * of the streaming media configuration UI's.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.config.MediaConfig
{
	/** FPS value that indicates the user wants to specify milliseconds */
	public static var MS_FPS = "ms";

	private static var SEC_IN_MINUTE:Number = 60;
	private static var SEC_IN_HOUR:Number = 3600;

	public static var testing:Boolean = false;
	public static var mode:String = "display";
//	public static var mode:String = "player";

	/**
	 * The cuepoint editor clip. The editor will register itself when
	 * it initializes.
	 */
	public static var cuePointEditor:CuePointEditor;

	/** Frames per second value for the config UI (or "ms" for milliseconds) */
	private static var _fps;

	/**
	 * fps, without the "ms" option. Used to initialize _fps when frames
	 * display is selected.
	 */
	private static var _frameFps:Number;

	/**
	 * Listener object for stage resize events.
	 */
	private static var resizeListener:Object;

	public static function useMs():Void
	{
		setFps(MS_FPS);
	}

	public static function isMs():Boolean
	{
		return (_fps == MS_FPS);
	}

	public static function getFps():Number
	{
		return _fps;
	}

	public static function setFps(anFps:Number):Void
	{
		//Tracer.trace("MediaConfig.setFps: old=" + _fps + ", new=" + anFps);
		var priorMs:Boolean = isMs();
		_fps = anFps;
		// Set the xch value
		_root.xch.fps = _fps;
		if ( !isNaN(Number(_fps)) )
		{
			_frameFps = _fps;
		}
		if (priorMs != isMs())
		{
			// We either switched from ms to frame, or vice versa
			MediaConfig.cuePointEditor.updateCuePointDisplay();
		}
	}

	/**
	 * Activate the last numeric frame value.
	 */
	public static function getFrameFps():Number
	{
		return _frameFps;
	}

	/**
	 * Activate the last numeric frame value.
	 */
	public static function activateFrameFps():Void
	{
		setFps(_frameFps);
	}

	/**
	 * Create the indicated stylesheet and put it in the global list.
	 *
	 * @param type The type of stylesheet. Supported options are
	 * "normal", "title", "big", and "input".
	 * @return The name of the stylesheet to use for the config ui.
	 */
	public static function createStyleSheet(type:String):String
	{
		var ssName:String = "mediaConfig" + type;
		if (_global.styles[ssName] == null)
		{
			// The stylesheet doesn't exist yet.
			// Create the stylesheet to use for the component instances.
			var ss:CSSStyleDeclaration = new CSSStyleDeclaration();
			ss.styleName = ssName;
			// Place our stylesheet on the global styles list so it can be accessed by subclasses
			_global.styles[ssName] = ss;
			// Now set the properties of the stylesheet
			if ( (type == "normal") || (type == "input") || (type == "combobox") )
				ss.fontSize = 9;
			else if (type == "big")
				ss.fontSize = 10;
			else if (type == "title")
				ss.fontSize = 12;

			ss.fontFamily = "Verdana";
			if ( (type == "title") || (type == "big") )
			{
				ss.fontWeight = "bold";
			}
			if ( (type != "input") && (type != "combobox") )
			{
				ss.embedFonts = true;
			}
		}

		return ssName;
	}

	/**
	 * Convert a number of seconds into an array of h, m, s, ms values
	 */
	public static function decomposeSeconds(seconds:Number):Array
	{
		//Tracer.trace("starting to decompose " + seconds + " seconds");
		var result:Array = new Array(4);
		// Hours
		result[0] = Math.floor(seconds / SEC_IN_HOUR);
		var leftover:Number = ( (result[0] == 0) ? seconds : seconds - (result[0] * SEC_IN_HOUR) );
//		Tracer.trace("hours=" + result[0] + " leftover=" + leftover);
		// Minutes
		result[1] = Math.floor(leftover / SEC_IN_MINUTE);
		leftover = ( (result[1] == 0) ? leftover : leftover - (result[1] * SEC_IN_MINUTE) );
//		Tracer.trace("minutes=" + result[1] + " leftover=" + leftover);
		// Seconds
		result[2] = Math.floor(leftover);
		// Milliseconds
		result[3] = Math.round( (leftover - Math.floor(leftover)) * 1000);
		//Tracer.trace("decomposed " + seconds + " into " + result);

		return result;
	}

	/**
	 * Convert hours, minutes, seconds, and ms into seconds.
	 */
	public static function composeSeconds(h:Number, m:Number, s:Number, ms:Number):Number
	{
		var seconds:Number = h * SEC_IN_HOUR + m * SEC_IN_MINUTE + s + ms / 1000;
//		Tracer.trace("composing " + h + "+" + m + "+" + "s" + "ms into " + seconds);
		return seconds;
	}

	public static function decomposeSecondsToFrames(seconds:Number, fps:Number):Array
	{
		//Tracer.trace("MediaConfig.decomposeSecondsToFrames( " + seconds + "," + fps + ")");
		var hmsf:Array = decomposeSeconds(seconds);
		// Now convert the milliseconds portion to a frame number
		var fr:Number = Math.round(fps / 1000 * hmsf[3]);
		hmsf[3] = fr;
		//Tracer.trace("MediaConfig.decomposeSecondsToFrames: done");
		return hmsf;
	}

	public static function composeSecondsFromFrames(h:Number, m:Number, s:Number, f:Number, fps:Number):Number
	{
		// Convert the # of frames to a # of ms
		var seconds:Number = composeSeconds(h, m, s, (f / fps) * 1000);
		// Limit the value to 3 decimal places
		seconds = Math.round(seconds * 1000) / 1000;
		//Tracer.trace("MediaConfig.composeSecondsFromFrames: " + h + ":" + m +
		//	":" + s + ":" + f + " @" + fps + " fps=" + seconds);
		return seconds;
	}

	/**
	 * This code is run on frame 1 of the main timeline to set up the
	 * SWF.
	 */
	public static function setup():Void
	{
		Stage.scaleMode = "noscale";
		Stage.showMenu = false;
		Stage.align = "LT";
		//Tracer.trace("Stage: " + Stage.width + "x" + Stage.height);

		resizeListener = new Object();
		resizeListener.onResize = function()
		{
			//Tracer.trace("onResize: " + Stage.width + "x" + Stage.height);
			var s:ScrollPane = _root.mainScroller;
			s.setSize(Stage.width, Stage.height);

		};
		Stage.addListener(resizeListener);

		// Set the initial size
		resizeListener.onResize();

		// Set the default stylesheets for components
		var ssName:String = createStyleSheet("normal");
		_global.styles.Button = _global.styles[ssName];
		_global.styles.CheckBox = _global.styles[ssName];
		_global.styles.RadioButton = _global.styles[ssName];
		_global.styles.Label = _global.styles[ssName];
		_global.styles.ComboBox = _global.styles[ssName];
	}

	/**
	 * This code is run from the frame after the "preload" frame of the
	 * main timeline. It makes sure that _root.xch is loaded, then
	 * progresses to the proper frame once it has.
	 */
	public static function processPreload():Void
	{
		if (testing)
		{
			trace("TESTING: bypassing straight to main!");
			_root.gotoAndStop(mode);
		}
		else
		{
			// Make sure that the xch object has been loaded
			if (typeof _root.xch == "undefined")
			{
				_root.gotoAndPlay("preload");
			}
			else
			{
				// Now that xch has loaded keep track of it.
				//Tracer.trace("xch:");
				var member:String;
				for (member in _root.xch)
				{
					//Tracer.trace("  " + member + "=" + _root.xch[member]);
				}
				// Record the initial value of fps
				setFps(_root.xch.fps);
				_frameFps = ( isNaN(Number(_root.xch.fps)) ? 30 : Number(_root.xch.fps) );

				_root.gotoAndStop(mode);
			}
		}
	}

}