package  org.silex.editionToolBar.toolbarItems.items{
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.editionToolBar.toolbarItems.DrawComponentButtonBase;
	
	
	public class CircleButton extends DrawComponentButtonBase {

		public function CircleButton() {
			_toolItemUid = "silex.EditionToolBar.ToolItem.Ellipse";
			super();
		}
		
		override protected function addComponent(eventData:Object):String
		{
			var initObj:Object = { x:eventData.coords.x,
			y:eventData.coords.y,
			width:eventData.coords.width,
			height:eventData.coords.height };
			
			return SilexAdminApi.getInstance().components.addItem({
				playerName:"Ellipse",
				type:ComponentAddInfo.TYPE_COMPONENT,
				metaData:"plugins/baseComponents/as2/Geometry.swf",
				initObj:initObj,
				className:"org.silex.ui.Circle"
			});
		}

	}
	
}
