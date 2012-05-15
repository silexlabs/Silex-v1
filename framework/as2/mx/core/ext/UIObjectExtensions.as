//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;
import mx.skins.SkinElement;
import mx.styles.CSSStyleDeclaration;
import mx.events.UIEventDispatcher;

// extensions to MovieClip and TextField to make the system work better
class mx.core.ext.UIObjectExtensions
{
	static var bExtended = false;

	static function addGeometry(tf:Object, ui:Object):Void
	{
		tf.addProperty("width", ui.__get__width, null);

		tf.addProperty("height", ui.__get__height, null);

		tf.addProperty("left", ui.__get__left, null);
		tf.addProperty("x", ui.__get__x, null);

		tf.addProperty("top", ui.__get__top, null);
		tf.addProperty("y", ui.__get__y, null);

		tf.addProperty("right", ui.__get__right, null);

		tf.addProperty("bottom", ui.__get__bottom, null);

		// add other things to the textfield so it looks more like a UIObject
		tf.addProperty("visible", ui.__get__visible, ui.__set__visible);

	}

	static function Extensions():Boolean
	{
		if (bExtended == true)
			return true;

		bExtended = true;

		var ui:Object = UIObject.prototype;

		var se:Object = SkinElement.prototype;
		addGeometry(se, ui);

		// add event dispatching
		UIEventDispatcher.initialize(ui);

		// force inclsion of ColoredSkinElement
 		var cse = mx.skins.ColoredSkinElement;

		mx.styles.CSSTextStyles.addTextStyles(ui);

		// add stuff to MovieClip
		var mc:Object = MovieClip.prototype;
		mc.getTopLevel = ui.getTopLevel;
		mc.createLabel = ui.createLabel;
		mc.createObject = ui.createObject;
		mc.createClassObject = ui.createClassObject;
		mc.createEmptyObject = ui.createEmptyObject;
		mc.destroyObject = ui.destroyObject;
		
		_global.ASSetPropFlags(mc, "getTopLevel",1);
		_global.ASSetPropFlags(mc, "createLabel",1);
		_global.ASSetPropFlags(mc, "createObject",1);
		_global.ASSetPropFlags(mc, "createClassObject",1);
		_global.ASSetPropFlags(mc, "createEmptyObject",1);
		_global.ASSetPropFlags(mc, "destroyObject",1);
		
		// add CSS style processing
		mc.__getTextFormat = ui.__getTextFormat;
		mc._getTextFormat = ui._getTextFormat;
		mc.getStyleName = ui.getStyleName;
		mc.getStyle = ui.getStyle;
		
		_global.ASSetPropFlags(mc, "__getTextFormat",1);
		_global.ASSetPropFlags(mc, "_getTextFormat",1);
		_global.ASSetPropFlags(mc, "getStyleName",1);
		_global.ASSetPropFlags(mc, "getStyle",1);

		// add geometry to the textfield so is looks more like a UIObject
		var tf = TextField.prototype;
		addGeometry(tf, ui);
		tf.addProperty("enabled", function() { return this.__enabled }, function(x){this.__enabled = x; this.invalidateStyle(); });

		tf.move = se.move;
		tf.setSize = se.setSize;

		tf.invalidateStyle = function()
		{
			this.invalidateFlag = true;
		}

		tf.draw = function()
		{
			if (this.invalidateFlag)
			{
				this.invalidateFlag = false;
				var tf = this._getTextFormat();
				this.setTextFormat(tf);
				this.setNewTextFormat(tf);
				this.embedFonts = (tf.embedFonts == true);
				if (this.__text!=undefined)
				{
					// only do this if textfield is empty
					// otherwise someone set text after
					// creating the textfield
					if (this.text == "")
						this.text = this.__text;
					delete this.__text;
				}
				this._visible = true;

			}
		}

		tf.setColor = function(color)
		{
		//	var tf = this._getTextFormat();
		//	tf.color = color;
		//	this.setTextFormat(tf);
			this.textColor = color;
		}

		tf.getStyle = mc.getStyle;
		tf.__getTextFormat = ui.__getTextFormat;

		// add databinding stuff to the textfield
		tf.setValue = function(v)
		{
			this.text = v;
		}

		tf.getValue = function()
		{
			return this.text;
		}

		tf.addProperty(
			"value",
			function(){ return this.getValue();},
			function(v){this.setValue(v);} );

		tf._getTextFormat = function()
		{
			var tf = this.stylecache.tf;
			if (tf != undefined)
				return tf;

			tf = new TextFormat();
			this.__getTextFormat(tf);
			this.stylecache.tf = tf;
			if (this.__enabled == false)
			{
				if (this.enabledColor == undefined)
				{
					var otf = this.getTextFormat();
					this.enabledColor = otf.color;
				}
				var c = this.getStyle("disabledColor");
				tf.color = c;
			}
			else
			{
				if (this.enabledColor != undefined)
					if (tf.color == undefined)
						tf.color = this.enabledColor;
			}
			return tf;
		}

		// formalize the convention we're using for sizing textFields
		tf.getPreferredWidth = function()
		{
			this.draw();
			return this.textWidth + 4;
		}
		tf.getPreferredHeight = function()
		{
			this.draw();
			return this.textHeight + 4;
		}


		// add a better text measuring method to TextFormat.
		// the current one is broken in Flash
		TextFormat.prototype.getTextExtent2 = function(s)
		{
			var o = _root._getTextExtent;

			if (o == undefined)
			{
				_root.createTextField("_getTextExtent", -2, 0, 0, 1000, 100);
				o = _root._getTextExtent;
				o._visible = false;
			}
			_root._getTextExtent.text = s;
			var z = this.align;
			this.align = "left";
			_root._getTextExtent.setTextFormat(this);
			this.align = z;
			return {width: o.textWidth, height: o.textHeight};
		}

		// set up the global objects here
		if (_global.style == undefined)
		{
			_global.style = new CSSStyleDeclaration();

			// the Defaults symbol in the library is where default styles are set up

			_global.cascadingStyles = true;
			_global.styles = new Object;	// create a place to hang named StyleDeclarations
			_global.skinRegistry = new Object; // registered SkinElements

			// the player resizes and centers the stage.  We need to know what our original
			// stage size is in order to know how we were centered.  Note that the FMX
			// authoring player seems to report the size incorrectly.
			if (_global._origWidth == undefined)
			{
				_global.origWidth = Stage.width;
				_global.origHeight = Stage.height;
				
			}

		}

		var r = _root;
		while (r._parent != undefined)
			r = r._parent;
		// add width and height to the _root so it looks more like a UIObject
		r.addProperty("width", function(){ return Stage.width; }, null);
		r.addProperty("height", function(){ return Stage.height; }, null);
		_global.ASSetPropFlags( r, "width",1);
		_global.ASSetPropFlags( r, "height",1);

		return true;
	}

	static var UIObjectExtended = Extensions();
    static var UIObjectDependency = UIObject;
    static var SkinElementDependency = SkinElement;
    static var CSSTextStylesDependency = mx.styles.CSSTextStyles;
    static var UIEventDispatcherDependency = UIEventDispatcher;
}
