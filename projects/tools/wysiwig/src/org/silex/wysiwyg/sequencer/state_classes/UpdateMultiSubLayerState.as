package org.silex.wysiwyg.sequencer.state_classes
{
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	
	public class UpdateMultiSubLayerState extends StateBaseShortcut
	{
		public function UpdateMultiSubLayerState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object)
		{
			super(silexAdminApi, toolCommunication);
			
		}
		
		/**
		 * When the state is instantiated, show/hide  the right toolboxes
		 */ 
		override public function enterState():void
		{
			_toolCommunication.hide(ToolCommunication.COMPONENTS_TOOLBOX);
			if (_silexAdminApi.components.getSelection().length > 0)
			{
				_toolCommunication.show(ToolCommunication.PROPERTIES_TOOLBOX);
			}
			
			_toolCommunication.show(ToolCommunication.MULTI_SUB_LAYER_COMPONENTS_TOOLBOX);
		}
		override public function destroy():void
		{
			_toolCommunication.show(ToolCommunication.COMPONENTS_TOOLBOX);
			_toolCommunication.hide(ToolCommunication.MULTI_SUB_LAYER_COMPONENTS_TOOLBOX);
			_toolCommunication.hide(ToolCommunication.PROPERTIES_TOOLBOX);
		}
		
		/**
		 * delete the selected layer by entering the remove layer state, providing
		 * the selected layer uid
		 */ 
		override public function keyboardDeleteCallback():void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, RemoveLayerState, _silexAdminApi.layers.getSelection()[_silexAdminApi.layers.getSelection().length - 1]));
		}
		
		/**
		 *  calls the save layout method on SilexAdminAPI on the necessary layout.
		 *  the default behavior is to save the selected layout, it is overriden in other states
		 * 
		 */ 
		override public function saveLayoutCallback(event:CommunicationEvent):void
		{
			var layouts:Array = _silexAdminApi.layouts.getData()[0];	
			for (var i:int; i<layouts.length; i++)
			{
				(layouts[i] as Layout).save();
			}
		}

		override public function componentsSelectionChangeCallback(event:AdminApiEvent):void
		{
			
			if (_silexAdminApi.components.getSelection() != null && _silexAdminApi.components.getSelection().length != 0)
			{
				ToolBoxAPIController.getInstance().loadEditor(ToolBoxAPIController.getInstance().getDefaultEditor().editorUrl, ToolBoxAPIController.getInstance().getDefaultEditor().description)
				
				refreshPropertyToolboxHeaderNames();
			}
		}
		
		/**
		 * update the components toolbox data
		 */ 
		override protected function updateComponentToolbox():void
		{
		}
		
		
		override public function componentsDataChangeCallback(event:AdminApiEvent):void
		{
		}
		

		
	}
}