import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetContainersBase;

/**
 * This is an asset container class for highlighted components
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.HighlightedComponentsContainer extends AssetContainersBase
{
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * override the asset ID and name to match those of the 
	 * highlighted component asset
	 */
	public function HighlightedComponentsContainer() 
	{
		_assetLibraryID = "HighlightedBackground";
		_assetInstanceName = "highlightedComponentBackground";
	}
	
}