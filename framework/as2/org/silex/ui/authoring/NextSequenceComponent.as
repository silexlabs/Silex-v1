/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
class org.silex.ui.authoring.NextSequenceComponent extends mx.core.UIComponent{
	// var clipParameters;
	
	// SymbolName for object
	static var symbolName:String = "NextSequenceComponent";

	// Class used in createClassObject
	static var symbolOwner:Object = org.silex.ui.authoring.NextSequenceComponent;

	// name of this class
	var className:String = "NextSequenceComponent";
	
	// visual element used for editing in Flash IDE
	var visu_mc:MovieClip;
	
	function LayerComponent() {
	}
	
	function onLoad () {
		//super.init();
		//initFromClipParameters();
		// remove visual element used for editing in Flash IDE
		visu_mc._visible=false;

		// next sequence
		_global.getSilex(this).sequencer.nextSequence();
	}
}
