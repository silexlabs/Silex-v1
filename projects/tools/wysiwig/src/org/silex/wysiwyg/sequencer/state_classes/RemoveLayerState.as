package org.silex.wysiwyg.sequencer.state_classes
{
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.StateEvent;
	
	/**
	 * extends the RemoveLayoutState, as when deleting a layer, it's parent layout gets actually deleted,
	 * deleting along all of it's child layers
	 */ 
	public class RemoveLayerState extends RemoveLayoutState
	{
		
		public function RemoveLayerState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object)
		{
			super(silexAdminApi, toolCommunication, data);
		}
		
		override protected function doEnterSuccessState():void
		{	
			doRemoveLayerCallback();
			super.doEnterSuccessState();
		}
		
		/**
		 * Determine wether the target can be deleted
		 */ 
		override protected function isTargetDeletable(targetUid:String):Boolean
		{
			var firstLayout:Layout = _silexAdminApi.layouts.getData()[0][0];
			
			var layers:Array = _silexAdminApi.layers.getData([firstLayout.uid])[0];
			for (var i:int = 0; i<layers.length; i++)
			{
				if ((layers[i] as Layer).uid == targetUid)
				{
					return false;
				}
			}
			
			return true;
		}
		
		/**
		 * When the user confirms his choice to remove a layer, delete it's parent layout
		 * 
		 */
		protected function doRemoveLayerCallback():void
		{
			_silexAdminApi.layers.deleteItem(_targetUid);
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
		}
	}
}