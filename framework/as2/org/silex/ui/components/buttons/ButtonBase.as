/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	
import org.silex.core.Utils;
class org.silex.ui.components.buttons.ButtonBase extends org.silex.ui.components.ComponentAnimated {

	/**
	 * function initialize
	 * @return void
	 */
	function _onLoad() {
		super._onLoad()
		
		bg_mc.onReleaseOutside 	= Utils.createDelegate(this, _onReleaseOutside);
		stop();
	}
	
	
	/**
	 * selectIcon
	 * called by openIcon and core.application::openSection
	 * to be overriden by sub classes - mark the media as selected?
	 */ 
	function selectIcon(isSelected:Boolean){
		if (isSelected){
			gotoAndStop("select");
		}
		else{
			gotoAndStop("deselect");
		}
	}

	/**
	 * function _onRelease
	 * @return 	void
	 */
	function _onRelease():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_RELEASE ,target:this });
	}
	/**
	 * function _onReleaseOutside
	 * @return 	void
	 */
	function _onReleaseOutside():Void{
	}
	
	/**
	 * function _onPress
	 * @return 	void
	 */	
	function _onPress():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_PRESS ,target:this });
	}
	
	/**
	 * function _onRollOver
	 * @return 	void
	 */
	function _onRollOver():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOVER ,target:this });
	}
	
	/**
	 * function _onRollOut
	 * @return 	void
	 */	
	function _onRollOut():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOUT ,target:this });
	}
		

	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
}