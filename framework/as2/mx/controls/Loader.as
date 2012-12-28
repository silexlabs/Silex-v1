//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.core.UIComponent;
import mx.core.UIObject;
import mx.core.View;

/**
* @tiptext complete event
* @helpid 3128
*/
[Event("complete")]
/**
* @tiptext progress event
* @helpid 31 29
*/
[Event("progress")]

[TagName("Loader")]
[IconFile("Loader.png")]

/**
* Loader class
* - extends View
* @tiptext Loader provides a container to load a MovieClip, JPEG or SWF
* @helpid 3130
*/

class mx.controls.Loader extends View
{
	static var symbolName:String = "Loader";
	static var symbolOwner:Object = mx.controls.Loader; // why not type Function???//#include "../core/ComponentVersion.as"
	var className:String = "Loader";

	var clipParameters:Object = { autoLoad: 1, scaleContent: 1, contentPath: 1 };
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(Loader.prototype.clipParameters, View.prototype.clipParameters);

	var __autoLoad:Boolean = true;
		// stores public "autoLoad" property

	var __bytesLoaded:Number = undefined;
		// stores public "bytesLoaded" property

	var __bytesTotal:Number = undefined;
		// stores public "bytesTotal" property

	var __contentPath:String = undefined;
		// stores public "contentPath" property

	var __scaleContent:Boolean = true;
		// stores public "scaleContent" property

	var contentHolder:UIComponent;

	var livePreview:TextField;
	
	var	_origWidth:Number;
	var	_origHeight:Number;

	// //////////////////////////////////////////////////
	//
	// Constructor
	//
	// //////////////////////////////////////////////////

	function Loader() // should constructor be able to have return type?
	{
	}

	// //////////////////////////////////////////////////
	//
	// Overridden methods
	//
	// //////////////////////////////////////////////////

	function init():Void
	{
		super.init();

		// UIComponent or UIObject will handle visible, enabled, taborder
	}

	function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		_origWidth = w;
		_origHeight = h;
		super.setSize(w, h, noEvent);
		if (_global.isLivePreview)
		{
			livePreview._width = __width - 1;
			livePreview._height = __height - 1;
		}
	}

	function draw():Void
	{
		size();
	}

	function size():Void
	{
		super.size();

		// We will either scale the content to the size of the Loader,
		// or we will scale the loader to the size of the content.
		if (__scaleContent)
			doScaleContent();
		else
			doScaleLoader();
	}

	function createChildren():Void
	{
		super.createChildren();
		
		if (_global.isLivePreview)
		{
			createTextField("livePreview", -1000, 0, 0, 99, 99);
			livePreview.text = "mx.controls.Loader";
			livePreview.border = true;
		}

		// Explicitly call load() AFTER contentHolder is created
		if (__autoLoad)
			load();
	}

	// //////////////////////////////////////////////////
	//
	// Public properties
	//
	// //////////////////////////////////////////////////

	// autoLoad

	function getAutoLoad():Boolean
	{
		return __autoLoad;
	}

	[Inspectable(defaultValue=true)]
/**
* @tiptext If true, automatically loads the content
* @helpid 3131
*/
	function get autoLoad():Boolean
	{
		return getAutoLoad();
	}

	function setAutoLoad(b:Boolean):Void
	{
		if (__autoLoad != b)
		{
			__autoLoad = b;

			// If you set autoLoad = true and content is not loaded, it should get loaded
			if (__autoLoad && !this[childNameBase + 0]._complete)
				load();
		}
	}

	function set autoLoad(b:Boolean):Void
	{
		setAutoLoad(b);
	}

	// bytesLoaded (readonly)

	function getBytesLoaded():Number
	{
		return __bytesLoaded;
	}

/**
* @tiptext Returns the number of bytes loaded of the Loader content
* @helpid 3132
*/
	function get bytesLoaded():Number
	{
		return getBytesLoaded();
	}

	// bytesTotal (readonly)

	function getBytesTotal():Number
	{
		return __bytesTotal;
	}

/**
* @tiptext Returns the size of the Loader content in bytes
* @helpid 3133
*/
	function get bytesTotal():Number
	{
		return getBytesTotal();
	}

	// content

	function getContent():UIComponent
	{
		return contentHolder;
	}

/**
* @tiptext Returns the content of the Loader
* @helpid 3134
*/
	function get content():UIComponent
	{
		return getContent();
	}

	// contentPath

	function getContentPath():String
	{
		return __contentPath;
	}

	[Inspectable(defaultValue="")]
	[Bindable]
/**
* @tiptext Gets or sets the absolute or relative URL of the content to be loaded
* @helpid 3135
*/
	function get contentPath():String
	{
		return getContentPath();
	}

	function setContentPath(url:String):Void
	{
		if (__contentPath != url)
		{
			__contentPath = url;

			if (childrenCreated) // prevent a load() before createChildren is called
				if (__autoLoad)
					load();
		}
	}

	function set contentPath(c:String):Void
	{
		setContentPath(c);
	}

	// percentLoaded (read-only)

	function getPercentLoaded():Number
	{
		var p:Number = 100 * (__bytesLoaded / __bytesTotal);
		if (isNaN(p))
			p = 0;
		return p;
	}

