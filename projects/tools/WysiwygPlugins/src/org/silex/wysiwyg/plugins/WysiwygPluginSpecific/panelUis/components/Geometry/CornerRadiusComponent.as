/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginSpecific.panelUis.components.Geometry
{
	import flash.display.Sprite;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	/**
	 * This class draws rectangles representing the radius of one of the Geometry component's corner
	 */ 
	public class CornerRadiusComponent extends Canvas
	{
		/**
		 * this is the target corner. ex: Top left, bottom right...
		 */ 
		private var _targetCorner:String = "";
		
		/**
		 * this is the radius of the corner we will draw in the component
		 */ 
		private var _cornerRadius:int;
		/**
		 * width of component at the stage
		 */
		private var _MCWidth:int;
		/**
		 * height of component at the stage
		 */
		private var _MCHeight:int;
		
		/**
		 * constant for the top left corner
		 */ 
		public static const TOP_LEFT_CORNER:String = "topLeftCorner";
		/**
		 * constant for the top left corner
		 */ 
		public static const TOP_RIGHT_CORNER:String = "topRightCorner";
		
		/**
		 * constant for the top left corner
		 */ 
		public static const BOTTOM_LEFT_CORNER:String = "bottomLeftCorner";
		
		/**
		 * constant for the top left corner
		 */ 
		public static const BOTTOM_RIGHT_CORNER:String = "bottomRightCorner";			
		
		/**
		 * UIcomponent that will add sprite, and this UIComponent will be addChild by Canvas
		 */
		private var cornerRadiusUI:UIComponent = new UIComponent();
		/**
		 * Corner raduis container size
		 */
		private static const CORNER_RADUIS_SIZE:int=22;
		/**
		 * sprite object that used to take the radius value
		 */
		private var radiusRectangle:Sprite = new Sprite();	
		/**
		 * Corner raduis color
		 */
		private static const CORNER_RADUIS_COLOR:uint = 0x656565;
		/**
		 *ratio between width of component and width of cornerRaduis container 
		 */
		private var witdhRatio:int;
		/**
		 *ratio between height of component and height of cornerRaduis container 
		 */		
		private var HeightRatio:int;
		/**
		 * width of cornerRaduis
		 */
		private var CornerWidth:int;
		/**
		 * height of cornerRaduis
		 */		
		private var CornerHeight:int;
		/**
		 * variable for raduis
		 */
		private var cornerRaduisoo:int;
		
		
		public function CornerRadiusComponent()
		{
			super();
		}
		
		/**
		 * draw the component rectangle based on the corner raduis and target corner
		 */ 
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if( _MCWidth!=0 || _MCHeight!=0 || _cornerRadius!=0)
			{
				witdhRatio = _MCWidth/CORNER_RADUIS_SIZE;
				HeightRatio = _MCHeight/CORNER_RADUIS_SIZE;
				
				if(HeightRatio>witdhRatio)
				{
					 CornerWidth = _MCWidth/HeightRatio;
					CornerHeight = _MCHeight/HeightRatio;
					if(_cornerRadius <= _MCWidth)
					{
						
						cornerRaduisoo = _cornerRadius/HeightRatio;		
					}else
					{
						cornerRaduisoo = CornerWidth;
					}
					
				}else
				{
					CornerWidth = _MCWidth/witdhRatio;
					CornerHeight = _MCHeight/witdhRatio;
					if(_cornerRadius <= _MCWidth)
					{
						cornerRaduisoo = (CornerWidth*_cornerRadius)/_MCWidth;						
					}else
					{
						cornerRaduisoo = CornerWidth;
					}
					
				}
				if(cornerRaduisoo != 0)
				{
					switch(_targetCorner)
					{
						case TOP_LEFT_CORNER:	
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(CORNER_RADUIS_COLOR);
							radiusRectangle.graphics.moveTo(cornerRaduisoo, 0); 
							radiusRectangle.graphics.curveTo(cornerRaduisoo/4, cornerRaduisoo/4, 0, cornerRaduisoo);    
							radiusRectangle.graphics.lineTo(0, CornerHeight);
							radiusRectangle.graphics.lineTo(CornerWidth, CornerHeight);
							radiusRectangle.graphics.lineTo(CornerWidth, 0);
							radiusRectangle.graphics.endFill();	
							
							
							break;
						case TOP_RIGHT_CORNER:	
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(CORNER_RADUIS_COLOR);
							radiusRectangle.graphics.moveTo(0, cornerRaduisoo); 
							radiusRectangle.graphics.curveTo(0, 0, -cornerRaduisoo, 0);    
							radiusRectangle.graphics.lineTo(-CornerWidth, 0);
							radiusRectangle.graphics.lineTo(-CornerWidth, CornerHeight);
							radiusRectangle.graphics.lineTo(0, CornerHeight);
							radiusRectangle.graphics.endFill();
													
							break;
						case BOTTOM_LEFT_CORNER:
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(CORNER_RADUIS_COLOR);
							radiusRectangle.graphics.moveTo(cornerRaduisoo, CornerHeight); 
							radiusRectangle.graphics.curveTo(cornerRaduisoo/4, CornerHeight-cornerRaduisoo/4, 0, CornerHeight-cornerRaduisoo);    
							radiusRectangle.graphics.lineTo(0, 0);
							radiusRectangle.graphics.lineTo(CornerWidth, 0);
							radiusRectangle.graphics.lineTo(CornerWidth, CornerHeight);
							radiusRectangle.graphics.endFill();
							break;
						case BOTTOM_RIGHT_CORNER:
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(CORNER_RADUIS_COLOR);
							radiusRectangle.graphics.moveTo(-cornerRaduisoo, CornerHeight); 
							radiusRectangle.graphics.curveTo(-cornerRaduisoo/4, CornerHeight-cornerRaduisoo/4,0, CornerHeight-cornerRaduisoo);    
							radiusRectangle.graphics.lineTo(0, 0);
							radiusRectangle.graphics.lineTo(-CornerWidth, 0);
							radiusRectangle.graphics.lineTo(-CornerWidth, CornerHeight);
							radiusRectangle.graphics.endFill();
							break;
							
						
					}
				}else
				{
					switch(_targetCorner)
					{
						case TOP_LEFT_CORNER:	
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(0x656565);
							radiusRectangle.graphics.drawRect(0,0,CornerWidth,CornerHeight);
							radiusRectangle.graphics.endFill();	
						break;
						case TOP_RIGHT_CORNER:
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(0x656565);
							radiusRectangle.graphics.drawRect(0,0,-CornerWidth,CornerHeight);
							radiusRectangle.graphics.endFill();	
						break;
						case BOTTOM_LEFT_CORNER:	
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(0x656565);
							radiusRectangle.graphics.drawRect(0,0,CornerWidth,CornerHeight);
							radiusRectangle.graphics.endFill();	
						break;
						case BOTTOM_RIGHT_CORNER:
							radiusRectangle.graphics.clear();
							radiusRectangle.graphics.beginFill(0x656565);
							radiusRectangle.graphics.drawRect(0,0,-CornerWidth,CornerHeight);
							radiusRectangle.graphics.endFill();	
						break;
						
							
					}
				}
				
			}
			cornerRadiusUI.addChild(radiusRectangle);
			this.rawChildren.addChild(cornerRadiusUI);
		}
		
		/**
		 * sets the value of the target corner then redraws the component
		 * 
		 * @param value the new value of the target corner
		 */ 
		public function set targetCorner(value:String):void
		{
			this._targetCorner = value;
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * returns the target corner
		 * 
		 * @return the target corner value
		 */ 
		public function get targetCorner():String
		{
			return this._targetCorner;
		}
		
		/**
		 * sets the value of the corner radius then redraws the component
		 * 
		 * @param value the new value of the corner radius
		 */ 
		public function set cornerRadius(value:int):void
		{
			this._cornerRadius = value;
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * returns the corner radius
		 * 
		 * @return the corner radius value
		 */ 
		public function get cornerRadius():int
		{
			return this._cornerRadius;
		}
		
		/**
		 * sets the value of the corner radius then redraws the component
		 * 
		 * @param value the new value of the corner radius
		 */ 
		public function set MCWidth(value:int):void
		{
			this._MCWidth = value;
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * returns the corner radius
		 * 
		 * @return the corner radius value
		 */ 
		public function get MCWidth():int
		{
			return this._MCWidth;
		}
		
		/**
		 * sets the value of the corner radius then redraws the component
		 * 
		 * @param value the new value of the corner radius
		 */ 
		public function set MCHeight(value:int):void
		{
			this._MCHeight = value;
			invalidateSize();
			invalidateDisplayList();
		}
		
		/**
		 * returns the corner radius
		 * 
		 * @return the corner radius value
		 */ 
		public function get MCHeight():int
		{
			return this._MCHeight;
		}
	}
}