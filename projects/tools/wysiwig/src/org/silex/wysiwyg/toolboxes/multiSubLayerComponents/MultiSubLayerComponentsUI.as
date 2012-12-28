package org.silex.wysiwyg.toolboxes.multiSubLayerComponents
{
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	
	public class MultiSubLayerComponentsUI extends StdUI
	{
		public function MultiSubLayerComponentsUI()
		{
			_toolBoxBodyClass = MultiSubLayerComponentsUIBody;
			_toolBoxHeaderClass = MultiSubLayerComponentsUIHeader;
			_toolBoxFooterClass = MultiSubLayerComponentsUIFooter;
			super();
			
			
		}
		
	}
}