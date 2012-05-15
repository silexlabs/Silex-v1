/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

// for sortItem etc, look at mx.controls.listclasses.DataSelector
import mx.controls.listclasses.DataProvider;
import mx.transitions.Tween;
import mx.transitions.easing.*;
import org.oof.OofBase;
import org.oof.lists.ListRow;

/////////////////////////////////////////
// events available for use in
// * ActionScript (event listeners)
// * SILEX (commands)
/////////////////////////////////////////
[Event("change")]
[Event("modelChanged")]
[Event("scroll")]
[Event("onRelease")]
[Event("itemRollOut")]
[Event("itemRollOver")]
[Event("itemMouseMove")]

/** 
 * class: org.oof.lists.CustomList
 * this is the base class for oof lists, that follows the mx list API as closely as possible. The 
 * whole API is not implemented, and in some cases it has been extended. 
 * See 
 * 
 * http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00003157.html#wp3707580
 * 
 * 
 * for the Adobe list, and explanations on the method details.
 * A list based on this class can have variable row heights, and 2 dimensions.  
 * There are a fixed number of items per row, and if necessary it is possible to scroll the rows
 * Here a row is considered horizontal if the list is vertical,
 * but vertical if the list is horizontal.
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * 
 * The list is composed of an array of rows, each containing
 *  between 1 and itemsPerRow cells. 
 * 
 * You can set the list data with a data provider, and this sets
 * all the data needed in one go. This is useful for complex data rendering, and
 * data that is set dynamically, for example when it comes from a data selector.
 * If you want to use static data, you can use the labels, data, and icon arrays.
 * 
 * @author Ariel Sommeria-klein and Alexandre Hoyau
 *
*/
class org.oof.lists.CustomList extends OofBase
{
    /* 
	* Group: internal
	*/	
	//do mixin so that Arrays support the DataProvider API. It would be nice to get rid of this, but for now we need it
	static var dummyForMixin:Boolean = DataProvider.Initialize(Array);   
	///////////////////////////////////
	// Attributes
	///////////////////////////////////

	private var _itemsPerRow:Number = 1;
	private var _cellMarginX:Number = 20;
	private var _cellMarginY:Number = 10;
	
	//two dummy variables to get the compiler to accept the shitty scope thing with getCellIndex
	private var listOwner : MovieClip; // the reference we receive to the list
	private var owner:MovieClip; // reference to the row movieclip

	//default values for vertical list
	//should use UIObject.move, but too much of a pain for refresh
	private var _rowAxis:String = "_x";
	private var _columnAxis:String = "_y";

	//use these 2 only for reading! use setSize for setting. see UIObject. note no "_"
	private var _rowDim:String = "width"; 
	private var _columnDim:String = "height";
	
	private var _vPosition:Number = 0;
	private var _hPosition:Number = 0;

	private var _fixedRowHeight:Number = 0;	
	private var _useVariableRowHeight:Boolean = false;
	
	//////////////////
	// UI
	/*
	Variable: mask_mc
	The MovieClip used as a mask so that we do not see the cells out of the listContent
	*/
	private var mask_mc:MovieClip;
	
	/*
	Variable: listContent
	The MovieClip containing the rows of the list. It can be a clip loaded from an external swf (see _cellRendererLibUrl and _useRemoteCellRendererLib)
	*/
	private var listContent:MovieClip;
	
	/*
	Variable: _cellRendererMCLoader
	The MovieClipLoader used to load the external cellRenderer swf file into the listContent clip.
	*/
	private var _cellRendererMCLoader:MovieClipLoader = null;
	//
	////////////////////
	
	/*
	Variable: _cellRendererLibUrl
	The url of the cellRenderer's swf file to use if _useRemoteCellRendererLib is true
	*/
	private var _cellRendererLibUrl:String;
	
	/*
	Variable: _listContentSet
	Tells if the listContent clip is ready to be manipulated (in case of external cellRenderer, it's not always the case)
	*/
	private var _listContentSet:Boolean;
	
	/*
	Variable: _useRemoteCellRendererLib
	Tells if the cellRenderer to use is embedded in the list swf or not (external => need to load it)
	*/
	private var _useRemoteCellRendererLib:Boolean;
	
	/*
	Variable: _cellRenderer
	Assigns the cell renderer to use for each row of the list. This property must be a symbol linkage identifier. Any class used for this property must implement the CellRenderer API.
	*/
	private var _cellRenderer:String;

	private var _rows:Array = null; //an array that stores references to all the row movie clips, which themselves contain the cells
	
	private var _rowCount:Number = 0;

	private var _easingDuration:Number = 0;
	/** isHorizontal
	 * true if the list is horizontal
	 * false if the list is vertical
	 */
	 private var _isHorizontal:Boolean;

