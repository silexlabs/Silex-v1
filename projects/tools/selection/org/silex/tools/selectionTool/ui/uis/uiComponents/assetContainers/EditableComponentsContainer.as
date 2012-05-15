import org.silex.core.plugin.HookManager;
import org.silex.core.Utils;
import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetBase;
import org.silex.tools.selectionTool.ui.uis.uiComponents.AssetContainersBase;

/**
 * This is an asset container class placing component place holder on top of each editable components, and
 * listening for user event on those place holders
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.uiComponents.assetContainers.EditableComponentsContainer extends AssetContainersBase
{
	////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The hook called when a component place holder is clicked
	 */
	public static var COMPONENT_PLACE_HOLDER_PRESS_HOOK:String = "onComponentPlaceHolderPress";
	
	/**
	 * The hook called when a component place holder is rolled over
	 */
	public static var COMPONENT_PLACE_HOLDER_ROLL_OVER_HOOK:String = "onComponentPlaceHolderRollOver";
	
	/**
	 * The hook called when a component place holder is rolled out
	 */
	public static var COMPONENT_PLACE_HOLDER_ROLL_OUT_HOOK:String = "onComponentPlaceHolderRollOut";
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * override the asset ID and name to match those of the 
	 * editable component place holder asset
	 */
	public function EditableComponentsContainer() 
	{
		_assetLibraryID = "EditableComponentPlaceHolder";
		_assetInstanceName = "editableComponentPlaceHolder";
	}
	
	/////////////////////////////////////
	// OVERRIDEN METHODS
	////////////////////////////////////
	
	/**
	 * add click, roll over and roll out listeners to a component place holder
	 * @param	assetInstance the asset instance to listen
	 */
	private function setAssetInstanceListeners(assetInstance:MovieClip):Void
	{
		assetInstance.onPress = Utils.createDelegate(this, onAssetPress, assetInstance);
		assetInstance.onRollOut = Utils.createDelegate(this, onAssetRollOut, assetInstance);
		assetInstance.onRollOver = Utils.createDelegate(this, onAssetRollOver, assetInstance);
		assetInstance.useHandCursor = false;
	}
	
	/**
	 * remove click, roll over and roll out listeners from a component place holder
	 * @param	assetInstance the asset to remove listeners from
	 */
	private function removeAssetInstanceListeners(assetInstance:MovieClip):Void
	{
		assetInstance.onPress = undefined;
		Utils.removeDelegate(this, onAssetPress, assetInstance);
	
		
		assetInstance.onRollOut = undefined;
		Utils.removeDelegate(this, onAssetRollOut, assetInstance);
		
		assetInstance.onRollOver = undefined;
		Utils.removeDelegate(this, onAssetRollOver, assetInstance);
		
		
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * When a component place holder is pressed, calls a hook added by the
	 * SelectionManager, sending the pressed place holder component's uid
	 * @param	asset the pressed place holder
	 */
	private function onAssetPress(asset:AssetBase):Void
	{
		HookManager.getInstance().callHooks(COMPONENT_PLACE_HOLDER_PRESS_HOOK, asset.uid);
	}
	
	/**
	 * When a component place holder is rolled out, calls a hook added by the
	 * SelectionManager
	 * @param	asset the rolled out place holder
	 */
	private function onAssetRollOut(asset:AssetBase):Void
	{
		HookManager.getInstance().callHooks(COMPONENT_PLACE_HOLDER_ROLL_OUT_HOOK);
	}
	
	/**
	 * When a component place holder is rolled over, calls a hook added by the
	 * SelectionManager, sending the rolled over place holder component's uid
	 * @param	asset the rolled over place holder
	 */
	private function onAssetRollOver(asset:AssetBase):Void
	{
		HookManager.getInstance().callHooks(COMPONENT_PLACE_HOLDER_ROLL_OVER_HOOK, asset.uid);
	}
	
}