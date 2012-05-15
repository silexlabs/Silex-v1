/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import mx.transitions.Tween;
import mx.transitions.easing.*;
/** This list ...
 * 
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * If you want to use one of the oof lists in flash, make sure that you have the right 
 * cell renderer (see cellRenderer parameter) and List Row in your library. In silex this
 * is done for you.
 * @author Alexandre Hoyau
 * */
class org.oof.lists.RollOverMenuList extends org.oof.lists.RiszeList{
	/* clickZoneSize
	 * if the mouse is over the clickZone, show the menu
	 * click zonone is aside the list
	 */
	[Inspectable(name="click zone size X",type=Number, defaultValue=100)]
	var clickZoneSizeX:Number;
	
	[Inspectable(name="click zone size Y",type=Number, defaultValue=30)]
	var clickZoneSizeY:Number;

	[Inspectable(name="click zone position X",type=Number, defaultValue=0)]
	var clickZonePosX:Number;
	
	[Inspectable(name="click zone position Y",type=Number, defaultValue=0)]
	var clickZonePosY:Number;
	
	/* showHide_tween
	 * tween object used for show / hide animation
	 */
	var showHide_tween:Tween;
	
	/* isMenuStateVisible
	 * true if the menu is visible
	 */
	[Inspectable(name="is visible at start",type=Boolean, defaultValue=true)]
	var isMenuStateVisible:Boolean;
	
	
	var listContentBg_mc:MovieClip;
	var maskContentBg_mc:MovieClip;
	
	public function RollOverMenuList()
	{
		typeArray.push("org.oof.lists.RollOverMenuList");
	}
	
	/* onLoad
	 *
	 */
	function _onLoad(){
		super._onLoad();
		if (isMenuStateVisible==false){
			if (_isHorizontal==true)
				listContent._x=-width;
			else
				listContent._y=-height;
		}
		Mouse.addListener(this);
		onMotionChanged();
		maskContentBg_mc._width=mask_mc._width;
		maskContentBg_mc._height = mask_mc._height;
		
//		redraw();
	}
	function redraw(){
		super.redraw();
		maskContentBg_mc._width=mask_mc._width;
		maskContentBg_mc._height=mask_mc._height;
	}
	/* onMouseMove
	 * check if the mouse over the the click zone 
	 * eventually open the menu
	 */
	function onMouseMove(){
		// shouldBeVisible is true if the menu should be visible
		var shouldBeVisible:Boolean=false;
		
		// if mouse is over the list + click zone
		shouldBeVisible=(isOverClickZone(_xmouse,_ymouse) || (isMenuStateVisible && isOverList(_xmouse,_ymouse)));

		// show or hide if necessary
		if (shouldBeVisible==true && isMenuStateVisible==false)
			startShowAnim();
		else if (shouldBeVisible==false && isMenuStateVisible==true)
			startHideAnim();
	}
	function isOverClickZone(x,y){
		// cilick zone =
		// VERT : 
		// 	0 < x < clickZoneSizeX
		// 	-clickZoneSizeY < y < 0
		// HORIZ : 
		// 	-clickZoneSizeX < x < 0
		// 	0 < y < clickZoneSizeY
		if (_isHorizontal==true){
			// HORIZ
			if ((x>clickZonePosX-clickZoneSizeX && x<clickZonePosX && y>clickZonePosY && y<clickZonePosY+clickZoneSizeY))
				return true;
		}else{
			// VERT
			if ((x>clickZonePosX && x<clickZonePosX+clickZoneSizeX && y>clickZonePosY-clickZoneSizeY && y<clickZonePosY))
				return true;
		}
		return false;
	}
	function isOverList(x,y){
		if (x>0 && x<width && y>0 && y<width)
			return true;
		return false;
	}
	/* startShowAnim
	 * start the animation
	 */
	function startShowAnim(){
		isMenuStateVisible=true;
		var animatedPropName:String;
		if (_isHorizontal==true)
			animatedPropName="_x";
		else
			animatedPropName="_y";

		showHide_tween.stop();
		showHide_tween=new Tween(listContent, animatedPropName, Strong.easeOut, listContent[animatedPropName], 0, 3, true);
		showHide_tween.onMotionChanged = Delegate.create(this,onMotionChanged);
		showHide_tween.onMotionFinished = function() {
		};
	}
	/* startHideAnim
	 * start the animation
	 */
	function startHideAnim(){
		isMenuStateVisible=false;
		var animatedPropName:String;
		var animatedPropTargetValue:Number;
		if (_isHorizontal==true){
			animatedPropName="_x";
			animatedPropTargetValue=-width;
		}
		else{
			animatedPropName="_y";
			animatedPropTargetValue=-height;
		}

		showHide_tween.stop();
		showHide_tween=new Tween(listContent, animatedPropName, Strong.easeIn, listContent[animatedPropName], animatedPropTargetValue, 1, true);
		showHide_tween.onMotionChanged = Delegate.create(this,onMotionChanged);
		showHide_tween.onMotionFinished = function() {
		};
	}
	function onMotionChanged(){
		listContentBg_mc._width=listContent._width;
		listContentBg_mc._height=listContent._height;
		listContentBg_mc._x=listContent._x;
		listContentBg_mc._y=listContent._y;
	}
}