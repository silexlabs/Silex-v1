//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


import mx.styles.StyleManager;
import mx.styles.CSSStyleDeclaration;
import mx.skins.SkinElement;

/**
* @tiptext resize event
* @helpid 3972
*/
[Event("resize")]
/**
* @tiptext move event
* @helpid 3969
*/
[Event("move")]
/**
* @tiptext draw event
* @helpid 3963
*/
[Event("draw")]
/**
* @tiptext load event
* @helpid 3968
*/
[Event("load")]
/**
* @tiptext unload event
* @helpid 3980
*/
[Event("unload")]

/**
* The base class for all components and graphical objects.
* UIObjects support events and styles and resize by scaling.
*
* @helpid 3285
* @tiptext Base class for all components and graphical objects. Extends MovieClip
*/
class mx.core.UIObject extends MovieClip
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "UIObject";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = UIObject;

	// Version string
#include "../core/ComponentVersion.as"

/**
* @private
* standard color list for text objects
*/
	static var textColorList = { color: 1, disabledColor: 1 };

	// whether the component needs to be drawn
	private var invalidateFlag:Boolean = false;
	// line width and color for drawing API
	private var lineWidth:Number = 1;
	private var lineColor:Number = 0;	// black

	// UIObjects are not supposed to receive focus
	var	tabEnabled:Boolean = false;

	// sometimes we inherit from something, but don't want to
	// inherit its class styles.
	var ignoreClassStyleDeclaration:Object;

	// sometimes properties get set before the children components
	// have been created.  This flag can be used to guard against
	// early property setting.
	var childrenCreated:Boolean;

/**
* @private
* @see mx.events.EventDispatcher
*/
	var createEvent:Function;
/**
* @private
* @see mx.events.EventDispatcher
*/
	var dispatchEvent:Function;

/**
* @see mx.events.EventDispatcher
* @tiptext Adds a listener for an event
* @helpid 3958
*/
	var addEventListener:Function;
/**
* @see mx.events.EventDispatcher
* @tiptext Handles all events
* @helpid 3032
*/
	var handleEvent:Function;
/**
* @see mx.events.EventDispatcher
*/
	var removeEventListener:Function;

	// see mx.managers.DepthManager
	var buildDepthTable:Function;
	var findNextAvailableDepth:Function;
	var createChildAtDepth:Function;
	var createClassChildAtDepth:Function

/**
* @see mx.accessibility.accImpl
*/
	var createAccessibilityImplementation:Function;

	// internal ID name for this instance
	private var _id:String;

/**
* @private
* Initialization property that forces immediate drawing after creation
*/
	var validateNow:Boolean;

	// foreground text color
	var color:Number;

	// mixed from styles
	var fontSize:Number;
	var fontWeight:String;
	var fontFamily:String;
	var fontStyle:String;
	var textAlign:String;
	var textDecoration:String;
	var textIndent:Number;
	var marginLeft:Number;
	var marginRight:Number;
	var embedFonts:Boolean;
	var changeTextStyleInChildren:Function;
	var changeColorStyleInChildren:Function;
	var notifyStyleChangeInChildren:Function;

	// mixed from DepthManager;
	var _topmost:Boolean;


/**
* @private
* The color style used by this component. If more than one
* color style, use an object containing the colors as properties
* on the object
*/
	var _color;

/**
* @private
* CSSStyleDeclaration or pointer to parent to be used by component in
* calculating style values.
*/
	var styleName:String;

/**
*
* Name of component class.  This is also used in calculating style values.
* If _global.styles[className] exists, it set defaults for a component.
*/
	var className:String;

	// cache of cascading styles
	var stylecache:Object;
	// list of functions used by doLater()
	var methodTable:Array;
	// array of skin instance names used by setSkin
	var idNames:Array;

/**
* set a style property.  Causes lots of processing so use sparingly.
* actual implementation is in mx.styles.CSSSetStyle.as
*
* @param	String	prop	name of style property
* @param	Variant	value	new value for style
*
* @tiptext Sets a style value for the specified style property
* @helpid 3978
*/
	var setStyle : Function;



/**
* @private
* list of clip parameters to check at init
* only getter/setter properties go in this list
*/
	var clipParameters:Object = {visible: 1, minHeight: 1, minWidth: 1, maxHeight: 1, maxWidth: 1, preferredHeight: 1, preferredWidth: 1};

