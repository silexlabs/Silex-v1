/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * Name space for silex api
 */
var silexNS;
if(!silexNS)
	silexNS = new Object;
/**
 * SilexAPIClass is the base class for SilexAPI singleton
 * When loaded, it calls the admin API AS2 part after successfully loging in, by hooking "loginSuccess" to loadAs2AdminApi.
 * Then AS2 API calls the "org.silex.adminApi.SilexAdminApi.adminApiLoad.START" hook 
 * Then JS part of the admin API is loaded, which then calls the hook "silexAdminApiReady".
 */
silexNS.SilexAPIClass = function ()
{
	this.SilexAPIClass();
}
silexNS.SilexAPIClass.prototype =
{
	/////////////////////////////////////////////////////////////
	// Group: Attributes
	/////////////////////////////////////////////////////////////
	/**
	 * variable used to determine the zoom of the browser, it is updated by adjustSilexWindowSize in silex.js (yes it is ... no comment)
	 * decimal value - multiply it by 100 to have a %
	 */
	silexBrowserZoom:1,
	/**
	 * array of javascirpt files to include 
	 */
	jsFilesToInclude:[],
	/**
	 * array of javascirpt files which have been included dynamically 
	 */
	jsFilesIncluded:[],
	/**
	 * array of callbacks to call when loading finished 
	 */
	onScriptsLoadedCallbacksArray:[],
	/**
	 * true if scripts are beeing loaded<br />
	 * loading flag
	 */
	isLoadingScripts:false,
	/**
	 * store the resize mode of the publication<br />
	 * String, can be "noScale", "showAll", "scroll", "pixel", "noscale", "showall"
	 */
	scaleMode:"noScale",
	/**
	 * store the size of the publication (comes form the config)<br />
	 */
	siteWidth:1,
	/**
	 * store the size of the publication (comes form the config)<br />
	 */
	siteHeight:1,
	flashStageWidth:1,
	flashStageHeight:1,

	/////////////////////////////////////////////////////////////
	// Group: Interface Methods
	/////////////////////////////////////////////////////////////
	/**
	 * Constructor
	 */
	SilexAPIClass : function()
	{
	},
	/**
	 * Destructor
	 * It has to be called explicitly.
	 */
	__SilexAPIClass : function()
	{
	},
	/**
	 * check hash compatibility with previous deeplinking system (id_site was after the hash)
	 * eventually redirect the browser to the website using the new deeplink format
	 * for retro compatibility with silex < v1.5.1
	 * @example	http://localhost/sourceforge.net/silex/trunk/silex_server/#/test-components => http://localhost/sourceforge.net/silex/trunk/silex_server/?/test-components
	 * @example	http://localhost/sourceforge.net/silex/trunk/silex_server/#/test-components/start => http://localhost/sourceforge.net/silex/trunk/silex_server/?/test-components/#/start
	 * @return	false if the user has to be redirected to be compatible, true if it is ok
	 */
	checkCompatibility : function(websiteStartSection, defaultWebsite, $hash_compat, $rootUrl)
	{
		// eventually remove the starting slash
		if ($hash_compat.indexOf("/")==0)
			$hash_compat=$hash_compat.substring(1);
		// eventually redirect
		if ($hash_compat != '')
		{
			$indexOfSlash = $hash_compat.indexOf('/');
			//if ($indexOfSlash==-1) $indexOfSlash = $hash_compat.length;
			$id_site_compat = $hash_compat.substring(0,$indexOfSlash);
			if ($id_site_compat != websiteStartSection){
				// deeplink is in the form http://mysite.com/#/id_site/page/subpage/
				$id_site = $id_site_compat;
				$deeplink = $hash_compat.substring($indexOfSlash+1);
				
				// skip id_site for default website
				if ($id_site == this.defaultWebsite) {
					$new_url = $rootUrl;
				}else{
					$new_url = $rootUrl + "?/" + $id_site + "/";
				}
				if ($deeplink!="") $new_url += '#/'+$deeplink;
				// redirect
				window.location = $new_url;
				
				// NOT compatible
				return false;
			}
		}
		// compatible
		return true;
	},
	loadAs2AdminApi : function (){
		//alert("loadAs2AdminApi");
		document.getElementById('silex').SetVariable('silex_exec_str','load_clip:silex_admin_api.swf,plugins');
	
	},
	
	loadJsAdminApi : function(){
		//alert("loadJsAdminApi");
		silexNS.SilexApi.addScript(javascriptFolderUrl + "silex_admin_api.min.js");
		silexNS.SilexApi.includeJSSCripts();
		
	},
	/**
	 * add a Script to be loaded<br />
	 * call includeJSSCripts after adding several scripts
	 */
	addScript : function(javascriptFileName)
	{
		this.jsFilesToInclude.push(javascriptFileName);
	},
	/**
	 * include all the javascript files which are in jsFilesToInclude
	 */
	includeJSSCripts : function (onScriptsLoadedCallback)
	{
		if(onScriptsLoadedCallback)
		{
			this.onScriptsLoadedCallbacksArray.push(onScriptsLoadedCallback);
		}
			
		if (this.isLoadingScripts == false)
		{
			// get next script to load and remove it from the script to be loaded
			var nextScript = this.jsFilesToInclude.shift();
			// add it to the loaded scripts
			this.jsFilesIncluded[nextScript]=true;
			// loading flag
			this.isLoadingScripts = true;
			// load it
			this._includeNextScript(nextScript);
		}
	},
	/**
	 * @private
	 * include the next javascript file
	 */
	_includeNextScript : function (javascriptFileName)
	{
		var refToThis = this;
		this._includeSilexScript(javascriptFileName, function(){
			var nextScript;
			var hasNextScript = false;
			// retrieve the next script
			if (refToThis.jsFilesToInclude.length > 0)
			{
				// get next script to load and remove it from the script to be loaded
				nextScript = refToThis.jsFilesToInclude.shift();
				// check if the script was loaded already
				while (refToThis.jsFilesToInclude.length > 0 && refToThis.jsFilesIncluded[nextScript] && refToThis.jsFilesIncluded[nextScript]==true)
				{
					// get next script to load and remove it from the script to be loaded
					nextScript = refToThis.jsFilesToInclude.shift();
				}
				if (!refToThis.jsFilesIncluded[nextScript] || refToThis.jsFilesIncluded[nextScript]==false)
				{
					hasNextScript = true;
				}
			}
			// if it has a next script load it, otherwise we are done (call onScriptsLoadedCallback)
			if (hasNextScript)
			{
				// add it to the loaded scripts
				refToThis.jsFilesIncluded[nextScript]=true;
				// load it
				refToThis._includeNextScript(nextScript);
			}
			else
			{
				// loading flag
				refToThis.isLoadingScripts = false;
				// we are done, all scripts havebeen loaded
				while(refToThis.onScriptsLoadedCallbacksArray.length > 0)
				{
					var callback = refToThis.onScriptsLoadedCallbacksArray.shift();
					if (callback) callback();
				}
			}
		});
	},
	/**
	 * @private
	 * include one javascript file
	 * write into the DOM, do not call before document is loaded
	 */
	_includeSilexScript : function(file_path, onLoadCallback)
	{
		//Create a 'script' element	
		var scrptE = document.createElement("script");

		// Set it's 'type' attribute	
		scrptE.setAttribute("type", "text/javascript");

		// Set it's 'language' attribute
		scrptE.setAttribute("language", "JavaScript");

		// Set it's 'src' attribute
		scrptE.setAttribute("src", file_path);

		// Set it's onLoad callback
		scrptE.onload = onLoadCallback;
		
		// for IE :
		scrptE.onreadystatechange= function () {
			if (this.readyState == 'loaded' || this.readyState == 'complete') onLoadCallback();
		}

		// Now add this new element to the head tag
		document.getElementsByTagName("head")[0].appendChild(scrptE);
	},
	////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: size of the flash object
	////////////////////////////////////////////////////////////////////////////////////////////////
	/*
		case html w/h > flash w/h
		
						noScale				showAll				scroll				pixel
		html w/h		100% avail space	100% avail space	page h, 100% w		100% avail space
		flash w/h		scale 100%			100% avail space	scale 100%			scale 100%
		
		
		case html w/h < flash w/h
		
						noScale				showAll				scroll				pixel
		html w/h		page h/w			100% avail space	page h, site w		100% avail space
		flash w/h		scale 100%			100% avail space	scale 100%			100% avail space
	*/
	
	
	/**
	 * store the size and the resize mode of the publication<br />
	 * compute the zoom level of the browser<br />
	 * @param	newScaleMode							String, can be "noScale", "showAll", "scroll", "pixel", "noscale", "showall"
	 * @param	newSiteWidth and newSiteHeight			Number, size of the publication (comes form the config)
	 * @param	flashStageWidth and flashStageHeight	Number, size of the stage at a given time, used to compute the zoom level of the browser
	 */
	setScaleMode : function(newScaleMode/*:String*/, newSiteWidth/*:Int*/, newSiteHeight/*:Int*/, flashStageWidth/*:Int*/, flashStageHeight/*:Int*/)
	{
		// store the size and the resize mode of the publication
		this.scaleMode = newScaleMode;
		this.siteWidth = newSiteWidth;
		this.siteHeight = newSiteHeight;
		// compute the zoom level of the browser
		this.silexBrowserZoom = this.siteHeight / $('#silex').height();
		//console.log("setScaleMode "+newSiteWidth+", "+newSiteHeight+ " - "+newScaleMode);
		this.resize();
	},
	updateFlashStageSize : function(newFlashStageWidth/*:Int*/, newFlashStageHeight/*:Int*/)
	{
		this.flashStageWidth = newFlashStageWidth;
		this.flashStageHeight = newFlashStageHeight;
		//console.log("updateFlashStageSize "+this.flashStageWidth+", "+this.flashStageHeight);
		this.resize();
	},
	/**
	 * ajust the size of Silex main flash object<br />
	 * use jquery to get/set the size of the flash object<br />
	 * called by the main html page, in the body tag: onresize="silexNS.SilexApi.resize();"<br />
	 * @param	$flashStageWidth and $flashStageHeight	size of the Flash stage, in pixels - may be different from the publication size, since media can be outside of the boundaries
	 */
	resize : function()
	{
		var $cssObj;
		// compute the zoom level of the browser<br />
		var htmlHeight/*:String*/;// = $('#silex').height();
		var htmlWidth/*:String*/;// = $('#silex').width();

		// compute html w/h > flash w/h or html w/h < flash w/h
		var isHTMLWidthBigger/*Bool*/ = ($('#silexScene').width() > this.siteWidth);
		var isHTMLHeightBigger/*Bool*/ = ($('#silexScene').height() > this.siteHeight);
		
		//fixing scope
		if(this.scaleMode == undefined)
			silexNS.SilexApi.resize();
		
		// scale mode case
		switch(this.scaleMode)
		{
			case "noScale":
			case "noscale":
				// by default, no scroll
				$cssObj = {'overflow' : 'hidden'};
				
				// horizontal width of silex scene div
				if (isHTMLWidthBigger)
				{
					htmlWidth = "100%";
					$cssObj = {'overflow' : 'auto'};
				}
				else
					htmlWidth = this.siteWidth + "px";
					
				if (isHTMLHeightBigger)
				{
					htmlHeight = "100%";
					$cssObj = {'overflow' : 'auto'};
				}
				else
					htmlHeight = this.siteHeight + "px";
				break;
			case "showAll":
			case "showall":
				htmlWidth = "100%";
				htmlHeight = "100%";
				$cssObj = {'overflow' : 'hidden'};
				break;
			case "scroll":
				// by default, no scroll
				$cssObj = {'overflow' : 'hidden'};
				
				// horizontal width of silex scene div
				if (isHTMLWidthBigger)
				{
					htmlWidth = "100%";
					$cssObj = {'overflow' : 'auto'};
				}
				else
				{
					htmlWidth = this.siteWidth + "px";
				}
//				htmlWidth = this.flashStageWidth + "px";
				if ($('#silexScene').height()>this.flashStageHeight)
				{
					htmlHeight = "100%";
					$cssObj = {'overflow' : 'auto'};
				}
				else
					htmlHeight = this.flashStageHeight + "px";
				break;
			case "pixel":
				htmlWidth = "100%";
				htmlHeight = "100%";
				$cssObj = {'overflow' : 'hidden'};
   				break;
		}
		// resize silex flash object
		$('#silex').width(htmlWidth);
		$('#silex').height(htmlHeight);

		// console.log("resize "+this.scaleMode+" - "+htmlWidth+","+htmlHeight);
		
		// fix for "horizontal scroll bar appears when view menu loads"
		// change the overflow (scroll)
		// useless?
//		if ($cssObj)
//			$('#silexScene').css($cssObj);

		
		
		//console.log("resize "+htmlWidth+" , "+htmlHeight+" - "+this.scaleMode);
		silexNS.HookManager.callHooks({type:'bodyResize'});
	}
}
/**
 * SilexAPI class
 */
silexNS.SilexApi = new silexNS.SilexAPIClass();
silexNS.HookManager.addHook("wysiwygLoginSuccess", silexNS.SilexApi.loadAs2AdminApi);
silexNS.HookManager.addHook("org.silex.adminApi.SilexAdminApi.adminApiLoad.START", silexNS.SilexApi.loadJsAdminApi);
//silexNS.HookManager.addHook("bodyResize", function (){ silexNS.SilexApi.resize();});
silexNS.HookManager.addHook("refreshWorkspace", function (){ silexNS.SilexApi.resize();});