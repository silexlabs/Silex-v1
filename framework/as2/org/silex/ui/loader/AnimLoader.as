/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/	/**************************************************		SILEX Loader	**************************************************	Name : AnimLoader.as	Package : org.silex.ui.loader	Version : 0.1	Date :  2009-06-19	Author : ariel sommeria-klein	URL : http://www.arielsommeria.com	 */import org.silex.ui.loader.SimpleLoader;	 class org.silex.ui.loader.AnimLoader extends SimpleLoader {	 		public var anim_mc:MovieClip;	public var percentLoaded:Number = 0;	// listener	function  onLoadProgress (target:MovieClip, bytesLoaded:Number, bytesTotal:Number) {		super.onLoadProgress (target, bytesLoaded, bytesTotal);		percentLoaded = Math.round(100 * bytesLoaded / bytesTotal) + 1;		_parent.anim_mc.gotoAndStop(Math.round(percentLoaded/10));	}}