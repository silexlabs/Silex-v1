/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package  org.silex.adminApi.selection
{
	import flash.events.EventDispatcher;
	
	import org.silex.adminApi.ExternalInterfaceController;
	/**
	 * The SelectionManager dispatches event related to selection and exposes methods
	 * to communicate with the HaXe selectionManager
	 * @author Yannick DOMINGUEZ
	 */
	public class SelectionManager extends EventDispatcher
	{
		////////////////////**/*/*/*/*/*/*/
		// COSNTANTS
		////////////////////**/*/*/*/*/*/*/
		
		public static const SELECTION_MANAGER_ID:String = "selectionManagerId";
		
		/**
		 * List the authorised pivot point positions
		 */
		public static const PIVOT_POINT_POSITION_TOP_LEFT:String = "pivotPointPositionTopLeft";
	
		public static const PIVOT_POINT_POSITION_TOP:String = "pivotPointPositionTop";
		
		public static const PIVOT_POINT_POSITION_TOP_RIGHT:String = "pivotPointPositionTopRight";
	
		public static const PIVOT_POINT_POSITION_RIGHT:String = "pivotPointPositionRight";
		
		public static const PIVOT_POINT_POSITION_BOTTOM_RIGHT:String = "pivotPointPositionBottomRight";
	
		public static const PIVOT_POINT_POSITION_BOTTOM:String = "pivotPointPositionBottom";
	
		public static const PIVOT_POINT_POSITION_BOTTOM_LEFT:String = "pivotPointPositionBottomLeft";
	
		public static const PIVOT_POINT_POSITION_LEFT:String = "pivotPointPositionLeft";
	
		public static const PIVOT_POINT_POSITION_CENTER:String = "pivotPointPositionCenter";
		
		/**
		* const for the event when a selection region has been drawn
		*/
		public static const SELECTION_REGION_STOP_DRAWING:String = "selectionRegionStopDrawing";
		
		/**
		* const for the event when the user starts drawing a selection region
		*/
		public static const SELECTION_REGION_START_DRAWING:String = "selectionRegionStartDrawing";
		
		/**
		* const for the event when the user is drawing a selection region
		*/
		public static const SELECTION_REGION_DRAWING:String = "selectionRegionDrawing";
		
		/**
		 * A function to select the components within a selection drawing
		 */
		private static const FUNC_SELECT_REGION:String = "selectRegion";
		
		/**
		 * A function to select the selection manager mode
		 */
		private static const FUNC_SET_SELECTION_MODE:String = "setSelectionMode";
		
		/**
		 * highlight components on the scene with their uids
		 */
		private static const FUNC_HIGHLIGHT_COMPONENTS:String = "highlightComponents";
		
		/**
		 * A function to set the position of the pivot point
		 */
		private static const FUNC_SET_PIVOT_POINT:String = "setUntypedPivotPoint";
		
		/**
		 * the selection manager mode use to select components
		 */
		public static const SELECTION_MODE_SELECTION:String = "selectionModeSelection";
		
		/**
		 * the selection manager mode use to browse the publication
		 */
		public static const SELECTION_MODE_NAVIGATION:String = "selectionModeNavigation";
		
		/**
		 * the selection manager mode use to create components by drawing
		 */
		public static const SELECTION_MODE_DRAWING:String = "selectionModeDrawing";
		
		/**
		* The constant of a global event dispatched when the selection mode changes
		*/
		public static const SELECTION_MODE_CHANGED:String = "selectionModeChanged";

		
		////////////////////**/*/*/*/*/*/*/
		// ATTRIBUTES
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * The target name on 
		 * silexAdminApi
		 */
		private var _targetName:String = "selectionManager";
		
		////////////////////**/*/*/*/*/*/*/
		// CONSTRUCTOR
		////////////////////**/*/*/*/*/*/*/
	
		public function SelectionManager()
		{
			
		}
		
		////////////////////**/*/*/*/*/*/*/
		// PUBLIC METHODS
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * Select the components within a selection region
		 * @param	regionCoords the coords of the selection region
		 * @param	useShift wether shifit was pressed during the selection
		 */
		public function selectRegion(regionCoords:Object, useShift:Boolean = false):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_SELECT_REGION, [regionCoords, useShift]);
		}
		
		/**
		 * Set the mode of the selection manager
		 * @param	selectionMode the mode of the selection manager
		 * @param resetComponentsEdition choose wether all components must be locked/unlocked due to a
		 * state change. It is useful to prevent unlocking all components when the user unlock then select
	     * a component in Navigation mode. The selection mode switch to Selection but all locked components
	     * remain locked.
		 */
		public function setSelectionMode(selectionMode:String, resetComponentsEdition:Boolean = true):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_SET_SELECTION_MODE, [selectionMode, resetComponentsEdition]);
		}
		
		/**
		 * Set the pivot point position
		 * @param	pivotPointPosition the pivot point position
		 */
		public function setPivotPoint(pivotPointPosition:String):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_SET_PIVOT_POINT, [pivotPointPosition]);
		}
		
		/**
		 * Highlight components on the scene with their uids
		 * @param	componentUids the uids of the components to highlight
		 */
		public function highlightComponents(componentUids:Array):void
		{
			ExternalInterfaceController.getInstance().callJsApiFunction(_targetName, FUNC_HIGHLIGHT_COMPONENTS, [componentUids]);
		}
		
	}

}