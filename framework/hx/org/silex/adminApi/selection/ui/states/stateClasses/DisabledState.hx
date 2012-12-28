package org.silex.adminApi.selection.ui.states.stateClasses;
import haxe.Log;
import org.silex.adminApi.selection.ui.events.UIEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.ui.states.StateBase;
import org.silex.adminApi.selection.utils.Structures;

/**
 * A state used when all SelectionTool interaction
 * must be disabled, like when the user logs out. Override methods
 * to prevent default behaviour
 * @author Yannick DOMINGUEZ
 */

class DisabledState extends StateBase
{

	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Hides all the selectionTool UIs
	 * @param	uis
	 */
	public function new(uis:UIsExtern) 
	{
		super(uis);
		unsetHighlightedComponents();
		unsetSelectionRegion();
		unsetSelectedComponents();
		unsetEditableComponents();
	}

	/////////////////////////////////////
	// OVERRIDEN METHODS
	////////////////////////////////////
	
	/**
	 * Prevent selectionRegion display
	 */
	override public function setSelectionRegion(selectionRegionCoord:Coords):Void
	{
	
	}
	
	/**
	 * Prevent highlighted components display
	 */
	override public function setHighlightedComponents(highlightedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
	
	}
	
	/**
	 * Prevent selection drawing display
	 */
	override public function setSelectionDrawing(coords:Coords):Void
	{
		
	}
	
	/**
	 * Prevent pivot point display
	 */
	override public function setPivotPoint(pivotPoint:Point):Void
	{
		
	}
	
	/**
	 * Prevent selected components display
	 */
	override public function setSelectedComponents(selectedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
	
	}
	
	/**
	 * Prevent display update of the selected components
	 */
	override public function updateSelectedComponents(selectedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		
	}
	
	
}