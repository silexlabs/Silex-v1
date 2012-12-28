/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.plugins.viewMenu.item
{
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.WysiwygModel;
	
	import org.silex.wysiwyg.toolbox_plugin_api.ui.WysiwygNumericStepper;
	

	
	public class ZoomControl extends Canvas
	{
		private var _stepper:WysiwygNumericStepper;
		
		public function ZoomControl()
		{
			super();
			
			SilexAdminApi.getInstance().wysiwygModel.addEventListener(WysiwygModel.EVENT_ZOOM_CHANGED, onZoomChange); 
			 
			
		}
		
		override protected function createChildren():void{
			super.createChildren();
			_stepper = new WysiwygNumericStepper();
			_stepper.styleName = "zoom";
		//	_stepper.valueFormatFunction = format;
		//	_stepper.valueParseFunction = parse;
			_stepper.maximum = 500;
			_stepper.minimum = 100;
			_stepper.stepSize = 10;
			_stepper.addEventListener(Event.CHANGE, onInputChange);
			addChild(_stepper);
		}
		
		private function onZoomChange(event:Event):void{
			trace("onZoomChange");
			invalidateProperties();			
		}
		
		private function onInputChange(event:Event):void{
			SilexAdminApi.getInstance().wysiwygModel.setZoom(_stepper.value);
		} 
		
		
		/**
		 * get the Number value from the input
		 * */
		private function parse(value:String):Number{
			value = value.split("%")[0]; //remove "%" at end if exists
			var parsed:Number = parseInt(value);
			if(isNaN(parsed)){
				return 100;
			}else{
				return parsed;
			}
		}
		
		/**
		 * format the text from the numeric value
		 * */
		private function format(value:Number):String{
			return (value + "%");
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			_stepper.value =	SilexAdminApi.getInstance().wysiwygModel.getZoom();
			
		}
	}
}