/**
* @private
* method used to init objects w/ getter-setters
*/
	var initProperties:Function;

	// these hold the actual values for the getter-setters
	var __width:Number;
	var __height:Number;
	private var _minHeight:Number;
	private var _minWidth:Number;
	private var _maxHeight:Number;
	private var _maxWidth:Number;
	private var _preferredHeight:Number;
	private var _preferredWidth:Number;

	// local copy of textformat
	private var _tf:TextFormat;
	// list of textfield children
	private var tfList:Object;

	// place to store the hooked copy of onUnload
	private var __onUnload:Function;

	// place to hook in other init-time functions
	private var _endInit:Function;

	function UIObject()
	{
		constructObject();
	}

/**
* width of object
* Read-Only:  use setSize() to change.
* @helpid 3982
*/
	function get width():Number
	{
		return _width;
	}

/**
* height of object
* Read-Only:  use setSize() to change.
* @helpid 3964
*/
	function get height():Number
	{
		return _height;
	}

/**
* left of object
* Read-Only:  use move() to change.
* @helpid 3967
*/
	function get left():Number
	{
		return _x;
	}
/**
* x = left of object
* Read-Only:  use move() to change.
* @helpid 3983
*/
	function get x():Number
	{
		return _x;
	}

/**
* top of object
* Read-Only:  use move() to change.
* @helpid 3979
*/
	function get top():Number
	{
		return _y;
	}
/**
* y = top of object
* Read-Only:  use move() to change.
* @helpid 3984
*/
	function get y():Number
	{
		return _y;
	}

/**
* right of object relative to its parent's right edge.
* Read-Only:  use setSize() to change.
* @helpid 3973
*/
	function get right():Number
	{
		return _parent.width - (_x + width);
	}

/**
* bottom of object relative to its parent's bottom
* Read-Only:  use setSize() to change.
* @helpid 3959
*/
	function get bottom():Number
	{
		return _parent.height - (_y + height);
	}

/**
* @private
* override this instead of adding your own getter-setter for minHeight
*/
	function getMinHeight(Void):Number
	{
		return _minHeight;
	}

/**
* @private
* override this instead of adding your own getter-setter for minHeight
*/
	function setMinHeight(h:Number):Void
	{
		_minHeight = h;
	}

/**
* minimum height of object
*/
	[Inspectable(defaultValue=0, verbose=1, category="Size")]
	function get minHeight():Number
	{
		return getMinHeight();
	}

	function set minHeight(h:Number):Void
	{
		setMinHeight(h);
	}

/**
* @private
* override this instead of adding your own getter-setter for minWidth
*/
	function getMinWidth(Void):Number
	{
		return _minWidth;
	}

/**
* @private
* override this instead of adding your own getter-setter for minWidth
*/
	function setMinWidth(w:Number):Void
	{
		_minWidth = w;
	}

/**
* minimum width of object
*/
	[Inspectable(defaultValue=0, verbose=1, category="Size")]
	function get minWidth():Number
	{
		return getMinWidth();
	}

	function set minWidth(w:Number):Void
	{
		setMinWidth(w);
	}

/**
* @private
* override this instead of adding your own getter-setter for visible
*/
	function setVisible(x:Boolean, noEvent:Boolean):Void
	{
		if (x != this._visible)
		{
			_visible = x;
			if (noEvent != true)
			{
				dispatchEvent({type: x ? "reveal" : "hide"});
			}
		}
	}

/**
* True if object is visible
* @helpid 3981
*/
	[Inspectable(defaultValue=true, verbose=1, category="Other")]
	function get visible():Boolean
	{
		return _visible;
	}
	function set visible(x:Boolean):Void
	{
		setVisible(x, false);
	}

/**
* 100 is standard scale
* @tiptext Specifies the horizontal scale factor
* @helpid 3974
*/
	function get scaleX():Number
	{
		return _xscale;
	}
	function set scaleX(x:Number):Void
	{
		_xscale = x;
		//__width = _width;
	}

/**
* 100 is standard scale
* @tiptext Specifies the vertical scale factor
* @helpid 3975
*/
	function get scaleY():Number
	{
		return _yscale;
	}
	function set scaleY(y:Number):Void
	{
		_yscale = y;
		//__height = _height;
	}

