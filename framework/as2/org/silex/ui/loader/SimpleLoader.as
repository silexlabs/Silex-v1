/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	/**************************************************
		SILEX Loader
	**************************************************
	Name : SimpleLoader.as
	Package : org.silex.ui.loader
	Version : 0.1
	Date :  2009-06-19
	Author : ariel sommeria-klein
	URL : http://www.arielsommeria.com
	 */
	 /**
	 * to use this class:
	 * create a fla with a movieclip linked to this class on the first frame. It will look for the following properties in the containing
	 * clip (probably the root).
	 * - loading_str : a vraiable where the loading info will be stored. You can link a text field to it by setting its 'var' field to 'loading_str'
	 * - widgetMode : 
	 * - id_site :
	 * - rootUrl :
	 */
//import org.silex.core.Utils;
	 
class org.silex.ui.loader.SimpleLoader extends MovieClip{	 
	private var _jsDataLoader_lv:LoadVars = null;
	private var _mcl:MovieClipLoader;
	
	function SimpleLoader(){
		onEnterFrame = onStep1EnterFrame;		
		_jsDataLoader_lv = new LoadVars;
		_parent.stop();
	}
	
	function formatLoadingString(bytesLoaded:Number, bytesTotal:Number):String{
		return "_" + Math.round(bytesLoaded / 1000).toString() + "Ko / " + Math.round(bytesTotal / 1000).toString() + "Ko_";
	}
	
	/***********************************************************************************************************************
	* step/frame 1: preload the loader. Executes as soon as the loader's first frame is ready,
	***********************************************************************************************************************/
	function onStep1EnterFrame() 
	{
		var bl:Number = getBytesLoaded();
		var bt:Number = getBytesTotal();
		_parent.loading_str = formatLoadingString(bl, bt);
		
		if (bl >= bt)
		{
			onEnterFrame = undefined;
			if (_parent.widgetMode=="true" && _parent.rootUrl && _parent.id_site)
				loadJsData(_parent.rootUrl, _parent.id_site);
			else
				onJsDataAvailable();
		}
	}
	
	/**
	 * load js data from widget.php
	 */
	function loadJsData(rootUrl, id_site) 
	{
		_jsDataLoader_lv.id_site = id_site;
		_jsDataLoader_lv.onLoad = mx.utils.Delegate.create(this, onJsDataAvailable);
		_jsDataLoader_lv.sendAndLoad(rootUrl + "widget.php", _jsDataLoader_lv, "GET");
	}
	/**
	 * either data is loaded from widget.php
	 * or it was allready passed through javascript
	 */
	function onJsDataAvailable(success:Boolean)
	{
		if(success != undefined)
		{
			// here we are  in widget mode (data loaded from widget.php)
			if(success)
			{
				// copy data from the loader to this
				for (var prop:String in _jsDataLoader_lv)
				{
					if(typeof(_jsDataLoader_lv[prop]) == "string")
						_root[prop] = _jsDataLoader_lv[prop];
				}
			}
			else
			{
				_parent.loading_str = "loading error - widget mode";
				return;
			}
		}
		
		//go to step 2
		onEnterFrame = onStep2EnterFrame;
		_parent.nextFrame();
	}
	/***********************************************************************************************************************
	* step/frame 2: load the api
	***********************************************************************************************************************/
	function onStep2EnterFrame() 
	{
		onEnterFrame = undefined;
	
		// container
		var apiContainer_mc:MovieClip = _parent.createEmptyMovieClip("apiContainer_mc", _parent.getNextHigestDepth());
		
		// MovieClipLoader
		_mcl = new MovieClipLoader;
		_mcl.addListener(this);
		if(_parent.rootUrl){
			_mcl.loadClip(_parent.rootUrl + "silex.swf", apiContainer_mc);
		}else{
			_mcl.loadClip("silex.swf", apiContainer_mc);
		}
	}
	
	// listener
	function  onLoadProgress (target:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
		_parent.loading_str = formatLoadingString(bytesLoaded, bytesTotal);
	}
	function onLoadInit(target_mc) {
		_parent.silexApi.application.addEventListener("preloadDone", mx.utils.Delegate.create(this, preloadDone));
		_parent.silexApi.application.start();
		//loading_str="rootUrl = "+rootUrl;
		_parent.loading_str = "website preload...";
	}
	function onLoadError(target_mc:MovieClip, errorCode:String) {
		//loading_str="rootUrl = "+rootUrl;
		_parent.loading_str =  "Error: \n" + errorCode;
	}
	function preloadDone()
	{
		_parent.silexApi.application.removeEventListener("preloadDone", preloadDone);
		_parent.nextFrame();
	}
}