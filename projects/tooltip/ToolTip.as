import org.silex.core.Api;
import org.silex.core.plugin.HookEvent;
import org.silex.core.plugin.HookManager;
import org.silex.core.Utils;
import org.silex.ui.LayerHooks;
/**
 * This class manages a tooltip displaying the tooltip text of UIBase components
 * @author yannick Dominguez yannick.dominguez[at]gmail[dot]com
 */
class ToolTip extends MovieClip
{
	//////////////////////////////////////////////////////
	// CONSTANTS
	/////////////////////////////////////////////////////
	
	/**
	 * This is the ID of the movieClip hosting the tooltip
	 */
	private static var TOOLTIP_CONTAINER_ID:String = "toolTipContainer";
	
	/**
	 * This the name of a JavaScript method called via ExternalInterface returning the config of the tooltip
	 */
	private static var GET_TOOLTIP_CONF_FUNC:String = "getToolTipConfig";
	
	//////////////////////////////////////////////////////
	// CONSTRUCTOR
	/////////////////////////////////////////////////////
	
	/**
	 * The constructor loads the tooltip asset in a movieClip and add a hook called by UiBase components when the user
	 * hover for a long period of time over a component
	 */
	public function ToolTip()
	{
		//this listener wiil be added to the mouse when the tooltip is shown
		//it is responsible to hide the tooltip when the user rolls out, clicks or move the mouse
		//Due to scoping trouble, we pass the listener as arguments with the Delegate
		var mouseListener:Object = new Object();
		mouseListener.onMouseMove = Utils.createDelegate(this, onComponentHideToolTip, mouseListener);
		mouseListener.onMouseOut = Utils.createDelegate(this, onComponentHideToolTip, mouseListener);
		mouseListener.onMouseDown = Utils.createDelegate(this, onComponentHideToolTip, mouseListener);
		mouseListener.onMouseUp = Utils.createDelegate(this, onComponentHideToolTip, mouseListener);
		
		Mouse.addListener(mouseListener);
		
		//we add a hook called by a UiBase component when the user hovers for the 
		//right amount of time over a component. This time is determined in te Silex config file.
		//we pass the mouseListener as an argument due to scoping trouble
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.addHook(LayerHooks.COMPONENT_SHOW_TOOLTIP, Utils.createDelegate(this, onComponentShowToolTip, mouseListener));
		
		//adds a new empty movieClip in which we will load the tooltip assets
		var toolTip:MovieClip = _root.createEmptyMovieClip(TOOLTIP_CONTAINER_ID, _root.getNextHighestDepth());
		//we get the url of the asset to load via the JavaScript config method
		var toolTipAssetUrl:String = flash.external.ExternalInterface.call(GET_TOOLTIP_CONF_FUNC).assetUrl;
		
		//this listener will call a callback when the loading of the tooltip asset is complete
		var toolTipListener:Object = new Object();
		toolTipListener.onLoadComplete = Utils.createDelegate(this, onToolTipLoadComplete);
		
		//this movieClip loader loads the tooltip asset in the tooltip container movieClip
		var tooltipLoader = new MovieClipLoader();
		tooltipLoader.addListener(toolTipListener);
		tooltipLoader.loadClip(toolTipAssetUrl, toolTip );
		
		//we listen for resize event to hide the tooltip
		var silexPtr:Api = _global.getSilex();
		silexPtr.application.addEventListener("resize", Utils.createDelegate(this, onComponentHideToolTip, mouseListener));
	}
	
	//////////////////////////////////////////////////////
	// PRIVATE METHODS
	/////////////////////////////////////////////////////
	
	/**
	 * called when the tooltip is done loading it's graphical asset,
	 * hides the tooltip
	 * @param	mc a reference to the tooltip movieClip
	 */
	private function onToolTipLoadComplete(mc:MovieClip):Void
	{
		Utils.removeDelegate(this, onToolTipLoadComplete);
		mc._visible = false;
	}
	
	/**
	 * Called when the COMPONENT_SHOW_TOOLTIP hook is called by a UiBase component, adds a listener
	 * to the Mouse object to control when the tooltip must be hidden. Set the tooltip up (layout + text)
	 * @param	event the HookEvent, contains the text to display in the tooltip
	 */
	private function onComponentShowToolTip(event:HookEvent):Void
	{
		//we add a listener to the Mouse. This is the mouseListener variable defined in the constructor
		//Due to scoping trouble, I couldn't find a better way to pass the argument, the HookManager doesn't
		//seem to keep the callback scope.
		//Mouse.addListener(arguments[1]);
		var toolTip:MovieClip = _root[TOOLTIP_CONTAINER_ID];
		
		//we retrieve the conf object from JavaScript (the method is defined in the index.php file of the plugin)
		var conf:Object = flash.external.ExternalInterface.call(GET_TOOLTIP_CONF_FUNC);
		
		//we set up the tooltip layout and text
		toolTip._x = _root._xmouse + conf.xOffset;
		toolTip._y = _root._ymouse + conf.yOffset;
		
		var tooltipText:TextField = toolTip.text;
		tooltipText._x = conf.leftMargin;
		tooltipText.autoSize = "left";
		tooltipText.text = event.hookData.text;
		
		var tooltipBackground:MovieClip = toolTip.background;
		tooltipBackground._width = tooltipText._width + conf.rightMargin;
		
		//then we show the tooltip
		toolTip._visible = true;
		
	}
	
	/**
	 * When the tooltip must be hidden, we first remove the mouseListener from the constructor
	 * from the Mouse listeners then we hide the tooltip
	 */
	private function onComponentHideToolTip(event:Object):Void
	{
		//Mouse.removeListener(arguments[0]);
		var toolTip:MovieClip = _root[TOOLTIP_CONTAINER_ID];
		toolTip._visible = false;
	}
	
}