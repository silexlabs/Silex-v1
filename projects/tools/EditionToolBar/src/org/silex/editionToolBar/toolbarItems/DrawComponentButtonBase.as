package  org.silex.editionToolBar.toolbarItems {
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.listedObjects.Property;
import org.silex.adminApi.listModels.Components;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.selection.SelectionManager;

/**
 * This is a base class for the edition toolbar items whose roles are to add a component
 * by drawing it on the publication. Listens to the selectionManager drawing events and manages the component
 * creation and properties update
 * @author Yannick DOMINGUEZ 
 */
public class DrawComponentButtonBase extends EditionToolBarButtonBase{

		/////////////////////**/*/*/*/*/*/*/
		// ATTRIBUTES
		////////////////////**/*/*/*/*/*/*/
	
		/**
		 * The uid of the last created component
		 */
		protected var _componentUid:String;
		
		/**
		 * The data of the last drawing event dispatched by the SelectionManager
		 */
		protected var _selectionRegionEventData:Object;
		
		/**
		 * Flag telling if EVENT_COMPONENT_CREATED or SELECTION_REGION_STOP_DRAWING events have been called
		 */
		protected var _compCreatedOrSelectionDrawnFlag:Boolean;

		/////////////////////**/*/*/*/*/*/*/
		// CONSTRUCTOR
		////////////////////**/*/*/*/*/*/*/
		
		public function DrawComponentButtonBase() {
			super();
			_compCreatedOrSelectionDrawnFlag = false;
		}
		
		/////////////////////**/*/*/*/*/*/*/
		// OVERRIDEN METHODS
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * Set listeners on the drawing events of the SelectionManager
		 */
		override protected function setListeners():void
		{
			super.setListeners();
			SilexAdminApi.getInstance().selectionManager.addEventListener(SelectionManager.SELECTION_REGION_START_DRAWING, onSelectionRegionStartDrawing);
		}
		
		/**
		 * Removes the listeners on the drawing events of the SelectionManager
		 */
		override protected function removeListeners():void
		{
			super.removeListeners();
			SilexAdminApi.getInstance().selectionManager.removeEventListener(SelectionManager.SELECTION_REGION_START_DRAWING, onSelectionRegionStartDrawing);
			SilexAdminApi.getInstance().selectionManager.removeEventListener(SelectionManager.SELECTION_REGION_DRAWING, onSelectionRegionDrawing);
			SilexAdminApi.getInstance().selectionManager.removeEventListener(SelectionManager.SELECTION_REGION_STOP_DRAWING, onSelectionRegionDrawn);
		}
		
		/**
		 * Set the drawing selection mode as default as this is the most likely
		 * used by inheriting classes
		 */
		override protected function setSelectionMode():void
		{
			SilexAdminApi.getInstance().selectionManager.setSelectionMode(SelectionManager.SELECTION_MODE_DRAWING);
		}
		
		/////////////////////**/*/*/*/*/*/*/
		// PROTECTED METHODS
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * When the selection drawing is complete, stores the event data and update the component
		 * properties if it's initialisation is complete (checked with the pending attribute). If the initialisation
		 * is not complete, the propeties will be updated when the component creation event is dispatched
		 * @param	event the drawing event dispatched by the SelectionManager
		 */
		protected function onSelectionRegionDrawn(event:AdminApiEvent):void
		{
			// remove uneeded listeners
			SilexAdminApi.getInstance().selectionManager.removeEventListener(SelectionManager.SELECTION_REGION_DRAWING, onSelectionRegionDrawing);
			SilexAdminApi.getInstance().selectionManager.removeEventListener(SelectionManager.SELECTION_REGION_STOP_DRAWING, onSelectionRegionDrawn);
			
			// set _selectionRegionEventData to the event containing the position of the drawn region
			_selectionRegionEventData = event.data;
			
			// update component properties
			updateComponentProperties();
		}
		
		/**
		 * When the selection drawing starts, instantiate the component and listens for it's creation complete event and reset
		 * the creation attributes
		 * @param	event the drawing event dispatched by the SelectionManager
		 */
		protected function onSelectionRegionStartDrawing(event:AdminApiEvent):void
		{
			// checks if _compCreatedOrSelectionDrawnFlag is false
			// i.e. if there are no listeners on EVENT_COMPONENT_CREATED and SELECTION_REGION_STOP_DRAWING events
			if(_compCreatedOrSelectionDrawnFlag == false)
			{
				// set variables
				_selectionRegionEventData = null;

				// remove uneeded listener
				SilexAdminApi.getInstance().selectionManager.removeEventListener(SelectionManager.SELECTION_REGION_START_DRAWING, onSelectionRegionStartDrawing);

				// set needed listeners
				SilexAdminApi.getInstance().selectionManager.addEventListener(SelectionManager.SELECTION_REGION_DRAWING, onSelectionRegionDrawing);
				SilexAdminApi.getInstance().selectionManager.addEventListener(SelectionManager.SELECTION_REGION_STOP_DRAWING, onSelectionRegionDrawn);
				SilexAdminApi.getInstance().components.addEventListener(Components.EVENT_COMPONENT_CREATED, onComponentCreated);
				
				// create component
				_componentUid = addComponent(event.data);
			}
		}
		
		/**
		 * Called when the selection drawing is in progress if the item is selected
		 * @param	event the event dispatched by the SelectionManager
		 */
		protected function onSelectionRegionDrawing(event:AdminApiEvent):void
		{
			//Abstract
		}
		
		/**
		 * Update the last created component coordinates properties through SilexAdminApi
		 */
		protected function updateComponentProperties():void
		{
			// if none of the two EVENT_COMPONENT_CREATED or SELECTION_REGION_STOP_DRAWING events have been called, set flag
			if (_compCreatedOrSelectionDrawnFlag == false)
			{
				_compCreatedOrSelectionDrawnFlag = true;
			}
			// if one of the two EVENT_COMPONENT_CREATED or SELECTION_REGION_STOP_DRAWING events have been called, update properties
			else
			{
				var properties:Object = SilexAdminApi.getInstance().properties.getSortedData([_componentUid], ["x", "y", "width", "height"])[0];
				(properties.x as Property).updateCurrentValue(_selectionRegionEventData.coords.x);
				(properties.y as Property).updateCurrentValue(_selectionRegionEventData.coords.y);
				
				(properties.width as Property).updateCurrentValue(_selectionRegionEventData.coords.width);
				(properties.height as Property).updateCurrentValue(_selectionRegionEventData.coords.height);
				
				_compCreatedOrSelectionDrawnFlag = false;
				
				// add needed listener so a new component can be created
				SilexAdminApi.getInstance().selectionManager.addEventListener(SelectionManager.SELECTION_REGION_START_DRAWING, onSelectionRegionStartDrawing);
			}
		}
		
		/**
		 * When the component is created, update the component properties if they have been previously stored. It is necessary
		 * for the case where the user stops the selection drawing before that the component creation is complete
		 * @param	event the component creation event dispatched by the SilexAdminApi
		 */
		protected function onComponentCreated(event:AdminApiEvent):void
		{
			SilexAdminApi.getInstance().components.removeEventListener(Components.EVENT_COMPONENT_CREATED, onComponentCreated);
			updateComponentProperties();
		}
		
		/**
		 * Add the component with SilexAdminApi, must be overriden by inheriting
		 * toolItem to instantiate their own components
		 * @param	eventData the data of the drawing event containing the drawing coords
		 * @return the uid of the created component
		 */
		protected function addComponent(eventData:Object):String
		{
			//abstract
			return null;
		}
	}
}