	/** selectedIndex
	 * the selected index of a list. last selected if multiple selection enabled
	 */
	private var _selectedIndex:Number = undefined; //start undefined, so no item selected by default
	/** selectedIndices
	 * the selected indices of a multiple-selection list, if multiple selection enabled
	 */
	private var _selectedIndices:Array = undefined; //start undefined, so no item selected by default

	/** _multipleSelection
	 * at the moment this is only used as information for the cell renderers, so that they know what
	 * to do on click. It does not forbid use of selectedIndices
	 */
	private var _multipleSelection:Boolean = false;


	/* __dataProvider
	 * data provider object
	 */
	private var __dataProvider:Array = null;

	private var _initialized:Boolean = false;
	//arrays to be used in simple cases to bypass the dataprovider
	private var _data : Array = null;
	private var _labels :Array = null;
	private var _icons :Array = null;

	//////////////////
	// group: public atributes
	// attributes from the mx.controls.listclasses.DataSelector class
	var lastSelID:Number;
	var lastSelected;
	/** labelField
	* specifies a field in each item to be used as display text.
	*/
	var labelField:String = "label";
	//////////////////
   	
	///////////////////////////////////
	// Methods
	///////////////////////////////////
	/** 
	* group: internal methods
	* */
	/*
	Function: CustomList
	Constructor of the CustomList class.	
	*/
	function CustomList()
	{
		super();
		_className = "org.oof.lists.CustomList";
		typeArray.push("org.oof.lists.CustomList");
		
		// initializations
		_rows = new Array();
		_selectedIndices = new Array();
		_useRemoteCellRendererLib = false;
		
		// set the mask invisble
		mask_mc._visible = false;
	}
   
	/**
	* function: indexToPos
	* takes an item index and converts to a row/column object
	* */
	private function indexToPos(i:Number):Object
	{
		var row = Math.floor(i / _itemsPerRow);
		var column = i - row * _itemsPerRow;
		return {row:row, column:column};
	}
	
	/**
	 * function: posToIndex
	 * converts a row and a column to an item index
	 * */
	private function posToIndex(row:Number, column:Number):Number
	{
		return row * _itemsPerRow + column;
	}
	
	/**
	* method to create a cell renderer. This is a separate method so that it can be overridden in a derived class
	*/
	private function createCellRenderer(row:ListRow, placeInRow:Number, initObj:Object):MovieClip
	{
		var ret = row.attachMovie(_cellRenderer,  "cell" + placeInRow, row.getNextHighestDepth() + placeInRow, initObj);
		if (!ret) throw(new Error("CustomList cell"+placeInRow+" creation error: There is not a symbol with linkage name "+_cellRenderer+" in the library!")); 
		return ret;
	}
	
	/**
	* method to destroy a cell renderer. Use it also when removing a row! 
	* This is a separate method so that it can be overridden in a derived class
	*/
	private function destroyCellRenderer(renderer:MovieClip):Void
	{
		renderer.removeMovieClip();
	}
	
	/**
	 * function: adjustCellsInRow
	 * This function adjusts the amount of cells in the row.
	 * This is mostly a delegate method for adjustCellsCount
	 * */
	private function adjustCellsInRow(row:ListRow, wantedNumCells:Number)
	{
		if(!row)
		{
			//sanity check, prevents an infintite loop if this happens
			return; 
		}
		var newCell:MovieClip = null;
		
		//there are never more cells than itemsPerRow. So use it as condition for loop
		for(var i = 0; i < _itemsPerRow; i++)
		{ 
			if(i < wantedNumCells)
			{
				//make sure there is a cell. if not, create it 
				if(row.cells[i] == undefined)
				{
					// create a new cell
					//init object: 
					var initObj = new Object();
					initObj.listOwner = this;
					initObj.owner = row;
					initObj.getCellIndex = getCellIndex;
					//set the dimensions and coordinates that won't move
					//column axis : cell is in a row that is already positionned. so 0.
					initObj[_columnAxis] = 0;
					// cell position and rowDim set here. Only degree of freedom is columnDim, 
					// done in its setValue method if the row has a variable height
					newCell = createCellRenderer(row, i, initObj);
					row.cells[i] = newCell;
				}
			}
			else
			{
				//make sure there is no cell. if there is, destroy it.
				if(row.cells[i] != undefined)
				{
					destroyCellRenderer(row.cells[i]);
					row.cells[i] = undefined;
				}
			}
		}
	}
	
