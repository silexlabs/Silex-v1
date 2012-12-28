//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.SimpleButton;
import mx.core.UIObject;
//import mx.core.UIComponent;

/**
* @tiptext click event
* @helpid 3168
*/
[Event("click")]

[TagName("Button")]
[IconFile("Button.png")]

/**
* Button class
* - extends SimpleButton
* - adds label and text with layout
* - adds ability to resize without distorting the skin
* @tiptext Button provides core button functionality.  Extends SimpleButton
* @helpid 3043
*/

class mx.controls.Button extends SimpleButton
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "Button";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner = mx.controls.Button;
	var	className:String = "Button";

	function Button()
	{
	}

	//#include "../core/ComponentVersion.as"

/**
* number used to offset the label and/or icon when button is pressed
*/
	var  btnOffset:Number = 0;
/**
*@private
* Color used to set the theme color
*/
	var _color = "buttonColor";
/**
*@private
* Text that appears in the label if no value is specified
*/
	var __label:String  = "default value";
/**
*@private
* default label placement
*/
	var __labelPlacement:String  = "right";
/**
//*@private
* store the linkage name of the icon at initalization
*/
var initIcon;
/**
* @private
* button state skin variables
*/
	var falseUpSkin:String  = "ButtonSkin";
	var falseDownSkin:String  = "ButtonSkin";
	var falseOverSkin:String = "ButtonSkin";
	var falseDisabledSkin:String = "ButtonSkin";
	var trueUpSkin:String = "ButtonSkin";
	var trueDownSkin:String = "ButtonSkin";
	var trueOverSkin:String = "ButtonSkin";
	var trueDisabledSkin:String = "ButtonSkin";

	var falseUpIcon:String = "";
	var falseDownIcon:String = "";
	var falseOverIcon:String = "";
	var falseDisabledIcon:String = "";
	var trueUpIcon:String = "";
	var trueDownIcon:String = "";
	var trueOverIcon:String = "";
	var trueDisabledIcon:String = "";

/**
* @private
* list of clip parameters to check at init
*/
	var clipParameters:Object = { labelPlacement:1, icon:1, toggle:1, selected:1, label:1 };
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(mx.controls.Button.prototype.clipParameters, SimpleButton.prototype.clipParameters);
	var labelPath:Object;
	var hitArea_mc:MovieClip;
	var _iconLinkageName:String;
	var centerContent : Boolean = true;
	var borderW : Number = 1;// buffer value for border

/**
* @private
* init variables. Components should implement this method and call super.init() to
* ensure this method gets called.  The width, height and clip parameters will not
* be properly set until after this is called.
*/
	function init(Void):Void
	{
		super.init();
	}

/**
* @private
*
*/
	function draw()
	{
		if (initializing)
			labelPath.visible = true;
			
		super.draw();
		if (initIcon != undefined)
			_setIcon(initIcon);
			    delete initIcon;

	}

/**
* This method calls SimpleButton's onRelease()
*/
	function onRelease(Void):Void
	{
		super.onRelease();
	}

/**
* @private
* create children objects. Components implement this method to create the
* subobjects in the component.  Recommended way is to make text objects
* invisible and make them visible when the draw() method is called to
* avoid flicker on the screen.
*/
	function createChildren(Void):Void
	{
		super.createChildren();
	}

/**
* @private
* sets the skin state based on tag and linkage name
*/
	function setSkin(tag:Number,linkageName:String, initobj:Object):MovieClip
	{
		return super.setSkin(tag, linkageName, initobj);
	}

/**
* @private
* sets the old skin's visibility to false and sets the new skin's visibility to true
*/
	function viewSkin(varName:String):Void
	{
		var skinStyle = getState() ? "true" : "false";
		skinStyle += enabled ? phase : "disabled";
		super.viewSkin(varName,{styleName:this,borderStyle:skinStyle});
	}

