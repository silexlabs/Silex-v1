/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.managers.DepthManager;
import mx.utils.Delegate;
import org.oof.lists.CustomList;
/*
 * This list is for displaying a list of images, such as thumbnails for a gallery.
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * 
 * @author Ariel Sommeria-klein
 * @author Thomas Fétiveau (Żabojad) http://tofee.fr
 */
class org.oof.lists.ThumbList extends CustomList
{
	////////////////////////////
	// Group: constants (internal)
	////////////////////////////
	static var ALIGN_LEFT:String = "left";
	static var ALIGN_CENTER:String = "center";
	static var ALIGN_RIGHT:String = "right";
	static var ALIGN_TOP:String = "top";
	static var ALIGN_MIDDLE:String = "middle";
	static var ALIGN_BOTTOM:String = "bottom";
	
	
	////////////////////////////
	// Group: variables (internal)
	////////////////////////////
	/*
	Variable: _keepProportions
	Tells to the ThumbCellRenderer to keep the image proportion even while resizing the image
	*/
	private var _keepProportions:Boolean = false;
	
	/*
	Variable: _removeExtraRowHeight
	When using keepProportions but not useVariableRowHeight, this allows to remove the extra row 
	height that appears with images larger than longer (for non horizontal lists) or when images are 
	longer than larger (with horizontal lists)
	*/
	private var _removeExtraRowHeight:Boolean = false;
	
	/*
	Variable: _horizontalAlign
	Tells how to align horizontally the image when its width is smaller than the cell's width
	*/
	private var _horizontalAlign:String = ALIGN_CENTER;
	
	/*
	Variable: _verticalAlign
	Tells how to align vertically the image when its height is smaller than the cell's height
	*/
	private var _verticalAlign:String = ALIGN_MIDDLE;
	
	/*
	Variable: _resizeImages
	Tells to resize the image to fit to the cells dimensions
	*/
	private var _resizeImages:Boolean = false;
	
	/*
	*/
	private var _urlPrefix:String = null;
	
	/*
	*/
	private var _urlPrefixWithAccessors:String = null;

	/*
	Function: ThumbList
	The ThumbList's constructor.
	*/
	function ThumbList()
	{
		super();
		typeArray.push("org.oof.lists.ThumbList");
		if(_cellRenderer == "")
		{
			_cellRenderer = "ThumbCellRenderer";	
		}
	}
	
	/*
	Function: setCellSize
	Override setCellSize method to support the removeExtraRowHeight parameter
	*/
	function setCellSize(cell_mc, _itemsPerRow, _fixedRowHeight):Void
	{
		// We should not do anything in case of active _removeExtraRowHeight parameter (parameter set to true + conditions so that it will be used)
		if( _useVariableRowHeight || !_removeExtraRowHeight && ( _resizeImages && _keepProportions || !_resizeImages ) )
		{
			super.setCellSize(cell_mc, _itemsPerRow, _fixedRowHeight);
		}
	}
	
	/*
	Function: setRowSize
	Override setRowSize method to support the removeExtraRowHeight parameter.
	*/
	function setRowSize(row,  maxCellColumnDim):Void
	{
		// we just override this first condition
		if(_useVariableRowHeight || _removeExtraRowHeight && (_resizeImages && _keepProportions || !_resizeImages) )
		{
			//set row depth to max depth of contained cells	
			if(!_isHorizontal)
			{				
				row.setSize(row.width, maxCellColumnDim);
			}
			else
			{
				row.setSize(maxCellColumnDim, row.height);
			}
		}
		else
		{
			if(!isHorizontal)
			{
				row.setSize(this.width, _fixedRowHeight);
			}
			else
			{
				row.setSize(_fixedRowHeight, this.height);
			}
		}
	}

	/*
	 * function set urlPrefix
	 * @param val(String)
	 * @returns void
	 */
	[Inspectable(name="url base", type=String, defaultValue="")]
	public function set urlPrefix(val:String)
	{
		_urlPrefix = val;
		_urlPrefixWithAccessors = silexPtr.utils.revealAccessors (_urlPrefix, this);
	}
	/*
	* function get urlPrefix
	* @returns String
	*/
	public function get urlPrefix():String
	{
		return _urlPrefix;
	}
	
	/*
	* function set resizeImages
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set resizeImages(val:Boolean)
	{
		_resizeImages = val;
		redraw();
	}
	/*
	* function get resizeImages
	* @returns Boolean
	*/
	public function get resizeImages():Boolean
	{
		return _resizeImages;
	}
	
	/*
	* Function: set keepProportions
	* Parameters:
	*	val - Boolean
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set keepProportions(val:Boolean)
	{
		_keepProportions = val;
		redraw();
	}
	/*
	* Function: get keepProportions
	* Returns:
	* The boolean value of the keepProportions parameter
	*/
	public function get keepProportions():Boolean
	{
		return _keepProportions;
	}
	
	/* 
	* Function: set removeExtraRowHeight
	* Parameters:
	*	val - Boolean
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set removeExtraRowHeight(val:Boolean)
	{
		_removeExtraRowHeight = val;
		redraw();
	}
	/*
	* Function: get removeExtraRowHeight
	* Returns:
	* The boolean value of the removeExtraRowHeight parameter
	*/
	public function get removeExtraRowHeight():Boolean
	{
		return _removeExtraRowHeight;
	}
	
	/* 
	* Function: set horizontalAlign
	* Parameters:
	*	val - String
	*/
	[Inspectable(type = String, defaultValue = ALIGN_CENTER)]
	public function set horizontalAlign(val:String)
	{
		_horizontalAlign = val;
	}
	/*
	* Function: get horizontalAlign
	* Returns:
	* The String value of the horizontalAlign parameter
	*/
	public function get horizontalAlign():String
	{
		return _horizontalAlign;
	}
	
	/* 
	* Function: set verticalAlign
	* Parameters:
	*	val - String
	*/
	[Inspectable(type = String, defaultValue = ALIGN_MIDDLE)]
	public function set verticalAlign(val:String)
	{
		_verticalAlign = val;
	}
	/*
	* Function: get verticalAlign
	* Returns:
	* The String value of the verticalAlign parameter
	*/
	public function get verticalAlign():String
	{
		return _verticalAlign;
	}
}