	/**
	 * function: adjustCellsCount
	 * update the number of rows and cells in each row.
	 * 
	 * */
	private function adjustCellsCount()
	{
		// ** 
		// update the number of rows and cells
		
		if(__dataProvider == null)
		{
			return;
		}
		
		if(!_initialized)
		{
			return;
		}
		
		// store old row count
		var oldRowCount:Number = _rowCount;

		// compute the number of rows wanted 
		_rowCount = Math.ceil(__dataProvider.length / _itemsPerRow);
		//cells that should be in last row
		var cellsInLastRowCount = __dataProvider.length - (_rowCount - 1) * _itemsPerRow;
		

		if(_rowCount < oldRowCount)
		{
		// remove rows if necessary
			for(var i = _rowCount; i < oldRowCount; i++)
			{
				var row:ListRow = _rows[i];
				adjustCellsInRow(_rows[i], 0);
				row.removeMovieClip();
			}
			_rows.splice(_rowCount);
			if(_rowCount > 0)
			{
				adjustCellsInRow(_rows[_rowCount - 1], cellsInLastRowCount);
			}
		} 
		else if(_rowCount > oldRowCount)
		{
			//complete old last row if necessary
			if(oldRowCount > 0)
			{
				adjustCellsInRow(_rows[oldRowCount - 1], _itemsPerRow);
			}
			//add rows			
			var newRow:ListRow = null;
			for(var i = oldRowCount; i < _rowCount; i++)
			{
				newRow = ListRow(listContent.attachMovie("ListRow", "row" + i, listContent.getNextHighestDepth()));
				if (!newRow) throw(new Error("CustomList row creation error: There is not a symbol with linkage name \"ListRow\" in the library!")); 
				newRow.itemIndex = i;
				newRow.cells = new Array(_itemsPerRow);
				if(i != _rowCount  - 1)
				{
					adjustCellsInRow(newRow, _itemsPerRow);
				}
				else
				{
					adjustCellsInRow(newRow, cellsInLastRowCount);
				}
				
				newRow[_rowAxis] = 0; 
				_rows.push(newRow);
			}
		} 
		else
		{
			//rowCount doesn't change. So look at number of cells in last row, and adjust if necessary
			if(_rowCount > 0)
			{
				adjustCellsInRow(_rows[_rowCount - 1], cellsInLastRowCount);
			}
		}
	}
	
	private function setCellData(cell_mc:MovieClip, dataProviderIndex:Number)
	{
		// cell data
		var dataVal = __dataProvider[dataProviderIndex];
		if(!dataVal)
		{
			return;
		}
		var labelVal = dataVal[labelField];
		var isSelected:Boolean = false;
		var indicesLen = _selectedIndices.length;
		for(var k = 0; k < indicesLen; k++)
		{
			if(dataProviderIndex == _selectedIndices[k])
			{
				isSelected = true;
				break;
			}
		}
		var revealedLabelVal:String = silexPtr.utils.revealAccessors (labelVal, this);
		cell_mc.setValue(revealedLabelVal, dataVal, isSelected);
	}
	
	/**
	* function for derived classes. If an anim is running on a row, don't mess with it; let it run
	*/
	private function canPositionRow(row:ListRow):Boolean
	{
		return true;
	}
	
	/*
	Function: refreshRowsAndCells
	positions the rows and cells, and sets the cell
	contents. Each cell is an instance of the cellRenderer,
	that respects the cell renderer API.
	*/
	private function refreshRowsAndCells(doNotRefreshData:Boolean)
	{
		if(__dataProvider == null)
		{
			return;
		}
		
		if(!_initialized)
		{
			return;
		}
		
		if(!_listContentSet)
		{
			return;
		}
		
		var accumulatedRowHeights:Number = 0;
		for ( var i = 0 ; i < _rowCount ; i++ )
		{
			var row = _rows[i];
			if(canPositionRow(row))
			{
				//adjust row coordinates
				row[_columnAxis] = accumulatedRowHeights;
				var maxCellColumnDim:Number = 0;
				
				for( var j = 0 ; j < _itemsPerRow ; j++ )
				{
					var cell_mc = row.cells[j];
					
					if(cell_mc == undefined)
					{
						//happens in incomplete rows
						break;
					}
					
					var posInDp:Number = posToIndex(i,j);
					
					// this a variable size list. So cell's position and rowDim are set here, but columnDim is set by 
					// the cell itself in setValue
					
					// row axis :
					if(j == 0)
					{
						cell_mc[_rowAxis] = 0;
					}
					else
					{
						var cellBeforeInRow_mc:MovieClip = row.cells[j - 1];
						cell_mc[_rowAxis] = cellBeforeInRow_mc[_rowAxis] + cellBeforeInRow_mc[_rowDim];
					}
					
					//column axis
					cell_mc[_columnAxis] = 0;
					
					setCellSize(cell_mc, _itemsPerRow, _fixedRowHeight);
					
					// we shortcut it when not necessary
					if(doNotRefreshData == undefined)
					{
						setCellData(cell_mc, posInDp);
					}
					
					//here measure maxCellColumnDim to fit rows one after another
					if(!_isHorizontal)
					{				
						if(cell_mc.height > maxCellColumnDim)
						{
							maxCellColumnDim = cell_mc.height;
						}
					}
					else
					{
						if(cell_mc.width > maxCellColumnDim)
						{
							maxCellColumnDim = cell_mc.width;
						}
					}
				}
				setRowSize(row, maxCellColumnDim);
			}
			accumulatedRowHeights += row[_columnDim];
		}
	}
	
