/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.dataIos.Display;
import org.oof.OofBase;

class org.oof.designTools.diagnosis.dataIos.DisplayTest extends OofBase{
	
	function runTests(testComp:OofBase):String{
		var ret:String = "";
		var display:Display = Display(testComp);
		if(display.playerState == PLAYER_STATE_ERROR){
			ret += display.playerName + " has errors. " + display._errorMessage; 
		}
		
	}
	
}