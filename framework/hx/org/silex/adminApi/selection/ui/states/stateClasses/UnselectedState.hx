/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.states.stateClasses;
import haxe.Log;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.ui.states.StateBase;

/**
 * The state used when no components are selected, the user interface is hidden
 * @author Yannick DOMINGUEZ
 */
class UnselectedState extends StateBase
{
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function new(uis:UIsExtern)
	{
		super(uis);
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// OVERRIDEN METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When entering the state, hides the selection and selected components backgrounds
	 * region as no components are selected
	 * 
	 * @param initObj an optionnal initObj for the state
	 */ 
	override public function enterState(initObj:Dynamic):Void
	{
		super.enterState(initObj);
		unsetSelectionRegion();
		unsetSelectedComponents();
	}
	
}