	/*
	Function: setCellSize
	The setCellSize method is used in refreshRowsAndCells(). It allow to override it in children classes.
	*/
	function setCellSize(cell_mc, _itemsPerRow, _fixedRowHeight):Void
	{
		if(_useVariableRowHeight)
		{
			//leave rowheight free.
			if(!_isHorizontal)
			{				
				cell_mc.setSize(this.width / _itemsPerRow, cell_mc.height);
			}
			else
			{
				cell_mc.setSize(cell_mc.width, this.height / _itemsPerRow);
			}
		}
		else
		{
			//set both dimensions
			if(!_isHorizontal)
			{				
				cell_mc.setSize(this.width / _itemsPerRow, _fixedRowHeight);
			}
			else
			{
				cell_mc.setSize(_fixedRowHeight, this.height / _itemsPerRow);
			}
		}
	}
	
	/*
	Function: setRowSize
	The setRowSize method is used in refreshRowsAndCells(). It allow to override it in children classes.
	*/
	function setRowSize(row, maxCellColumnDim):Void
	{
		if(_useVariableRowHeight)
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
	
	/**
 	 * function: assembleDataProvider
 	 * creates a data provider from the labels, data, and icons array.
	 * */
	function assembleDataProvider()
	{
		var newDpLen:Number = 0;
		if(_labels.length > newDpLen)
		{
			newDpLen = _labels.length;
		}
		if(_data.length > newDpLen)
		{
			newDpLen = _data.length;
		}
		if((_icons) && (_icons.length > newDpLen))
		{
			newDpLen = _icons.length;
		}
		
		var dp:Array = new Array();

		for(var i = 0; i < newDpLen; i++)
		{
			// handle accessors for the label and data fields
			// have to do it here (as well as in setCellData) because empty cells has to be removed, even if they are empty only after revealing accessors
			// By lexa 2009/12/12 (pixies)
			var revealedLabel_str:String = silexPtr.utils.revealAccessors (_labels[i], this);
			var revealedData_str:String = silexPtr.utils.revealAccessors (_data[i], this);
			if (revealedLabel_str && revealedData_str && revealedLabel_str!="" && revealedData_str!="")
			{
				dp.push({label:revealedLabel_str, data:revealedData_str, icon:_icons[i]});
			}
		} 
		
		dataProvider = dp;
	}
   
	/**
	* function: getCellIndex
	* This method is given to each cell to determine its position in the list
	* scoped to the cell. Any cell in the row will receive these methods. 
	* from the flash help:
	* returns an object with two fields, columnIndex and itemIndex, that locate the cell in the component. 
	* Each field is an integer that indicates a cell's column position and item position. 
	* For any components other than the DataGrid component, the value of columnIndex is always 0.
	* This method is provided by the List class; you do not have to implement it. 
	* 
	* */
	function getCellIndex(Void):Object
	{
		var itemIndex = this.owner.itemIndex;
		var len = this.listOwner.itemsPerRow;
		var columnIndex = -1;
		for(var i = 0; i < len; i++)
		{
			if(this == owner.cells[i])
			{
				columnIndex = i;
				break;
			}
		}
		return {columnIndex:columnIndex, itemIndex:itemIndex};
	}

	/*
	Function: _initAfterRegister
	We initiate the external cell renderer loading here if necessary.
	*/
	public function _initAfterRegister()
	{     
		super._initAfterRegister();
		
		// initializes the listContent MovieClip
		listContent = createEmptyMovieClip("listContent", this.getNextHighestDepth());
			
		// The listContent is not ready yet to be manipulated
		_listContentSet = false;
		
		// get the dimensions given by the designer on the scene. 
		// using _width and _height would seem logical, but somehow they are not set properly. So use width and height
		setSize(width, height);
		
		if(_useRemoteCellRendererLib)
		{
			// Loads an external swf into the listContent clip. This swf contains the cellRenderer we wanna use
			// initialize the MovieClipLoader
			_cellRendererMCLoader = new MovieClipLoader();
			_cellRendererMCLoader.addListener(this);
			
			// reveal first the url
			var revealedCellRendererLibUrl:String = silexPtr.utils.revealAccessors(_cellRendererLibUrl, this);
			
			// What do we do if the url is not defined ?
			if(_cellRendererLibUrl == undefined) { }
			
			var ret = _cellRendererMCLoader.loadClip(revealedCellRendererLibUrl, listContent);
			if(!ret)
			{
				throw new Error("["+this+"] ERROR cannot load cellRenderer from url: " + revealedCellRendererLibUrl);
			}
		}
		else
		{
			// if not using an external cellRenderer, we initalize the list content right away
			_initListContent();
		}
	}
	
	/*
	Function: _initListContent
	Initializes the list contents (dataProvider, rows and cells).
	*/
	private function _initListContent()
	{
		// We apply the mask once listContent ready only
		listContent.setMask(MovieClip(mask_mc));
		
		if ( _data.length > 0 && ( _labels.length > 0 || _icons.length > 0) )
		{
			assembleDataProvider();
		}

		_initialized = true;
		// call _initAfterRegister on each cell
		for (var i = 0; i < _rowCount; i++)
			for(var j = 0; j < _itemsPerRow; j++)
				_rows[i].cells[j]._initAfterRegister();
			
		// The listContent is ready to be manipulated
		_listContentSet = true;
	}
	
	///////////////////////////////////////
	// listeners for the _cellRendererMCLoader
	///////////////////////////////////////
	/*
	Function: onLoadProgress
	Invoked as the loading process progresses. 
	*/
	function onLoadProgress(target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void {	}
	
	/*
	Function: onLoadComplete
	Invoked when a file completes downloading, but before the loaded movie clip's methods and properties are available. This handler is called before the onLoadInit handler.
	*/
	function onLoadComplete(target_mc:MovieClip, httpStatus:Number):Void { }

	/*
	Function: onLoadInit
	Invoked when the actions on the first frame of the loaded clip have been executed.
	*/
	function onLoadInit(target_mc:MovieClip):Void
	{
		// we can now initialize the list's contents
		_initListContent();
	}	
	
	/*
	Function: onLoadError
	Invoked when a file loaded with MovieClipLoader.loadClip() has failed to load.
	*/
	function onLoadError(target_mc:MovieClip, errorCode:String, httpStatus:Number):Void
	{
		throw new Error("["+this+"] ERROR OCCURRED while loading cellRenderer from url: " + _cellRendererLibUrl);
	}
   
	///////////////////////////////////
	// UIObject class methods
	///////////////////////////////////
	/**
	* function: setsize
	*  resizes the object to the requested size.
	* */
	function setSize(w:Number, h:Number) 
	{
		super.setSize(w, h);
		
		mask_mc._width = w;
		mask_mc._height = h;
		
		invalidate();
	}

	/**
	* function: move
	*  moves the object to the requested position.
	* */ 
	function move(x:Number, y:Number)
	{
		super.move(x, y);
	}
   
   	function onModelChanged():Void
	{
		invalidate();
		// dispatch event
		dispatch( { type:"modelChanged", target:this } );
   	}
	
	function redraw()
	{
		adjustCellsCount();
		refreshRowsAndCells();					
	}
	
	/** 
	  * Group: public functions and properties
	  * */
	/**
	  * function selectItemFromKey
	  * non standard function, used to find and select an item from a key. 
	 */
    function selectItemFromKey(key:String):Void
	{
		var newIndex:Number = -1;
		for (var i:Number = __dataProvider.length; i --> 0;)
		{
			var dpObj:Object = __dataProvider[i];
			if(dpObj["label"] == key)
			{
				newIndex = i;
				break;
			}
			if(dpObj["data"] == key)
			{
				newIndex = i;
				break;
			}
			var dpObjData:Object = dpObj["data"];
			if(dpObjData){
				for (var dataObjKey:String in dpObjData)
				{
					if(dpObjData[dataObjKey] == key)
					{
						newIndex = i;
						break;
					}
				}
			}
		}
		selectedIndex = newIndex;
    }
	
	///////////////////////////////////
	// List class methods
	///////////////////////////////////
	/** 
	* property: dataProvider
	* set this to give data to the list. 
	* */
	public function get dataProvider():Array
	{
		return __dataProvider;
	}
	public function set dataProvider(dp:Array)
	{
		if (__dataProvider != dp)
		{
			// stop listening the "modelChanged" event of the OLD data provider object
			if (__dataProvider)
			{
				__dataProvider["removeEventListener"](org.silex.core.Utils.removeDelegate(this,"modelChanged"), onModelChanged);
			}
			// store the new data provider 
			__dataProvider = dp;
			// listen the "modelChanged" event of the DataProvider class
			__dataProvider.addEventListener("modelChanged",org.silex.core.Utils.createDelegate.create(this, onModelChanged));

			onModelChanged();
		}
	}
	
	/**
	 * property: selectedIndex
	 * returns the index of the selected item.
	 * If an item is selected, this is between 0 and the number of items minus 1.
	 * If no item is selected, this is NaN. (not a number).
	 * */
	function get selectedIndex():Number
	{
		return _selectedIndex;
	}
	function set selectedIndex(val:Number)
	{
		if (typeof(val) != "number")
			val = parseInt(val.toString());
		
		//if (_selectedIndex != val)
		//{
			// store the new value
			_selectedIndex = val;
			//syncronize _selectedIndices, and  cancel any multiple selection 
			_selectedIndices = new Array();
			_selectedIndices.push(_selectedIndex);
			
			// We refresh the rows and cells contents (only to refresh the _isSelected parameters of the cells, there may be something to do to optimize here)	TODO optimize (with events ?)
			refreshRowsAndCells();
			
			// dispatch event
			dispatch( { type:"change", target:this } );
		//}
	}

	/*
	 * property: selectedIndices
	 * If multiple selection is enabled, this is an array containing 
	 * the indexes of each selected item. 
	 */
	function get selectedIndices():Array
	{
		return _selectedIndices;
	}
	function set selectedIndices(val:Array)
	{
		_selectedIndices = val;
		_selectedIndex  = val[val.length - 1];
		
		// We refresh the rows and cells contents (only to refresh the _isSelected parameters of the cells, there may be something to do to optimize here)	TODO optimize (with events ?)
		refreshRowsAndCells();
		
		// dispatch event
		dispatch({type:"change", target:this});
	}
	
	/**
	 * property: selectedItem
	 * the selected item. read-only.
	 * */
	function get selectedItem():Object
	{
		return getItemAt(_selectedIndex);
	}
		
	/**
	* property: selectedItems
	* the selected items, onyl valid if multiple selection is enabled. read-only.
	* */
	function get selectedItems():Object
	{
		var ret:Array = new Array();
		var len = _selectedIndices.length; 
		for(var i = 0; i < len; i++)
		{
			ret.push(getItemAt(_selectedIndices[i]));
		}
		return ret;
	}
	
	/**
	 * function: addItem
	 * Adds an item to the end of the list.
	 * */
	function addItem(_obj)
	{
		if (__dataProvider == null)
			__dataProvider = new Array();
			
		__dataProvider.push(_obj);
		invalidate();
	}
	
	/**
	* function: addItemAt
	* Adds an item to the list at the specified index.
	* */
	function addItemAt(i:Number,_obj:Object)
	{
		__dataProvider.splice(i, 0, _obj);
		invalidate();
	}
	
	/**  
	 * function: getItemAt
	 * Returns the item at the specified index.
	 * */
	function getItemAt(i:Number)
	{
		return __dataProvider.getItemAt(i);
	}
	
	/**
	 * function: removeAll
	 * Removes all items from the list.
	 */
	function removeAll()
	{
		dataProvider = null;			
		_selectedIndex = undefined;
		invalidate();
	}
	
	/**
	 * function: removeItemAt
	 * Removes the item at the specified index.
	 * */
	function removeItemAt(i:Number)
	{
		__dataProvider.splice(i, 1);
		invalidate();
	}
	
	/**
	 * function: replaceItemAt
	 * Replaces the item at the specified index with another item.
	 * */
	function replaceItemAt(i:Number, _obj:Object)
	{
		__dataProvider[i] = _obj;
		invalidate();
	}
	
	/**
	 *  function: setPropertiesAt
	 * Applies the specified properties to the specified item.
	 * not implemented yet
	 * */
	function setPropertiesAt()
	{
		invalidate();
	}
	
	/**
	*  function: sortItems
	* Sorts the items in the list according to the specified compare function.
	* not implemented yet
	* */
	function sortItems()
	{
		invalidate();
	}
	
	/**
	*  function: sortItemsBy
	* Sorts the items in the list according to a specified property.
	* not implemented yet
	* */
	function sortItemsBy()
	{
		invalidate();
	}
   
	/**
	* property: length
	* returns the number of items in the list. read only.
	* */
	function get length():Number
	{
		if(!__dataProvider)
		{
			return 0;
		}
		else
		{
			return __dataProvider.length;
		}
	}

	/**
	* property: vPosition
	* the vertical scrolling position. a whole value between 0 and numItems if
	* isHorizontal is false, 0 if isHorizontal is true
	* */
	function get vPosition():Number
	{
		return _vPosition;
	}
	function set vPosition(val:Number)
	{
		if (isHorizontal)
		{
			return;
		}
		var topRowIndex = Math.floor(val / _itemsPerRow);
		var y = - _rows[topRowIndex]._y;
//		listContent._y = - y;
		// declare var temp to avoid errors at compilation with MTASC
		var temp:Tween = new Tween(listContent, "_y", Strong.easeOut, listContent._y, y, _easingDuration, true);
		_vPosition = val;
		dispatch( { type:"scroll", target:this } );
	}
	
	/**
	* property: hPosition
	* the horizontal scrolling position. a whole value between 0 and numItems if
	* isHorizontal is true, 0 if isHorizontal is false
	* */
	function get hPosition():Number
	{
		return _hPosition;
	}

	function set hPosition(val:Number)
	{
		if (!isHorizontal)
		{
			return;
		}
		var topRowIndex = Math.floor(val / _itemsPerRow);
		var x = - _rows[topRowIndex]._x;
//		listContent._y = - y;
		// declare var temp to avoid errors at compilation with MTASC
		var temp:Tween = new Tween(listContent, "_x", Strong.easeOut, listContent._x, x, _easingDuration, true);
		_hPosition = val;
		dispatch( { type:"scroll", target:this } );
	}
	
	/**
	* group: inspectable properties
	* */

	/**
	* property: rowHeight
	* there is no rowWidth in the list API, so this function should be used instead, 
	* independantly of the list being horizontal. rowDepth would have 
	* been a better name, but this list tries to follow the mx component API 
	* whenever possible.
	* 
	* if useVariableRowHeight is set to true, this property is an average, and
	* setting it has no effect. 
	* */
	/** function set rowHeight
	* @param val(Number)
	* @returns void
	*/
	[Inspectable(name = "fixed row height", type = Number, defaultValue = 50)]
	public function set rowHeight(val:Number)
	{
		_fixedRowHeight = val;
		invalidate();
	}
	/** function get rowHeight
	* @returns Number
	*/
	function get rowHeight():Number
	{
		if(_useVariableRowHeight)
		{
			var ret:Number = 0;
			if(!isHorizontal)
			{
				ret = listContent._height / _rowCount;		
			}
			else
			{
				ret = listContent._width / _rowCount;		
			}
			return ret;
		}
		else
		{
			return _fixedRowHeight;
		}
	}
	

	///////////////////////////////////
	// UIBase class methods
	///////////////////////////////////
	/** 
	 * property: cellRenderer
	 * the name of the cellRenderer that will be used with the list. If you use this
	 * class in Flash, the cellRenderer must be a movieclip in the library. With silex,
	 * the cellRenderer must be included in the compiled component, so you probably
	 * shouldn't change this property unless you compile your silex component.
	 * 
	 * Each list has a default value for this property. For example, the RichTextList
	 * has the RichTextCellRenderer.  
	 * */
	[Inspectable(type = String, defaultValue = "")]
	public function set cellRenderer(val:String)
	{
		_cellRenderer = val;
		invalidate();
	}
	/** function get cellRenderer
	* @returns String
	*/
	public function get cellRenderer():String 
	{
		return _cellRenderer;
	}
	
	/**
	 * property: data
	 * an array of data values that will be rendered in the list. If you don't know
	 * how to use this, start with the labels.
	 * This is only useful if your list understands data. For example, a textlist
	 * will only understand labels. An image list will only understand icons. 
	 * use in combination with labels and icons. Don't use when you are
	 * using a data provider.
	 * */
	/** function set data
	* @param val(Array)
	* @returns void
	*/
	[Inspectable(type = Array)]
	public function set data(val:Array)
	{
		_data = val;
		if(_initialized)
		{
			assembleDataProvider();
		}
	}
	/** function get data
	* @returns Array
	*/
	public function get data():Array
	{
		return _data;
	}
	
	/**
	 * property: labels
	 * an array of strings, used to set the label of each cell.
	 * 
	 * example: ['label1', 'label2', 'label3']
	* 
	* This is only useful if your list understands labels. For example, a textlist
	* will only understand labels. An image list will only understand icons. 
	* use in combination with data and icons. Don't use when you are
	* using a data provider.
	* */
	/** function set labels
	* @param val(Array)
	* @returns void
	*/
	[Inspectable(type = Array)]
	public function set labels(val:Array)
	{
		_labels = val;
		if(_initialized)
		{
			assembleDataProvider();
		}
	}
	/** function get labels
	* @returns Array
	*/
	public function get labels():Array
	{
		return _labels;
	}
	
   /**
	* property: icons
	* an array of strings, used to set the icon of each cell.
	* 
	* example: ['http://yoursite.com/images/image1.jpg', 'http://yoursite.com/images/image2.jpg', 'http://yoursite.com/images/image3.jpg']
	* 
	* This is only useful if your list understands icons. For example, a textlist
	* will only understand labels. An image list will only understand icons. 
	* use in combination with labels and icons. Don't use when you are
	* using a data provider.
	* */
	/** function set icons
	* @param val(Array)
	* @returns void
	*/
	[Inspectable(type = Array)] 
	public function set icons(val:Array)
	{
		_icons = val;
		if(_initialized)
		{
			assembleDataProvider();
		}
	}
	/** function get icons
	* @returns Array
	*/
	public function get icons():Array
	{
		return _icons;
	}
	
	
	////////////////////////////////////
	//extensions not in macromedia list
	///////////////////////////////////
	/**
	 * show hand cursor on roll over?
	 * set bg_btn.useHandCursor in the cellRenderer (org.oof.lists.cellRenderers.CellRendererBase)
	 */
	public var _useHandCursor:Boolean = false;
	
	/**
	 * property: itemsPerRow
	 * the number of items in each row. 1, in most cases.
	 * */
	/** function set itemsPerRow
	* @param val(Number)
	* @returns void
	*/
	[Inspectable(name="items per row",type = Number, defaultValue =1)]
	public function set itemsPerRow(val:Number)
	{
		_itemsPerRow = val;
	//	invalidate(); //don't redraw for now, code not ready
	}
	/** function get itemsPerRow
	* @returns Number
	*/
	public function get itemsPerRow():Number
	{
		return _itemsPerRow;
	}
	
	/**
	 * property: isHorizontal
	 * is the list horinzontal? 
	 * true or false
	 * */
	/** function set isHorizontal
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="list is horizontal",type = Boolean, defaultValue =false)]
	public function set isHorizontal(val:Boolean)
	{
		if(!val)
		{
			_rowAxis = "_x";
			_columnAxis = "_y";
			_rowDim = "width";
			_columnDim = "height";
		}
		else
		{
			_rowAxis = "_y";
			_columnAxis = "_x";
			_rowDim = "height";
			_columnDim = "width";
		}
		_isHorizontal = val;
		redraw();
	}
	/** function get isHorizontal
	* @returns Boolean
	*/
	public function get isHorizontal():Boolean
	{
		return _isHorizontal;
	}
	
	/**
	 * property: useVariableRowHeight
	 * in most cases, you want each item to have the same height, so leave this to false.
	 * If you want each cell to adjust its heghit and position according to its content,
	 * set to true
	 * */
	/** function set useVariableRowHeight
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set useVariableRowHeight(val:Boolean)
	{
		_useVariableRowHeight = val;
		redraw();
	}
	/** function get useVariableRowHeight
	* @returns Boolean
	*/
	public function get useVariableRowHeight():Boolean
	{
		return _useVariableRowHeight;
	}
	
	/**
	 * property: multipleSelection
	 * In most cases, you only want the user to be able to select one
	 * item at a time in a list. If not, set to true.
	 * */
	/** function set multipleSelection
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(type = Boolean, defaultValue = false)]
	public function set multipleSelection(val:Boolean)
	{
		_multipleSelection = val;
		redraw();
	}
	/** function get multipleSelection
	* @returns Boolean
	*/
	public function get multipleSelection():Boolean
	{
		return _multipleSelection;
	}
	
	/**
	 * property: cellMarginX
	 * This property is used to position each cell horizontally
	 * */
	/**
	 * Get the value of cellMarginX
	 * @return The value of cellMarginX
	 */ 
	[Inspectable(type = Number,defaultValue = 10)]
	public function get cellMarginX() : Number
	{
		return _cellMarginX;
	}
	/**
	 * Set the value of cellMarginX
	 * @param val The value to set cellMarginX to
	 */ 
	public function set cellMarginX(val : Number) : Void
	{
		_cellMarginX = val;
		redraw();
	}
	
   /**
	* property: cellMarginY
	* This property is used to position each cell vertically
	* */
	/**
	 * Get the value of cellMarginY
	 * @return The value of cellMarginY
	 */ 
	[Inspectable(type = Number,defaultValue = 10)]
	public function get cellMarginY() : Number
	{
		return _cellMarginY;
	}
	/**
	 * Set the value of cellMarginY
	 * @param val The value to set cellMarginY to
	 */ 
	public function set cellMarginY(val : Number) : Void
	{
		_cellMarginY = val;
		redraw();
	}
	
	/**
	 * property: easingDuration
	 * if your list uses an animation to scroll, this defines the duration
	 * of the animation
	 * */
	/**
	 * Get the value of easingDuration
	 * @return The value of easingDuration
	 */ 
	[Inspectable(name="easing duration", type = Number,defaultValue = 0.5)]
	public function get easingDuration() : Number
	{
		return _easingDuration;
	}
	/**
	 * Set the value of easingDuration
	 * @param peasingDuration The value to set easingDuration to
	 */ 
	public function set easingDuration(val : Number) : Void
	{
		_easingDuration = val;
	}
	
	/*
	Property: cellRendererLibUrl
	The url of the cellRenderer's swf file to use in cases we use an external one. The setter sets _useRemoteCellRendererLib to true.
	*/
	[Inspectable(type = String, defaultValue = "")]
	public function set cellRendererLibUrl(val:String)
	{
		if(val != null && val != "")
			_useRemoteCellRendererLib = true;
		
		_cellRendererLibUrl = val;
	}
	public function get cellRendererLibUrl():String
	{
		return _cellRendererLibUrl;
	}
}