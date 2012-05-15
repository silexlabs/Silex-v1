package  org.silex.editionToolBar.toolbarItems.items{
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.selection.SelectionManager;
import org.silex.editionToolBar.toolbarItems.DrawComponentButtonBase;

/**
* This is the class used for the "arrow" edition toolbar item, used to switch to 
* selection mode. It extends the draw component button base class as it listens to drawing event
* to select components within the drawn region
* @author Yannick DOMINGUEZ 
*/
public class SelectionButton extends DrawComponentButtonBase {

	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Set the toolItem uid, and select it as selection is the default mode, this 
	 * tool item must be selected when the admin logs in
	 */
	public function SelectionButton() {
		_toolItemUid = "silex.EditionToolBar.ToolItem.Selection";
		
		
		//listens for selection changes on components
		SilexAdminApi.getInstance().components.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, onSelectionEvent);
		
		super();
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// OVERRIDEN METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When the selection region has been drawn by the user, call a method on the selection
	 * manager to select all the components within the drawn region
	 * @param	event triggered by the SelectionManager on region drawing stop
	 */
	override protected function onSelectionRegionDrawn(event:AdminApiEvent):void
	{
		
		var useShift:Boolean;
		if (event.data.useShift == "false")
		{
			useShift =  false;
		}
		else
		{
			useShift = true;
		}
		SilexAdminApi.getInstance().selectionManager.selectRegion(event.data.coords, useShift);
	}
	
	/**
	 * set the selection mode as Selection. This method is called when this tool item is pressed
	 */
	override protected function setSelectionMode():void
	{
		SilexAdminApi.getInstance().selectionManager.setSelectionMode(SelectionManager.SELECTION_MODE_SELECTION);
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When the selection changes on the display components, switch back to 
	 * selection mode. This is a safety method useful when the user is for instance in drawing mode.
	 * When he selects the drawn component to edit it, this methods automatically switch the selection manager
	 * back to selection mode
	 * @param	event triggered by the Selection Manager
	 */
	private function onSelectionEvent(event:AdminApiEvent):void
	{
		//the second arguments prevent unlocking all components. Components are all unlocked only if the selection button
		//is pressed by the user
		SilexAdminApi.getInstance().selectionManager.setSelectionMode(SelectionManager.SELECTION_MODE_SELECTION, false);
		
		SilexAdminApi.getInstance().toolBarGroups.select([_toolItemUid]);
	}
	


}
	
}
