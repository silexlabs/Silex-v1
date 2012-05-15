/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 *
 * Name : ComponentBase.as
 * Package : ui.components
 * Version : 0.9
 * Date :  2007-08-03
 * Author : julien Rollin
 * URL : http://www.jenreve.fr
 * Mail : j.rollin@jenreve.fr	 
 */
import org.silex.ui.UiBase;
 
class org.silex.ui.components.ComponentBase extends UiBase {
	
	/**
	 * function initialize
	 * @return void
	 */
	private function _initialize():Void{
		super._initialize();
		//editableProperties
		this.editableProperties.unshift(   
			{ name :"width" ,			description:"PROPERTIES_LABEL_WIDTH", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: "none"	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"height" , 			description:"PROPERTIES_LABEL_HEIGHT", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: ""	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"scale" , 			description:"PROPERTIES_LABEL_SCALE", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: ""	, isRegistered: false	, minValue:1,  	maxValue:100, group:"attributes" }
		)
	}
	
}