/**
*  Queues a function to be called later
*
* @param	obj	Object that contains the function
* @param	fn	Name of function on Object
*/
	function doLater(obj:Object, fn:String):Void
	{
		if (methodTable == undefined)
		{
			methodTable = new Array();
		}
		methodTable.push({obj:obj, fn:fn});
		onEnterFrame = doLaterDispatcher;
	}

	// callback that then calls queued functions
	function doLaterDispatcher(Void):Void
	{
		delete onEnterFrame;

		// invalidation comes first
		if (invalidateFlag)
		{
			redraw();
		}

		// make a copy of the methodtable so methods called can requeue themselves w/o putting
		// us in an infinite loop
		var __methodTable:Array = methodTable;
		// new doLater calls will be pushed here
		methodTable = new Array();

		// now do everything else
		if (__methodTable.length > 0)
		{
			var m:Object;
			while((m = __methodTable.shift()) != undefined)
			{
				m.obj[m.fn]();
			}
		}
	}

/**
* cancel all queued functions
*/
	function cancelAllDoLaters(Void):Void
	{
		delete this.onEnterFrame;
		this.methodTable = new Array();
	}

/**
* mark component so it will get drawn later
* @tiptext Marks an object to be redrawn on the next frame interval
* @helpid 3966
*/
	function invalidate(Void):Void
	{
		invalidateFlag = true;
		onEnterFrame = doLaterDispatcher;
	}

/**
* called if just styles are changing so subclasses don't have to redraw everything
*/
	function invalidateStyle(Void):Void
	{
		invalidate();
	}

/**
* redraws object if you couldn't wait for invalidation to do it
*
* @param bAlways	if False, doesn't redraw if not invalidated
* @tiptext Redraws an object immediately
* @helpid 3971
*/
	function redraw(bAlways:Boolean):Void
	{
		if (invalidateFlag || bAlways)
		{
			invalidateFlag = false;
			// all textfields are hung off this method so we can call them as well since they don't
			// have their own enterFrame event
			var i:String;
			for (i in tfList)
			{
				tfList[i].draw();
			}
			draw();
			dispatchEvent({ type:"draw"});
		}
	}

/**
* @private
* draw the object.  Called by redraw() which is called explicitly or
* by the system if the object is invalidated.
* Each component should implement this method and make subobjects visible and lay them out.
* Most components do the layout by calling their size() method.
*/
	function draw(Void):Void
	{
	}

/**
* move the object
*
* @param	x	left position of the object
* @param	y	top position of the object
* @param	noEvent	if true, doesn't broadcast "move" event
*
* @tiptext Moves the object to the specified location
* @helpid 3970
*/
	function move(x:Number, y:Number, noEvent:Boolean):Void
	{
		//trace("UIObject.move " + this + " -> (" + x + ", " + y + ")");
		var oldX:Number = _x;
	  	var oldY:Number = _y;

		_x = x;
		_y = y;

		if (noEvent != true)
		{
			dispatchEvent({type:"move", oldX:oldX, oldY:oldY});
		}
	}

/**
* size the object
*
* @param	w	width of the object
* @param	h	height of the object
* @param	noEvent	if true, doesn't broadcast "resize" event
*
* @tiptext Resizes the object to the specified size
* @helpid 3976
*/
	function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		// trace("UIObject.setSize " + this + " -> (" + w + ", " + h + ")");
		var oldWidth:Number = __width;
	  	var oldHeight:Number = __height;

		__width = w;
		__height = h;

		size();

		if (noEvent != true)
		{
			dispatchEvent({type:"resize", oldWidth:oldWidth, oldHeight:oldHeight});
		}
	}

/**
* @private
* size the object.  called by setSize().  Components should implement this method
* to layout their contents.  The width and height properties are set to the
* new desired size by the time size() is called.
*/
	// default is to scale object.  override to do something more intelligent
	function size(Void):Void
	{
		_width = __width;
		_height = __height;
	}

/**
* draw unfilled rectangle on the screen
*
* @param	x1	(x1, y1) is one corner of rectangle
* @param	y1	(x1, y1) is one corner of rectangle
* @param	x2	(x2, y2) is other corner of rectangle
* @param	y2	(x2, y2) is other corner of rectangle
* @param	r	(r) is corner radius of rectangle or object containing radii for each corner
*/
	function drawRect(x1:Number, y1:Number, x2:Number, y2:Number):Void
	{
		moveTo(x1,y1);
		lineTo(x2,y1);
		lineTo(x2,y2);
		lineTo(x1,y2);
		lineTo(x1,y1);
	}

