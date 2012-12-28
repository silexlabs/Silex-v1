/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
//[InspectableList("layer_name")]
class org.silex.ui.authoring.layerComponentFantom extends mx.core.UIComponent{
	// var clipParameters;
	
	// SymbolName for object
	static var symbolName:String = "layerComponentFantom";

	// Class used in createClassObject
	static var symbolOwner:Object = org.silex.ui.authoring.layerComponentFantom;

	// name of this class
	var className:String = "layerComponentFantom";

	// instance to look after
	[Inspectable(type="String",name="target MovieClip path",variable="target_str")]
	var target_str:MovieClip;
	[Inspectable(type="String",name="UNUSED(parent) - source MovieClip path",variable="source_str")]
	var source_str:MovieClip;
	
	// visual element used for editing in Flash IDE
	var visu_mc:MovieClip;
	
	function LayerComponent() {
	}
	function onLoad () {
		//super.init();
		//initFromClipParameters();
		// remove visual element used for editing in Flash IDE
		visu_mc._visible=false;
		target_mc=_global.getSilex(this).utils.getTarget(_parent,target_str);
		source_mc=_global.getSilex(this).utils.getTarget(_parent,source_str);
	}
	var target_mc:MovieClip;
	var source_mc:MovieClip;
	function onEnterFrame () {
/*		for (var propName_str:String in this){
			target_mc[propName_str]=this[propName_str];
		}*/
		target_mc._x=_parent._x;
		target_mc._y=_parent._y;
		target_mc._xscale=_parent._xscale;
		target_mc._yscale=_parent._yscale;
		target_mc._alpha=_parent._alpha;
		target_mc._rotation=_parent._rotation;
/*		target_mc._x=source_mc._x;
		target_mc._y=source_mc._y;
		target_mc._xscale=source_mc._xscale;
		target_mc._yscale=source_mc._yscale;
		target_mc._alpha=source_mc._alpha;
		target_mc._rotation=source_mc._rotation;
*/	}
}
