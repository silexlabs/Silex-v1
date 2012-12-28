/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.addComponents
{
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	
	/**
	 * This toolbox list all the components that can be added to the Silex publication.
	 * It displays groups of component that can be added and parametrise
	 */ 
	public class AddComponentsTool extends SilexToolBase
	{
		public function AddComponentsTool()
		{
			super();
			_toolUI = new AddComponentsUI();
			this.percentWidth = 100;
			addChild(_toolUI);
			
			_toolUI.addEventListener(ToolsEvent.OVERWRITE_SKIN, onOverWriteSkin);
		}
		
		/**
		 * When the user wants to upload a skin file with a name already existing
		 * asks the user to confirm the overwrite with a confirm box
		 */ 
		private function onOverWriteSkin(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.OVERWRITE_SKIN,  null, true));
		}
		
	}
}