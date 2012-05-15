/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.utils
{
	import flash.display.MovieClip;
	
	import mx.containers.HBox;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class SimpleLoader extends HBox
	{
		
		private var _loaderAssetClass:Class;
		
		private var _loaderClip:MovieClip;
		
		public function SimpleLoader()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onCreationComplete(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			this.styleName = 'simpleLoader';
			
			_loaderAssetClass = this.getStyle('busyCursor') as Class;
			
			_loaderClip = new _loaderAssetClass() as MovieClip;
			
			var loaderClipContainer:UIComponent = new UIComponent();
			loaderClipContainer.addChild(_loaderClip);
			
			this.addChild(loaderClipContainer);
		}
		
		public function setLoadingProgress(progress:int):void
		{
			_loaderClip.gotoAndStop(progress);
		}
		
		public function play():void
		{
			_loaderClip.play();
		}
		

	}
}