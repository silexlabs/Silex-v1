//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.styles.CSSStyleDeclaration;
import mx.core.ext.UIObjectExtensions;
import mx.core.UIObject;

class mx.skins.sample.Defaults
{
	var lineTo:Function;
	var curveTo:Function;
	var moveTo:Function;
	var beginFill:Function;
	var endFill:Function;
	var beginGradientFill:Function;

	static function setThemeDefaults():Void
	{
		var o = _global.style;
		o.disabledColor = 0x848284;
		o.modalTransparency = 0;// completely transparent

		o.filled = true;
		o.stroked = true;
		o.strokeWidth = 1;
		o.strokeColor = 0x000000;
		o.fillColor = 0xffffff;
		o.repeatInterval = 35;	// fast.
		o.repeatDelay = 500;	// half second.

		o.fontFamily = "_sans";
		o.fontSize = 12;

		o.selectionColor = 0xeeeeee;
		o.rollOverColor =  0xaaaaaa;
		o.useRollOver = true;

		o.backgroundDisabledColor = 0xdddddd;
		o.selectionDisabledColor = 0xdddddd;
		o.selectionDuration = 200;
		o.openDuration = 250;
		o.borderStyle = "inset";

		o.color = 0x000000;
		o.backgroundColor = 0xffffff;
		o.textSelectedColor = 0x005f33;
		o.textRollOverColor = 0x2b333c;
		o.textDisabledColor = 0xffffff;

		o.vGridLines = true;
		o.hGridLines = false;
		o.vGridLineColor = 0x666666;
		o.hGridLineColor = 0x666666;
		o.headerColor = 0xeaeaea;
		o.indentation = 17;
		o.folderOpenIcon = "TreeFolderOpen";
		o.folderClosedIcon = "TreeFolderClosed";
		o.defaultLeafIcon = "TreeNodeIcon";
		o.disclosureOpenIcon = "TreeDisclosureOpen";
		o.disclosureClosedIcon = "TreeDisclosureClosed";
		o.popupDuration = 150;

		o.todayColor = 0x666666;

		// default styles for various classes. other
		// properties are set on the ListAssets symbol
		o = _global.styles.ScrollSelectList = new CSSStyleDeclaration();
		o.backgroundColor = 0xffffff;
		o.borderStyle = "inset";

		o = _global.styles.Button = new CSSStyleDeclaration();
		o.buttonColor = 0xEFEBEF;
		o.borderColor = 0xEFEBEF;
		o.highlightColor = 0xffffff;
		o.shadowColor = 0x636363;
		o.borderColor = 0x000000;

		o = _global.styles.NumericStepper = new CSSStyleDeclaration();
		o.textAlign = "center";

		o = _global.styles.RectBorder = new CSSStyleDeclaration();
		o.borderColor = 0xd5dddd;
		o.buttonColor =  0x6f7777;
		o.shadowColor =  0xEEEEEE;
		o.highlightColor = 0xc4cccc;

		var p = new Object();
		p.borderColor = 0xFF0000;
		p.buttonColor = 0xFF0000;
		p.shadowColor = 0xFF0000;
		p.highlightColor = 0xFF0000;

		mx.core.UIComponent.prototype.origBorderStyles = p;

		var x;
		x = _global.styles.TextInput = new CSSStyleDeclaration();
		x.backgroundColor = 0xffffff;
		x.borderStyle = "inset";
		_global.styles.TextArea = _global.styles.TextInput;

		x = _global.styles.Window = new CSSStyleDeclaration();
		x.borderStyle = "outset";
		x.backgroundColor = 0xefebef;

		var q = _global.styles.windowStyles = new CSSStyleDeclaration();
		q.color = 0x000000;

		x = _global.styles.Alert = new CSSStyleDeclaration();
		x.borderStyle = "outset";
		x.backgroundColor = 0xefebef;

		x = _global.styles.ScrollView = new CSSStyleDeclaration();
		x.borderStyle = "inset";
		x.borderColor = 0xefefef;

		x = _global.styles.View = new CSSStyleDeclaration();
		x.borderStyle = "none";

		x = _global.styles.ProgressBar = new CSSStyleDeclaration();
		x.color = 0xAAB3B3;
		x.fontWeight = "bold";

	}

	function drawRoundRect(x,y,w,h,r,c,alpha,rot,grad)
	{
			// passing an object for r allows for different corner radii
			if (typeof r == "object") {
				var rbr = r.br //bottom right corner
				var rbl = r.bl //bottom left corner
				var rtl = r.tl //top left corner
				var rtr = r.tr //top right corner
			}else{
				var rbr =  rbl = rtl = rtr = r;
			}

			if(typeof c == "object"){
				var alphas = [alpha,alpha];
				var ratios = [ 0, 0xff ];
				var sh = h *.7

				var matrix = {matrixType:"box", x:-sh, y:sh, w:w*2, h:h*4, r:rot * 0.0174532925199433 }
				if (grad == "radial"){
					this.beginGradientFill( "radial", c, alphas, ratios, matrix );
				}else{
					this.beginGradientFill( "linear", c, alphas, ratios, matrix );
				}
			}else if (c != undefined) {
				this.beginFill (c, alpha);
			}

			// Math.sin and Math,tan values for optimal performance.
			// Math.rad = Math.PI/180 = 0.0174532925199433
			// r*Math.sin(45*Math.rad) =  (r*0.707106781186547);
			// r*Math.tan(22.5*Math.rad) = (r*0.414213562373095);

			//bottom right corner
			r = rbr;
			var a = r - (r*0.707106781186547); //radius - anchor pt;
			var s = r - (r*0.414213562373095); //radius - control pt;
			this.moveTo ( x+w,y+h-r);
			this.lineTo ( x+w,y+h-r );
			this.curveTo( x+w,y+h-s,x+w-a,y+h-a);
			this.curveTo( x+w-s,y+h,x+w-r,y+h);

			//bottom left corner
			r = rbl;
			var a = r - (r*0.707106781186547);
			var s = r - (r*0.414213562373095);
			this.lineTo ( x+r,y+h );
			this.curveTo( x+s,y+h,x+a,y+h-a);
			this.curveTo( x,y+h-s,x,y+h-r);

			//top left corner
			r = rtl;
			var a = r - (r*0.707106781186547);
			var s = r - (r*0.414213562373095);
			this.lineTo ( x,y+r );
			this.curveTo( x,y+s,x+a,y+a);
			this.curveTo( x+s,y,x+r,y);

			//top right
			r = rtr;
			var a = r - (r*0.707106781186547);
			var s = r - (r*0.414213562373095);
			this.lineTo ( x+w-r,y );
			this.curveTo( x+w-s,y,x+w-a,y+a);
			this.curveTo( x+w,y+s,x+w,y+r);
			this.lineTo ( x+w,y+h-r );

			if (c != undefined)
				this.endFill();
	}

	static function classConstruct():Boolean
	{

		UIObjectExtensions.Extensions();

		setThemeDefaults();

		UIObject.prototype.drawRoundRect = Defaults.prototype.drawRoundRect;


		return true;
	}
	static var classConstructed = classConstruct();
	static var CSSStyleDeclarationDependency = CSSStyleDeclaration;
	static var UIObjectExtensionsDependency = UIObjectExtensions;
	static var UIObjectDependency = UIObject;

}
