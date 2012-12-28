/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.OofBase;
import mx.utils.Delegate;
/** this class is to help integrate components that are not based on oof, and therefore
 * don't have access to the oof finding system. This object basically does the work for them so
 * that they can be found as if they were oof components
 * @author Ariel Sommeria-klein
 * */

class org.oof.util.Finder extends OofBase{
	private var _compPath:String = null;
	/**
	 * when movieclip is transformed to UIoObject
	 */
	 public function _onLoad(){		
		//don't call super._onLoad();!!
		
	 }
	
	public function onEnterFrame(){
		var target = findObj(_compPath);
		//look for the target, and check that its class is instanciated, by looking for its setsize method. 
		//this supposes that the target does have a setsize method, which means that it should derive
		//from mx.core.UIObject. Maybe find a better test later.
		if((target != undefined) && (target.setSize != undefined)){
			//add target to _alloofCompsList, make it look like a oof comp
			target.playerName = target._name;
			target.onLoadEventOccurred = true;
			_alloofCompsList.push(target);
			lookForObjectsWantingToLink(target);
			this.onEnterFrame = null; //cancel this function once used
		}
	}

	
	/** function set compPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="Non Oof Comp Path", type=String, defaultValue="")]
	public function set compPath(val:String){
		_compPath = val;
	}
	
	/** function get compPath
	* @returns String
	*/
	
	public function get compPath():String{
		return _compPath;
	}		

	
}