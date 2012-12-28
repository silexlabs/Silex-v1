/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.components;
import haxe.Log;
import org.silex.adminApi.selection.com.HookManagerCommunication;
import org.silex.adminApi.selection.com.SilexApiCommunication;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.SelectionManager;
import org.silex.adminApi.selection.com.SilexAdminApiCommunication;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

/**
 * Manages the components selection. Set listeners on the editable components place holders and the background and dispatches signals
 * for the SelectionManager when the user interacts with them
 * @author Yannick DOMINGUEZ
 */
class ComponentsManager 
{
	////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The hook called when a component place holder is clicked
	 */
	public inline static var COMPONENT_PLACE_HOLDER_PRESS_HOOK:String = "onComponentPlaceHolderPress";
	
	/**
	 * The hook called when a component place holder is rolled over
	 */
	public inline static var COMPONENT_PLACE_HOLDER_ROLL_OVER_HOOK:String = "onComponentPlaceHolderRollOver";
	
	/**
	 * The hook called when a component place holder is rolled out
	 */
	public inline static var COMPONENT_PLACE_HOLDER_ROLL_OUT_HOOK:String = "onComponentPlaceHolderRollOut";
	
	/**
	 * The hook called when a non editable component place holder is clicked
	 */
	public inline static var NON_EDITABLE_COMPONENT_PLACE_HOLDER_PRESS_HOOK:String = "onNonEditableComponentPlaceHolderPress";
	
	////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * the name of the current selection mode
	 */
	private var _selectionMode:String;
	
	/**
	 * dispatches a signal when an editable component place holder is clicked
	 */
	public var componentPlaceHolderMouseDownSignaler(default, null):Signaler<ComponentCoordsProxy>;
	
	/**
	 * dispatches a signal when an editable component place holder is rolled over
	 */
	public var componentPlaceHolderRollOverSignaler(default, null):Signaler<ComponentCoordsProxy>;
	
	/**
	 * dispatches a signal when an editable component place holder is rolled out
	 */
	public var componentPlaceHolderRollOutSignaler(default, null):Signaler<Void>;
	
