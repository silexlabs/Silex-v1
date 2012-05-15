/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * initialize the patch for wmode=transparent
 */
function initWModePatch($flashId)
{
	var broz = navigator.userAgent.toLowerCase();
	if (broz.indexOf("gecko")>-1 || broz.indexOf("chrome")>-1 /* || broz.indexOf("msie")>-1 */)
	{
		var embedObject;
		embedObject = document.getElementById($flashId);
		embedObject.SetVariable("browserTypeTransparentWModePatch",broz);
		//embedObject.onkeypress = onEmbededObjectKeyPressed;

		embedObject.onkeypress = function (e)
		{
			var evtobj = window.event ? window.event : e;
			var unicode = evtobj.charCode ? evtobj.charCode : evtobj.keyCode;
			this.SetVariable("keyboardInputFromJS",unicode);
		};
	}
}
/////////////////////////////////////////////////////////////////
/** 
 * Decodes a UTF8 formated string
 */
utf8Decode=function (utf8str)
{
	var str = new Array();
	var pos = 0;
	var tmpStr = '';
	var j=0;
	while ((pos = utf8str.search(/[^\x00-\x7F]/)) != -1) {
		tmpStr = utf8str.match(/([^\x00-\x7F]+[\x00-\x7F]{0,10})+/)[0];
		str[j++]= utf8str.substr(0, pos) + this._utf8Decode(tmpStr);
		utf8str = utf8str.substr(pos + tmpStr.length);
	}
	
	str[j++] = utf8str;
	return str.join('');
};
/**
 * @private
 * it is a private function for internal use in utf8Decode function 
 */
_utf8Decode=function(utf8str)
{	
	var str = new Array();
	var code,code2,code3,code4,j = 0;
	for (var i=0; i<utf8str.length; ) {
		code = utf8str.charCodeAt(i++);
		if (code > 127) code2 = utf8str.charCodeAt(i++);
		if (code > 223) code3 = utf8str.charCodeAt(i++);
		if (code > 239) code4 = utf8str.charCodeAt(i++);
		
		if (code < 128) str[j++]= String.fromCharCode(code);
		else if (code < 224) str[j++] = String.fromCharCode(((code-192)<<6) + (code2-128));
		else if (code < 240) str[j++] = String.fromCharCode(((code-224)<<12) + ((code2-128)<<6) + (code3-128));
		else str[j++] = String.fromCharCode(((code-240)<<18) + ((code2-128)<<12) + ((code3-128)<<6) + (code4-128));
	}
	return str.join('');
};
/////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
////////////////// class constants ////////////////////
////////////////////////////////////////////////////////////////
/**
 * debug mode
 */
JsFrameBase.prototype.ALLOW_FIREBUG = false;

/**
 * Log constant
 */
JsFrameBase.prototype.TRACE_ERROR = "error";
/**
 * Log constant
 */
JsFrameBase.prototype.TRACE_WARNING = "warning";
/**
 * Log constant
 */
JsFrameBase.prototype.TRACE_DEBUG = "debug";
/**
 * Log constant
 */
JsFrameBase.prototype.nextZIndex = 100;

/**
 * class name
 */
JsFrameBase.prototype.className = "JsFrameBase";

/**
 * id of silex main swf - given by as2 component "AsFrameCommunication.as"
 */
JsFrameBase.prototype.resizeSwfId = "silex";

////////////////////////////////////////////////////////////////
////////////////// JsFrame class ////////////////////
////////////////////////////////////////////////////////////////
/**
 * The Frame component lets you display HTML content in your AS2 or AS3 application.
 * In ActionScript or in Flash with the component inspector, use the location property to specify the URL of an HTML page whose content is displayed in place of the Flash component. 
 * Also you can specify the URL of an object to be placed in <object> and <embed> HTML tags, a plugin detection will occure. 
 * Each action on the Flash component reflects on the HTML frame through the JSFrame class and JSFrame class proxies the frame events to the Flash component.
 * @class	JsFrameBase
 * @author	lex@silex-ria.org
 */
