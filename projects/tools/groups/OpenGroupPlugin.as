package  {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;

	public class OpenGroupPlugin extends Sprite {

		/**
		* This is a reference to the button that you put on the stage of your FLA
		*/
		public var button:SimpleButton;

		/**
		* This is the url of the Flex Application that we want to load in the wysiwyg
		* It is the relative path starting from the server root
		*/
		//private static const pluginUrl:String = "plugins/groups/groupsWysiwyg.swf";
		private static const pluginUrl:String = "plugins/wysiwyg/panels/Groups.swf";

		/**
		* We add a listener to the click of the button
		*/
		public function OpenGroupPlugin()
		{
		button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}

		/**
		* When the user clicks the button, we get an instance of the ToolBoxApiController and ask it
		* to load our Flex application in the properties toolbox
		*/
		private function mouseDownHandler(event:MouseEvent):void
		{
		ToolBoxAPIController.getInstance().loadEditor(pluginUrl, "Opens the Group plugin");
		}
	}

}
