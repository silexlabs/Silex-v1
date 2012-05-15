//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIComponent;

[Event("click")]

[TagName("SimpleButton")]

/**
* SimpleButton class
* extends UIComponent
* use if button does not need to be resized
* does support icons or text
* @tiptext Provides core button functionality without resizability.  Extends UIComponent
* @helpid 3169
*/
class mx.controls.SimpleButton extends UIComponent
{

/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "SimpleButton";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.controls.SimpleButton;
//#include "../core/ComponentVersion.as"
/**
* @private
* className for object
*/
	var	className:String = "SimpleButton";
	var style3dInset:Number = 4;
/**
* @private
* number used to offset the label and/or icon when button is pressed
*/
	var btnOffset:Number = 1;
/**
* @private
* define private toggle value
*/
	var __toggle:Boolean = false;
/**
* @private
* define private state value
*/
	var __state:Boolean = false;
/**
* @private
* define private emphasized value
*/
	var __emphasized:Boolean = false;
/**
* @private
* define private emphatic value
*/
	var __emphatic:Boolean = false;
/**
* @private
* define button down handler
*/
	var buttonDownHandler:Function;
/**
* @private
* define click handler
*/
	var clickHandler:Function;
/**
* @private
* way of storing data off of component
*/
	var detail:Number;
/**
* @private
* falseUp depth
*/
	static var falseUp:Number = 0;
/**
* @private
* falseDown depth
*/
	static var falseDown:Number = 1;
/**
* @private
* falseOver depth
*/
	static var falseOver:Number = 2;
/**
* @private
* falseDisabled depth
*/
	static var falseDisabled:Number = 3;
/**
* @private
* trueUp depth
*/
	static var trueUp:Number = 4;
/**
* @private
* trueDown depth
*/
	static var trueDown:Number = 5;
/**
* @private
* trueOver depth
*/
	static var trueOver:Number = 6;
/**
* @private
* trueDisabled depth
*/
	static var trueDisabled:Number = 7;
/**
* @private
* falseUpSkin name
* change of value will change the viewable state
*/
	var falseUpSkin:String = "SimpleButtonUp";
/**
* @private
* falseDownSkin name
* change of value will change the viewable state
*/
	var falseDownSkin:String = "SimpleButtonIn";
/**
* @private
* falseOverSkin name
* change of value will change the viewable state
*/
	var falseOverSkin:String = "";
/**
* @private
* falseDisabledSkin name
* change of value will change the viewable state
*/
	var falseDisabledSkin:String = "SimpleButtonUp";
/**
* @private
* trueUpSkin name
* change of value will change the viewable state
*/
	var trueUpSkin:String = "SimpleButtonIn";
/**
* @private
* trueDownSkin name
* change of value will change the viewable state
*/
	var trueDownSkin:String = "";
/**
* @private
* trueOverSkin name
* change of value will change the viewable state
*/
	var trueOverSkin:String = "";
/**
* @private
* trueDisabledSkin name
* change of value will change the viewable state
*/
	var trueDisabledSkin:String = "SimpleButtonIn";
/**
* @private
* falseUpSkinEmphasized name
* change of value will change the viewable state
*/
	var falseUpSkinEmphasized:String;
/**
* @private
* falseDownSkinEmphasized name
* change of value will change the viewable state
*/
	var falseDownSkinEmphasized:String;
/**
* @private
* falseOverSkinEmphasized name
* change of value will change the viewable state
*/
	var falseOverSkinEmphasized:String;
/**
* @private
* falseDisabledSkinEmphasized name
* change of value will change the viewable state
*/
	var falseDisabledSkinEmphasized:String;
/**
* @private
* trueUpSkinEmphasized name
* change of value will change the viewable state
*/
	var trueUpSkinEmphasized:String;
/**
* @private
* trueDownSkinEmphasized name
* change of value will change the viewable state
*/
	var trueDownSkinEmphasized:String;
/**
* @private
* trueOverSkinEmphasized name
* change of value will change the viewable state
*/
	var trueOverSkinEmphasized:String;
/**
* @private
* trueDisabledSkinEmphasized name
* change of value will change the viewable state
*/
	var trueDisabledSkinEmphasized:String;
/**
* @private
* falseUpIcon name
* change of value will change the viewable state
*/
	var falseUpIcon:String = "";
/**
* @private
* falseDownIcon name
* change of value will change the viewable state
*/
	var falseDownIcon:String = "";
/**
* @private
* falseOverIcon name
* change of value will change the viewable state
*/
	var falseOverIcon:String = "";
/**
* @private
* falseDisabledIcon name
* change of value will change the viewable state
*/
	var falseDisabledIcon:String = "";
/**
* @private
* trueUpIcon name
* change of value will change the viewable state
*/
	var trueUpIcon:String = "";
/**
* @private
* trueDownIcon name
* change of value will change the viewable state
*/
	var trueDownIcon:String = "";
/**
* @private
* trueOverIcon name
* change of value will change the viewable state
*/
	var trueOverIcon:String = "";
/**
* @private
* trueDisabledIcon name
* change of value will change the viewable state
*/
	var trueDisabledIcon:String = "";
/**
* @private
* falseUpIconEmphasized name
* change of value will change the viewable state
*/
	var falseUpIconEmphasized:String;
/**
* @private
* falseDownIconEmphasized name
* change of value will change the viewable state
*/
	var falseDownIconEmphasized:String;
/**
* @private
* falseOverIconEmphasized name
* change of value will change the viewable state
*/
	var falseOverIconEmphasized:String;
/**
* @private
* falseDisabledIconEmphasized name
* change of value will change the viewable state
*/
	var falseDisabledIconEmphasized:String;
/**
* @private
* trueUpIconEmphasized name
* change of value will change the viewable state
*/
	var trueUpIconEmphasized:String;
/**
* @private
* trueDownIconEmphasized name
* change of value will change the viewable state
*/
	var trueDownIconEmphasized:String;
/**
* @private
* trueOverIconEmphasized name
* change of value will change the viewable state
*/
	var trueOverIconEmphasized:String;
/**
* @private
* trueDisabledIconEmphasized name
* change of value will change the viewable state
*/
	var trueDisabledIconEmphasized:String;

/**
* @private
*  emphasizedStyleDeclaration
*/
	static var emphasizedStyleDeclaration;
/**
* @private
* define skinName
*/
	var skinName:Object;
/**
* @private
* linkage string length
*/
	var linkLength:Number;
/**
* @private
*
*/
	var preset:Boolean;
/**
* @private
*
*/
	var iconName:Object;
/**
* @private
*
*/
	var __emphaticStyleName:String;
/**
* @private
*
*/
	var phase:String = "up";
/**
* @private
*
*/
	var autoRepeat:Boolean;
/**
* @private
*
*/
	var interval;
/**
* @private
*
*/
	var boundingBox_mc:MovieClip;

/**
* @private
*
*/
	var fui;
/**
* @private
*
*/
	var fus;
/**
* @private
*
*/
	var fdi;
/**
* @private
*
*/
	var fds;
/**
* @private
*
*/
	var frs;
/**
* @private
*
*/
	var fri;
/**
* @private
*
*/
	var dfi;
/**
* @private
*
*/
	var dfs;
/**
* @private
*
*/
	var tui;
/**
* @private
*
*/
	var tus;
/**
* @private
*
*/
	var tdi;
/**
* @private
*
*/
	var tds;
/**
* @private
*
*/
	var trs;
/**
* @private
*
*/
	var tri;
/**
* @private
*
*/
	var dts;
/**
* @private
*
*/
	var dti;
/**
* @private
*
*/
	var rolloverSkin:Object;
/**
* @private
*
*/
	var rolloverIcon:Object;
/**
* @private
*
*/
	var upSkin:Object;
/**
* @private
*
*/
	var downSkin:Object;
/**
* @private
*
*/
	var disabledSkin:Object;
/**
* @private
*
*/
	var upIcon:Object;
/**
* @private
*
*/
	var downIcon:Object;
/**
* @private
*
*/
	var disabledIcon:Object;
/**
* @private
*
*/
	var initializing:Boolean = true;
/**
* @private
* SimpleButton constructor
*/
	function SimpleButton()
	{
		
	}

/**
* @private
* init variables. Components should implement this method and call super.init() to
* ensure this method gets called.  The width, height and clip parameters will not
* be properly set until after this is called.
*/
	function init(Void):Void
	{
		super.init();

		fui = "falseUpIcon";
		fus = "falseUpSkin";
		fdi = "falseDownIcon";
		fds = "falseDownSkin";
		frs = "falseOverSkin";
		fri =  "falseOverIcon";
		dfi = "falseDisabledIcon";
		dfs = "falseDisabledSkin";
		tui = "trueUpIcon";
		tus = "trueUpSkin";
		tdi = "trueDownIcon";
		tds = "trueDownSkin";
		trs  = "trueOverSkin";
		tri  = "trueOverIcon";
		dts = "trueDisabledSkin";
		dti = "trueDisabledIcon";

		rolloverSkin = frs;
		rolloverIcon = fri;
		upSkin = fus;
		upIcon = fui;
		downSkin = fds;
		downIcon = fdi;
		disabledSkin = dfs;
		disabledIcon = dfi;

		if (preset == undefined)
		{
			boundingBox_mc._visible = false;
			boundingBox_mc._width = boundingBox_mc._height = 0;

			//trace("width :: " + width)
			//trace("_width :: " + _width)
			//trace("__width :: " + __width)
		}
		useHandCursor  = false;
	}
/**
* @private
* array of names used to set the state
*/
	var idNames = ["fus","fds","frs","dfs","tus","tds", "trs","dts",
			   "fui","fdi","fri","dfi","tui","tdi","tri","dti" ];
/**
* @private
* state names of a button
*/
	var stateNames = ["falseUp","falseDown","falseOver","falseDisabled","trueUp","trueDown","trueOver","trueDisabled"];
/**
* @private
*
*/
	var refNames = ["upSkin","downSkin","rolloverSkin","disabledSkin"];
/**
* @private
*
*/
	var tagMap = { falseUpSkin: 0, falseDownSkin: 1, falseOverSkin: 2, falseDisabledSkin: 3,
					trueUpSkin: 4, trueDownSkin: 5, trueOverSkin: 6, trueDisabledSkin: 7,
					falseUpIcon: 0, falseDownIcon: 1, falseOverIcon: 2, falseDisabledIcon: 3,
					trueUpIcon: 4, trueDownIcon: 5, trueOverIcon: 6, trueDisabledIcon: 7  };
/**
* @private
* create children objects. Components implement this method to create the
* subobjects in the component.  Recommended way is to make text objects
* invisible and make them visible when the draw() method is called to
* avoid flicker on the screen.
*/
	function createChildren(Void):Void
	{
		if (preset != undefined)	// initial state Skin is present in the symbol
		{
			var ref = this[idNames[preset]];
			this[refNames[preset]] = ref;
			skinName = ref;
			if (falseOverSkin.length == 0)
				rolloverSkin = fus;
			if (falseOverIcon.length == 0)
				rolloverIcon = fui;
			initializing = false;
		}
		else
		{
			if (__state == true)
				setStateVar(true);
			else
			{
				if (falseOverSkin.length == 0)
					rolloverSkin = fus;
				if (falseOverIcon.length == 0)
					rolloverIcon = fui;
			}
		}
	}
/**
* @private
*
*/
	function setIcon(tag:Number,linkageName:String):Object
	{
		return setSkin(tag + 8,linkageName);
	}
/**
* @private
*
*/
	function changeIcon(tag:Number,linkageName:String):Void
	{
		linkLength = linkageName.length;
		var s = stateNames[tag] + "Icon";
		this[s] = linkageName;
		this[idNames[tag +8]] = s;
		setStateVar(getState());
	}
/**
* @private
*
*/
	function changeSkin(tag:Number,linkageName:String):Void
	{
		var s = stateNames[tag] + "Skin";
		this[s] = linkageName;
		this[idNames[tag]] = s;
		setStateVar(getState());
	}
/**
* @private
*
*/
	function viewIcon(varName:String):Void
	{
		var v = varName + "Icon";
		var ref = this[v];
		// ref is now .fui or equivalent which points to a movieclip
		// or the name of variable that holds the linkage name (falseUpIcon)
		if(typeof(ref) == "string")
		{
			var s = ref;
			if (__emphasized)
			{
				if (this[ref + "Emphasized"].length > 0)
					ref = ref + "Emphasized";
			}
			if(this[ref].length == 0 )return;
			ref = setIcon(tagMap[s], this[ref]);
			if (ref == undefined && _global.isLivePreview){
				ref = setIcon(0,"ButtonIcon") ;
			}
			this[v] = ref;
		}
		iconName._visible = false;
		iconName = ref;
		iconName._visible  = true;
	}

/**
* @private
*
*/
	function removeIcons()
	{
		for (var t = 0; t <2 ;t++){
			for (var i = 8;i < 16;i++){
				destroyObject(idNames[i]);
				this[stateNames[i-8]+"Icon"] = "";
			}
		}
		refresh();
	}
/**
* @private
*
*/
	function setSkin(tag:Number,linkageName:String, initobj:Object):MovieClip
	{
		var o = super.setSkin(tag, linkageName, initobj!= undefined?initobj:{styleName: this});
		calcSize(tag, o);
		return o;
	}
/**
* @private
*
*/
	function calcSize():Void
	{
		 __width = _width;
		 __height  = _height;
	}
/**
* @private
*
*/
	function viewSkin(varName:String,initObj:Object):Void
	{
		var v = varName+"Skin";
		var ref = this[v];
		if(typeof(ref) == "string")
		{
			var s = ref;
			if (__emphasized)
			{
				if (this[ref + "Emphasized"].length > 0)
					ref = ref + "Emphasized";
			}
			if(this[ref].length == 0 )return;
			ref = setSkin(tagMap[s], this[ref], initObj!= undefined? initObj: {styleName: this} );
			this[v] = ref;
		}

		skinName._visible = false;
		skinName = ref;
		skinName._visible  = true;
	}
/**
* @private
*
*/
	function showEmphasized (e:Boolean):Void
	{
		if (e && !__emphatic)
		{
			if (SimpleButton.emphasizedStyleDeclaration != undefined)
			{
				__emphaticStyleName = styleName;
				styleName = SimpleButton.emphasizedStyleDeclaration;
			}
			__emphatic = true;
		}
		else
		{
			if (__emphatic)
			{
				styleName = __emphaticStyleName;
			}
			__emphatic = false;
		}
	}
/**
* @private
*
*/
	function refresh(Void):Void
	{
		var offset:Boolean = getState();
		if (enabled == false ) {
			viewIcon("disabled");
			viewSkin("disabled");
		}
		else
		{
			viewSkin(phase);
			viewIcon(phase);
		}
		setView(phase == "down");

		iconName.enabled = enabled;
	}
/**
* @private
*
*/
	function setView(offset:Boolean):Void
	{
		if(iconName == undefined) return;
		var n = offset ? btnOffset : 0;
		iconName._x = (__width - iconName._width)/2 + n;
		iconName._y = (__height - iconName._height)/2 + n;
	}
/**
* @private
*
*/
	function setStateVar(state:Boolean):Void
	{
		if (state)
		{
			if (trueOverSkin.length == 0)
			{
				rolloverSkin = tus;
			}
			else
			{
				rolloverSkin = trs;
			}
			if (trueOverIcon.length == 0)
			{
				rolloverIcon = tui;
			}
			else
			{
				rolloverIcon = tri;
			}
			upSkin = tus;
			downSkin = tds;
			disabledSkin = dts;
			upIcon = tui;
			downIcon = tdi;
			disabledIcon = dti;
		}
		else
		{
			if (falseOverSkin.length == 0)
			{
				rolloverSkin = fus;
			}
			else
			{
				rolloverSkin = frs;
			}
			if (falseOverIcon.length == 0)
			{
				rolloverIcon = fui;
			}
			else
			{
				rolloverIcon = fri;
			}
			upSkin = fus;
			downSkin = fds;
			disabledSkin = dfs;
			upIcon = fui;
			downIcon = fdi;
			disabledIcon = dfi;
		}
		__state = state;
	}
/**
* @private
*
*/
	function setState(state:Boolean):Void
	{
		if (state != __state)
		{
			setStateVar(state);
			invalidate();
		}
	}
/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/
	function size(Void):Void
	{
		refresh();
	}
/**
* @private
*
*/
	function draw(Void):Void
	{
		if (initializing)
		{
			initializing = false;
			skinName.visible = true;
			iconName.visible = true;
		}
		size();
}
/**
* @private
*
*/
	function getState(Void):Boolean
	{
		return __state;
	}
/**
* @private
*
*/
	function setToggle(val:Boolean)
	{
		__toggle = val;
		if (__toggle == false) setState(false);
	}
/**
* @private
*
*/
	function getToggle(Void):Boolean
	{
		return __toggle;
	}
/**
* @private
*
*/
	function set toggle(val:Boolean)
	{
		setToggle(val);
	}
/**
* @tiptext  Needs tooltip
* @helpid 3406
*/
	[Inspectable(defaultValue=false)]
	function get toggle():Boolean
	{
		return getToggle();
	}

/**
* @private
*
*/
	function set value(val:Boolean)
	{
		setSelected(val);
	}
/**
* @private
*
*/
	function get value():Boolean
	{
		return getSelected();
	}
/**
* @private
*
*/
	function set selected (val:Boolean)
	{
		setSelected(val);
	}
/**
* @tiptext  Needs tooltip
* @helpid 3405
*/
	[Inspectable(defaultValue=false)]
	function get selected ():Boolean
	{
		return getSelected();
	}
/**
* @private
*
*/
	function setSelected (val:Boolean)
	{
		if(__toggle)
		{
			setState(val);
		}
		else
		{
			setState( (initializing) ? val : __state);
		}
	}
/**
* @private
*
*/
	function getSelected ():Boolean
	{
		return __state;
	}
/**
* @private
*
*/
	function setEnabled(val:Boolean):Void
	{
		if (enabled != val)
		{
			super.setEnabled(val);
			invalidate();
		}
	}
/**
* @private
*
*/
	function onPress(Void):Void
	{
		pressFocus();
		phase = "down";
		refresh();
		dispatchEvent({type:"buttonDown"});
		
		if (autoRepeat)
		{
			interval = setInterval(this, "onPressDelay", getStyle("repeatDelay"));
		}
	}
/**
* @private
*
*/
	function onPressDelay(Void):Void
	{
		dispatchEvent({type:"buttonDown"});
		if (autoRepeat)
		{
			clearInterval(interval);
			interval = setInterval(this, "onPressRepeat", getStyle("repeatInterval"));
		}
	}
/**
* @private
*
*/
	function onPressRepeat(Void):Void
	{
		dispatchEvent({type:"buttonDown"});
		updateAfterEvent();
	}
/**
* @private
*
*/
	function onRelease(Void):Void
	{
		releaseFocus();
		phase = "rollover";
		if (interval != undefined)
		{
			clearInterval(interval);
			delete interval;
		}

		if (getToggle()) {
			setState(!getState());
		}
		else
		{
			refresh();
		}
		dispatchEvent({type:"click"});
	}
/**
* @private
*
*/
	function onDragOut(Void):Void
	{
		phase = "up";
		refresh();
		dispatchEvent({type:"buttonDragOut"});
	}
/**
* @private
*
*/
	function onDragOver(Void):Void
	{
		if (phase != "up")
		{
			// it is possible to get a onDragOver even though we never got a dragOut or press.
			// in this situation, we map onDragOver to onPress
			onPress();
			return;
		}
		else
		{
			phase = "down";
			refresh();
		}
	}
/**
* @private
*
*/
	function onReleaseOutside(Void):Void
	{
		releaseFocus();
		phase="up";
		if (interval != undefined)
		{
			clearInterval(interval);
			delete interval;
		}
	}
/**
* @private
*
*/
	function onRollOver(Void):Void
	{
		phase = "rollover";
		refresh();
	}
/**
* @private
*
*/
	function onRollOut(Void):Void
	{
		phase = "up";
		refresh();
	}
/**
* @private
*
*/
	function getLabel(Void):String
	{
		return fui.text;
	}

/**
* @private
*
*/	function setLabel(val:String):Void
	{
		if (typeof(fui) == "string")
		{
			createLabel("fui", 8, val);
			fui.styleName = this;
		}
		else
			fui.text = val;

		var tf = fui._getTextFormat();
		var extent = tf.getTextExtent2(val);
		fui._width = extent.width + 5;
		fui._height = extent.height + 5;
		iconName = fui;
		setView(__state);
	}
/**
* @private
*
*/
	function get emphasized():Boolean
	{
		return __emphasized;
	}
/**
* @private
*
*/
	function set emphasized(val:Boolean)
	{
		__emphasized = val;
		for (var i = 0; i < 8; i++)
		{
			this[idNames[i]] = stateNames[i] + "Skin";
			if (typeof(this[idNames[i+8]]) == "movieclip")
			{
				this[idNames[i+8]] = stateNames[i] + "Icon";
			}
		}
		showEmphasized(__emphasized);
		setStateVar(__state);
		invalidateStyle();
	}
/**
* @private
*
*/
	function keyDown(e:Object):Void
	{
		if (e.code == Key.SPACE)
			onPress();
	}
/**
* @private
*
*/
	function keyUp(e:Object):Void
	{
		if (e.code == Key.SPACE)
			onRelease();
	}

	function onKillFocus(newFocus:Object):Void
	{
		super.onKillFocus();
		// most of the time the system sends a rollout, but there are situations
		// where the mouse is over something else that you don't get one so
		// we force one here
		if (phase != "up")
		{
			phase = "up";
			refresh();
		}
	}
	
	private static var ButtonSkinDependency = mx.skins.halo.ButtonSkin;
}





