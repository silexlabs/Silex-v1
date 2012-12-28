/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;
import mx.data.encoders.Num;
import mx.events.EventDispatcher;
import org.silex.core.Api;
import org.silex.core.plugin.HookManager;
import org.silex.core.Utils;
import org.silex.tools.selectionTool.ui.event.UIEvent;
import org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.EditableComponentsContainer;
import org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.HighlightedComponentsContainer;
import org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.NonEditableComponentsContainer;
import org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.SelectedComponentsContainer;
import org.silex.tools.selectionTool.ui.uis.uiComponents.PivotPoint;
import org.silex.tools.selectionTool.ui.uis.uiComponents.RollOverBackground;
import org.silex.tools.selectionTool.ui.uis.uiComponents.RotationHandle;
import org.silex.tools.selectionTool.ui.uis.uiComponents.ScaleHandle;
import org.silex.tools.selectionTool.ui.uis.uiComponents.SelectedComponentBackground;
import org.silex.tools.selectionTool.ui.uis.uiComponents.SelectionDrawing;
import org.silex.tools.selectionTool.ui.uis.uiComponents.SelectionRegion;
import org.silex.tools.selectionTool.ui.utils.MouseCursorManager;

/**
 * Holds a reference to each part of the UI. Abstract access to the UI by exposing methods
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.UIs extends EventDispatcher
{
	/////////////////////////////////////
	// CONSTANTS
	////////////////////////////////////
	
	/**
	 * A hook called when the selection uis is initialised
	 */
	private static var HOOK_UIS_READY:String = "uisReady";
	
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	// Lists all the UI parts
	
	public var selectionRegion:SelectionRegion;
	
	public var selectionDrawing:SelectionDrawing;
	
	public var pivotPoint:PivotPoint;
	
	public var scaleHandleTL:ScaleHandle;
	
	public var scaleHandleT:ScaleHandle;
	
	public var scaleHandleTR:ScaleHandle;
	
	public var scaleHandleL:ScaleHandle;
	
	public var scaleHandleBL:ScaleHandle;
	
	public var scaleHandleB:ScaleHandle;
	
	public var scaleHandleBR:ScaleHandle;
	
	public var scaleHandleR:ScaleHandle;
	
	public var mouseCursorManager:MouseCursorManager;
	
	public var rotationHandleTL:RotationHandle;
	
	public var rotationHandleTR:RotationHandle;
	
	public var rotationHandleBR:RotationHandle;
	
	public var rotationHandleBL:RotationHandle;
	
	/**
	 * The container for the asset displayed around highlighted components
	 */
	public var highlightedComponentsContainer:HighlightedComponentsContainer;
	
	/**
	 * The container for the asset displayed around selected components
	 */
	public var selectedComponentsContainer:SelectedComponentsContainer;
	
	/**
	 * the container for the component place holders placed on top of each editable
	 * components
	 */
	public var editableComponentsContainer:EditableComponentsContainer;
	
	/**
	 * the container for the components place holders placed on top of each non-editable
	 * components
	 */
	public var nonEditableComponentsContainer:NonEditableComponentsContainer;
	
	/**
	 * listens to key up and key down event on the keyboard and dispatches event in response
	 * for the SelectionManager
	 */
	private var _keyboardListener:Object;
	
	/**
	 * Listen for mouse move and mouse up events and dispatches events in response for
	 * the SelectionManager
	 */
	private var _mouseListener:Object;
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Initialise the uis, by calling the init method on the next frame
	 */
	public function UIs() 
	{	
		super();
		hideUis();
		var silex_ptr:Api = _global.getSilex();
		
		
		//hack, use silex sequencer else, scale handles positions are set before they are
		//instantiated
		//wait for a few frame to be sure that Silex is initialised
		silex_ptr.sequencer.doInNFrames(30, Utils.createDelegate(this, init));
	}
	
	/////////////////////////////////////
	// PUBLIC METHODS
	////////////////////////////////////
	
	/**
	 * Place the point according to the passed position
	 * @param	pivotPointPosition the place of the pivot point
	 */
	public function setPivotPoint(pivotPointPosition:Object):Void
	{
		pivotPoint._x = pivotPointPosition.x;
		pivotPoint._y = pivotPointPosition.y;
	}
	
	/**
	 * get the pivot point position
	 * @return the pivot point position
	 */
	public function getPivotPoint():Object
	{
		return { x:pivotPoint._x , y:pivotPoint._y };
	}
	
	/**
	 * Place and resize the selection region movie clip
	 * @param	selectionRegionCoord the coords of the selection region
	 */
	public function setSelectionRegion(selectionRegionCoord:Object):Void
	{
		selectionRegion._x = 0;
		selectionRegion._y = 0;
		selectionRegion._width = selectionRegionCoord.width;
		selectionRegion._height = selectionRegionCoord.height;

		//we use a flash matrix to rotate the selection region, else it it disformed
		var rotationMatrix:Matrix = selectionRegion.transform.matrix;
		rotationMatrix.rotate((selectionRegionCoord.rotation * Math.PI) / 180);
		selectionRegion.transform.matrix = rotationMatrix;
		
		selectionRegion._visible = true;
		selectionRegion._x = selectionRegionCoord.x;
		selectionRegion._y = selectionRegionCoord.y;
		
		pivotPoint._visible = true;
		
		showHandles();
		placeHandles();
	}
	
	/**
	 * returns the current position of the mouse
	 * @return
	 */
	public function getMousePosition():Object
	{
		return {x:_xmouse, y:_ymouse };
	}
	
	/**
	 * Hides the selection region movie clip and reset it's rotation
	 */
	public function unsetSelectionRegion():Void
	{
		selectionRegion._rotation = 0;
		hideUis();
	}
	
	/**
	 * return the selection region coords
	 * @return the selection region coords
	 */
	public function getSelectionRegionCoords():Object
	{
		return { x:selectionRegion._x,
		y:selectionRegion._y,
		rotation:selectionRegion._rotation,
		width:selectionRegion._width,
		height:selectionRegion._height };
	}
	
	/**
	 * Shows the selection drawing
	 */
	public function showSelectionDrawing():Void
	{
		selectionDrawing._visible = true;
	}
	
	/**
	 * Hides the selection drawing
	 */
	public function hideSelectionDrawing():Void
	{
		selectionDrawing._visible = false;
	}
	
	/**
	 * Show the scale and rotation handles
	 */
	public function showHandles():Void
	{
		scaleHandleTL._visible = true;
		scaleHandleT._visible = true;
		scaleHandleTR._visible = true;
		scaleHandleR._visible = true;
		scaleHandleBR._visible = true;
		scaleHandleB._visible = true;
		scaleHandleBL._visible = true;
		scaleHandleL._visible = true;
		rotationHandleTL._visible = true;
		rotationHandleTR._visible = true;
		rotationHandleBR._visible = true;
		rotationHandleBL._visible = true;
	}
	
	/**
	 * hide the scale and rotation handles
	 */
	public function hideHandles():Void
	{
		rotationHandleBL._visible = false;
		rotationHandleBR._visible = false;
		rotationHandleTL._visible = false;
		rotationHandleTR._visible = false;
		scaleHandleB._visible = false;
		scaleHandleBL._visible = false;
		scaleHandleBR._visible = false;
		scaleHandleL._visible = false;
		scaleHandleR._visible = false;
		scaleHandleTL._visible = false;
		scaleHandleTR._visible = false;
		scaleHandleT._visible = false;
	}
	
	/**
	 * set the size and position of the selection drawing
	 * @param	coords the coords of the selection drawing 
	 */
	public function setSelectionDrawing(coords:Object):Void
	{
		selectionDrawing._x = coords.x;
		selectionDrawing._y = coords.y;
		selectionDrawing._width = coords.width;
		selectionDrawing._height = coords.height;
	}
	
	/**
	 * returns the size and position of the selection drawing
	 * @return the coords of the selection drawing
	 */
	public function getSelectionDrawingCoords():Object
	{
		return { x:selectionDrawing._x, y:selectionDrawing._y, width:selectionDrawing._width, height:selectionDrawing._height };
	}
	
	/**
	 * set the visual assets around the highlighted components
	 * @param	componentsCoords contains all of the highlighted components coords
	 */
	public function setHighlightedComponents(componentsCoords:Array):Void
	{
		highlightedComponentsContainer.setAssets(componentsCoords);
	}
	
	/**
	 * Hides the highlighted component movie clip and reset the mouse cursor
	 */
	public function unsetHighlightedComponents():Void
	{
		highlightedComponentsContainer.unsetAssets();
		setMouseCursor(MouseCursorManager.MOUSE_CURSOR_DEFAULT);
	}
	
	/**
	 * Set a custom mouse cursor
	 * @param	mouseCursor the name of the target mouse cursor
	 */
	public function setMouseCursor(mouseCursor:String):Void
	{
		mouseCursorManager.setMouseCursor(mouseCursor);
	}
	
	/**
	 * set the component place holders above the editable components which will dispatches
	 * UIevent
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function setEditableComponents(editableComponentsCoords:Array):Void
	{
		editableComponentsContainer.setAssets(editableComponentsCoords);
	}
	
	/**
	 * update the component place holders coords 
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function updateEditableComponents(editableComponentsCoords:Array):Void
	{
		editableComponentsContainer.updateAssets(editableComponentsCoords);
	}
	
	/**
	 * remove all the component place holders 
	 */
	public function unsetEditableComponents():Void
	{
		editableComponentsContainer.unsetAssets();
	}
	
	/**
	 * set the component place holders above the non editable components 
	 * @param	nonEditableComponentsCoords the coords of the non editable components
	 */
	public function setNonEditableComponents(nonEditableComponentsCoords:Array):Void
	{
		nonEditableComponentsContainer.setAssets(nonEditableComponentsCoords);
	}
	
	/**
	 * update the component place holders coords 
	 * @param	nonEditableComponentsCoords the coords of the non  editable components
	 */
	public function updateNonEditableComponents(nonEditableComponentsCoords:Array):Void
	{
		nonEditableComponentsContainer.updateAssets(nonEditableComponentsCoords);
	}
	
	/**
	 * remove all the components place holders 
	 */
	public function unsetNonEditableComponents():Void
	{
		nonEditableComponentsContainer.unsetAssets();
	}
	
	/**
	 * set the visual asset around the selected components
	 * @param	componentsCoords contains all of the selected components coords
	 */
	public function setSelectedComponents(componentsCoords:Array):Void
	{
		selectedComponentsContainer.setAssets(componentsCoords);
	}
	
	/**
	 * Update the coords of all the currently attached selected components background MovieClips
	 * @param	componentsCoords contains all of the selected components coords
	 */
	public function updateSelectedComponents(componentsCoords:Array):Void
	{
		selectedComponentsContainer.updateAssets(componentsCoords);
	}
	
	/**
	 * Unload all the movieClip displayed in the selected components background container
	 */
	public function unsetSelectedComponents():Void
	{
		selectedComponentsContainer.unsetAssets();
	}
	
	/**
	 * return the pressed keys on the keyboard among the watched keys
	 * @return contains a boolean for each key, stating wether it is pressed or not
	 */
	public function getKeyboardState():Object
	{
		return { 
			useShift:Key.isDown(Key.SHIFT),
			useAlt:Key.isDown(Key.ALT),
			useCtrl:Key.isDown(Key.CONTROL),
			useLeft:Key.isDown(Key.LEFT),
			useRight:Key.isDown(Key.RIGHT),
			useUp:Key.isDown(Key.UP),
			useDown:Key.isDown(Key.DOWN)
		}
		
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * Set the listeners on the ui components
	 */
	private function setListeners():Void
	{
		//scale handles
		scaleHandleB.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleB, scaleHandleT);
		scaleHandleBL.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleBL, scaleHandleTR);
		scaleHandleT.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleT, scaleHandleB);
		scaleHandleTL.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleTL, scaleHandleBR);
		scaleHandleTR.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleTR, scaleHandleBL);
		scaleHandleBR.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleBR, scaleHandleTL);
		scaleHandleR.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleR, scaleHandleL);
		scaleHandleL.onPress = Utils.createDelegate(this, onScaleHandlePress, scaleHandleL, scaleHandleR);
		
		scaleHandleB.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_B);
		scaleHandleBL.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_BL);
		scaleHandleT.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_T);
		scaleHandleTL.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_TL);
		scaleHandleTR.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_TR);
		scaleHandleBR.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_BR);
		scaleHandleR.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_R);
		scaleHandleL.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_SCALE_HANDLE_L);
		
		scaleHandleB.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleBL.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleT.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleTL.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleTR.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleBR.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleR.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		scaleHandleL.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		
		scaleHandleB.useHandCursor = false;
		scaleHandleBL.useHandCursor  = false;
		scaleHandleT.useHandCursor = false;
		scaleHandleTL.useHandCursor = false;
		scaleHandleTR.useHandCursor = false;
		scaleHandleBR.useHandCursor = false;
		scaleHandleR.useHandCursor = false;
		scaleHandleL.useHandCursor = false;
		
		//rotation handles
		rotationHandleBL.onPress = Utils.createDelegate(this, onRotationHandlePress, rotationHandleBL);
		rotationHandleBR.onPress = Utils.createDelegate(this, onRotationHandlePress, rotationHandleBR);
		rotationHandleTL.onPress = Utils.createDelegate(this, onRotationHandlePress, rotationHandleTL);
		rotationHandleTR.onPress = Utils.createDelegate(this, onRotationHandlePress, rotationHandleTR);
		
		rotationHandleBL.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_ROTATION_HANDLE_BL);
		rotationHandleBR.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_ROTATION_HANDLE_BR);
		rotationHandleTL.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_ROTATION_HANDLE_TL);
		rotationHandleTR.onRollOver = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_OVER_ROTATION_HANDLE_TR);
		
		rotationHandleBL.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		rotationHandleBR.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		rotationHandleTL.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		rotationHandleTR.onRollOut = Utils.createDelegate(this, setMouseCursor, MouseCursorManager.MOUSE_CURSOR_DEFAULT);
		
		rotationHandleBL.useHandCursor = false;
		rotationHandleBR.useHandCursor = false;
		rotationHandleTL.useHandCursor = false;
		rotationHandleTR.useHandCursor = false;
		
		
		//pivot point
		pivotPoint.onPress = Utils.createDelegate(this, onPivotPointPlace);	
		
		//keyboard
		_keyboardListener = new Object();
		_keyboardListener.onKeyDown = Utils.createDelegate(this, onKeyBoardKeyDown);
		_keyboardListener.onKeyUp = Utils.createDelegate(this, onKeyBoardKeyUp);
		
		Key.addListener(_keyboardListener);
		
		
		//mouse
		_mouseListener = new Object();
		_mouseListener.onMouseMove = Utils.createDelegate(this, onMouseMove);
		_mouseListener.onMouseUp = Utils.createDelegate(this, onMouseUp);
		
		Mouse.addListener(_mouseListener);
	}
	
	
	/**
	 * Initialise the ui components and set the listeners on them. Then call the hook starting
	 * the selection Manager
	 */
	private function init():Void
	{
		hideUis();
		
		scaleHandleB.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM;
		scaleHandleBL.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM_LEFT;
		scaleHandleL.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_LEFT;
		scaleHandleTL.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_TOP_LEFT;
		scaleHandleT.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_TOP;
		scaleHandleTR.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_TOP_RIGHT;
		scaleHandleR.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_RIGHT;
		scaleHandleBR.handlePosition = ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM_RIGHT;
		
		
		rotationHandleTL.handlePosition = RotationHandle.ROTATION_HANDLE_POSITION_TL;
		rotationHandleTR.handlePosition = RotationHandle.ROTATION_HANDLE_POSITION_TR;
		rotationHandleBR.handlePosition = RotationHandle.ROTATION_HANDLE_POSITION_BR;
		rotationHandleBL.handlePosition = RotationHandle.ROTATION_HANDLE_POSITION_BL;
		
		setListeners();
		
		HookManager.getInstance().callHooks(HOOK_UIS_READY, this);
	}
	
	/**
	 * Hide all the ui components
	 */
	private function hideUis():Void
	{
		this.selectionRegion._visible = false;
		this.selectionDrawing._visible = false;
		pivotPoint._visible = false;
		hideHandles();
		
	}
	
	/**
	 * place the rotation and scale handles when the selection region is updated
	 */
	private function placeHandles():Void
	{
		//scale handles
		scaleHandleTL._x = Math.round(selectionRegion._x);
		scaleHandleTL._y = Math.round(selectionRegion._y);
		
		scaleHandleT._x = Math.round(selectionRegion._x + (selectionRegion._width / 2));
		scaleHandleT._y = Math.round(selectionRegion._y );
		
		scaleHandleTR._x = Math.round(selectionRegion._x + (selectionRegion._width ) );
		scaleHandleTR._y = Math.round(selectionRegion._y );
		
		scaleHandleR._x = Math.round(selectionRegion._x + (selectionRegion._width ) );
		scaleHandleR._y = Math.round(selectionRegion._y + (selectionRegion._height / 2));
		
		scaleHandleBR._x = Math.round(selectionRegion._x + (selectionRegion._width ) );
		scaleHandleBR._y = Math.round(selectionRegion._y + (selectionRegion._height) );
		
		scaleHandleB._x = Math.round(selectionRegion._x + (selectionRegion._width / 2 ) );
		scaleHandleB._y = Math.round(selectionRegion._y + (selectionRegion._height) );
		
		scaleHandleBL._x = Math.round(selectionRegion._x  );
		scaleHandleBL._y = Math.round(selectionRegion._y + (selectionRegion._height) );
		
		scaleHandleL._x = Math.round(selectionRegion._x  );
		scaleHandleL._y = Math.round(selectionRegion._y + (selectionRegion._height / 2) );
		
		
		//rotation handles
		rotationHandleTL._x = Math.round(selectionRegion._x - rotationHandleTL._width - Math.round(scaleHandleTL._width / 2));
		rotationHandleTL._y = Math.round(selectionRegion._y - rotationHandleTL._height - Math.round(scaleHandleTL._height / 2));
		
		rotationHandleTR._x = Math.round(selectionRegion._x + selectionRegion._width  + Math.round(scaleHandleTL._width / 2));
		rotationHandleTR._y = Math.round(selectionRegion._y - rotationHandleTL._height - Math.round(scaleHandleTL._height / 2));
		
		rotationHandleBR._x = Math.round(selectionRegion._x + selectionRegion._width  + Math.round(scaleHandleTL._width / 2));
		rotationHandleBR._y = Math.round(selectionRegion._y + selectionRegion._height + Math.round(scaleHandleTL._height / 2));
		
		rotationHandleBL._x = Math.round(selectionRegion._x - rotationHandleTL._width - Math.round(scaleHandleTL._width / 2));
		rotationHandleBL._y = Math.round(selectionRegion._y + selectionRegion._height + Math.round(scaleHandleTL._height / 2));
		
	}
	
	/////////////////////////////////////////
		// UIS CALLBACKS
	////////////////////////////////////////
	
	/**
	 * Called when one of the scale handle is pressed
	 * @param	target the clicked scale handle
	 * @param opositeHandle the handle oposed to the clicked one
	 */
	private function onScaleHandlePress(target:ScaleHandle, opositeHandle:ScaleHandle):Void
	{
		dispatchEvent(new UIEvent(UIEvent.MOUSE_EVENT_SCALE_HANDLE_MOUSE_DOWN, {
			target: { x:target._x, y:target._y },
			opositeHandle: { x:opositeHandle._x, y:opositeHandle._y },
			handlePosition:target.handlePosition}));
	}
	
	/**
	 * Called when one of the rotation handle is pressed
	 * @param	target the clicked rotation handle
	 */
	private function onRotationHandlePress(target:RotationHandle):Void
	{
		dispatchEvent(new UIEvent(UIEvent.MOUSE_EVENT_ROTATION_HANDLE_MOUSE_DOWN, {target:{x:target._x, y:target._y}, handlePosition:target.handlePosition} ));
	}
	
	/**
	 * Called when the pivot point is pressed
	 */
	private function onPivotPointPlace():Void
	{
		dispatchEvent(new UIEvent(UIEvent.MOUSE_EVENT_PIVOT_POINT_MOUSE_DOWN));
	}
	
	/**
	 * on key down, dispatches an event for the UiManager
	 */
	private function onKeyBoardKeyDown():Void
	{
		dispatchEvent(new UIEvent(UIEvent.KEYBOARD_EVENT_KEY_DOWN));
	}
	
	/**
	 * on key up, dispatches an event for the UiManager
	 */
	private function onKeyBoardKeyUp():Void
	{
		dispatchEvent(new UIEvent(UIEvent.KEYBOARD_EVENT_KEY_UP));
	}
	
	/**
	 * on mouse move, dispatches an event for the UiManager
	 */
	private function onMouseMove():Void
	{
		dispatchEvent(new UIEvent(UIEvent.MOUSE_EVENT_MOUSE_MOVED));
	}
	
	/**
	 * on mouse up, dispatches an event for the UiManager
	 */
	private function onMouseUp():Void
	{
		dispatchEvent(new UIEvent(UIEvent.MOUSE_EVENT_MOUSE_UP));
	}
	
	
}