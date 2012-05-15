package  org.silex.editionToolBar.toolbarItems {
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.selection.SelectionManager;

/**
 * This is a base class for the buttons in the edition toolbar. It manages the tool item selection
 * @author Yannick DOMINGUEZ
 */
public class EditionToolBarButtonBase extends MovieClip{
	
		/////////////////////**/*/*/*/*/*/*/
		// ATTRIBUTES
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * a reference to the currently displayed button
		 */
		protected var _button:SimpleButton;
		
		/**
		 * The uid of this tool item
		 */
		protected var _toolItemUid:String;

		/////////////////////**/*/*/*/*/*/*/
		// CONSTRUCTOR
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * Instantiate the default up button (non selected) and listens for click on the button and
		 * for selected tool item changes on the SilexAdminApi
		 */
		public function EditionToolBarButtonBase() {
			_button = new UpButton();
			addChild(_button);
			_button.addEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp);
			SilexAdminApi.getInstance().toolBarGroups.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, onGroupSelectionChanged);
			
		}
		
		/////////////////////**/*/*/*/*/*/*/
		// PROTECTED METHODS
		////////////////////**/*/*/*/*/*/*/
		
		/**
		 * When the user click on the button, select it in the toolbar group to unselect all the other buttons
		 * in the group, then selects the right selection mode for the selection manager (selection, drawing...)
		 * @param	event the mouseEvent dispatched by the clicked button
		 */
		protected function onButtonMouseUp(event:MouseEvent):void
		{
			SilexAdminApi.getInstance().toolBarGroups.select([_toolItemUid]);
			setSelectionMode();
		}
		
		/**
		 * When the selection in a group changes, the tool item checks if its uid is selected
		 * and if it is, display the selected button state and set events listeners
		 * @param	event triggered when the selection changes on the tool items
		 */
		protected function onGroupSelectionChanged(event:AdminApiEvent):void
		{
			//retrieve the new item seelction
			var newSelection:Array = SilexAdminApi.getInstance().toolBarGroups.getSelection();
			
			//checks if this item uid is among the selection
			var flagSelection:Boolean = false;
			for (var i:int = 0; i<newSelection.length; i++)
			{
				if (newSelection[i] == _toolItemUid)
				{
					flagSelection = true;
				}
			}
			
			removeChild(_button);
			_button.removeEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp);
			
			//if this item is selected
			//set listeners and instantiate the selected button skin
			if (flagSelection == true)
			{
				
				_button = new SelectedButton();
				setListeners();
			}
			
			//else remove the listners and instantiate the up button skin
			else
			{
				_button = new UpButton();
				removeListeners();
			}
			_button.addEventListener(MouseEvent.MOUSE_UP, onButtonMouseUp);
			addChild(_button);
		}
		
		/**
		 * Set this tool items listeners when it is selected. To be overriden by
		 * inherting classes
		 */
		protected function setListeners():void
		{
			//abstract
		}
		
		/**
		 * Removes this tool items listners when it is unselected. To be overriden by
		 * inherting classes
		 */
		protected function removeListeners():void
		{
			//abstract
		}
		
		/**
		 * Set the selection mode of the selection manager. To be overriden by inheriting classes
		 */
		protected function setSelectionMode():void
		{
			//abstract
		}

	}
	
}