function JsFrameBase($id)
{
	////////////////////////////////////////////////////////////////
	//////////////////		attributes		////////////////////
	////////////////////////////////////////////////////////////////
	/**
	 * the id given by createFrame
	 */
	this.idFrame;
	/**
	 * static reference to the frame container in the dom
	 */
	this.frameContainer;
	/**
	 * reference to the javascript frame object (div or iframe)
	 */
	this.frame;
	
	/**
	 * [private] true if the div has to be redrawn
	 */
	this.isHtmlTextDirty = false;

	/**
	 * [private] true if the content of the frame is loaded (iframe case)
	 */
	this.isContentLoaded = false;
	////////////////////////////////////////////////////////////////
	////////////////// 	setter & getter	//////////////////
	////////////////////////////////////////////////////////////////
	/**
	 * @private
	 * if true then use iframe, or use div otherwise<br />
	 * when this value changes, toggle to iFrame if a div was already instanciated<br />
	 * depends on the use of htmlText (div) or location (iframe)<br />
	 */
	this._useIframe = true;
	this.getUseIframe =	function ()
	{
		return this._useIframe;
	};
	this.setUseIframe = function ($val)
	{
		if (this.frame && this._useIframe != $val)
		{
			// we need to remove the existing frame and put a div instead of a frame or vice versa
			this.exitDom();
			this._useIframe = $val;
			this.enterDom();
		}
		else
			this._useIframe = $val;
	};

	/**
	 * The URL to be displayed.
	 */
	this._location = "";
	this.getLocation = function ()
	{
		return this._location;
	};
	this.setLocation = function ($val)
	{
		$val = unescape($val);
		if ($val && $val != "" && $val != this._location && $val != "http://")
		{
			// this.trace("location set to "+$val);
			// force the content to redraw
			this.isHtmlTextDirty = true;
			// unset the htmlText property
			this._htmlText = "";
			// store the new location
			this._location = $val;
			// toggle to iFrame if needed
			this.setUseIframe(true);					
			// apply changes
			this.applyFrameProperties();
		}
	};
	/**
	 * html code of the content of the frame.
	 */
	this._htmlText = "";
	this.getHtmlText = function ()
	{
		return this._htmlText;
	};
	this.setHtmlText = function ($val)
	{
		$val = unescape($val);
		if ($val && $val != "" && $val != this._htmlText)
		{
			// this.trace("htmlText set to "+$val);
			// force the content to redraw
			this.isHtmlTextDirty = true;
			// store the new htmlText
			this._htmlText = $val;
			// unset the location property
			this._location = "";
			// toggle to DIV if needed
			this.setUseIframe(false);
			// apply changes
			this.applyFrameProperties();
		}
	};
	/**
	 * visibility
	 */
	this._visible = true;
	this.getVisible = function ()
	{
		return this._visible;
	};
	this.setVisible = function ($val)
	{
		this._visible = $val;
		this.applyFrameProperties();
	};
	this.getVisibility = function ()
	{
		if (this._visible == true || this._visible == "true")
			return "visible";
		else
			return "hidden";
	};
	/**
		position and dimentions attributes
	 */
	/**
	 * x position
	 */
	//this._x = 0;
	this.getX = function ()
	{
		return this._x;
	};
	this.setX = function ($val)
	{
		if(isNaN($val))
			return;
		$val = unescape($val);
		this._x = this.correctSizeWithBrowserZoom($val);
		this.applyFrameProperties();
	};
	/**
	 * y position
	 */
	//this._y = 0;
	this.getY = function ()
	{
		return this._y;
	};
	this.setY = function ($val)
	{
		if(isNaN($val))
			return;
		$val = unescape($val);
		this._y = this.correctSizeWithBrowserZoom($val);
		this.applyFrameProperties();
	};
	/**
	 * width
	 */
	this._width = 100;
	this.getWidth = function ()
	{
		return this._width;
	};
	this.setWidth = function ($val)
	{
		$val = unescape($val);
		this._width = $val;
		this.applyFrameProperties();
	};
	this.correctSizeWithBrowserZoom = function ($val)
	{
		//Stage.height / <object>.height
//		$val = $val / (silexJsObj.silexBrowserZoom);
//alert("test "+$val+ " - "+silexJsObj.silexBrowserZoom);

//		$val = $val + ($val * (1 - silexJsObj.silexBrowserZoom));

		return $val;
	};
	/**
	 * height
	 */
	this._height = 100;
	this.getHeight = function ()
	{
		return this._height;
	};
	this.setHeight = function ($val)
	{
		$val = unescape($val);
		this._height = $val;
		this.applyFrameProperties();
	};

	////////////////////////////////////////////////////////////////
	////////////////// 	methods	//////////////////
	////////////////////////////////////////////////////////////////
	/**
	 * @constructor
	 */
	this.JsFrameBase = function($id)
	{
		// this.trace("constructor - id: "+this.idFrame);
		
		//console.log ("constructor - id: "+this.idFrame+ " - "+JsFrameBase.resizeSwfId);
		// store id
		this.idFrame = $id;
	};
	/**
	 * force to redraw the content
	 */
	this.redraw = function ()
	{
		this.isHtmlTextDirty = true;
		this.applyFrameProperties();
	};
	/**
	 * log function (abstraction layer)
	 */
	this.trace = function($obj,$level)
	{
		if (this.ALLOW_FIREBUG == true && typeof console != "undefined") 
		{
			try 
			{
				switch($level)
				{
					case this.TRACE_ERROR:
						console.error(this.className+" - "+this.idFrame+": ",$obj);
						break;
					case this.TRACE_WARNING:
						console.warning(this.className+" - "+this.idFrame+": ",$obj);
						break;
					default:
						console.log(this.className+" - "+this.idFrame+": ",$obj);
				}
			}
			catch(e)
			{
			}
		}
		else
		{
			// 				alert(this.className+" - "+this.idFrame+": ",$obj);
		}
	};
	/**
	 * [private] creates the iframe or div object in dom. 
	 */
	this.enterDom = function()
	{
		if (!this.frame)
		{
			// this.trace("enterDom "+this.idFrame+" - useIframe = "+this.getUseIframe());

			// if the frame container doesn't exist, then create it and store it int the static variable frameContainer
			if (!$('#frameContainer').length)
				$('body').append('<div style="position: absolute; z-index: '+(this.nextZIndex++)+'" id="frameContainer" name="frameContainer"></div>');

			JsFrameBase.frameContainer = $('#frameContainer');

			// create the frame	
			var $frame;
			if (this.getUseIframe() == true)
			{
				$frame = $('<iframe frameborder="0" style="position: absolute; z-index: '+(this.nextZIndex++)+'; background-color:transparent; border-width:0;" id="'+this.idFrame+'" name="'+this.idFrame+'" />'); //onload="getJsFrame('+this.idFrame+').isContentLoaded = true; getJsFrame('+this.idFrame+').applyFrameProperties();" />');// onload="getJsFrame('+this.idFrame+').executeFrameScripts();"
				//$frame[0].ready(function (){alert("aaa");});
/*				$frame[0].load(function() 
				{
					executeFrameScripts();
				});*/
   			}
			else
				$frame = $('<div style="overflow: auto; position: absolute; z-index: '+(this.nextZIndex++)+'; border: 0px; padding-top: 0px; padding-bottom: 0px; padding-left: 0px; padding-right: 0px; visibility:hidden" id="'+this.idFrame+'" name="'+this.idFrame+'" />');
				
				//alert(this.nextZIndex);

			$('#frameContainer').append($frame);
			
			// store the frame
			this.frame = $frame[0];
			//$frame.onload = applyFrameProperties;
			
			// reset loaded flag
			this.isContentLoaded = false;
			
			// fill in the frame after it has been created
			var $refToThis = this;
			// apply properties to the new frame
			// this.applyFrameProperties();
			// after frame was created for sure
			setTimeout(
				function()
				{
					if ($refToThis.getUseIframe() == true)
						$refToThis.isContentLoaded = true;
					// apply properties to the new frame
					$refToThis.applyFrameProperties();
					// execute scripts in the new frame
					//if ($refToThis.getUseIframe() == false)
					//	$refToThis.executeFrameScripts();
				}
			, 1 );
		}
		else
		{
			throw(new Error("enterDom - The frame is allready in the DOM: "+$id));
		}
	};
	/**
	 * [private] apply properties of JSFrame object to the javascript frame
	 */
	this.applyFrameProperties = function()
	{
		if (this.frame && this._x!=undefined && this._y!=undefined)
		{
			//this.trace("applyFrameProperties "+this.frame.id);
			
			// apply styles
			if (this.frame.style.position != "absolute")
				this.frame.style.position = "absolute";

			//if (this.frame.style.background-color != "transparent")
				//this.frame.style.background-color = "transparent";
				
			//if (this.frame.style.border-width != "0")
			//	this.frame.style.border-width = "0";

			// apply position and size
			var silexFrameTmp = $("#flashcontent");
			var xRelativeToSilexJSObj = (parseInt(this.getX()) + parseInt(silexFrameTmp.position().left)).toString();
			var yRelativeToSilexJSObj = this.getY();//(parseInt(this.getY()) + parseInt(silexFrameTmp.position().top)).toString();

			//if (this.frame.offsetTop == undefined) this.frame.offsetTop = 0;
			if (this.frame.style.top != yRelativeToSilexJSObj + "px")
				this.frame.style.top = yRelativeToSilexJSObj + "px";// - this.frame.offsetTop;

			// this may be exectuted in executeFrameScripts if the iframe is not loaded yet
			if (this.isContentLoaded == true && this.frame.style.visibility != this.getVisibility()){
				//alert(this.getVisibility()+" - "+this.frame.style.visibility);
				this.frame.style.visibility = this.getVisibility();
			}
			//console.log ("applyFrameProperties "+this.isContentLoaded+" - "+this.frame.style.visibility+" - "+this.getVisibility());

			//if (this.frame.offsetLeft == undefined) this.frame.offsetLeft = 0;
			if (this.frame.style.left != xRelativeToSilexJSObj + "px")
				this.frame.style.left = xRelativeToSilexJSObj + "px";// - this.frame.offsetLeft;
			
			if (this.frame.style.width != this.getWidth()+"px")
				this.frame.style.width = this.getWidth()+"px";
			
			if(this.frame.style.height != this.getHeight()+"px")
				this.frame.style.height = this.getHeight()+"px";
			
			// apply content
			// iframe case
			if (this.getUseIframe() == true)
			{
				if (this.isHtmlTextDirty && this.frame.src != this.getLocation())
				{
					this.frame.src = this.getLocation();
					this.isHtmlTextDirty = false;
				}
			}
			// div case
			else
			{
				if (this.isHtmlTextDirty)
				{
					this.frame.innerHTML = utf8Decode(this.getHtmlText());
					this.executeFrameScripts();
					this.isHtmlTextDirty = false;
				}
			}
		}
	};
	/**
	 * [private] execute the scripts of the loaded frame
	 */
	this.executeFrameScripts = function()
	{
//alert("test");
//		alert ("eee "+this.frame.contentWindow.document.getElementsByTagName("*").length);
//		alert("tttt "+this.frame.getElementsByTagName("script").length);
//		alert("yes "+this.frame.contentWindow.document.getElementsByTagName("script").length); 

		if (this.frame)
		{
			// set loaded flag
			this.isContentLoaded = true;
			//alert("executeFrameScripts");
			// display the frame
			if (this.frame.style.visibility != this.getVisibility())
			{
				//alert(this.getVisibility()+" - "+this.frame.style.visibility);
				this.frame.style.visibility = this.getVisibility();
			}
			// store the scripts
			var AllScripts;
			if (this.frame.contentWindow)
			// frame case
				AllScripts=this.frame.contentWindow.document.getElementsByTagName("script");
			else
				// div case
				AllScripts=this.frame.getElementsByTagName("script");
			// execue all scripts
			for (var i=0; i<AllScripts.length; i++) 
			{ 
				var s=AllScripts[i]; 
				var scriptTag;
				if (s.src && s.src!="")
					scriptTag = s.src; 
				else 
					scriptTag = s.innerHTML; 
					
				try
				{
					eval(scriptTag); 
					// this.trace((i+1)+" / "+AllScripts.length+" - loaded script: "+scriptTag); 
					//alert(scriptTag); 
				}
				catch(e)
				{
					this.trace("Frame component, error in the loaded script. The error message: "+e.toString()+"    ----    The script: "+scriptTag, JsFrameBase.prototype.TRACE_WARNING); 
					// alert("Frame component, error in the loaded script. The error message: "+e.toString()+"    ----    The script: "+scriptTag); 
				}
			} 
		}
	};
	
	/**
	 * [private] removes the iframe or div object from dom
	 */
	this.exitDom = function ()
	{
		if (this.frame)
		{
			// this.trace("exitDom "+this.idFrame);

			// remove frame
			$("#"+this.idFrame).remove();
			
			// unset the frame object
			delete this.frame;
			this.frame = undefined;
		}
		else
		{
			// this.trace("exitDom error: was not in the dom", this.TRACE_WARNING);
		}
	};
	/**
	 * unload / clean
	 */
	this.unload = function ()
	{
		// exit the dom
		this.exitDom();
	};
	
	////////////////////////////////////////////////////////////////
	/////////////////// call constructor /////////////////////
	////////////////////////////////////////////////////////////////
	this.JsFrameBase($id);
}

