package  org.silex.editionToolBar.toolbarItems.items{
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.selection.SelectionManager;
import org.silex.editionToolBar.toolbarItems.EditionToolBarButtonBase;
	
/**
* This is the class used for the navigation edition toolbar item, used to switch to 
* navigation mode. when switching to navigation mode, all components are made on-editable
* and can be click to browse the publication
* 
* @author Yannick DOMINGUEZ 
*/	
public class NavigationButton extends EditionToolBarButtonBase {

	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Set the tool item uid and listens for layout data change event on the SilexAdminApi
	 */
	public function NavigationButton() {
		_toolItemUid = "silex.EditionToolBar.ToolItem.Navigation";
		SilexAdminApi.getInstance().toolBarGroups.select([_toolItemUid]);
		SilexAdminApi.getInstance().layouts.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, onLayoutDataChanged);
		
		super();
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// OVERRIDEN METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * when the tool item is clicked, set the selection manager to navigation mode
	 */
	override protected function setSelectionMode():void
	{
		SilexAdminApi.getInstance().selectionManager.setSelectionMode(SelectionManager.SELECTION_MODE_NAVIGATION);
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When the layout data changes, meaning that the user is browsing the publication, switch back to 
	 * navigation mode. It is a safety method called for instance when the user locks an icon component, making it non-editable.
	 * If the user clicks the component, a new page is opened and the selection manager switch back to navigation mode
	 * 
	 */ 
	private function onLayoutDataChanged(event:AdminApiEvent):void
	{
		setSelectionMode();
		SilexAdminApi.getInstance().toolBarGroups.select([_toolItemUid]);
	}


}
	
}