/**
* @private
* Watch for a style change.
*/
	function invalidateStyle(c:String):Void
	{
		labelPath.invalidateStyle(c);
		super.invalidateStyle(c);
	}

/**
* @private
* sets the color to each one of the states
*/
	function setColor(c:Number):Void
	{
		for (var i=0;i<8;i++)
		{
			this[idNames[i]].redraw(true);
		}
	}

/**
* @private
* this is called whenever the enabled state changes.
*/
	function setEnabled(enable:Boolean):Void
	{
		labelPath.enabled = enable;
		super.setEnabled(enable);
	}

/**
* @private
* sets same size of each of the states
*/
	function calcSize(tag:Number, ref:Object):Void
	{
		if ((__width == undefined) || (__height == undefined)) return;

		if(tag < 7 )
		{
			ref.setSize(__width,__height,true);
		}
	}

/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/
	function size(Void):Void
	{
		setState(getState());
		setHitArea(__width,__height);
		for (var i = 0; i < 8; i++)
		{
			var ref = idNames[i];
			if (typeof(this[ref]) == "movieclip")
			{
				this[ref].setSize(__width, __height, true);
			}
		}
		super.size();
	}

/**
* sets the label placement of left,right,top, or bottom
* @tiptext Gets or sets the label placement relative to the icon
* @helpid 3044
*/
	[Inspectable(enumeration="left,right,top,bottom", defaultValue="right")]
	function set labelPlacement (val:String)
	{
		__labelPlacement = val;
		invalidate();
	}

/**
* returns the label placement of left,right,top, or bottom
* @tiptext Gets or sets the label placement relative to the icon
* @helpid 3045
*/
	function get labelPlacement():String
	{
		return __labelPlacement;
	}

/**
* @private
* use to get the label placement of left,right,top, or bottom
*/
	function getLabelPlacement(Void):String
	{
		return __labelPlacement;
	}

/**
* @private
* use to set the label placement to left,right,top, or bottom
*/
	function setLabelPlacement(val:String):Void
	{
		__labelPlacement = val;
		invalidate();
	}

/**
* @private
* use to get the btnOffset value
*/
	function getBtnOffset(Void):Number
	{
		var n;
		if(getState())
		{
			n = btnOffset;
		}
		else
		{
			if(phase == "down")
			{
				n = btnOffset;
			}
			else
			{
				n = 0;
			}
		}
		return n;
	}

/**
* @private
* Controls the layout of the icon and the label within the button.
* note that layout hinges on a variable, "centerContents", which is set to true in Button.
* but false in check and radio.
*/
	function setView(offset:Number):Void
	{
		var n = offset ? btnOffset : 0;
		var val = getLabelPlacement();
		var iconW : Number = 0;
		var iconH : Number = 0;
		var labelW : Number = 0;
		var labelH : Number = 0;
		var labelX : Number = 0;
		var labelY : Number = 0;

		var lp = labelPath;
		var ic = iconName;

		// measure text size
		var textW = lp.textWidth;
		var textH = lp.textHeight;

		var viewW = __width-borderW-borderW;
		var viewH = __height-borderW-borderW;

		if (ic!=undefined) {
			iconW = ic._width;
			iconH = ic._height;
		}

		if (val ==  "left" || val == "right")
		{
			if (lp!=undefined)
			{
				lp._width = labelW = Math.min(viewW-iconW, textW+5);
				lp._height = labelH = Math.min(viewH, textH+5);
			}

			if (val == "right")
			{
				labelX = iconW;
				if (centerContent) {
					labelX += (viewW - labelW - iconW)/2;
				}
				ic._x =  labelX - iconW;
			}
			else
			{
				labelX = viewW - labelW - iconW;
				if (centerContent) {
					labelX = labelX / 2;
				}
				ic._x  = labelX + labelW;
			}

			ic._y  = labelY = 0;
			if (centerContent) {
				ic._y  = (viewH - iconH )/2;
				labelY = (viewH - labelH )/2;
			}

			if (!centerContent)
				ic._y += Math.max(0, (labelH-iconH)/2);
		}
		else
		{
			if (lp!=undefined) {
				lp._width = labelW = Math.min(viewW, textW+5);
				lp._height =  labelH = Math.min(viewH-iconH, textH+5);
			}

			labelX  = (viewW - labelW )/2;

			ic._x  = (viewW - iconW )/2;

			if (val == "top")
			{
				labelY = viewH - labelH - iconH;
				if (centerContent) {
					labelY = labelY / 2;
				}
				ic._y = labelY + labelH;
			}
			else
			{
				labelY = iconH;
				if (centerContent) {
					labelY += (viewH - labelH - iconH)/2;
				}
				ic._y = labelY - iconH;
			}

		}
		var buff = borderW + n;
		lp._x = labelX + buff;
		lp._y = labelY + buff;
		ic._x += buff;
		ic._y += buff;
	}