/**
* @tiptext Gets the percentage of the content loaded
* @helpid 3136
*/
	[Bindable("readonly")]
	[ChangeEvent("progress")]
	function get percentLoaded():Number
	{
		return getPercentLoaded();
	}

	// scaleContent

/**
* @tiptext If true, scales the content to fit the Loader's size
* @helpid 3137
*/
	[Inspectable(defaultValue=true)]
	function get scaleContent():Boolean
	{
		return getScaleContent();
	}

	function getScaleContent():Boolean
	{
		return __scaleContent;
	}

	function setScaleContent(b:Boolean):Void
	{
		if (__scaleContent != b)
		{
			__scaleContent = b;
			// We will either scale the content to the size of the Loader,
			// or we will scale the loader to the size of the content.
			if (__scaleContent)
				doScaleContent();
			else
				doScaleLoader();
		}
	}

	function set scaleContent(b:Boolean):Void
	{
		setScaleContent(b);
	}

	// //////////////////////////////////////////////////
	//
	// Public methods
	//
	// //////////////////////////////////////////////////

/**
* @tiptext Tells the Loader to start loading its content
* @helpid 3138
*/
	function load(url:String):Void
	{
		if (url != undefined)
			__contentPath = url;

		if (this[childNameBase + 0] != undefined)
		{
			if (this[childNameBase + 0]._complete)
			{
				// If we've had a child completely loaded and have scaled
				// the Loader to the size of the content, then the Loader
				// component will have some arbitrary size, which we want
				// to reset back to the original size. If the content has
				// been scaled to the Loader (even if the Loader has been
				// scaled to the content first), the size ought to be OK,
				// but we reset it anyway.
				setSize(_origWidth, _origHeight);
			}

			destroyChildAt(0);
		}

		if (__contentPath == undefined || __contentPath=="")
			return;

		createChild(__contentPath, "contentHolder");
	}

	function childLoaded(obj:MovieClip):Void // param type???
	{
		super.childLoaded(obj);

		// In Live Preview, the rotation gets mysteriously set to 90 in
		// our super-method. Slam it back to zero here.
		obj._rotation = 0;

		// Record these original sizes in case we toggle from scaled Loader back to scaled Content.
		_origWidth = __width;
		_origHeight = __height;

		// We will either scale the content to the size of the Loader,
		// or we will scale the loader to the size of the content.
		if (__scaleContent)
			doScaleContent();
		else
			doScaleLoader();
	}

	function dispatchEvent(obj:Object):Void // type???
	{
		if (obj.type == "progress" || obj.type == "complete")
		{
			// fake target so it looks like the container and not the child
			obj.target = this;

			// keep track of progress in case we're asked
			__bytesTotal = obj.total;
			__bytesLoaded = obj.current;
		}

		super.dispatchEvent(obj);
	}

	// //////////////////////////////////////////////////
	//
	// Private methods
	//
	// //////////////////////////////////////////////////

	function doScaleContent():Void
	{
		if (!this[childNameBase + 0]._complete)
			return;

		// Make sure any previous scaling is undone.
		unScaleContent();

		// Scale the content to the size of the loader, preserving aspect ratio.
		var bM = border_mc.borderMetrics;

		var interiorWidth = _origWidth - bM.left - bM.right;
		var	interiorHeight = _origHeight - bM.top - bM.bottom;
		var x = bM.left;
		var y = bM.top;
		var xscale = interiorWidth / contentHolder._width;
		var yscale = interiorHeight / contentHolder._height;
		var scale;
		if (xscale > yscale)
		{
			x = bM.left + Math.floor((interiorWidth - contentHolder._width*yscale) / 2);
			scale = yscale;
		}
		else
		{
			y = bM.top + Math.floor((interiorHeight - contentHolder._height*xscale) / 2);
			scale = xscale;
		}

		// Normalize the scale from a basis of one to a basis of 100,
		// since that's how Flash scale works.
		scale *= 100;

		// Scale by the same amount in both directions.
		contentHolder._xscale = contentHolder._yscale = scale;
		contentHolder._x = x;
		contentHolder._y = y;

		if (__width != _origWidth || __height != _origHeight)
			setSize(_origWidth, _origHeight);
	}

	function doScaleLoader():Void
	{
		if (!this[childNameBase + 0]._complete)
			return;

		unScaleContent();

		// Scale the laoder to the size of the content.
		var bM = border_mc.borderMetrics;

		var newWidth = contentHolder._width + bM.left + bM.right;
		var newHeight = contentHolder._height + bM.top + bM.bottom;

		if (__width != newWidth || __height != newHeight)
			setSize( newWidth, newHeight);

		contentHolder._x = bM.left;
		contentHolder._y = bM.top;
	}

	function unScaleContent():Void
	{
		// don't do this stuff unless we're done loading.
		// make sure callers enforce this by checking before calling.
		contentHolder._xscale = contentHolder._yscale = 100;
		contentHolder._x = contentHolder._y = 0;
	}
	
	private static var RectBorderDependency = mx.skins.halo.RectBorder;
}
