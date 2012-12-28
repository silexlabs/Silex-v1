package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.external.ExternalInterface;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxApi.event.ToolBoxAPIEvent
	
	
	public class OpenSpecificPlugin extends Sprite {

		public var button:SimpleButton;
		
		private static const pluginUrl:String = "plugins/wysiwyg/panels/SpecificPlugin.swf";
		
		public function OpenSpecificPlugin() 
		{
			ToolBoxAPIController.getInstance().setAsDefault(pluginUrl, "plugin");
			button = new buttonDown();
			addChild(button);
			checkButtonState(ToolBoxAPIController.getInstance().getDefaultEditor());
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_EDITOR, onLoadEditor);
			
		}
		
		private function onLoadEditor(event:ToolBoxAPIEvent):void
		{
			checkButtonState(event.data);
		}
		
		private function checkButtonState(currentEditor:Object):void
		{
			
			if (currentEditor.editorUrl == pluginUrl)
			{
				removeChild(button);
				button = new buttonDown();
			}
			
			else
			{
				removeChild(button);
				button = new buttonUp();
				button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
			
			addChild(button);
			
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			ToolBoxAPIController.getInstance().setAsDefault(pluginUrl, "plugin");
			ToolBoxAPIController.getInstance().loadEditor(pluginUrl, "plugin");
		}
	}
	
}
