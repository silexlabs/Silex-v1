//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.SkinElement;
import mx.core.UIComponent;
import mx.core.UIObject;
import mx.skins.sample.Defaults;
import mx.managers.DepthManager;

class mx.skins.sample.FocusRect extends SkinElement
{
	var boundingBox_mc:MovieClip;
	var drawRoundRect:Function;
	function FocusRect()
	{
		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;
	}

	function draw(o:Object):Void
	{
		o.adjustFocusRect();
	}

	function setSize(w:Number, h:Number, r, a:Number, rectCol:Number):Void
	{
		_xscale = _yscale = 100;

		clear();


		if (typeof r ==  "object"){
			r.br = (r.br>2)? r.br-2 : 0;
			r.bl = (r.bl>2)? r.bl-2 : 0;
			r.tr = (r.tr>2)? r.tr-2 : 0;
			r.tl = (r.tl>2)? r.tl-2 : 0;

			this.beginFill(rectCol,a*.3);
			this.drawRoundRect(0,0,w,h,r);
			this.drawRoundRect(2,2,w-4,h-4,r)
			this.endFill();

			r.br = (r.br>1)? r.br+1 : 0;
			r.bl = (r.bl>1)? r.bl+1 : 0;
			r.tr = (r.tr>1)? r.tr+1 : 0;
			r.tl = (r.tl>1)? r.tl+1 : 0;

			this.beginFill(rectCol,a*.3);
			this.drawRoundRect(0+1,0+1,w-2,h-2,r);

			r.br = (r.br>1)? r.br-1 : 0;
			r.bl = (r.bl>1)? r.bl-1 : 0;
			r.tr = (r.tr>1)? r.tr-1 : 0;
			r.tl = (r.tl>1)? r.tl-1 : 0;

			this.drawRoundRect(2,2,w-4,h-4,r)
			this.endFill();


		}
		else
		{
			var cr;
			if ( r != 0 )
			{
				cr = r-2;
			}
			else
			{
				cr = 0;
			}

			this.beginFill(rectCol,a*.3);
			this.drawRoundRect(0,0,w,h,r);
			this.drawRoundRect(2,2,w-4,h-4,cr)
			this.endFill();

			this.beginFill(rectCol,a*.3);
			if ( r != 0 )
			{
				cr = r-2;
				r = r-1;
			}
			else
			{
				cr = 0;
				r = 0
			}
			this.drawRoundRect(0+1,0+1,w-2,h-2,r);
			this.drawRoundRect(2,2,w-4,h-4,cr)
			this.endFill();
		}
	}

	function handleEvent(e:Object):Void
	{
		if (e.type == "unload")
			this._visible = true;
		else if (e.type == "resize")
			e.target.adjustFocusRect();
		else if (e.type == "move")
			e.target.adjustFocusRect();

	}

	static function classConstruct():Boolean
	{
		UIComponent.prototype.drawFocus = function(focused)
		{
			var o = this._parent.focus_mc;
			if (!focused)
			{
				// return the component to its original depth
				// hide the focus object
				o._visible = false;
				this.removeEventListener("unload", o);
				this.removeEventListener("move", o);
				this.removeEventListener("resize", o);
			}
			else
			{
				// slide a rectangle behind the component by creating the focus rect on the parent
				if (o == undefined)
				{
					o = this._parent.createChildAtDepth("FocusRect", DepthManager.kTop);
					o.tabEnabled = false;
					this._parent.focus_mc = o;
				}
				else
					o._visible = true;
				// swapping depths so it goes behind the item
				// make it just a hair larger and center it
				o.draw(this);
				if (o.getDepth() < this.getDepth())
					o.setDepthAbove(this);
				this.addEventListener("unload", o);
				this.addEventListener("move", o);
				this.addEventListener("resize", o);
			}
		}
		UIComponent.prototype.adjustFocusRect = function()
		{
			var rectCol = this.getStyle("themeColor");
			if (rectCol==undefined)
				rectCol = 0x80ff4d;

			var o = this._parent.focus_mc;
			o.setSize(this.width + 4, this.height + 4, 0, 100, rectCol);
			o.move(this.x - 2, this.y - 2);
		}

		TextField.prototype.drawFocus = UIComponent.prototype.drawFocus;
		TextField.prototype.adjustFocusRect = UIComponent.prototype.adjustFocusRect;

		FocusRect.prototype.drawRoundRect = Defaults.prototype.drawRoundRect;

		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var DefaultsDependency:Defaults = Defaults;
	static var UIComponentDependency:UIComponent = UIComponent;

}

