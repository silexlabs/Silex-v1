/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.ui.tools.RegionToolKnob;
import org.silex.core.Utils;

/**
* This class displays and handles RegionTool. This is a tool to let the user select a region on stage.
*/
class org.silex.ui.tools.RegionTool {
	/**
	* The MovieClip in which to display the RegionTool.
	*/
	private var parentmc : MovieClip;
	/**
	* The MovieClip in which to draw the RegionTool.
	*/
	private var draw_mc : MovieClip;
	
	/**
	* Knobs' stroke color.
	*/
	public static var knobStrokeColor : Number = 0x00FF00;
	/**
	* Knobs' stroke color alpha component (0 = transparent, 100 = opaque)
	*/
	public static var knobStrokeAlpha : Number = 100;
	/**
	* Knobs' "background" color.
	*/
	public static var knobFillColor : Number = 0x00FF00;
	/**
	* Knobs' background color alpha component (0 = transparent, 100 = opaque).
	*/
	public static var knobFillAlpha : Number = 100;
	
	/**
	* RegionTool's borders' color.
	*/
	public static var bgKnobStrokeColor : Number = 0x00FF00;
	/**
	* RegionTool's border's color alpha component ( 0 = transparent, 100 = opaque)
	*/
	public static var bgKnobStrokeAlpha : Number = 100;
	/**
	* RegionTool's background color.
	*/
	public static var bgKnobFillColor : Number = 0x00FF00;
	/**
	* RegionTool's background color alpha component (0 = transparent, 100 = opaque)
	*/
	public static var bgKnobFillAlpha : Number = 25;
	
	
	/**
	* The Top-Left Knob
	*/
	private var tl_handler : RegionToolKnob;
	/**
	* The Top-Right Knob
	*/
	private var tr_handler : RegionToolKnob;
	/**
	* The Bottom-Left Knob.
	*/
	private var bl_handler : RegionToolKnob;
	/**
	* The Bottom-Right Knob.
	*/
	private var br_handler : RegionToolKnob;
	/**
	* The Knob used to draw the background.
	*/
	private var bg_handler : RegionToolKnob;
	
	/**
	* Called when the region has moved or has been resized.
	*/
	public var onChange : Function;
	
	/**
	* Stores coordinates in FLASH coordinate space.
	* Has to be {x : Number, y : Number, width : Number, height : Number}
	*/
	private var _coords : Object;
	
	/**
	* Stores coordinates in SILEX coordinate space.
	* Has to be {x : Number, y : Number, width : Number, height : Number}
	*/
	private var _silexCoords : Object;
	
	/**
	* Returns coordinates in SILEX space.
	*/
	public function get coords() : Object
	{
		return Utils.scaleCoords(_coords);
	}
	
	/**
	* Coordinates of the RegionTool.
	* Has to be SILEX coordinates.
	*/
	public function set coords(value: Object) : Void
	{
		_silexCoords = value;
		_coords = Utils.unscaleCoords(value);
		draw();
	}
	
	/**
	* Moves and resizes knob so that they fit the selected region.
	*/
	public function draw()
	{
		//Move handles
		tl_handler.y = _coords.y;
		tr_handler.y = _coords.y;
		tl_handler.x = _coords.x;
		bl_handler.x = _coords.x;
		tr_handler.x = _coords.x + _coords.width;
		br_handler.x = _coords.x + _coords.width;
		bl_handler.y = _coords.y + _coords.height;
		br_handler.y = _coords.y + _coords.height;
		bg_handler.x = _coords.x;
		bg_handler.y = _coords.y;
		bg_handler.width = _coords.width;
		bg_handler.height = _coords.height;
	}
	
