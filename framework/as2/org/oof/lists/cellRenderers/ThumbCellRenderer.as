/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/import mx.utils.Delegate;import org.oof.OofBase; import org.oof.lists.cellRenderers.CellRendererBase;
import org.oof.lists.ThumbList;/*
 * Companion cell renderer for the thumb list.
 * * @author Ariel Sommeria-klein
 * @author Thomas Fétiveau (Żabojad) http://tofee.fr
 * TODO cout the LoadInit and LoadError and call refreshCellsAndRows only once when we have them all
 */class org.oof.lists.cellRenderers.ThumbCellRenderer extends CellRendererBase
{	/*
	Variable: _loadedIcon
	This variable is used to check if the icon field changed.
	*/	private var _loadedIcon:String = null;
	
	/*
	Variable: _mcLoader
	The MovieClipLoader used to load the thumb image.
	*/	private var _mcLoader:MovieClipLoader = null;
	
	/*
	Variable: container
	The MovieClip in which will be loaded the thumb image.
	*/	var container:MovieClip;
	/*
	Function: ThumbCellRenderer
	The ThumbCellRenderer's constructor.
	*/	function ThumbCellRenderer()
	{		super();		_mcLoader = new MovieClipLoader();		_mcLoader.addListener(this);		//container.useHandCursor = false;		// container._xscale = 100;		// container._yscale = 100;//		container.useHandCursor = listOwner._useHandCursor;	}
	/*
	Function: setValue
	We call the loadClip function for the cell here
	*/	function setValue(str:String, item:Object, sel:Boolean) : Void
	{		super.setValue(str, item, sel);		//if this isn't checked , image is reloaded on every click. 		if(icon != _loadedIcon)
		{			//_mcLoader.unloadClip(container);			// display icon			var url:String = listOwner._urlPrefixWithAccessors + icon;			if(url == undefined)
			{
						}
			
			// Reset scales (necessary in case of an already existing cell re-used for another thumb)
			container._xscale = 100;
			container._yscale = 100;
			// Reset the size inherited fom the list parameters
			if(!listOwner.isHorizontal)
			{
				setSize( listOwner.width / listOwner._itemsPerRow , listOwner._fixedRowHeight );
			}
			else
			{
				setSize( listOwner._fixedRowHeight , listOwner.height / listOwner._itemsPerRow );
			}
						var ret = _mcLoader.loadClip(url, container);			if(!ret)
			{				throw new Error(this + " problem loading image from url : " + icon);			}			_loadedIcon = icon;		}	}
	
	/*
	Function: redrawThumb
	update the image and cell's dimensions.
	*/
	function redrawThumb():Void
	{
		if(listOwner.resizeImages)
		{
			// The dimensions of the available space for the image in the cells
			var availableHeight:Number;
			var availableWidth:Number;
			
			// the available space's dimensions depend on the useVariableRowHeight option.
			if(listOwner.useVariableRowHeight)
			{
				if(!listOwner.isHorizontal)
				{
					availableHeight = container._height - _cellMarginY * 2;
					availableWidth = width - _cellMarginX * 2;
				}
				else
				{
					availableHeight = height - _cellMarginY * 2;
					availableWidth = container._width - _cellMarginX * 2;
				}
			}
			else
			{
				// case with fixed row height
				availableWidth = width - _cellMarginX * 2;
				availableHeight = height - _cellMarginY * 2;
			}
			
			// we don't want negative values for cell's height and width
			if(availableHeight < 0) availableHeight = 0;
			if(availableWidth < 0) availableWidth = 0;
			
			// Now we resize the container (the image) itself
			if(!listOwner.keepProportions)
			{
				// If keepProportions not set, the cell dimensions minus the margins will be the image dimensions
				container._height = availableHeight;
				container._width = availableWidth;
			}
			else
			{
				// the resize rate common to width and height
				var resizeRate:Number;
				
				// The smallest resize rate is the one we gonna use
				(availableWidth/container._width < availableHeight/container._height) ? resizeRate = availableWidth/container._width : resizeRate = availableHeight/container._height;
				
				// we resize the MovieClip loading the image
				container._height = resizeRate * container._height;
				container._width = resizeRate * container._width;
			}
		}
		
		// adapt the row height if variable. The row height depends on the container (image)'s dimensions.
		if(listOwner.useVariableRowHeight || listOwner.keepProportions && listOwner.removeExtraRowHeight)
		{
			if(!listOwner.isHorizontal)
			{
				setSize( width , (container._height + _cellMarginY * 2) );
			}
			else
			{
				setSize( (container._width + _cellMarginX * 2) , height );
			}
		}
	}
		///////////////////////////////////////	// listeners for the mcloader	///////////////////////////////////////
	/*
	Function: onLoadProgress
	Invoked as the loading process progresses. 
	*/
	function onLoadProgress(target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void {	}
	
	/*
	Function: onLoadComplete
	Invoked when a file completes downloading, but before the loaded movie clip's methods and properties are available. This handler is called before the onLoadInit handler.
	*/	function onLoadComplete(target_mc:MovieClip, httpStatus:Number):Void { }
	/*
	Function: onLoadInit
	Called when the Image has been initiated. We resize and position the image here. If useVariableRowHeight is set to true on the list, we also resize the cell here.
	*/	function onLoadInit(target_mc:MovieClip)
	{
		// we redraw the cell and its thumb		redrawThumb();
		
		// we invalidate our list for redraw
		listOwner.invalidate();	}		
	/*
	Function: onLoadError
	Invoked if the clip (the thumb) cannot be loaded.
	*/	function onLoadError(target_mc:MovieClip, errorCode:String, httpStatus:Number)
	{
		// we throw the error
		throw new Error("ThumblistCellRenderer error "+errorCode+" while loading the thumb "+_loadedIcon);
				// we set the cells dimensions to 0
		setSize(0,0);
		
		// we invalidate our list for redraw
		listOwner.invalidate();	}	
	/*
	Function: redraw
	Redraw the Thumblist.
	*/	function redraw()	{		super.redraw();
		
		// we manage here the container (image) alignment
		// horizontally
		if(listOwner.horizontalAlign == ThumbList.ALIGN_LEFT || !listOwner.keepProportions)
		{
			container._x = _cellMarginX;
		}
		else if(listOwner.horizontalAlign == ThumbList.ALIGN_RIGHT)
		{
			container._x = width -  container._width - _cellMarginX;
		}
		else
		{
			// default case: center
			container._x = (width - container._width) / 2;
		}
		// and vertically
		if(listOwner.verticalAlign == ThumbList.ALIGN_TOP || !listOwner.keepProportions)
		{
			container._y = _cellMarginY;
		}
		else if(listOwner.verticalAlign == ThumbList.ALIGN_BOTTOM)
		{
			container._y = height - container._height - _cellMarginY;
		}
		else
		{
			//default case: middle
			container._y = ( height - container._height) / 2;
		}	}}