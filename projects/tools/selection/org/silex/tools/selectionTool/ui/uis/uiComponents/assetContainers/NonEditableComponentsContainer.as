import org.silex.core.plugin.HookManager;
import org.silex.core.Utils;
import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetBase;
import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetContainersBase;

/**
 * This is an asset container class placing component place holder on top of each non editable components
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.NonEditableComponentsContainer extends AssetContainersBase
{
	
	////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The hook called when a non editable component place holder is clicked
	 */
	public static var NON_EDITABLE_COMPONENT_PLACE_HOLDER_PRESS_HOOK:String = "onNonEditableComponentPlaceHolderPress";
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * override the asset ID and name to match those of the 
	 * non editable component place holder asset
	 */
	public function NonEditableComponentsContainer() 
	{
		_assetLibraryID = "NonEditableComponentsPlaceHolder";
		_assetInstanceName = "nonEditableComponentsPlaceHolder";
	}
	
	/////////////////////////////////////
	// OVERRIDEN METHODS
	////////////////////////////////////
	
	/**
	 * add click listener to a component place holder
	 * @param	assetInstance the asset instance to listen
	 */
	private function setAssetInstanceListeners(assetInstance:MovieClip):Void
	{
		assetInstance.onPress = Utils.createDelegate(this, onAssetPress, assetInstance);
		assetInstance.useHandCursor = false;
	}
	
	/**
	 * remove click listeners from a component place holder
	 * @param	assetInstance the asset to remove listeners from
	 */
	private function removeAssetInstanceListeners(assetInstance:MovieClip):Void
	{
		assetInstance.onPress = undefined;
		Utils.removeDelegate(this, onAssetPress, assetInstance);
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * When a non editable component place holder is pressed, calls a hook added by the
	 * SelectionManager, sending the pressed place holder component's uid
	 * @param	asset the pressed place holder
	 */
	private function onAssetPress(asset:AssetBase):Void
	{
		HookManager.getInstance().callHooks(NON_EDITABLE_COMPONENT_PLACE_HOLDER_PRESS_HOOK, asset.uid);
	}
	
}