////////////////////////////////////////////////////////////////
////////////////// class constants ////////////////////
////////////////////////////////////////////////////////////////
/**
 * class name
 */
//JsFrame.prototype.className = "JsFrame";

////////////////////////////////////////////////////////////////
/////////////////	global functions		////////////////
////////////////////////////////////////////////////////////////
/**
 * window resize and swf scale mode<br />
 * called by as2 component "AsFrameCommunication.as"
 */
function initJsFrameResize($resizeSwfId)
{
	//console.log ("initJsFrameResize " + $resizeSwfId);
	JsFrameBase.resizeSwfId = $resizeSwfId;
}
/**
 * window resize and swf scale mode
 */
var silexFramesTimeOutInProgress = false;
/**
 * window resize and swf scale mode
 */
function onFrameResize($delay)
{
	//console.log("onFrameResize "+JsFrameBase.resizeSwfId + " - "+$delay);
	if (!$delay) 
		$delay = 1;
		
	//alert("onFrameResize "+JsFrameBase.resizeSwfId+" - "+$("#"+JsFrameBase.resizeSwfId).width());
	if (JsFrameBase.resizeSwfId && silexFramesTimeOutInProgress==false)
	{
		setTimeout(doFrameResize, $delay);
		silexFramesTimeOutInProgress = true;
	}
}
/**
 * window resize and swf scale mode
 */