	/**
	 * dispatches a signal when the background is clicked
	 */
	public var backgroundMouseDownSignaler(default, null):Signaler<Void>;
	
	
	////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Initialise the signalers and set a listener to the background click. Add hooks
	 */
	public function new() 
	{
		
		componentPlaceHolderMouseDownSignaler = new DirectSignaler(this);
		backgroundMouseDownSignaler = new DirectSignaler(this);
		componentPlaceHolderRollOutSignaler = new DirectSignaler(this);
		componentPlaceHolderRollOverSignaler = new DirectSignaler(this);
		
		setBackgroundListener();
		
		addHooks();
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * For all the components coord proxy in the transformedComponentsData array, update the coordinates of the coreesponding
	 * components
	 * with the placeComponents method
	 * @param	tranformedComponentsData an array containing the updated components coord with the corresponding component uid
	 */
	public function placeComponents(tranformedComponentsData:Array<ComponentCoordsProxy>):Void
	{
		var tranformedComponentsDataLength:Int = tranformedComponentsData.length;
		for (i in 0...tranformedComponentsDataLength)
		{
			this.placeComponent(tranformedComponentsData[i]);
		}
	}
	
	/**
	 * Set the selection mode on the component manager.
	 * @param	selectionMode the name of the selection mode
	 */
	public function setSelectionMode(selectionMode:String):Void
	{
		_selectionMode = selectionMode;
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	
	////////////////////**/*/*/*/*/*/*/
		// LISTENERS METHODS
		// set and remove listeners
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Addf hooks for press, roll over and roll out event on Components place holders
	 */
	private function addHooks():Void
	{
		HookManagerCommunication.getInstance().componentPlaceHolderMouseDownSignaler.bind(onComponentPlaceHolderMouseDown);
		HookManagerCommunication.getInstance().nonEditableComponentPlaceHolderMouseDownSignaler.bind(onNonEditableComponentPlaceHolderMouseDown);
		HookManagerCommunication.getInstance().componentPlaceHolderRollOverSignaler.bind(onComponentPlaceHolderRollOver);
		HookManagerCommunication.getInstance().componentPlaceHolderRollOutSignaler.bindVoid(onComponentPlaceHolderRollOut);
	}
	
	/**
	 * Set a listener for click event on the background movieClip, through the SilexApi abstraction
	 * class 
	 */
	private function setBackgroundListener():Void
	{
		SilexApiCommunication.getInstance().silexApiBackgroundMouseDownSignaler.bindVoid(onBackgroundMouseDown);
	}
	
	/////////////////////////////////////////
		// CALLBACKS METHODS
	////////////////////////////////////////
	
	/**
	 * When a component place holder is pressed, dispatch a signal sending the actual component 
	 * coords. The signal changes based on the current selection mode
	 * @param	componentUid the uid of the clicked component
	 */
	private function onComponentPlaceHolderMouseDown(componentUid:String):Void
	{
		switch (_selectionMode)
		{
			//in selection mode, we dispatch the component place holder mouse down signal
			//as we want to select the component
			case SelectionManager.SELECTION_MODE_SELECTION:
			//only dispatch the signal if the component is editable
			if (checkIfEditable(componentUid) == true)
			{
				componentPlaceHolderMouseDownSignaler.dispatch(SilexAdminApiCommunication.getInstance().getComponentCoordsProxyFromUid(componentUid));
			}
			
			//we don't dispatch a signal in navigation mode as the user wants to browse
			//the site and not select or move a component
			case SelectionManager.SELECTION_MODE_NAVIGATION:
			
			//in drawing mode we dispatch the same signal as the background click signal
			//as we want to draw a zone, even if we click on a component place holder
			case SelectionManager.SELECTION_MODE_DRAWING:
			backgroundMouseDownSignaler.dispatch();
		}
		
	}
	
	/**
	 * When a non editable component place holder is pressed, sends the same signal as when the
	 * background is clicked as we want to start drawing a selection region
	 * @param	componentUid the uid of the clicked non-editable component place holder
	 */
	private function onNonEditableComponentPlaceHolderMouseDown(componentUid:String):Void
	{
		switch(_selectionMode)
		{
			//only dispatch in those modes
			case SelectionManager.SELECTION_MODE_SELECTION,
			SelectionManager.SELECTION_MODE_DRAWING:
			backgroundMouseDownSignaler.dispatch();
		}
	}
	
	/**
	 * When a component place holder is rolled over, dispatch a signal with the actual rolled over component's coords. The signal might not get dispatched
	 * based on the current selection mode
	 * @param	componentUid the uid of the rolled over component
	 */
	private function onComponentPlaceHolderRollOver(componentUid:String):Void
	{
		switch (_selectionMode)
		{
			case SelectionManager.SELECTION_MODE_SELECTION:
			//only dispatch the signal if the component is editable
			if (checkIfEditable(componentUid) == true)
			{
				componentPlaceHolderRollOverSignaler.dispatch(SilexAdminApiCommunication.getInstance().getComponentCoordsProxyFromUid(componentUid));
			}
			
			
			//we don't dispatch a signal in navigation or drawing mode as the user wants to browse or draw
			// and not highlight the editable components
			case SelectionManager.SELECTION_MODE_NAVIGATION,
			SelectionManager.SELECTION_MODE_DRAWING:
		}
	}
	
	/**
	 * When a component place holder is rolled out, dispatch a signal
	 * @param event the event dispatched by the rolled out component place holder
	 */
	private function onComponentPlaceHolderRollOut():Void
	{
		componentPlaceHolderRollOutSignaler.dispatch();
	}
	
	/**
	 * When the user clicks on the background of the publication, dispatches a signal. The signal changes
	 * based on the selection mode, in navigation mode, we don't dispatch a signal as we don't want to register
	 * clicks on the background
	 */
	private function onBackgroundMouseDown():Void
	{
		switch (_selectionMode)
		{
			case SelectionManager.SELECTION_MODE_SELECTION,
			SelectionManager.SELECTION_MODE_DRAWING:
			backgroundMouseDownSignaler.dispatch();
		}
	}
	
	/////////////////////////////////////////
		// UTILITIES METHODS
	////////////////////////////////////////
	
	/**
	 * Returns wether a component is editable or not with it's uid
	 * @param	componentUid the uid of the component to check
	 */
	private function checkIfEditable(componentUid:String):Bool
	{
		return SilexAdminApiCommunication.getInstance().getComponentProxyFromUid(componentUid).getEditable();
	}
	
	/**
	 * Update the position of a component, retrieving it with it's uid
	 * @param	transformedComponentData the new coordinates of the component and it's uid
	 */
	private function placeComponent(transformedComponentData:ComponentCoordsProxy):Void
	{
		var component:Dynamic = SilexAdminApiCommunication.getInstance().getComponentProxyFromUid(transformedComponentData.componentUid).getComponent();

		if (transformedComponentData.componentCoords.x != null)
		{
			component._x = transformedComponentData.componentCoords.x;
		}
		
		if (transformedComponentData.componentCoords.y != null)
		{
			component._y = transformedComponentData.componentCoords.y;
		}
		
		if (transformedComponentData.componentCoords.width != null)
		{
			if (component.width != null)
			{
				component.width = transformedComponentData.componentCoords.width;
			}
			else if (component._width != null)
			{
				component._width = transformedComponentData.componentCoords.width;
			}
		}
		
		if (transformedComponentData.componentCoords.height != null)
		{
			if (component.height != null)
			{
				component.height = transformedComponentData.componentCoords.height;
			}
			else if (component._height != null)
			{
				component._height = transformedComponentData.componentCoords.height;
			}
		}
		
		if (transformedComponentData.componentCoords.rotation != null)
		{
			component._rotation = transformedComponentData.componentCoords.rotation;
		}
	}
	
}