	/**
	* Constructor.
	* parentmc : The movieClip in which ot draw the zone.
	* coords : Coordinates in SILEX page. Should be { x : Number, y : Number, width: Number, height : Number}.
	*/
	public function RegionTool(parentmc : MovieClip, coords : Object)
	{
		this.parentmc = parentmc;
		//this.coords = {x : 0.0, y: 0.0, width: 0.0, height : 0.0};
		draw_mc = this.parentmc.createEmptyMovieClip("", this.parentmc.getNextHighestDepth());
		//Hide at creation
		this.hide();

		//###Create knobs
		bg_handler = new RegionToolKnob(draw_mc);
		//The background Knob must not be drawn centered.
		bg_handler.center = false;
		tl_handler = new RegionToolKnob(draw_mc);
		tr_handler = new RegionToolKnob(draw_mc);
		bl_handler = new RegionToolKnob(draw_mc);
		br_handler = new RegionToolKnob(draw_mc);

		//Set the background Knob's colors.
		bg_handler.fillColor = RegionTool.bgKnobFillColor;
		bg_handler.fillAlpha = RegionTool.bgKnobFillAlpha;
		bg_handler.strokeColor = RegionTool.bgKnobStrokeColor;
		bg_handler.strokeAlpha = RegionTool.bgKnobStrokeAlpha;
		
		//Set coords to the one given as parameter.
		this.coords = coords;
		
		//Set event handlers to be able to handle movement of knobs.
		tl_handler.onMoveEnd = org.silex.core.Utils.createDelegate(this, handleMoveEnd);
		tr_handler.onMoveEnd = org.silex.core.Utils.createDelegate(this, handleMoveEnd);
		bl_handler.onMoveEnd = org.silex.core.Utils.createDelegate(this, handleMoveEnd);
		br_handler.onMoveEnd = org.silex.core.Utils.createDelegate(this, handleMoveEnd);
		bg_handler.onMoveEnd = org.silex.core.Utils.createDelegate(this, handleMoveEnd);
		
		_global.getSilex().application.addEventListener("resize", Utils.createDelegate(this, handleResize));
	}
	
	private function handleResize()
	{
		//Recalculate coords from silexCoords
		this.coords = this._silexCoords;
	}
	
	/**
	* Called when a knob has been moved
	*/
	public function handleMoveEnd(caller : RegionToolKnob)
	{
		//Recalculate coordinates depending on the knob that has been moved.
		switch(caller)
		{
			case tl_handler:
				_coords.x = caller.x;
				_coords.y = caller.y;
				_coords.height = br_handler.y - tl_handler.y;
				_coords.width = br_handler.x - tl_handler.x;
				break;
			case tr_handler:
				_coords.y = caller.y;
				_coords.width = caller.x - tl_handler.x;
				_coords.height = br_handler.y - caller.y;
				break;
			case bl_handler:
				_coords.x = caller.x;
				_coords.height = caller.y - tl_handler.y;
				_coords.width = br_handler.x - caller.x;
				break;
			case br_handler:
				_coords.height = caller.y - tr_handler.y;
				_coords.width = caller.x - bl_handler.x;
				break;
			case bg_handler:
				_coords.x = caller.x;
				_coords.y = caller.y;
				break;
		}

		//Save coords in SILEX space
		this._silexCoords = coords;
		//Redraw RegionTool now that coordinates have been calculated.
		draw();

		//Call onChange if it is set.
		if(onChange != null && onChange != undefined)
			onChange(this);
	}
	
	/**
	* Displays the RegionTool
	*/
	public function show()
	{
		this.draw_mc._visible = true;
	}
	
	/**
	* Hides the RegionTool
	*/
	public function hide()
	{
		this.draw_mc._visible = false;
	}
	
	/**
	* Removes the RegionTool's MC from its container. Call when you don't need the RegionTool anymore.
	* Also frees delegates.
	*/
	public function destruct()
	{
		//Remove delegates
		org.silex.core.Utils.removeDelegate(this, handleMoveEnd);
		org.silex.core.Utils.removeDelegate(this, handleResize);
		
		//Destruct knobs
		tl_handler.destruct();
		tr_handler.destruct();
		bl_handler.destruct();
		br_handler.destruct();
		bg_handler.destruct();
		
		//Remove our movieClip
		draw_mc.removeMovieClip();
	}
}
