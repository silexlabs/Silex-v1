﻿/*This file is part of Oof - see http://projects.silexlabs.org/?/oofOof is © 2010-2011 Silex Labs and is released under the GPL License:This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.To read the license please visit http://www.gnu.org/copyleft/gpl.html*/import mx.utils.Delegate;import org.oof.OofBase; import mx.events.EventDispatcher;/*  base class for all oof cell renderers. This is based on the CellRenderer API defined * in the mx documentation. * Historically this class inherits from mx.core.UIComponent, but since 12/10 this creates issues, so copy the necessary bits here. A.S. *  * when creating it, be sure to pass the different init elements as an init object as parameter, * so that they can be used in the constructor. * example : * 	var initObj = new Object(); * 	initObj.listOwner = this; * 	initObj.owner = row; * 	initObj.getCellIndex = getCellIndex; * 	newCell = row.attachMovie(cellRenderer, getNextHighestDepth(), initObj); * * @author Ariel Sommeria-klein*/class org.oof.lists.cellRenderers.CellRendererBase extends MovieClip{		var listOwner : MovieClip; // the reference we receive to the list	var owner:MovieClip; // reference to the row movieclip	var getCellIndex : Function; // the function we receive from the list	var	getDataLabel : Function; // the function we receive from the list		// UI	var bg_btn:Button;	var selected_mc:MovieClip;		//	var label:String = "";	var data:Object = null;	var icon:String;	// constants, override in child class if needed	var _preferredHeight:Number = 44;	var _preferredWidth:Number = 44;		//defaults. if listOwner is org.oof.lists.CustomList, they are overridden by values set in the list params.	var _cellMarginX:Number = 10;	var _cellMarginY:Number = 10;		// these hold the actual values for the getter-setters	var __width:Number;	var __height:Number;		//EventDispatcher	var addEventListener:Function;	var removeEventListener:Function;	var dispatchEvent:Function;			private var _firstSetValueDone:Boolean = false;		/*	Variable: _isSelected	Stores the information about the selection state of the cell	*/	private var _isSelected:Boolean = false;		/**	 * constructor	 * init the background clips	 */	function CellRendererBase(Void)	{		super();		EventDispatcher.initialize(this);		__width = _width;		__height = _height;		// retrieve click zone		var click_obj:Object;		if (bg_btn)			click_obj = bg_btn;		else			click_obj = this;				// attach events		click_obj.onPress = Delegate.create(this,onPressCallback);		click_obj.onRelease = Delegate.create(this,onReleaseCallback);		click_obj.onRollOver = Delegate.create(this,onRollOverCallback);		click_obj.onRollOut = Delegate.create(this,onRollOutCallback);		click_obj.onReleaseOutside = Delegate.create(this,onReleaseOutsideCallback);		click_obj.useHandCursor = listOwner._useHandCursor;				onMouseMove = Delegate.create(this,onMouseMoveCallback);		if(listOwner.cellMarginX != undefined)		{			_cellMarginX = listOwner.cellMarginX;		}		if(listOwner.cellMarginY != undefined)		{			_cellMarginY = listOwner.cellMarginY;		}	}		/*	Function: getOneDimIndex	Convert a multi-dim index to 1-dim index	*/	function getOneDimIndex()	{		var cellIndex = getCellIndex();		var itemsPerRow = listOwner.itemsPerRow;				if(itemsPerRow  == undefined)		{			// most cases			itemsPerRow = 1;		}		return cellIndex.itemIndex * itemsPerRow + cellIndex.columnIndex;	}		/////////////////////////	// Events callbacks	/////////////////////////	function onPressCallback()	{		listOwner.dispatch( { type: "onPress", index: getOneDimIndex(), target: listOwner } );	}	function onMouseMoveCallback()	{		// we don't use dispatch here, it would be too performance expensive		listOwner.dispatchEvent( { type: "itemMouseMove", index: getOneDimIndex(), target: listOwner } );	}	function onRollOutCallback()	{		listOwner.dispatch( { type: "itemRollOut", index: getOneDimIndex(), target: listOwner } );	}	function onRollOverCallback()	{		listOwner.dispatch( { type: "itemRollOver", index: getOneDimIndex(), target: listOwner } );	}	function onReleaseCallback()	{		if(_isSelected)		{			//already selected. do nothing			return;		}		if(listOwner.multipleSelection)		{			var indices = listOwner.selectedIndices;						indices.push(getOneDimIndex());			//explicitly call the setter function, otherwise its code won't be called			listOwner.selectedIndices = indices;		}		else		{			listOwner.selectedIndex = getOneDimIndex();		}				listOwner.dispatch( { type: "onRelease", target: listOwner});	}	function onReleaseOutsideCallback() { }		/*	Function: setupWithListOwner	called by parent after creation and setting of different callback elements 	*/	function setupWithListOwner() {	}	// note that setSize is implemented by UIComponent and calls size(), after setting	// __width and __height		public function setValue(str:String, item:Object, sel:Boolean) : Void	{/*trace(this  + "setValue "+str);for (var idx in item){	trace(idx+"->"+item[idx]);}trace("selected : " + sel);/**/		//data 		data = item.data;				//icon must be here!		this.icon = item.icon;				if (item == undefined)		{			_visible = false;			return;		}		// visible if there is data		_visible = true;				// selected item?		selected = sel;				redraw();	}	function getPreferredHeight(Void) : Number	{		return _preferredHeight;	}	function getPreferredWidth(Void) : Number	{		return _preferredWidth;	}		/**	 * redraw a cell: update position and size of the background clips	 */	function redraw()	{		selected_mc._width = bg_btn._width = width;		selected_mc._height = bg_btn._height = height;		selected_mc._x = selected_mc._y = bg_btn._x = bg_btn._y = 0;	}		/*	Function: set selected	The setter for _isSelected.	*/	function set selected(sel:Boolean):Void	{		// By default, for most cellRenderers, we display the selected_mc (if not, please override this method in your custom CellRenderer)		selected_mc._visible = sel;				// we store the _isSelected value		_isSelected = sel;	}		/**	 * width of object	 */	function get width():Number	{		return __width;	}		/**	 * height of object	 */	function get height():Number	{		return __height;	}		function setSize(w:Number, h:Number, noEvent:Boolean):Void	{		var oldWidth:Number = __width;		var oldHeight:Number = __height;				__width = w;		__height = h;		redraw();	}	}