function doFrameResize()
{
	var frameRef = document.getElementById(JsFrameBase.resizeSwfId);
	//console.log("doFrameResize "+frameRef);
	silexFramesTimeOutInProgress = false;
	if (frameRef)
	{
		// with ExternalInterface :
		//$("#"+JsFrameBase.resizeSwfId)[0].onFrameResize($("#"+JsFrameBase.resizeSwfId).width(),$("#"+JsFrameBase.resizeSwfId).height(),$(window).width(),$(window).height());
		// with SILEX commands
		//alert("resize");
		$silexCommand = "silex.interpreter.resizeAllAsFrames:"+$("#"+JsFrameBase.resizeSwfId).width()+","+$("#"+JsFrameBase.resizeSwfId).height()+","+$(window).width()+","+$(window).height();
		frameRef.SetVariable("silex_exec_str",$silexCommand);
		
	}
//	else
//		onFrameResize(250);
}

/**
 * Creates a JSFrame object named "id" and store it in a global object
 * Called by ExternalInterface
 */
function addJsFrame ($id)
{
	// workaround IE bug JsFrame.jsFrames undefined
	//if (!JsFrame.jsFrames) alert("pas de jsframe "+$id);
	if (!JsFrameBase.jsFrames) JsFrameBase.jsFrames = new Array();

	if (JsFrameBase.jsFrames[$id])
	{
		//console.error("The frame id was allready defined: "+$id);
		throw(new Error("addJsFrame - The frame id was allready defined: "+$id));
	}
	JsFrameBase.jsFrames[$id] = new JsFrameBase($id);
	return JsFrameBase.jsFrames[$id];
}
/**
 * @return 	The frame created with this id
 * Called by ExternalInterface
 */
function getJsFrame ($id)
{
	return JsFrameBase.jsFrames[$id];
}
/**
 * Delete the frame created with this id
 * Called by ExternalInterface
 */
function removeJsFrame ($id)
{
	JsFrameBase.jsFrames[$id].unload();
	delete JsFrameBase.jsFrames[$id];
}
/*
function embedFlashPlugin($id, $urlMedia, $newId, $w, $h)
{
	alert("embedFlashPlugin "+$id+", "+$urlMedia+", "+$newId+", "+$w+", "+$h);
	var so = new SWFObject($urlMedia, $newId, $w, $h, "8", "#64696D"); 
	so.addParam("wmode", "transparent"); so.addParam("AllowScriptAccess","always"); 
	so.write($idFrame);
}
*/
// Hooks
/*
// init right now
$(window).resize(onFrameResize);
// init later
$(document).ready(
	function()
	{
		$(window).resize( onFrameResize );
	}
);
*/
silexNS.HookManager.addHook("bodyResize", function (){ onFrameResize();});
silexNS.HookManager.addHook("refreshWorkspace", function (){ onFrameResize();});
