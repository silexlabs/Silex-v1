/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.lists.cellRenderers.CellRendererBase; 

/** this is the companion cell renderer to the rich text list. You must have this in
 * your library if you want your rich text list to function.
 * @author Ariel Sommeria-klein
 * */
class org.oof.lists.cellRenderers.RichTextCellRenderer extends CellRendererBase{
	
	// UI
	var ioTextField:TextField;
	/**
	 * a text field visible only on roll over
	 * if it does not exist in the .fla then it is ignored
	 */
	var ioTextFieldOver:TextField;
	
	/**
	 * a text field visible only when cell is selected
	 * if it does not exist in the .fla then it is ignored
	 */
	var ioTextFieldSelected:TextField;
	
	//setting ioTextField.htmlText doesn't work properly. So use ioTextField.variable as a workaround
	var textHolder:String;
	
	/**
	 * constructor
	 * init the text fields
	 */
	function RichTextCellRenderer(){
		super();
		
		// init the textfield
		initTextField(ioTextField);
		
		if (ioTextFieldOver)
		{
			// init the over textfield
			initTextField(ioTextFieldOver);
			// hide the over text field
			ioTextFieldOver._visible = false;
		}
			
		if (ioTextFieldSelected)
		{
			// init the selected textfield
			initTextField(ioTextFieldSelected);
			// hide the selected text field
			ioTextFieldSelected._visible = false;
		}

	}
	function initTextField(tf:TextField):Void 
	{
		tf.variable = "textHolder";
		tf.html = listOwner.html;
		tf.autoSize = listOwner.autoSize;
		tf.wordWrap = listOwner.wordWrap;
		tf.embedFonts = listOwner.embedFonts;
		//for testing
		//ioTextField.border = true;		

		//This is because setting a dynamic text field's text somehow loses the text formating, and this somehow fixes it
		//see http://bobspace.wordpress.com/2006/09/28/flash-yourmomgettextformat-is-the-key-to-letterspacing/
		var fmt:TextFormat = tf.getTextFormat();
		tf.setTextFormat(fmt);
		tf.setNewTextFormat(fmt); 		
	}

	function setValue(str:String, item:Object, sel:Boolean) : Void{
		
		super.setValue(str, item, sel);		

		textHolder = str;
		
		// selection text color
		if (ioTextFieldSelected)
		{
			ioTextFieldSelected._visible = _isSelected;
			ioTextField._visible = !_isSelected;
		}
		redrawTextFields();
	}
	/**
	 * update position and size of a textField (ioTextField, ioTextFieldSelected or ioTextFieldOver)
	 * for an horizontal list with variable row height
	 */
	function redrawTextFieldHorizontalVariableSize(tf:TextField):Void 
	{
		//height of cell depends on height of textfield, width determined by cell
		var vHeight:Number = height - _cellMarginY * 2;
		tf._height = vHeight;
		
		// update cell width
		var newVal = tf._width + _cellMarginX * 2;
		setSize(newVal, height);		
	}
	/**
	 * update position and size of a textField (ioTextField, ioTextFieldSelected or ioTextFieldOver)
	 * for an vertical list with variable row height
	 */
	function redrawTextFieldVerticalVariableSize(tf:TextField):Void 
	{
		var vWidth:Number = width - _cellMarginX * 2;
		tf._width = vWidth;
		
		// update cell height
		var newVal = tf._height + _cellMarginY * 2;
		setSize(width, newVal);
	}
	/**
	 * update position and size of a textField (ioTextField, ioTextFieldSelected or ioTextFieldOver)
	 * for a list with fixed row height
	 */
	function redrawTextFieldFixedSize(tf:TextField):Void 
	{
		tf._width = width - listOwner.cellMarginX * 2;
		tf._height = height - listOwner.cellMarginY * 2;
		
		var wantedTFWidth = width - listOwner.cellMarginX * 2;
		tf._width = wantedTFWidth;
	}
	/**
	 * redraw a cell: update position and size of textFields
	 */
	function redraw()
	{
		super.redraw();
	}
	/**
	 * update position and size of a textFields
	 */
	function redrawTextFields()
	{
		if (listOwner.useVariableRowHeight)
		{
			if (listOwner.isHorizontal)
			{
				redrawTextFieldHorizontalVariableSize(ioTextField);
				// update the over textfield
				if (ioTextFieldOver)
					redrawTextFieldHorizontalVariableSize(ioTextFieldOver);

				// update the selected textfield
				if (ioTextFieldSelected)
					redrawTextFieldHorizontalVariableSize(ioTextFieldSelected);
			}
			else
			{
				redrawTextFieldVerticalVariableSize(ioTextField);
				// update the over textfield
				if (ioTextFieldOver)
					redrawTextFieldVerticalVariableSize(ioTextFieldOver);
				// update the selected textfield
				if (ioTextFieldSelected)
					redrawTextFieldVerticalVariableSize(ioTextFieldSelected);
			}
		}
		else
		{
			// fixed width and height
			redrawTextFieldFixedSize(ioTextField);
			// update the over textfield
			if (ioTextFieldOver)
				redrawTextFieldFixedSize(ioTextFieldOver);
			// update the selected textfield
			if (ioTextFieldSelected)
				redrawTextFieldFixedSize(ioTextFieldSelected);
		}
		
		// adapt textfield position
		ioTextField._x = listOwner.cellMarginX;
		ioTextField._y = listOwner.cellMarginY;
		if (ioTextFieldOver)
		{
			ioTextFieldOver._x = listOwner.cellMarginX;
			ioTextFieldOver._y = listOwner.cellMarginY;
		}
		if (ioTextFieldSelected)
		{
			ioTextFieldSelected._x = listOwner.cellMarginX;
			ioTextFieldSelected._y = listOwner.cellMarginY;
		}
		//setting textfield width doesn't always work. Ok in Flash8, not in Flash7.
		//use this ack if you need centered text and are publishing in Flash 7.
		//note: the Flash 7 issue is the reason the rich text list must be published in Flash 8!
/*		if (listOwner.autoSize == "center")
		{
			ioTextField._x = (width - ioTextField._width) * 0.5;
			if (ioTextFieldOver)
				ioTextFieldOver._x = ioTextField._x;
			if (ioTextFieldSelected)
				ioTextFieldSelected._x = ioTextField._x;
		}
*/		
	}
	/**
	 * override onRollOut behaviour for text formating
	 */
	function onRollOutCallback()
	{
		super.onRollOutCallback();
		if (_isSelected)
		{
			if (ioTextFieldSelected)
			{
				ioTextFieldSelected._visible = true;
				ioTextField._visible = false;
			}
			else
			{
				ioTextField._visible = true;
			}
			if (ioTextFieldOver)
			{
				ioTextFieldOver._visible = false;
			}
		}
		else
		{
			if (ioTextFieldOver)
			{
				ioTextFieldOver._visible = false;
			}
			ioTextField._visible = true;
		}
	}
	/**
	 * override onRollOver behaviour for text formating
	 */
	function onRollOverCallback()
	{
		super.onRollOverCallback();
		
		if (ioTextFieldOver)
		{
			ioTextFieldOver._visible = true;
			ioTextField._visible = false;
		}
		else
			ioTextField._visible = true;
			
		if (ioTextFieldSelected)
			ioTextFieldSelected._visible = false;
	}

}