/**
* @private
* create a text label subobject.  Used by most components to get a lightweight
* text object to display text in the component.
*
* @param	name	instance name of text object
* @param	depth	z order of object
* @param	text	text of object
* @return	reference to text object
*/
	function createLabel(name:String, depth:Number, text):TextField
	{
		//createTextField(name, depth, x, y, w, h);
		createTextField(name, depth, 0, 0, 0, 0);
		var o:TextField = this[name];
		o._color = UIObject.textColorList;
		o._visible = false;

		// defer the style lookup to the textfield's draw routine
		o.__text = text;
		// @@ this needs improvement, since margin will vary with the font and size
	//	var margin = 4;
	//	o.setSize(o.textWidth + margin, o.textHeight + margin);
		if (tfList == undefined)
			tfList = new Object();
		tfList[name] = o;
		o.invalidateStyle();
		invalidate();		// force redraw call
		o.styleName = this;	// labels always inherit styles of parent unless set otherwise
		return o;
	}

/**
* create a subobject from its symbol name
*
* @param	symbol	symbol name of object
* @param	id		instance name of object
* @param	depth	z order of object
* @param	initObj	object containing initialization properties
* @return	reference to object
*
* @tiptext Creates a sub-object using its symbol name
* @helpid 3960
*/
	function createObject(linkageName:String, id:String, depth:Number, initobj:Object):MovieClip
	{
		// trace("UIObject createObject: " + linkageName);
		return attachMovie(linkageName, id, depth, initobj);
	}

/**
* create a subobject from its class definition
*
* @param	class	reference to class of object
* @param	id		instance name of object
* @param	depth	z order of object
* @param	initObj	object containing initialization properties
* @return	reference to object
*
* @tiptext Creates a sub-object using its class name
* @helpid 3961
*/
	function createClassObject(className:Function, id:String, depth:Number, initobj:Object):UIObject
	{
		var bSubClass:Boolean = (className.symbolName == undefined);

		if (bSubClass)
		{
			Object.registerClass(className.symbolOwner.symbolName, className);
		}
		var o:UIObject = UIObject(createObject(className.symbolOwner.symbolName, id, depth, initobj));

		if (bSubClass)
		{
			Object.registerClass(className.symbolOwner.symbolName, className.symbolOwner);
		}

		return o;
	}

/**
* create a blank or empty subobject
*
* @param	id		instance name of object
* @param	depth	z order of object
* @return	reference to object
*/
	function createEmptyObject(id:String, depth:Number):UIObject
	{
		return createClassObject(UIObject, id, depth);
	}

/**
* destroy the subobject
*
* @param	id		instance name of object
*
* @tiptext Destroys the specified object
* @helpid 3962
*/
	function destroyObject(id:String):Void
	{
		var o:MovieClip = this[id];
		if (o.getDepth() < 0)
		{
			var dt:Array = buildDepthTable();
			var i:Number = findNextAvailableDepth(0, dt, "up");
			var temp = i;	// COMPILER WORKAROUND
			o.swapDepths(temp);
		}
		o.removeMovieClip();
		delete this[id];
	}

/**
* @private
* lookup the instance name from the skin ID number.  Uses the idNames
* array to map to an instance name
*
* @param	tag		id number in idNames
*/
	function getSkinIDName(tag:Number):String
	{
		return idNames[tag];
	}

/**
* @private
* create a skin element.  Recommended way of adding graphical
* objects to a component.
*
* @param	tag		id number of skin
* @param	name	symbol name of object
* @param	initObj	object containing initialization properties
* @return	reference to object
* @helpid 3977
*/
	function setSkin(tag:Number, linkageName:String, initObj:Object):MovieClip
	{
		if (_global.skinRegistry[linkageName] == undefined)
		{
			SkinElement.registerElement(linkageName, SkinElement);
		}
		return createObject(linkageName, getSkinIDName(tag), tag, initObj);
	}

/**
* @private
* create a blank or empty skin element.  Rarely used.  Recommended way is to
* load a skin containing graphics or drawing code
*
* @param	tag		id number of skin
* @return	reference to object
*/
	function createSkin(tag:Number):UIObject
	{
		var id:String = getSkinIDName(tag);
		createEmptyObject(id, tag);
		return this[id];
	}

