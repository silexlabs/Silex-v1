//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
* factory for adding CSS Text styles to StyleDeclarations and UIObject
*/
class mx.styles.CSSTextStyles
{
	static function addTextStyles(o:Object, bColor:Boolean):Void
	{
/**
* the text alignment or justification.  Allowed values are "left", "center", "right"
*
* @tiptext
* @helpid 3336
*/
		o.addProperty("textAlign", function() { return this._tf.align; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.align = x; });

/**
* the font weight.  Allowed values are: "none", "bold"
*
* @tiptext
* @helpid 3337
*/
		o.addProperty("fontWeight", function() { return (this._tf.bold != undefined) ? (this._tf.bold ? "bold" : "none") : undefined},
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.bold = (x == "bold"); });

/**
* the font color.  Allowed values are colors in the form of 0xRRGGBB (0xFF0000 is red).
*
* @tiptext
* @helpid 3338
*/
		if (bColor)
			o.addProperty("color", function() { return this._tf.color; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.color = x; });

/**
* the font family.  Allowed values are font names like "Times New Roman" or "Arial"
*
* @tiptext
* @helpid 3339
*/
		o.addProperty("fontFamily", function() { return this._tf.font; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.font = x; });

/**
* the number of pixels to indentation the first line of a paragraph
*
* @tiptext
* @helpid 3340
*/
		o.addProperty("textIndent", function() { return this._tf.indent; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.indent = x; });

/**
* the font style.  Allowed values are: "none", "italic"
*
* @tiptext
* @helpid 3341
*/
		o.addProperty("fontStyle", function() { return (this._tf.italic != undefined) ? (this._tf.italic ? "italic" : "none") : undefined},
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.italic = (x == "italic"); });

/**
* the number of pixels to the left of the text
*
* @tiptext
* @helpid 3342
*/
		o.addProperty("marginLeft", function() { return this._tf.leftMargin; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.leftMargin = x; });

/**
* the number of pixels to the right of the text
*
* @tiptext
* @helpid 3343
*/
		o.addProperty("marginRight", function() { return this._tf.rightMargin; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.rightMargin = x; });

/**
* the font size.  Allowed values are numbers 6 and higher.
*
* @tiptext
* @helpid 3344
*/
		o.addProperty("fontSize", function() { return this._tf.size; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.size = x; });

/**
* the text decoration.  Allowed values are: "none", "underline"
*
* @tiptext
* @helpid 3345
*/
		o.addProperty("textDecoration", function() { return (this._tf.underline != undefined) ? (this._tf.underline ? "underline" : "none") : undefined},
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.underline = (x == "underline"); });


/**
* whether to embed fonts or use device fonts.  "true" embeds fonts, making them look better
* and allowing them to be drawn at different angles, but making the download larger.
* "false" uses device fonts which cannot be drawn at an angle and if the user doesn't
* have the exact font on their system will approximate the font, but makes the download smaller.
*
* @tiptext
* @helpid 3346
*/
		o.addProperty("embedFonts", function() { return this._tf.embedFonts; },
								function(x) { if (this._tf == undefined) this._tf = new TextFormat();
											  this._tf.embedFonts = x; });

	}
}
