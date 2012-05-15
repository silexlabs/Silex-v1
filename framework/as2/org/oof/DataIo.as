/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;

/**
 * base class for all Ios. 
 * registers with a dataUser then synchronizes data with the get value and set value methods.
 * every data user communicates with an input or output component uses the "value" property.
 * for the DataSelector this is done in outputformat.
 * for the record updater, creator this is done in inputs.
 * 
 * input or output components include text input/outputs, displays, the uploader.
 * 
 * @author Ariel Sommeria-klein
 * 
 * */
class org.oof.DataIo extends OofBase{

	public function DataIo(){
		super();
		typeArray.push("org.oof.DataIo");
	}
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tabChildren = true;
		
		//get the dimensions given by the designer on the scene. 
		//using _width and _height would seem logical, but somehow they are not set properly. So use width and height
		setSize(width, height);
	 }

	
	/** function get value
	*  simply retrieve the data from ui, without the field name. 
	* @returns Object. 
	*/
	
	function get value():Object{
		throw new Error(this + " get value not implemented");
		return null;
		
	}

	/** function set value
	*  simply set the data from ui, without the field name. 
	* @returns void 
	*/
	
	function set value(val:Object){
		throw new Error(this + " set value not implemented");
		
	}	

}
	
	
	