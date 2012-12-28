package org.silex.wysiwyg.ui.library.components
{
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.core.ClassFactory;
	import mx.events.ListEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.ui.WysiwygList;
	
	public class WysiwygLibraryList extends WysiwygList
	{
		public function WysiwygLibraryList()
		{
			super();
			this.styleName = "library";
			this.maxWidth = 280;
			this.minWidth = 280;
			this.percentHeight = 100;
			this.itemRenderer = new ClassFactory(LibraryFinderListItemRenderer);
			this.addEventListener(ListEvent.CHANGE, onListChange);
			this.addEventListener(ListEvent.ITEM_DOUBLE_CLICK, onDoubleClickItem);
			this.verticalScrollPolicy = ScrollPolicy.ON;
		}
		
		
		private function onListChange(event:ListEvent):void
		{
			
			var newPath:String = this.dataProvider.source.path + this.selectedItems[0]['item name'];
			dispatchEvent(new PluginEvent(PluginEvent.UPDATE_LIBRARY_PATH, newPath));
		}
		
		private function onDoubleClickItem(event:ListEvent):void
		{
			var newPath:String = this.dataProvider.source.path + this.selectedItems[0]['item name'];
			dispatchEvent(new PluginEvent(PluginEvent.SELECT_LIBRARY_ITEM, newPath));
		}
		
		override public function set data(value:Object):void
		{
			this.dataProvider = value;
		}
		
		
		override public function get data():Object
		{
			return this.dataProvider.source;
		}
		
		/**
		 *  @private
		 */
		override public function set selectedIndex(value:int):void
		{
			super.selectedIndex = value;
			scrollToIndex(value);
		}
		
		
		
		
	}
}