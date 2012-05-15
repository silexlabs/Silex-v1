/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this is a horizontal scroll bar.
 * @author Ariel Sommeria-klein
 * */
import mx.utils.Delegate;
import org.oof.OofBase;
import mx.events.EventDispatcher;
import mx.transitions.Tween;
import mx.transitions.easing.*;
import org.oof.ui.elements.ScrollUi;

class org.oof.ui.elements.ScrollUiHorizontal extends ScrollUi{
	
	 public function onLoad(){		
	 	_scrollDim = "_x";
	 	_scrollDimSize = "_width";
	 	super.onLoad();
	}

	
}