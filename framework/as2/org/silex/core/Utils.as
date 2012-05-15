/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

//import mx.managers.DepthManager;
import org.silex.core.UtilsHooks;
import org.silex.core.plugin.HookManager;
/**
 * In Utils class we put all the usefull functions used to deal with medias and standard user interactions.
 * in the repository : /trunk/core/Utils.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-17
 * @mail : lex@silex.tv
 */
class org.silex.core.Utils
{
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;

	/**
	 * Constructor.
	 * @param	api	Reference to silex main Api
	 */
	function Utils(api:org.silex.core.Api){
		// store Api reference
		silex_ptr=api;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: Date and time accessors
	// to display today date as 08/02/14 : ((<<silex.utils.YY>>/<<silex.utils.MM>>/<<silex.utils.DD>>))
	// to display today date as monday 14 february : ((<<silex.utils.DAY>> <<silex.utils.DD>> <<silex.utils.MONTH>>))
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * @return the year on 2 digits (eg 08 for 2008)
	 */
	function get YY():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getFullYear()-2000,2);
	}
	/**
	 * @return the month number on 2 digits (eg 01 for january)
	 */
	function get MM():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getMonth()+1,2);
	}
	/**
	 * @return the day number on 2 digits (eg 08 for 8th day of the month)
	 */
	function get DD():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getDate(),2);
	}
	/**
	 * @return the hour (from 0 to 23)  on 2 digits
	 */
	function get HH():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getHours(),2);
	}
	/**
	 * @return the hour (from 0 to 12)  on 2 digits
	 */
	function get HH12():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getHours()%12,2);
	}
	/**
	 * @return the minutes (from 0 to 59) on 2 digits
	 */
	function get MMIN():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getMinutes(),2);
	}
	/**
	 * @return the year on 4 digits (eg 2008) 
	 */
	function get YEAR():String{
		var today_date:Date = new Date();
		return formatNumberWithNDigits(today_date.getFullYear(),2);
	}	
	/**
	 * dependent on the language config
	 * @return the day of today (eg Monday)
	 */
	function get DAY():String{
		var daysOfWeek:Array = new Array(silex_ptr.config.DATE_SUNDAY,silex_ptr.config.DATE_MONDAY,silex_ptr.config.DATE_TUESDAY,silex_ptr.config.DATE_WEDNESDAY,silex_ptr.config.DATE_THURSDAY,silex_ptr.config.DATE_FRIDAY,silex_ptr.config.DATE_SATURDAY);
		var today_date:Date = new Date();
		return daysOfWeek[today_date.getDay()];
	}
	/**
	 * dependent on the language config
	 * @return the month (eg February)
	 */
	function get MONTH():String{
		var monthNames:Array = new Array(silex_ptr.config.DATE_JANUARY,silex_ptr.config.DATE_FEBRUARY,silex_ptr.config.DATE_MARCH,silex_ptr.config.DATE_APRIL,silex_ptr.config.DATE_MAY,silex_ptr.config.DATE_JUNE,silex_ptr.config.DATE_JULY,silex_ptr.config.DATE_AUGUST,silex_ptr.config.DATE_SEPTEMBER,silex_ptr.config.DATE_OCTOBER,silex_ptr.config.DATE_NOVEMBER,silex_ptr.config.DATE_DECEMBER);
		var today_date:Date = new Date();
		return monthNames[today_date.getMonth()];
	}
	/**
	 * @return the hour (from 0 to 23) 
	 */
	function get HOUR():String{
		var today_date:Date = new Date();
		return today_date.getHours().toString();
	}
	/**
	 * @return the hour (from 0 to 12) 
	 */
	function get HOUR12():String{
		var today_date:Date = new Date();
		return (today_date.getHours()%12).toString();
	}
	/**
	 * @return AM or PM
	 */
	function get AMPM():String{
		var today_date:Date = new Date();
		var res:String;
		if (today_date.getHours()>=12)
			res="pm";
		else
			res="am";
		return res;
	}
	/**
	 * @return the minutes (from 0 to 59)
	 */
	function get MINUT():String{
		var today_date:Date = new Date();
		return today_date.getMinutes().toString();
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: Conversions
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Convert an html formated text into a raw text (removes all tags).
	 * @param html_str		the html formated text
	 * @return				the corresponding raw text
	 */
	public function getRawTextFromHtml(html_str:String):String
	{
		if (!_root.utils_mc) _root.createEmptyMovieClip("utils_mc",_root.getNextHighestDepth());
		if (!_root.utils_mc.getRawTextFromHtml_txt) _root.createTextField("getRawTextFromHtml_txt",_root.getNextHighestDepth(),0,0,0,0);
		_root.getRawTextFromHtml_txt._visible=false;
		_root.getRawTextFromHtml_txt.html=true;
		// htmlElementToSpace contains all elements where a space should be added
		var htmlElementToSpace:Array = new Array('</font>','<br/>','<br />','<br>','</FONT>','<BR/>','<BR />','<BR>')
		// add a space character before html elements defined in htmlElementToSpace so first and last words of each html part are not aggregated
		for (var element in htmlElementToSpace) {
			html_str = replace(html_str, htmlElementToSpace[element], ' ' + htmlElementToSpace[element]);
		}
		// fill getRawTextFromHtml_txt htmlText with cleaned html_str
		_root.getRawTextFromHtml_txt.htmlText = html_str;
		
		return _root.getRawTextFromHtml_txt.text;
	}
	/**
	 * Remove unwanted chars from ID.
	 * Cleans a given ID to only use allowed characters. Accented characters are converted to unaccented ones.
	 * Comes from dokuwiki inc/pageutils.php.
	 *
	 * @example				filterSectionName("my Section. NAME") returns "my_section._name"
	 * @param  raw_id    The pageid to clean
	 */
	function cleanID(id:String):String
	{
		
		// Strip whitespace (or other characters) from the beginning and end of a string
		// in php: id = trim(raw_id);
		switch(id.charAt(0)){
			case " ":
			case "\r":
			case "\n":
			case "\t":
				id=id.substring(1);
		}
		switch(id.charAt(id.length-1)){
			case " ":
			case "\r":
			case "\n":
			case "\t":
				id=id.substring(0,id.length-1);
		}
		
		// to lower case
		id = id.toLowerCase();
		
		// to do for russian etc. , see dokuwiki inc/utf8.php
		// id = utf8_romanize(id);
		
		// remove accents
		id = deaccent(id);
		
		//remove specials
		// to do remove special chars such as & @ ...
		// id = utf8_stripspecials(id,sepchar,'\*');
		
		// ? if(ascii) id = utf8_strip(id);
		
		//clean up
		id = replace(id, " ",silex_ptr.config.sepchar);
		
		return id;
	}
	/**
	 * Add slashes to a string before characters that need to be quoted in database queries etc. These characters are single quote ('), double quote ("), backslash (\).
	 * @param	_str	the string to which to add the slashes
	 * @return a string with backslashes before characters that need to be quoted in database queries etc. 
	 */
	function addslashes(_str:String):String
	{
		var res:String=_str;
		res = replace(res, "\\", "\\\\");
		res = replace(res, "'", "\\'");
		res = replace(res, '"', '\\"');
		return res;
	}
	/**
	 * Convert num into string and adds 0s before it so that it has nDigits numbers.
	 * @param	num			the number to convert
	 * @param	nDigits		the number of digits which the output string will have
	 * @return	a string with nDigits digit and which represents the input number 
	 * @example	formatNumberWithNDigits(25,5) returns "00025"
	 */
	function formatNumberWithNDigits(num:Number,nDigits:Number):String{
		var res_str:String=num.toString();
		while(res_str.length<nDigits){
			res_str="0"+res_str;
		}
		return res_str;
	}
	/**
	 * Encodes a html string using html entities.
	 * @param	str: the html sting to be encoded
	 * @return	a string html entities encoded
	 */
	function htmlEntitiesEncode(str:String):String
	{
		return (new XMLNode( 3, str )).toString();
	}
	/**
	 * Decodes a html string using html entities.
	 * @param	str: the html sting to be decoded
	 * @return	a string html entities decoded
	 */
	function htmlEntitiesDecode(str:String):String
	{
		return (new XML(str)).firstChild.nodeValue;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: User interaction windows
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * handler for all dialogs to call before closing<br />
	 * dispatch the "closeDialog" hook
	 * @param	args	array of the arguments which will be passed to the callback of the dialog, you can modify the values in the hook
	 */
	public function handleCloseDialog(args:Array)
	{
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(UtilsHooks.DIALOG_END_HOOK_UID, args);
	}
	/**
	 * Name of the last opened alertSimple dialog box.
	 */
	var lastOpenedAlertSimpleName:String="";
	/**
	 * Display a message in a dialog box. when the user closes the window (click on "ok" button or on "close" button), the desired callback function is called.
	 * @param text_str		the text to be displayed (the message)
	 * @param cbkFunction	the callback function to be called when the user closes the window
	 * @return	the dialog box (use it to force the dialog box to close for example)
	 */
	public function alert(text_str:String,cbkFunction:Function):MovieClip
	{
		// call hook
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(UtilsHooks.DIALOG_START_HOOK_UID, arguments);
		// prevent default behaviour
        if ((!text_str || text_str=="") && cbkFunction == null)
        {
            return null;
		}
		//var wndName:String="dialog"+(Math.round(Math.random()*10000).toString())+"_mc";
		var _mc:MovieClip=silex_ptr.pluginsContainer_mc.dialogBox.attachMovie("alert","dialog"+(Math.round(Math.random()*10000).toString())+"_mc",_root.getNextHighestDepth(),{cbkFunction:function(){this.handleCloseDialog(this.arguments);cbkFunction();},dialogText:text_str,handleCloseDialog:handleCloseDialog});
//		_root[wndName]=_root.createChildAtDepth("alert",DepthManager.kTop,{cbkFunction:cbkFunction,dialogText:text_str});

		centerMedia(_mc,Stage.width,Stage.height,silex_ptr.application.stageRect.left,silex_ptr.application.stageRect.top);
		
		// return the message window
		return _mc;
	}
	
	/**
	 * Display a message without a dialog box.
	 * @param text_str		the text to be displayed (the message)
	 * @param time_num		duration in milliseconds for the message to be displayed
	 * @param cbkFunction	the callback function to be called when the time has elapsed
	 * @param status the status of the message (info, debug, warning, error)
	 */
	public function alertSimple(text_str:String,time_num:Number,cbkFunction:Function, status:String):Void
	{

		silex_ptr.application.dispatchEvent( { type:"alertSimple", text:text_str, time:time_num, status:status } );
	}
	/**
	 * Display a question in a dialog box with "ok" and "cancel" buttons. 
	 * When the user closes the window (click on "ok" button or on "close" button or "cancel" button), the desired callback function is called.
	 * @param text_str		the text to be displayed (the message)
	 * @param cbkFunction	the callback function to be called when the user closes the window
	 * @return	the dialog box (use it to force the dialog box to close for example)
	 */
	public function confirm(text_str:String,cbkFunction:Function):MovieClip
	{
		// call hook
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(UtilsHooks.DIALOG_START_HOOK_UID, arguments);
		// prevent default behaviour
        if ((!text_str || text_str=="") && cbkFunction == null)
        {
            return null;
		}

		//var wndName:String="dialog"+(Math.round(Math.random()*10000).toString())+"_mc";
		var _mc:MovieClip=silex_ptr.pluginsContainer_mc.dialogBox.attachMovie("confirm","dialog"+(Math.round(Math.random()*10000).toString())+"_mc",_root.getNextHighestDepth(),
		{
			cbkFunction:function(isOk){
				this.handleCloseDialog(this.arguments);
				cbkFunction(isOk);
			},
			dialogText:text_str,
			handleCloseDialog:handleCloseDialog
		});
//		_root[wndName]=_root.createChildAtDepth("confirm",DepthManager.kTop,{cbkFunction:cbkFunction,dialogText:text_str});
		centerMedia(_mc,Stage.width,Stage.height,silex_ptr.application.stageRect.left,silex_ptr.application.stageRect.top);

		// return the message window
		return _mc;
	}
	/**
	 * Ask the user to write a string. when the user closes the window (click on "ok" button or on "close" button or "cancel" button), the desired callback function is called.
	 * @param text_str		the text to be displayed (the message)
	 * @param default_str	the default string to be displayed before the user modify it
	 * @param cbkFunction	the callback function to be called when the user closes the window
	 * @return	the dialog box (use it to force the dialog box to close for example)
	 */
	public function prompt(text_str:String,default_str:String,cbkFunction:Function):MovieClip
	{
		// call hook
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(UtilsHooks.DIALOG_START_HOOK_UID, arguments);
		// prevent default behaviour
        if ((!text_str || text_str=="") && cbkFunction == null)
        {
            return null;
		}
		
		var _mc:MovieClip=silex_ptr.pluginsContainer_mc.dialogBox.attachMovie("prompt","dialog"+(Math.round(Math.random()*10000).toString())+"_mc",_root.getNextHighestDepth(),{cbkFunction:function(isOk){this.handleCloseDialog(this.arguments);cbkFunction(isOk);},dialogText:text_str,dialogDefault:default_str});
		centerMedia(_mc,Stage.width,Stage.height,silex_ptr.application.stageRect.left,silex_ptr.application.stageRect.top);

		// return the message window
		return _mc;
	}
	/**
	 * Ask the user to login
	 * @param text_str		the text to be displayed (the message)
	 * @param cbkFunction	the callback function to be called when the user closes the window
	 * @return	the dialog box (use it to force the dialog box to close for example)
	 */
	public function promptPassword(text_str:String,cbkFunction:Function):MovieClip
	{
		// call hook
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(UtilsHooks.DIALOG_START_HOOK_UID, arguments);
		// prevent default behaviour
        if ((!text_str || text_str=="") && cbkFunction == null)
        {
            return null;
		}

		var _mc:MovieClip= silex_ptr.pluginsContainer_mc.dialogBox.attachMovie("promptPassword","dialog"+(Math.round(Math.random()*10000).toString())+"_mc",_root.getNextHighestDepth(),{cbkFunction:function(input_str,password_str){this.handleCloseDialog(this.arguments);cbkFunction(input_str,password_str);},dialogText:text_str,handleCloseDialog:handleCloseDialog});
		centerMedia(_mc,Stage.width,Stage.height,silex_ptr.application.stageRect.left,silex_ptr.application.stageRect.top);

		// return the message window
		return _mc;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: swf related functions
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Takes the url from which _root was downloaded, remove the file name and return the url of the folder from which _root was downloaded.
	 * Also used in Api rootUrl getter.
	 * @return the url of the folder from which _root was downloaded
	 */
	public function getRootUrl():String
	{
		// ****************
		// WORKAROUND BUG GATEWAY
		// remove file name, e.g. ROOTS.swf
		var path_str:String;
		if (silex_ptr.parent.rootUrl)
			path_str = silex_ptr.parent.rootUrl;
		else
			path_str = silex_ptr.parent._url.slice(0, 1 + silex_ptr.parent._url.lastIndexOf("/"));
			
		return path_str;
		// ***************
	}
	/**
	 * retrieve an object from its path, starting in a given MovieClip
	 * @param	source_mc	the object in which to start looking for the target
	 * @param	path_str	the target path starting in the source MovieClip
	 * @param	separator	the separator used for inclusion in the notation (path.to.a.variable or path/to/a/variable) - default is "."
	 * @return the targeted object
	 */
	public function getTarget(source_mc/*:Object*/,path_str:String,separator:String):Object{
		if (!path_str || path_str=="" || path_str=="." )
			return source_mc;

		// Choose the first clip : source_mc or silex or silexGabaritRoot or layout root
		var tmp_source_mc = null;

		// default separator = "."
		if (!separator) separator=".";

		// get a path array from the path string
		var path_array:Array=path_str.split(separator);
		
		var firstInPathArray:String = path_array[0];
		//_global.getSilex(this).utils.alert("path_str : " + path_str + ", firstInPathArray : " + firstInPathArray);		
		switch(firstInPathArray){
			case "_global":
				tmp_source_mc = _global;
				path_array.shift();
			break;
			case "_root":
				tmp_source_mc = _root;
				path_array.shift();
				break;
			case "silex":
				tmp_source_mc = silex_ptr;
				path_array.shift();
				break;
			case "layout":
				tmp_source_mc = silex_ptr.application.getLayout(source_mc);
				path_array.shift();
				break;
			case "plugins":
				tmp_source_mc = silex_ptr.pluginsContainer_mc;
				path_array.shift();
				break;
			default:
				var playerTmp = silex_ptr.application.getPlayerByName(firstInPathArray);
				if (playerTmp){
					tmp_source_mc = playerTmp;
					path_array.shift();
				}else if (source_mc[firstInPathArray] != undefined){ // source_mc
					// start looking for the target in the source object
					tmp_source_mc = source_mc;
				}				
			
			
		}
		// reach the targeted clip
		for(var i=0;i<path_array.length;i++){
			if (tmp_source_mc[path_array[i]]!=undefined)
				tmp_source_mc=tmp_source_mc[path_array[i]];
			else{
		
				return null;
			}
		}
		return tmp_source_mc;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: media functions
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Array which contains all the files and streams being downloaded.
	 */
	public var loadingMedias:Array;
	/**
	 * Resize the given movie clip so that it fits the rectangle and it keeps the same width/height ratio.
	 * @param target_mc	the movie clip to be resized
	 * @param w			the maximum width that the media can have
	 * @param h			the maximum height that the media can have
	 * @return			the ratio by which the media has been resized
	 */
	public function resizeMedia(target_mc:MovieClip,w:Number,h:Number):Number
	{
		// compute the ratio to be applyed to the media
		var ratio:Number=w/target_mc._width;
		if (ratio*target_mc._height>h)
			ratio=h/target_mc._height;

		// apply the ratio to height and width
		target_mc._width=ratio*target_mc._width;
		target_mc._height=ratio*target_mc._height;
		
		return ratio;
	}
	/**
	 * Center a movie clip in a specifyed zone or container.
	 * @param target_mc	movie clip to be centered
	 * @param w			container's width
	 * @param h			container's height
	 * @param delta_x	optional - container's upper left corner x-coordinate
	 * @param delta_y	optional - container's upper left corner y-coordinate
	 */
	public function centerMedia(target_mc,w:Number,h:Number,delta_x:Number,delta_y:Number)
	{
		if (!w || !h)
			return;
		
		
		var centre:Number;
		
		// default values
		if (!delta_x) delta_x=0;
		if (!delta_y) delta_y=0;

		// center on the x axis
		centre=target_mc._x+target_mc._width/2;
		target_mc._x-=centre-w/2;
		target_mc._x+=delta_x;

		// center on the y axis
		centre=target_mc._y+target_mc._height/2;
		target_mc._y-=centre-h/2;
		target_mc._y+=delta_y;
	}
	/**
	 *
	 */
	public function unLoadMedia(target_mc:MovieClip)
	{
		var _mcl:MovieClipLoader = new MovieClipLoader;
		_mcl.unloadClip(target_mc);
	}
	/**
	 * Loads a media into a container. the media can be of any type (jpg, swf, mp3, flv, and other once the frame development will be done).
	 * While downloading, the media will be referenced in an object stored in loadingMedias.
	 * TO DO : USE IT IN org.silex.ui.players.Image
	 * @param url_str			url of the media to be loaded
	 * @param target_mc			the MovieClip in which to load the media
	 * @param extension			the extension of the source. flv, swf, jpg, gif, or png are supported
	 * @param resObj			optional - the listener object
	 * @param container_rect	optional - object representing the rectangle used to center or resize the media once loaded, contains left, top, right and bottom attributes
	 * @param resize_bool		optional - if true, the media is resized to fit container_rect
	 * @param center_bool		optional - if true, the media is centered with container_rect's center
	 */
	public function loadMedia(url_str:String,target_mc:MovieClip,extension:String, resObj:Object,container_rect:Object,resize_bool:Boolean,center_bool:Boolean)
	{
		//_global.getSilex(this).utils.alert("utils.loadMedia" + url_str + ", " + target_mc + ", " + extension);
		if (!loadingMedias) loadingMedias=new Array;

		switch (extension)
		{
			case "flv":
				// TO DO: use target_mc as a video screen
				break;
			case "mp3":
				// TO DO
				break;
			case "swf":
				System.security.allowDomain(url_str);
			case "jpg":
			case "gif":
			case "png":
				var _mcl:MovieClipLoader = new MovieClipLoader;
				if (url_str.indexOf("http")==0 || url_str.indexOf("file")==0)
					_mcl.loadClip(url_str, target_mc);
				else
					_mcl.loadClip(silex_ptr.rootUrl+url_str,target_mc);
				
				var _listener:Object=new Object;
				_listener.ext_str=extension;
				_listener.url_str=url_str;
				if (container_rect)
				{
					_listener.container_rect=container_rect;
					_listener.resize_bool=resize_bool;
					_listener.center_bool=center_bool;
				}
				_listener.resObj=resObj;
				_listener.refToThis=this;
				loadingMedias.push(_listener);
				
				_listener.onLoadStart = function(target:MovieClip)
				{
					this.resObj.onLoadStart(target);
				}
				_listener.onLoadProgress = function(target:MovieClip, bytesLoaded:Number, bytesTotal:Number)
				{
					this.resObj.onLoadProgress(target, bytesLoaded, bytesTotal);
				}
				_listener.onLoadComplete = function(target:MovieClip)
				{
					this.resObj.onLoadComplete(target);
				}
				_listener.onLoadInit = function(target:MovieClip)
				{
					
					if (this.ext_str=="swf") target._lockroot=true;
					this.resObj.onLoadInit(target);
					
					// removes from loadingMedias array
					for (var idx:Number=0;idx<this.refToThis.loadingMedias.length;idx++){
						if (this.refToThis.loadingMedias[idx]==this){
							this.refToThis.loadingMedias.splice(idx,1);
						}
					}
					
					// center and resize
					if (this.container_rect)
					{
						if (this.resize_bool==true)
						{
							this.refToThis.resizeMedia(target,this.container_rect.right-this.container_rect.left,this.container_rect.bottom-this.container_rect.top);
						}
						if (this.center_bool==true)
						{
							this.refToThis.centerMedia(target,this.container_rect.right-this.container_rect.left,this.container_rect.bottom-this.container_rect.top,this.container_rect.left,this.container_rect.top);
						}
					}
				}
				_listener.onLoadError = function(target:MovieClip, errorCode:String)
				{
					this.resObj.onLoadError(target, errorCode);
					
					// removes from loadingMedias array
					for (var idx:Number=0;idx<this.refToThis.loadingMedias.length;idx++){
						if (this.refToThis.loadingMedias[idx]==this){
							this.refToThis.loadingMedias.splice(idx,1);
						}
					}
				}
				_mcl.addListener(_listener);
				break;
		}
	}
/*	/**
	 * Custom trace function. Use XRAY debug console if it is available.
	 * @param	_obj		the object to trace
	 * @param	level_str	a debug level
	 */
/*	public function trace(_obj:Object,level_str:String)
	{
		
		//_global.Xray.xrayLogger.debug("myObj"[, obj]);
		//_global.Xray.xrayLogger.info("myObj"[, obj]);
		//_global.Xray.xrayLogger.warn("myObj"[, obj]);
		//_global.Xray.xrayLogger.error("myObj"[, obj]);
		//_global.Xray.xrayLogger.fatal("myObj"[, obj]);
		
		var _str:String;
		if (typeof(_obj)=="movieclip" || typeof(_obj)=="object")
			_str=dump(_obj);
		else
			_str=_obj.toString();
		
		// cause an infinite loop if compiled with mtasc
		switch(level_str)
		{
			case silex_ptr.config.DEBUG_LEVEL_ERROR:
				_global.Xray.xrayLogger.fatal(_str);
			break;
			case silex_ptr.config.DEBUG_LEVEL_WARNING:
				_global.Xray.xrayLogger.warn(_str);
			break;
			case silex_ptr.config.DEBUG_LEVEL_DEBUG:
			default:
				_global.Xray.xrayLogger.debug(_str);
			break;
		}
	}*/
/*	/**
	 * Dump an object recursively. Trace all its properties and dump its objects
	 * @param	_obj	the object to dump
	 * @param	tab		tab characters to be added at the beginning of a line for formatting
	 * @return	a string which can be printed or traced
	 */
/*	function dump(_obj:Object,tab:String):String{
		var res_str="";//"dump\n-----\n";
		if (!tab) tab="";
		
		for (var prop:String in _obj){
			if (typeof(_obj[prop])=="movieclip" || typeof(_obj[prop])=="object")
				res_str+=prop+":\n"+dump(_obj[prop],tab+"-");
			else
				res_str+=tab+prop+"="+_obj[prop].toString()+"\n";
		}
		return res_str;
	}*/
	/**
	 * Serialize an object recursively into a json string
	 * @param	_obj	the object, array or value to serialize
	 * @return	a string which can be printed or traced
	 */
	function obj2json(_obj):String{
		var res_str = "";
		
		if (typeof(_obj) == "movieclip" || typeof(_obj) == "array" || typeof(_obj) == "object")
		{
			for (var prop:String in _obj)
			{
				if (res_str != "") res_str += ",";
				if (typeof(_obj) != "array") res_str += prop + ":";
				res_str+=obj2json(_obj[prop]);
			}
			if (typeof(_obj) == "array")
				res_str = "[" + res_str + "]";
			else
				res_str = "{"+res_str+"}";
		}
		else
			res_str = "\"" + _obj.toString() + "\"";
		return res_str;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: strings utilities
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Replace a string by another string in the source string.
	 * @param	chaine_str
	 * @param	a_remplacer_str
	 * @param	remplacement_str
	 * @return	the input with all occurences replaced
	 */
	function replace(chaine_str:String,a_remplacer_str:String,remplacement_str:String):String
	{
		var res_str:String="";
		var tmp_index:Number;
		var tmp_array:Array=chaine_str.split(a_remplacer_str);
		
		for (tmp_index=0;tmp_index<tmp_array.length;tmp_index++)
		{
			res_str+=tmp_array[tmp_index];
			if (tmp_index!=tmp_array.length-1)
				res_str+=remplacement_str;
		}
		return res_str;
	}
	/**
	 * Replace accented UTF-8 characters by unaccented ASCII-7 equivalents.
	 * From dokuwiki inc/utf8.php.
	 * @param	_str	the input string
	 * @return	the de-accented string
	 */
	function deaccent(_str:String):String{
		// lowercases
		for (var idx:Number=0;idx<silex_ptr.config.UTF8_LOWER_ACCENTS.length;idx++)
		    _str = replace(_str,silex_ptr.config.UTF8_LOWER_ACCENTS[idx].accented,silex_ptr.config.UTF8_LOWER_ACCENTS[idx].ascii);

		// uppercases
		for (var idx:Number=0;idx<silex_ptr.config.UTF8_UPPER_ACCENTS.length;idx++)
		    _str = replace(_str,silex_ptr.config.UTF8_UPPER_ACCENTS[idx].accented,silex_ptr.config.UTF8_UPPER_ACCENTS[idx].ascii);

	  return _str;
	}
	/**
	 * Use the accessors delimiters paterns to split the input string into an array.
	 * @param	input_str	a string containing accessors
	 * @param	leftTag		[[optional]]left delimiter, (( by default
	 * @param	rightTag	[[optional]]right delimiter, )) by default
	 * @return	the array of strings containing accessors
	 */
	function splitTags(input_str:String,leftTag:String,rightTag:String):Array 
	{
		
		// default values
		if (!leftTag) leftTag = "((";
		if (!rightTag) rightTag = "))";

		// tmp_array is used to store the string splited on "((" for text that should be removed if the accessor has no value
		var tmp_array:Array;

		// result array
		var _array:Array=new Array;

		// **
		// split on ((
		tmp_array=input_str.split("((");

		// ?! useless : if there is no "((" the array has only 1 element !!!
/*		if (!tmp_array) // no "(("
		{
			tmp_array=new Array([input_str]);
		}
*/

		// split on ))
		for(var idx:Number=0;idx<tmp_array.length;idx++)
		{
			if (tmp_array[idx] != "")
			{
				var tmp_idx:Number=tmp_array[idx].indexOf("))");
				if (tmp_idx && tmp_idx>=0)
				{// bug : when no "))" is found, tmp_idx=undefined
					_array.push(tmp_array[idx].slice(0,tmp_idx));
					if (tmp_idx+2<tmp_array[idx].length)
						_array.push(tmp_array[idx].substr(tmp_idx+2));
				}
				else
					_array.push(tmp_array[idx]);
			}
		}
		
		if (_array.length > 0)
		{
			if(_array[0] == "")
				_array.shift();
			
			if(_array[_array.length-1] == "")
				_array.pop();
		}
		
//		return ["- <<subobj1.var1>> ","- ","<<subobj1.var2>> - "," - xxx"];
//		((- <<subobj1.var1>> ))- ((<<subobj1.var2>> - )) - xxx

		// avoid empty element at start (case of string begining with "((")
		// bug : leave the openning and closing (( and )) 
		// if (_array[0] == "") _array.shift();
		
		return _array;

	}
	/**
	 * Replaces accessors by their values in a String.
	 * for example "my text is for <<dbdata.name1>>!!! not for <<dbdata.name2>> ((nor for <<dbdata.name3>>!!!))" becomes
	 * - "my text is for valueName1!!! not for valueName2 nor for valueName3!!!" if all name variables exist
	 * - "my text is for valueName1!!! not for valueName2" if only dbdata.name1 & dbdata.name2 exists
	 * - "" if only dbdata.name1 or dbdata.name2 exists
	 * - "nor for valueName3!!!" if only dbdata.name3 exists
	 * 
	 * @param input_str	a string containing accessors ("((...<<path.to.a.variable>>...))")
	 * @param source_mc	the movie clip from which to start when looking for the variable (see org.silex.Utils.getTarget)
	 * @param separator	the separator used for inclusion in the notation (path.to.a.variable or path/to/a/variable) - default is "."
	 * @return	the resulting string [or object if only 1 accessor in the string, or an array of objects if only accessors and no other chars]
	 */
	function revealAccessors(input_str/*:String*/, source_mc:Object, separator:String)//:String
	{
		// _array is used to store the string splited on "((" and "))" for text that should be removed if the accessor has no value
		var _array:Array;
		// temp index
		var idx:Number;
		// flag used to determine the return value type (string, object or array of objects
		var hasStringInIt:Boolean=false;
		// default separator = "."
		if (!separator) separator=silex_ptr.config.accessorsSepchar;

		// **
		// check input
		if (!input_str)
		{
			// error in the input
			// throw new Error("org.silex.core.Utils  revealAccessors - error in the input argument, input_str is not a String: "+input_str);
			return "";
		}
		if (typeof(input_str) != "string")
		{
			input_str = input_str.toString();
		}
		
		// split on ((
		_array = splitTags(input_str, "((", "))");
		
		// **
		// replaces accessors by data on each element
		for (idx=0;idx<_array.length;idx++)
		{
			var ltgt_length_num:Number=2; // length of "<<" and ">>"
			var start_idx:Number=_array[idx].indexOf(silex_ptr.config.accessorsLeftTag);
			// against html encoding bug
			if (start_idx==-1)
			{
				ltgt_length_num=8;// length of "<<" and ">>"
				start_idx=_array[idx].indexOf((silex_ptr.config.accessorsLeftTagHtml));
			}
			// it has no << so it is a string
			if (start_idx == -1)
				hasStringInIt = true;
				
			// if there is no accessor, leave the "((" and "))"
			// there was a "((" and "))" pair only if we are not on a pair index // the first or last array element
/*			removed this - fixed ((<<uneValeurDynamique>>)) - ((<<uneDeuxièmeValeurDynamique>>)) -> uneValeurDynamiqueRévélée (( - )) uneDeuxièmeValeurDynamiqueRévélée
			if (start_idx==-1 && idx%2!=0)//idx!=0 && idx!=_array.length-1)
			{
				_array[idx] = "((" + _array[idx] + "))";
			}
*/			
			// for each accessor found in this element
			while (start_idx>=0)
			{
				ltgt_length_num=2;// length of "<<" and ">>"
				var end_idx:Number=_array[idx].indexOf(silex_ptr.config.accessorsRightTag);
				// against html encoding bug
				if (end_idx==-1) 
				{
					ltgt_length_num=8;// length of "<<" and ">>"
					end_idx=_array[idx].indexOf((silex_ptr.config.accessorsRightTagHtml));
				}

				// no ">>" to close the "<<"
				if (end_idx <= start_idx) break; 
				
				// get the accessor name
				var accessor_name:String=_array[idx].slice(start_idx+ltgt_length_num,end_idx);
				
				// retrieve the filter name
				var hasFilter:Boolean = false;
				var filter_name:String;
				var args:Array;
				var filter_separator_index:Number = accessor_name.indexOf(silex_ptr.config.filterSeparator);
				if (filter_separator_index > 0)
				{
					// retrieve the filter name and args, e.g. "filter:arg1,arg2" in <<filter:arg1,arg2 accessor>>
					filter_name = accessor_name.substr(0, filter_separator_index);
					// retrieve the arguments, e.g. ["filter","arg1,arg2"] in <<filter:arg1,arg2 accessor>>
					var argsArray = filter_name.split(":");
					// update filter name, e.g. "filter" in <<filter:arg1,arg2 accessor>>
					filter_name = argsArray[0];
					// retrieve the arguments, e.g. ["arg1","arg2"] in <<filter:arg1,arg2 accessor>>
					args = argsArray[1].split(silex_ptr.config.filterArgsSeparator);
					// retrieve the accessor itself, e.g. "accessor" in <<filter:arg1,arg2 accessor>>
					accessor_name = accessor_name.substr(filter_separator_index + 1);
				}
				
				
				// get the corresponding value
				var value_obj:Object=getTarget(source_mc,accessor_name,separator);

				// filter value
				if (silex_ptr.filter.filterExist(filter_name,value_obj,args,source_mc))
				{
					value_obj = silex_ptr.filter.exec(filter_name,value_obj,args,source_mc);
				}
				
				// is there a value?
				if (value_obj!=null)
				{// yes, there is a value
					// retrieve value
					var value_str:String;
					if (typeof(value_obj)!="string")
					{
						// filter value
/*						if (silex_ptr.filter.filterExist(filter_name,value_obj,args,source_mc))
						{
							_array[idx] = silex_ptr.filter.exec(filter_name,value_obj,args,source_mc);
						}
						*/
						_array[idx] = value_obj;
						break;
					}
					else
					{
						if(typeof(value_obj)=="string")
						{
							// return value will be string
							hasStringInIt = true;
	
							value_str = value_obj.toString();
							
							// replace the accessor in the element by the value
							_array[idx]=
								_array[idx].slice(0,start_idx)
								+ value_str
								+ _array[idx].substr(end_idx + ltgt_length_num);
						}
						else
						{
							_array[idx] = value_obj;
							break;
						}
					}
				}
				else
				{// no, there is no value
					// remove all the text between "((" and "))"
					_array[idx] = ""; 
					hasStringInIt = true;
				}
				// loop: next accessor (next "<<")
				ltgt_length_num=2;// length of "<<" and ">>"
				start_idx=_array[idx].indexOf(silex_ptr.config.accessorsLeftTag);
				// against html encoding bug
				if (start_idx==-1) 
				{
					ltgt_length_num=8;// length of "<<" and ">>"
					start_idx=_array[idx].indexOf((silex_ptr.config.accessorsLeftTagHtml));
				}
			}
		}
		
		var res;
		if (hasStringInIt == true)
		{
			// return value is string
			res = _array.join("");
		}
		else if (_array.length>1)
		{
			// return value is array of objects
			res = _array;
		}
		else
		{
			// return value is an object
			res = _array[0];
		}
		return res;
	}
	/**
	 * Reveal wiki tags.
	 * Images and links, see bellow
	 * @param	input_str	a string which contains wiki tags
	 * @return	the resulting string
	 */
	function revealWikiSyntax(input_str:String):String{
		// split on (( and ))
/*		var _array:Array = splitTags(input_str, "((", "))");
		// **
		// replaces by data on each element
		for (var idx:Number=0;idx<_array.length;idx++)
		{
			// reveal links
			_array[idx] = revealTags(_array[idx],"[[","]]",Utils.createDelegate(this,processWikiLinkTag));
			// reveal images
			_array[idx] = revealTags(_array[idx], "{{", "}}", Utils.createDelegate(this, processWikiImageTag));
		}
		// return result
		return _array.join("");
*/
		// reveal links
		input_str = revealTags(input_str,"[[","]]",Utils.createDelegate(this,processWikiLinkTag));
		// reveal images
		input_str = revealTags(input_str, "{{", "}}", Utils.createDelegate(this, processWikiImageTag));
		return input_str;
	}
	/**
	 * Reveal images.
	 * @param	tag_str	the string between {{ and }}
	 * @return	the equivalent html code
	 * @example "...{{image.jpg}}..." becomes "...<img src='image.jpg' />..."
	 */
	function processWikiImageTag(tag_str:String):String {
		// 
		var attr_str:String="";
		// align parameter
		if (tag_str.charAt(0)==" "){
			attr_str+="align='right' ";
			tag_str=tag_str.substring(1);
		}
		else if (tag_str.charAt(tag_str.length-1)==" "){
			attr_str+="align='left' ";
			tag_str=tag_str.substring(0,tag_str.length-1);
		}
		// size parameter
		// is there a '?' with something before and after it?
		var qmIdx:Number=tag_str.lastIndexOf("?");
		if (qmIdx>0 && qmIdx<tag_str.length-1){
			// extract size parameter (50x80)
			var sizeParam_str:String=tag_str.substring(qmIdx+1);
			// is there a 'x' with something before and after it?
			var xIdx:Number=sizeParam_str.lastIndexOf("x");
			if (xIdx>0 && xIdx<sizeParam_str.length-1){
				var width_num=sizeParam_str.substring(0,xIdx);
				var height_num=sizeParam_str.substring(xIdx+1);
				// are the values numbers?
				if (parseInt(width_num)>0 && parseInt(height_num)>0){
					attr_str+="width='"+width_num+"' height='"+height_num+"' ";
					tag_str=tag_str.substring(0,qmIdx);
				}
			}
		}
		if (tag_str.length>0)
			return "<img src='"+tag_str+"' "+attr_str+"/>";//hspace=0 vspace=0 
		else
			return "";
	}
	/**
	 * Reveal links.
	 * If you use this, you have to declare a function like the one in the text field movie which displays the text:
	 * 	function processWikiLinkTagCallback (escapedCommands_str:String) {
	 * 		silexInstance.utils.processWikiLinkTagCallback(escapedCommands_str);
	 *	}
	 * @param	tag_str	the string between {{ and }}
	 * @return	the equivalent html code
	 * @example "...[[command1:arg1,arg2|command2:arg3,arg4|CLICK HERE TEXT]]..." becomes "...<a href='asfunction:interpretHref,command1:arg1,arg2|command2:arg3,arg4'>CLICK HERE TEXT</a>..."
	 * @example "...[[command1:arg1,arg2|command2:arg3,arg4]]..." is replaced by the result of command2:arg3,arg4 or command1:arg1,arg2
	 */
	function processWikiLinkTag(tag_str:String):String {

		// displayed text
		var text_str:String=null;
		
		// **
		// build 2 arrays of commands: onLoad and onRelease
		var commands_array:Array = tag_str.split("|");
		
		// remove label if there is one (element after last pipe)
		if (commands_array.length > 1) text_str=commands_array.pop().toString();
		
		// build the arrays
		var immediatOnLoadCommands_array:Array = new Array;
		var clickOnReleaseCommands_array:Array = new Array;
		
		for (var idx:Number = 0; idx < commands_array.length; idx++)
		{
			// removes the event name - if there is one
			// at the end, eventType_str is onLoad or onRelease (default=onRelease) and event name has been removed from commands_array[idx] if there was one
			var eventName_str:String;
			var eventType_str:String = "onRelease";
			
			// onLoad
			eventName_str = "onLoad ";
			if (commands_array[idx].indexOf(eventName_str)==0)
			{
				commands_array[idx] = commands_array[idx].substr(eventName_str.length);
				eventType_str = "onLoad";
			}
			else
			{
				eventName_str = "onRelease ";
				if (commands_array[idx].indexOf(eventName_str)==0)
				{
					commands_array[idx]=commands_array[idx].substr(eventName_str.length);
				}
				eventType_str = "onRelease";
			}
			// add to the right array
			if (eventType_str == "onLoad")
			{
				immediatOnLoadCommands_array.push(commands_array[idx]);
			}
			else
			{
				clickOnReleaseCommands_array.push(commands_array[idx]);
			}
		}
		// execute immediat onLoad commands
		var res_str:String = "";
		for (var idx = 0; idx < immediatOnLoadCommands_array.length; idx++)
		{
			var res = silex_ptr.interpreter.exec(immediatOnLoadCommands_array[idx]);
			if (res && (typeof(res)=="string" || typeof(res)=="number" || typeof(res)=="boolean"))
				res_str += res.toString();
		}
		// if there is not a text specified but there was immediat onLoad commands 
		if (text_str == null && immediatOnLoadCommands_array.length>0)
		{
			// if the immediat onLoad commands returned a result, this result will be displayed
			// otherwise, return null so that the text between "((" and "))" will be deleted
			if (res_str != "") text_str = res_str;
			else return null;
		}
		
		// extract click onRelease commands
		var command_str:String=clickOnReleaseCommands_array.join("|");

		// extract text
		// no pipe => text = command
		// otherwise, text = after the pipe
		if(text_str==null) text_str=tag_str.substr(tag_str.lastIndexOf("|")+1);

		// return the replacement string
		if (clickOnReleaseCommands_array.length>0)
		{
			// make the text clickable => asfunction and callack defined in root and in utils (see utils contructor)
			return "<a href='asfunction:processWikiLinkTagCallback," + escape(command_str) + "'>" + text_str + "</a>";
		}
		else
		{
			// execute command and replace text by the command result
			return text_str;
		}
	}
	/**
	 * Callback function executed when the user clicks on a link in a text. Execute the commands associated with this link.
	 * @param escapedCommands_str	escaped string containing SILEX commands separated by a pipe character ("|")
	 */
	function processWikiLinkTagCallback (escapedCommands_str:String) {
		var commands_array:Array = htmlEntitiesDecode(unescape(escapedCommands_str)).split("|");
		for (var idx:Number=0;idx<commands_array.length;idx++){
			silex_ptr.interpreter.exec(commands_array[idx]);
		}
	}
	/**
	 * Reveal all wiki tags or accessors contained in a string.
	 * @param	input_str			string containing wiki tags or accessors
	 * @param	openTag_str			accessor left patern
	 * @param	closeTag_str		accessor right patern
	 * @param	processTagFunction	callback function to be called for each tag found
	 * @return	the resulting string
	 */
	function revealTags(input_str:String,openTag_str:String,closeTag_str:String,processTagFunction:Function):String {
		var split_array:Array=input_str.split(openTag_str);
		
		// elements 1, 3, 5, ... are the strings after the open tags
		// here split_array is: ["...","tag>...","tag>...","tag>..."]
		// for each even index, replace tag by the desired value
		for (var idx:Number=1;idx<split_array.length;idx++){
			var closeTagIndex_num:Number=split_array[idx].indexOf(closeTag_str);
			if (!closeTagIndex_num){
				// error: no closing tag
				//throw new Error("org.silex.core.Utils  revealTags - no closing tag for tag: "+openTag_str+split_array[idx]+" in "+input_str);
				return "";
			}
			// get the string between the open and close tags ("tag")
			var tagContent:String=split_array[idx].substr(0,closeTagIndex_num);
			// replace the tag by the desired value "tag>..." => desired_value+"..."
			// if there is no return value, erase the whole line (between "((" and "))")
			var res_str:String = processTagFunction(tagContent);
			if (res_str)
				split_array[idx] = res_str + split_array[idx].substr(closeTagIndex_num + openTag_str.length);
			else 
				return "";
		}
		return split_array.join("");
	}

	///////////////////////////////////////////////////////////////////////////
	// Group: validators
	///////////////////////////////////////////////////////////////////////////
	/**
	 * Mail validation.
	 * @param	mail_str	a string which is suposed to be an email
	 * @return	true if it is a valid email adress
	 */
	function checkValidMail(mail_str):Boolean
	{
		var len = mail_str.length ;
		var indiceAdr = mail_str.lastIndexOf ("@") ;
		var indiceDot = mail_str.lastIndexOf (".") ;
		var ext = mail_str.substring (indiceDot + 1, len);
	
		// Un mail ne pas pas faire moins de 8 lettres
		if (len < 8) return false ;
		
		// L'index de l'Arobasce doit toujours être supèrieure à 1, puisque elle doit être présente 
		// et qu'au moins une lettre doit la précédée
		if (indiceAdr < 1) return false ;
	
		// L'index du Point doit toujours être à au moins 3 caractères de la longueur total du mail
		if (len - indiceDot < 3) return false ;
		
		// Il y a toujours au minimun 3 lettres en l'Arobasce et le Point
		if (indiceDot - indiceAdr <= 3) return false ;
		
		// L'extention d'un mail fait toujours au minimun 2 lettres
		if (ext.length < 2) return false ;
		
		// L'extention d'un mail ne peut être un numéro
		if (!isNaN (parseFloat(ext))) return false ;
		
		// Sinon, le mail semble correct...
		return true ;
	}
	///////////////////////////////////////////////////////////////////////////
	// Group: arrays utilities
	///////////////////////////////////////////////////////////////////////////
	/**
	 * check if an array is part of another array
	 * @param	localContext_array	the context that may be contained in the other context
	 * @param	globalContext_array	the context that may contain the other context
	 * @return 	true if localContext is included in globalContext
	 * @example	isPartOf([a,b,c] , [a,b]) returns false
	 * @example	isPartOf([a,b] , [a,b,c]) returns true
	 */
	function isPartOf(localContext_array:Array,globalContext_array:Array):Boolean{
	
		// check inputs
		if (globalContext_array==undefined || globalContext_array.length<=0) return false;
		if (localContext_array==undefined || localContext_array.length<=0) return true;
		
		
		// for each selected item, check if it is in the list
		for (var idx:Number=0;idx<localContext_array.length;idx++){
			var isFound:Boolean=false;
			// all char
			if (localContext_array[idx]=="*"){
				return true;
			}
			// search this context item in the global context
			for (var idxGlobal:Number=0;idxGlobal<globalContext_array.length;idxGlobal++){
				if (globalContext_array[idxGlobal]==localContext_array[idx]){
					isFound=true;
					break;
				}
			}

			if (isFound==false){
				return false;
			}
		}
		return true;
	}
	///////////////////////////////////////////////////////////////////////////
	// Group: effects
	///////////////////////////////////////////////////////////////////////////
	/**
	 * Typewriter effect.
	 * @example	_global.getSilex().utils.applyTypeWriterEffect(_txt,"My display text", 40);
	 * @param	_txt		TextField to which to apply the effect
	 * @param	text_str	the text to display
	 * @param	speen_num	the speed of the effect
	 * @param	callback	callback called at the end of the anomation
	 */
	function applyTypeWriterEffect(_txt:TextField,text_str:String,speen_num:Number,callback:Function) {
		if (_txt.type_interval!=undefined){
			clearInterval(_txt.type_interval);
		}
		_txt.type_counter = 0;
		_txt.type_str=text_str;
		_txt.callback=callback;
		var typeCallback:Function = function() {
			this.text = this.text+this.type_str.charAt(this.type_counter);
			this.type_counter++;
			// doesn't work: this.dispatchEvent({type:"onChanged",target:this});
			// => workaround
			this.callback(this);
			if (this.type_counter >= this.type_str.length) {
				clearInterval(this.type_interval);
			}
		};
		_txt.type_interval = setInterval(Utils.createDelegate(_txt,typeCallback),speen_num);

	}
	/**
	 * Remove the effect from the TextFiled
	 * @param	_txt	TextFiled which has a typewriter effect
	 */
	function removeTypeWriterEffect(_txt:TextField) {
		if (!_txt.typeWriter) return;

		clearInterval(_txt.typeWriter.type_interval);
		_txt.typeWriter = undefined;
	}
	private static var _delegatesArray:Array;
	/**
	 * Creates a functions wrapper for the original function so that it runs in the provided context.<br/>
	 * You can pass parameters to the function<br/>
	 * Stores a reference to the resulting function so that you can remove the delegate with removeEventListener<br/>
	 * @parameter obj Context in which to run the function.
	 * @paramater func Function to run.
	 * @paramater ... parameters to pass to the delegated function
	 */
	static function createDelegate(obj:Object, func:Function):Function 
	{
		// Creates an array of the parameters that were also passed
		// with the create code.
		var parameters:Array = new Array();
		// Using the arguments variable fill the array with the
		// parameters passed.  Start i at 2 because obj and func
		// use the first to positions in the arguments array
		for (var i:Number = 2; i < arguments.length; i++) 
		{
			parameters[i - 2] = arguments[i];
		}
		var f = function() 
		{
			// set the target scope and function
			var target = arguments.callee.target;
			var funcLocal = arguments.callee.func;
			// use concat to link all the arguments together
			var newArguments = arguments.concat(parameters);
			//apply the function to the target with the arguments
			return funcLocal.apply(target, newArguments);
		};
		f.target = obj;
		f.func = func;
		
		// store a reference to the resulting function so that you can remove the delegate with removeEventListener
		if (!_delegatesArray) _delegatesArray = new Array;
		_delegatesArray.push({obj:obj,func:func,delegate:f});
		
		// using the return value from f will return the result of the original function designated
		return f;
	}
	/**
	 * returns the delegate function previously created with Utils.createDelegate(obj,func,...)
	 */
	public static function getDelegate(obj,func):Function
	{
		// check if there are delegates
		if (!_delegatesArray) return null;

		// look for the one
		var idx:Number;
		for (idx = 0; idx < _delegatesArray.length; idx++)
		{
			if (_delegatesArray[idx].obj == obj && _delegatesArray[idx].func == func)
				return _delegatesArray[idx].delegate;
		}
	}
	/**
	 * delete and returns the delegate function previously created with Utils.createDelegate(obj,func,...)<br />
	 */
	public static function removeDelegate(obj,func):Function
	{
		// check if there are delegates
		if (!_delegatesArray) return null;

		// look for the one
		var idx:Number;
		for (idx = 0; idx < _delegatesArray.length; idx++)
		{
			if (_delegatesArray[idx].obj == obj && _delegatesArray[idx].func == func)
			{
				var res:Function = _delegatesArray[idx].delegate;
				_delegatesArray.splice(idx,1);
				return res;
			}
		}
	}
	
	
	/**
	 * Return the X scale of the silex scene
	 * @return the X scale of Silex scene
	 */
	public static function getSilexXScale():Number
	{
	 return (_global.getSilex().application.sceneRect.right - _global.getSilex().application.sceneRect.left) / _global.getSilex().config.layoutStageWidth;
	}

	/**
	 * Return the Y scale of the silex scene
	 * @return the Y scale of Silex scene
	 */
	public static function getSilexYScale():Number
	{
	 return (_global.getSilex().application.sceneRect.bottom - _global.getSilex().application.sceneRect.top) / _global.getSilex().config.layoutStageHeight;
	}

	/**
	 * Scale the coords to fit with the properties value retrieved
	 * from SilexAdminApi
	 * @param coords the coords to scale
	 * @return the scaled coords
	 */
	public static function scaleCoords(coords:Object):Object
	{
		var silexScaleX:Number = getSilexXScale();
		var silexScaleY:Number = getSilexYScale();

		var nCoords = {x: coords.x, y: coords.y, width: coords.width, height: coords.height};
		nCoords.x -= _global.getSilex().application.sceneRect.left;
		nCoords.y -= _global.getSilex().application.sceneRect.top;
		nCoords.x =  Math.round(nCoords.x / silexScaleX);
		nCoords.y =  Math.round(nCoords.y / silexScaleY);
		nCoords.width = Math.round(nCoords.width / silexScaleX);
		nCoords.height = Math.round(nCoords.height / silexScaleY);

	 return nCoords;
	}

	/**
	 * Scale the coords to the scale of the silex scene
	 * @param coords the coords to unscale
	 * @return the unscaled coords
	 */
	public static function unscaleCoords(coords:Object):Object
	{
		var silexScaleX:Number = getSilexXScale();
		var silexScaleY:Number = getSilexYScale();

		var nCoords = {x: coords.x, y: coords.y, width: coords.width, height: coords.height};
		nCoords.x = Math.round(nCoords.x * silexScaleX);
		nCoords.y = Math.round(nCoords.y * silexScaleY);
		nCoords.x += _global.getSilex().application.sceneRect.left;
		nCoords.y += _global.getSilex().application.sceneRect.top;
		nCoords.width = Math.round(nCoords.width * silexScaleX);
		nCoords.height = Math.round(nCoords.height * silexScaleY);

		return nCoords;
	}
}