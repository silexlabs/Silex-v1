import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetContainersBase;

/**
 * This is an asset container class for selected components
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.SelectedComponentsContainer extends AssetContainersBase
{
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * override the asset ID and name to match those of the 
	 * selected component asset
	 */
	public function SelectedComponentsContainer() 
	{
		_assetLibraryID = "SelectedComponentBackground";
		_assetInstanceName = "selectedComponentBackground";
	}
	
}