//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIComponent;

// extensions to TextField so they look more like UIComponents
class mx.core.ext.UIComponentExtensions
{
	static var bExtended = false;

	static function Extensions():Boolean
	{
		if (bExtended == true)
			return true;

		bExtended = true;

		TextField.prototype.setFocus = function()
		{
			Selection.setFocus(this);
		}

		TextField.prototype.onSetFocus = function(oldFocus)
		{
			if (this.tabEnabled != false)
			{
				if (this.getFocusManager().bDrawFocus)
					this.drawFocus(true);
			}
		}

		TextField.prototype.onKillFocus = function(oldFocus)
		{
			if (this.tabEnabled != false)
			{
				this.drawFocus(false);
			}
		}

		TextField.prototype.drawFocus = UIComponent.prototype.drawFocus;
		TextField.prototype.getFocusManager = UIComponent.prototype.getFocusManager;

		mx.managers.OverlappedWindows.enableOverlappedWindows();
		mx.styles.CSSSetStyle.enableRunTimeCSS();	// this doesn't need a dependency
		mx.managers.FocusManager.enableFocusManagement();

	}

 	static var UIComponentExtended = Extensions();
   	static var UIComponentDependency = mx.core.UIComponent;
   	static var FocusManagerDependency = mx.managers.FocusManager;
   	static var OverlappedWindowsDependency = mx.managers.OverlappedWindows;
}
