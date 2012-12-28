/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	/**************************************************
		SILEX API 2007
	**************************************************
	Name : Interface.as
	Package : ui.players
	Version : 0.2
	Date :  2007-08-03
	Author : julien Rollin
	URL : http://www.jenreve.fr
	Mail : j.rollin@jenreve.fr	 
	 */

interface org.silex.ui.Interface
{
	// params to use
/*	availableContextMenuMethods
	rotation
	url

	// UiObject
	redraw
*/
	/*
	Interface methods
	*/
    function setEditable(alowEdit:Boolean):Void;
	
	/*
	Methods to use in your component
	*/
	function addContextMenu();
	function removeContextMenu();
	function dispatch(eventObject:Object):Void;

	/*
	Methods to override
	*/
    //function setFocus(getFocusOrLooseIt:Boolean):Void;
    function setSelected(selectItOrDeselectIt:Boolean):Void;
    function loadMedia(url:String):Void;
    function unloadMedia():Void;
	
	// initialization
	function _populateProperties();
	function _populateEvents();
	function _populateMethods();
	function _populateContextMenu();
	function _initBeforeRegister();
	function _registerWithSilex();
	function _initAfterRegister();
	// deprecated, for compatibility :
	function _initialize():Void;
	
	// events
	function selectIcon(isSelected:Boolean);
	
	// position
	function getGlobalCoordTL();
	function getGlobalCoordBR();
	
	// seo data / html equivalent
	function getSeoData(url_str:String):Object;

}