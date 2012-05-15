import flash.external.ExternalInterface;
import org.silex.core.Api;
import org.silex.core.Application;
import org.silex.core.Utils;
/**
 * ...
 * @author 
 */
class StageBorder extends MovieClip
{
	
	
	public function StageBorder() 
	{
		this._visible = false;
		ExternalInterface.addCallback("toggleStageBorderVisibility", this, toggleStageBorderVisibility);
		ExternalInterface.addCallback("refreshStageBorder", this, resizeStageBorder);
		
		var silexInstance:Api = _global.getSilex();
		silexInstance.application.addEventListener("resize", Utils.createDelegate(this, resizeStageBorder));
	}
		
		


	public function toggleStageBorderVisibility()
	{
		if (this._visible)
		{
			this._visible = false;
		}
		else {
			resizeStageBorder();
			this._visible = true;

		}
	}

	
	public function resizeStageBorder():Void
	{
		var _silex_ptr = _global.getSilex();
		
		this['border_mc']._width = Math.round(_silex_ptr.application.sceneRect.right - _silex_ptr.application.sceneRect.left);
		this['border_mc']._height = Math.round(_silex_ptr.application.sceneRect.bottom - _silex_ptr.application.sceneRect.top);
		this['border_mc']._x = Math.round(_silex_ptr.application.sceneRect.left);
		this['border_mc']._y = Math.round(_silex_ptr.application.sceneRect.top);
	}
	
}