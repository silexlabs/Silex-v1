package  org.silex.editionToolBar.toolbarItems.items{
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.editionToolBar.toolbarItems.DrawComponentButtonBase;
	
	
	public class TextButton extends DrawComponentButtonBase {

		public function TextButton() {
			_toolItemUid = "silex.EditionToolBar.ToolItem.TextSelection";
			super();
		}
		
		override protected function addComponent(eventData:Object):String
		{
			var initObj:Object = { x:eventData.coords.x,
			y:eventData.coords.y,
			width:eventData.coords.width,
			height:eventData.coords.height };
			
			return SilexAdminApi.getInstance().components.addItem({
				playerName:"Text",
				type:ComponentAddInfo.TYPE_COMPONENT,
				metaData:"plugins/baseComponents/as2/org.silex.ui.players.Text.swf",
				initObj:initObj,
				className:"org.silex.ui.players.Text"
			});
		}

	}
	
}
