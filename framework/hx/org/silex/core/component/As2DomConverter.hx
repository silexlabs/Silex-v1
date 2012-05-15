/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
*  converts AS2 DOM properties to generic DOM properties and vice versa
*  @todo once uibase is dropped, find a system for supporting width/_width
**/
package org.silex.core.component;

class As2DomConverter implements IDomConverter{


	public function new() 
	{
		
		
	}
	
	public function specificPropertyNameToGeneric(name:String):String {
		switch(name) {
			case "_x", "_y", "_alpha", "_xscale", "_yscale", "_rotation": //, "_width", "_height" see todo above
				//remove the "_"
				return name.split("_")[1];
			default: 
				return name;
			
		}
	}
	

	public function genericPropertyNameToSpecific(name:String):String {	
		switch(name) {
			case "x", "y", "alpha", "xscale", "yscale", "rotation": //"width", "height",  see todo above
				//add the "_"
				return "_" + name;
			default: 
				return name;
			
		}
	}	
	
}