/**
* sets the associated label text
* @tiptext Gets or sets the Button label
* @helpid 3046
*/
	[Inspectable(defaultValue="Button")]
	function set label(lbl:String)
	{
		setLabel(lbl);
	}

/**
* @private
* sets the associated label text
*/
	function setLabel(label:String):Void
	{
		if (label=="")
		{
			labelPath.removeTextField();
			refresh();
			return;
		}

		if (labelPath == undefined)
		{
			var lp =  createLabel("labelPath", 200, label);
			lp._width = lp.textWidth + 5;
			lp._height = lp.textHeight +5;
			
			if (initializing)
				lp.visible = false;
		}
		else
		{
			delete labelPath.__text;
			labelPath.text = label;
			refresh();
		}
	}


/**
* @private
* gets the associated label text
*/
	function getLabel(Void):String
	{
		// if __text is set, it is waiting for a redraw so use it instead
		return (labelPath.__text != undefined) ? labelPath.__text : labelPath.text;
	}

/**
* gets the associated label text
* @tiptext Gets or sets the Button label
* @helpid 3047
*/
	function get label():String
	{
		return getLabel();
	}


	function _getIcon(Void):String
	{
		return _iconLinkageName;
	}

/**
* sets the associated icon
* use setIcon() to set the icon
* @tiptext Gets or sets the linkage identifier of the Button's icon
* @helpid 3404
*/
	function get icon():String
	{
		if (initializing)
			return initIcon;
		return _iconLinkageName;
	}

/**
*@private
* sets the icon for the falseUp, falseDown and trueUp states
* use setIcon() to set the icon
*/
	function _setIcon(linkage):Void
	{
		if (initializing)
		{
			if (linkage == "" ) return;
			initIcon = linkage;
		}
		else
		{
			if ( linkage == ""){removeIcons();return;} 
			super.changeIcon(0,linkage);
			super.changeIcon(1,linkage);
			super.changeIcon(3,linkage);
			super.changeIcon(4,linkage);
			super.changeIcon(5,linkage);
			_iconLinkageName = linkage;
			refresh();
		}
	}

/**
* @sets the icon for all states of the button
* @tiptext Gets or sets the linkage identifier of the Button's icon
* @helpid 3048
*/
	[Inspectable(defaultValue="")]
	function set icon(linkage)
	{
		_setIcon(linkage);
	}

/**
* @private
* @method to set the hit area dimensions
*/
	function setHitArea(w:Number,h:Number)
	{
		if (hitArea_mc == undefined)
			createEmptyObject("hitArea_mc",100); //reserved depth for hit area
		var ha = hitArea_mc;
		ha.clear();
		ha.beginFill(0xff0000);
		ha.drawRect(0,0,w,h);
		ha.endFill();
		ha.setVisible(false);
	}

	[Bindable]
	[ChangeEvent("click")]
	var _inherited_selected : Boolean;
	
}
