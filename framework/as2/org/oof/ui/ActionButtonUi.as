/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.utils.Delegate;
import mx.controls.Button;
/** this is a test for a custom ui that works both in flash and silex. for oof v2...
 * @author Ariel Sommeria-klein
 * */
class org.oof.ui.ActionButtonUi extends MovieClip{
	var captionTxt:TextField;
	var propertyHolder:Object = null;
	
	function onEnterFrame(){
		if(propertyHolder == null){
			//valid at design time in flash only, in silex propertyHolder is set elsewhere
			propertyHolder = _parent.xch; 
		}
		captionTxt.text = propertyHolder.caption;
		captionTxt.onChanged = Delegate.create(this, onCaptionChanged);
		
		this.onEnterFrame = null;
	}
	
	function onCaptionChanged(){
		propertyHolder.caption = captionTxt.text;
	}
	
}