/**
* @private
* create children objects. Components implement this method to create the
* subobjects in the component.  Recommended way is to make text objects
* invisible and make them visible when the draw() method is called to
* avoid flicker on the screen.
*
*/
	function createChildren(Void):Void
	{
	}

	// call create children	 and set flag.
	function _createChildren(Void):Void
	{
		createChildren();
		childrenCreated = true;
	}

	// sets up the order of construction of a component
	function constructObject(Void):Void
	{
		// this gets called when being defined as the prototype
		// don't do anything, just return.
		if (_name == undefined)
		{
			return;
		}

		// initialize variables and the like;
		init();
		// create child objects
		_createChildren();
		// create accessibility if needed
		createAccessibilityImplementation();
		// hook extension
		_endInit();

		// draw it now
		if (validateNow)
		{
			redraw(true);
		}
		else // or draw it later
		{
			invalidate();
		}
	}

	// process all the clipParameters in the list so the setters get fired.
	function initFromClipParameters(Void):Void
	{
		var bFound:Boolean = false;

		var i:String;
		for (i in clipParameters)
		{
			if (this.hasOwnProperty(i))
			{
				bFound = true;
				this["def_" + i] = this[i];
				delete this[i];
			}
		}
		if (bFound)
		{
			for (i in clipParameters)
			{
				var v = this["def_" + i];
				if (v != undefined)
					this[i] = v;
			}
		}
	}

/**
* @private
* init variables.  Components should implement this method and call super.init() to
* ensure this method gets called.  The width, height and clip parameters will not
* be properly set until after this is called.
*
*/
	function init(Void):Void
	{
		__width = _width;
		__height = _height;

		if (initProperties == undefined)
		{
			initFromClipParameters();
		}
		else
		{
			initProperties();	// defined in onClipEvent(initialize) for each instance.
		}

		if (_global.cascadingStyles == true)
		{
			stylecache = new Object();
		}
	}

	// find the class style sheet for this instance.  Equivalent
	// to type selectors in CSS, except that it also uses
	// inheritance as valid types
	function getClassStyleDeclaration(Void):CSSStyleDeclaration
	{
		var o:Object = this;
		var c:String = className;
		while (c != undefined)
		{
			if (ignoreClassStyleDeclaration[c] == undefined)
			{
				if (_global.styles[c] != undefined)
				{
					return _global.styles[c];
				}
			}
			o = o.__proto__;
			c = o.className;
		}
	}

