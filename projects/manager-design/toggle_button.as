/**
This file is part of Silex: RIA developement tool - see http://silex-ria.org/
Silex is (c) 2007-2012 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL)
as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/*
AUTHOR : Solvejg Bougeois => http://solveig.bougeois.free.fr
*/

import org.silex.core.Utils;
class toggle_button extends org.silex.ui.components.buttons.LabelButtonBase {

	////////////////////////////////////////////
	/**
	 * selectIcon
	 * called by openIcon and core.application::openSection
	 * to be overriden by sub classes - mark the media as selected?
	 */
var bg_mc_selected:MovieClip;

function selectIcon(isSelected:Boolean) {
		super.selectIcon(isSelected);
		if (isSelected) {
			bg_mc._visible = false;
			bg_mc_selected._visible = true;
		} else {
			bg_mc._visible = true;
			bg_mc_selected._visible = false;
		}
	}
}