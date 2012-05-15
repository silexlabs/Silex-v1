/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.core;

import org.silex.adminApi.ComponentDescriptorManager;
import org.silex.adminApi.HistoryManager;
import org.silex.adminApi.undoableActions.UpdatePropertyValue;
import org.silex.adminApi.undoableActions.SelectComponents;
import org.silex.adminApi.undoableActions.SelectSubLayer;
import org.silex.adminApi.undoableActions.SelectLayer;
import org.silex.adminApi.undoableActions.ChangeComponentsOrder;
import org.silex.adminApi.undoableActions.OpenSection;
import org.silex.adminApi.undoableActions.AddComponent;
import org.silex.adminApi.undoableActions.DeleteComponent;
import org.silex.adminApi.undoableActions.AddAction;
import org.silex.core.LayerModelBuilder;
import org.silex.core.LayerHelper;
import org.silex.core.SubLayerBuilder;
import org.silex.core.XmlUtils;
import org.silex.publication.LayerParser;
import org.silex.adminApi.selection.SelectionManager;
import org.silex.adminApi.util.ComponentCopier;

import haxe.BaseCode;

import flash.Stage;

class CodeInjection
{

	
	public static function main(): Void
	{
		Stage.align = "";
        Stage.scaleMode = "noScale";
		//Give reference to our context to the AS2 code
		untyped org.silex.link.HaxeLink.initialize(flash.Lib.current);
		//Run the AS2 entry point. Should work without the "_global", but sopehow the compiler screws up without, only on my machine. A.S.
		untyped _global.org.silex.core.Api.main(flash.Lib.current);
	}
}