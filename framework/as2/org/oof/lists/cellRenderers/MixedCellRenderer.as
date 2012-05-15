/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** 
 * an example class for a cell renderer that mixes images and text
 * @author Ariel Sommeria-klein
 * */
import mx.utils.Delegate;
import org.oof.lists.cellRenderers.CellRendererBase; 

class org.oof.lists.cellRenderers.MixedCellRenderer extends CellRendererBase{
	/**
	 * holds a reference to the loaded image. 
	 * */
	private var _loadedIcon:String = null;
	
	/**
	 * a movie clip loader
	 * */
	private var _mcLoader:MovieClipLoader = null;
	
	/**
	 * the clip where the image is loaded
	 * */	
	public var container:MovieClip;
	
	/**
	 * a text field
	 * */
	public var tf:TextField;
	
	public function MixedCellRenderer(){
		_mcLoader = new MovieClipLoader();
	}
	
	function setValue(str:String, item:Object, sel:Boolean) : Void{
		super.setValue(str, item, sel);	
		//this check is necessary to avoid multiple loads
		if(icon != _loadedIcon){ 
			//trace("MixedCellRenderer, loading from : " + icon + ", to clip : " + container);
			var ret = _mcLoader.loadClip(icon, container);
			if(!ret){
				throw new Error(this + " problem loading image from url : " + icon);
			}
			_loadedIcon = icon;
		}
		tf.text = str;
		redraw();
	}
	
	/**
	 * position your elements here if you need to
	 * */
	function redraw(){
		super.redraw();
	}
	
	

}