/**
* @private
* set color on object.  This method gets called if the value of a
* color style gets changed and that color style is listed
* as the _color property of the component.
*
*/
	function setColor(color:Number):Void
	{
		// standard UIObject doesn't do any coloring
	}


	// called recursively to fill out a textFormat object by calling each of its parents
	function __getTextFormat(tf:TextFormat, bAll:Boolean):Boolean
	{
		// see if we have a cached text format.  Note that this should never be true on the first
		// call since this does not get called if the object has a cached text format.  This is only to
		// see if a parent has a text format.
		var o:TextFormat = stylecache.tf;
		if (o != undefined)
		{
			// for each field in the mapping
			var j:String;
			for (j in StyleManager.TextFormatStyleProps)
			{
				if (bAll || StyleManager.TextFormatStyleProps[j])
					if (tf[j] == undefined)
						tf[j] = o[j];
			}
			return false;
		}

		var bUndefined:Boolean = false;

		// for each field in the mapping
		var j:String;
		for (j in StyleManager.TextFormatStyleProps)
		{
			if (bAll || StyleManager.TextFormatStyleProps[j])
			{
				if (tf[j] == undefined)
				{
					// get the value from the textFormat
					var v = _tf[j];
					// store it in the tf if not defined
					if (v != undefined)
					{
						tf[j] = v;
					}
					else
					{
						// nsaxena: for cascading styles, if _parent is a movie clip
						// since mx.styles.CSSTextStyles.addTextStyles(mc) is not called
						// no better way to check than reverse mapping
						if(j == "font" && this["fontFamily"] != undefined)
						{
							tf[j] = this["fontFamily"];
						}
						else if(j == "size" && this["fontSize"] != undefined)
						{
							tf[j] = this["fontSize"];
						}
						else if(j == "color" && this["color"] != undefined)
						{
							tf[j] = this["color"];
						}
						else if(j == "leftMargin" && this["marginLeft"] != undefined)
						{
							tf[j] = this["marginLeft"];
						}
						else if(j == "rightMargin" && this["marginRight"] != undefined)
						{
							tf[j] = this["marginRight"];
						}
						else if(j == "italic" && this["fontStyle"] != undefined)
						{
							tf[j] = (this["fontStyle"] == j);
						}
						else if(j == "bold" && this["fontWeight"] != undefined)
						{
							tf[j] = (this["fontWeight"] == j);
						}
						else if(j == "align" && this["textAlign"] != undefined)
						{
							tf[j] = this["textAlign"];
						}
						else if(j == "indent" && this["textIndent"] != undefined)
						{
							tf[j] = this["textIndent"];
						}
						else if(j == "underline" && this["textDecoration"] != undefined)
						{
							tf[j] = (this["textDecoration"] == j);
						}
						else if(j == "embedFonts" && this["embedFonts"] != undefined)
						{
							tf[j] = this["embedFonts"];
						}
						else
						{
							bUndefined = true;
						}
					}
				}
			}
		}

		// if some fields are still undefined use css rules to ask the next person
		if (bUndefined)
		{
			// check our style sheet
			var name = styleName;
			if (name != undefined)
			{
				if (typeof (name) != "string")
				{
					bUndefined = name.__getTextFormat(tf, true, this);
				}
				else
				{
					if (_global.styles[name] != undefined)
					{
						bUndefined = _global.styles[name].__getTextFormat(tf, true, this);
					}
				}
			}
		}
		if (bUndefined)
		{
			var ss = getClassStyleDeclaration();
			if (ss != undefined)
				bUndefined = ss.__getTextFormat(tf, true, this);
		}
		if (bUndefined)
		{
			if (_global.cascadingStyles)
			{
				if (_parent != undefined)
					bUndefined = _parent.__getTextFormat(tf, false);
			}
		}
		if (bUndefined)
			bUndefined = _global.style.__getTextFormat(tf, true, this);

		return bUndefined;
	}

	// text objects call this to find out their styles
	function _getTextFormat(Void):TextFormat
	{
		var tf:TextFormat = stylecache.tf;
		if (tf != undefined)
			return tf;

		tf = new TextFormat();
		__getTextFormat(tf, true);
		stylecache.tf = tf;

		if (enabled == false)
		{
			var c:Number = getStyle("disabledColor");
			tf.color = c;
		}
		return tf;
	}

	// Used to see if a styleDeclaration change might apply to
	// this instance.
	function getStyleName(Void):String
	{
		var name = styleName;	// can be object or string
		if (name != undefined)
		{
			if (typeof (name) != "string")
			{
				return name.getStyleName();
			}
			else
				return name;
		}

		if (_parent != undefined)
			return _parent.getStyleName();
		else
			return undefined;

	}

/**
* get a style property
*
* @param	String	prop	name of style property
* @return	Variant	the style value
*
* @tiptext Gets the style value associated with the style property
* @helpid 3965
*/
	function getStyle(styleProp:String)
	{
		var v = undefined;

		_global.getStyleCounter ++;

		// see if it is in-line
		if (this[styleProp] != undefined)
		{
			return this[styleProp];
		}

		// check our style sheet
		var name = styleName;
		if (name != undefined)
		{
			if (typeof (name) != "string")
			{
				// went back to   Slightly slower for inheriting styles, but required for non-inheriting
				v = name.getStyle(styleProp);
			}
			else
			{
				var ss = _global.styles[name];
				v = ss.getStyle(styleProp);
//				if (ss[styleProp] != undefined)
//					v = ss[styleProp];
			}
		}
		if (v != undefined)
			return v;

		var ss = getClassStyleDeclaration();
		if (ss != undefined)
			v = ss[styleProp];
		if (v != undefined)
			return v;

		if (_global.cascadingStyles)
		{
			if (StyleManager.isInheritingStyle(styleProp) || StyleManager.isColorStyle(styleProp))
			{
				// see if there is a style cache
				var b:Object = stylecache;
				if (b != undefined)
				{
					// see if the value is on the style cache
					if (b[styleProp] != undefined)
						return b[styleProp];
				}

				// if we have a parent get it from the parent
				if (_parent != undefined)
					v = _parent.getStyle(styleProp);
				else {
					v = _global.style[styleProp];
				}
				if (b != undefined)
					b[styleProp] = v;

				return v;
			}
		}
		if (v == undefined)
			v = _global.style[styleProp];

		return v;
	}

/**
* @private
* Used by component developers to create the list of clip parameters.
*/
	static function mergeClipParameters(o, p):Boolean
	{
		for (var i in p)
		{
			o[i] = p[i];
		}
		return true;
	}

}

