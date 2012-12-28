package org.silex.wysiwyg.toolboxes.multiSubLayerComponents
{
	import mx.core.UIComponent;
	
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	
	public class MultiSubLayerComponentsTool extends SilexToolBase
	{
		public function MultiSubLayerComponentsTool()
		{
			_toolUI = new MultiSubLayerComponentsUI();
			this.maxWidth = 280;
			this.width = 280;
			addChild(_toolUI);
		}
		
		/**
		 * add this toolBox to the displayList
		 * 
		 * @param target the toolBox parent
		 */ 
		override public function show(target:ToolCommunication):void
		{
			if (! target.hDividedBox.getChildByName(this.name))
			{
				target.hDividedBox.addChildAt(this, 1);
			}
				
			else
			{
				(target.hDividedBox.getChildByName(this.name) as UIComponent).includeInLayout = true;
				target.hDividedBox.getChildByName(this.name).visible = true;
			}
		}
	}
}