/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.core.UIComponent;
import org.silex.core.Utils;
//import org.oof.ApiProxy.As2ApiProxyWithLocalConnection;
/**
 * @description
 * <strong>Author:</strong>lex@silex-ria.org<br />
 * <strong>Description: </strong>
 * This component is covered up at runtime by an HTML frame controled by a JSFrame object. 
 * The component is visible if the frame is opaque to avoid the flickering which occures when something moves behind an HTML frame. 
 * The mouse pointer has to be invisible over the component for the same reason.
 * @author lex@silex-ria.org
 */
class org.silex.ui.asframe.AsFrameBase extends UIComponent
{
	/////////////////////////////////////////////
	//////////////	constants	/////////////////
	/////////////////////////////////////////////
	/**
	 * class name
	 */
	public var className:String = "AsFrameBase"
	
	/**
	 * debug mode
	 */
	private static var ALLOW_DEBUG:Boolean = true;
	
	/**
	 * store all instances of the class
	 */
	static var _allFrames:Array;
	/**
	 * interval to sychronize the js frame attributes
	 */
	static var jsRefreshInterval:Number = 100;
	
	
	/**
	 * embeded object tag template
	 */
	//	private var OBJECT_TAG:String = '<div><object><param name="width" value="<<width>>" /><param name="height" value="<<height>>" /><param name="id" value="flashId2" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="true" /><param name="movie" value="<<urlMedia>>" /><param name="wmode" value="transparent"><embed width="<<width>>" height = "<<height>>" src="<<urlMedia>>" id="flashId2" allowScriptAccess="always" allowFullScreen="true" wmode="transparent" type="application/x-shockwave-flash"></embed></object></div>';	
	// with wmode=transparent	private var OBJECT_TAG:String = '<div><object><param name="width" value="<<width>>" /><param name="height" value="<<height>>" /><param name="movie" value="<<urlMedia>>" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="true" /><param name="wmode" value="transparent"><embed wmode="transparent" src="<<urlMedia>>" type="application/x-shockwave-flash" width="<<width>>" height="<<height>>" allowScriptAccess="always" allowFullScreen="true"></embed></object></div>';	
	// with referer and baseUrl in the flashvars, for use to test proxy.php - proxy.php?url=http%3A%2F%2Fwww2.wat.tv%2Fswftv%2F155196t2vmsmP1419169%2F971034
	//private var OBJECT_TAG:String = '<object width="1200" height="400"><param name="FlashVars" value="flashId=<<flashId>>&revision=2.52.35&mediaID=1419169&playlistID=971034&referer=undefined&request=%2Fplaylist%2F971034&browser=firefox&autoPlaylister=true&embedded=true&baseUrl=www2.wat.tv"/><param name="movie" value="<<urlMedia>>" /><param name="id" value="<<flashId>>" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="true" /><param name="wmode" value="transparent"><embed wmode="transparent" src="<<urlMedia>>" type="application/x-shockwave-flash" id="<<flashId>>" width="1200" height="400" FlashVars="flashId=<<flashId>>&revision=2.52.35&mediaID=1419169&playlistID=971034&referer=undefined&request=%2Fplaylist%2F971034&browser=firefox&autoPlaylister=true&embedded=true&baseUrl=www2.wat.tv" allowScriptAccess="always" allowFullScreen="true"></embed></object>';	

		// yes : private var OBJECT_TAG:String = '<div><object><param name="wmode" value="transparent"><param name="width" value="<<width>>" /><param name="height" value="<<height>>" /><param name="movie" value="<<urlMedia>>" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="true" /><embed wmode="transparent" src="<<urlMedia>>" type="application/x-shockwave-flash" width="<<width>>" height="<<height>>" allowScriptAccess="always" allowFullScreen="true"></embed></object></div>';	
	private var OBJECT_TAG:String = '<div><object><param name="wmode" value="transparent"><param name="width" value="<<width>>" /><param name="height" value="<<height>>" /><param name="movie" value="<<urlMedia>>" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="true" /><embed wmode="transparent" src="<<urlMedia>>" type="application/x-shockwave-flash" width="<<width>>" height="<<height>>" allowScriptAccess="always" allowFullScreen="true"></embed></object></div>';	
	/////////////////////////////////////////////
	///////////////	attributes ////////////////
	/////////////////////////////////////////////
	/**
	 * background clip
	 * resized to the component size
	 * the component is at 100% scale
	 */
	var bg_mc:MovieClip;
	
	/**
	 * visibility of the frame
	 */
	var isFrameVisible:Boolean = true;
	
	/**
	 * interval id for the timer
	 */
	private var intervalId:Number = -1;
	
	/**
	 * visibility of the background
	 */
	[Inspectable]
	private var _backgroundVisible:Boolean = true;
	public function get backgroundVisible():Boolean 
	{
		return _backgroundVisible;
	}
	public function set backgroundVisible(v:Boolean)
	{
		bg_mc._visible = _backgroundVisible = v;
	}
	
	/**
	 * next object tag id
	 */
	private static var nextObjectId:Number=0;
	
	
	/**
	 * embeded object attribute
	 * display the object in an object tag
	 */
	private var _embededObject:String="";
	[Inspectable]
	public function set embededObject(val:String)
	{
		_embededObject = val;
		if (val && val!="")
		{
			// new object id
			//var newId = "flashObject"+Math.round(Math.random(100000))+"_"+(nextObjectId++).toString();
			
			// compute position and size in global coordinates
			// top left point
			var globTL:Object = {x:_x,y:_y};
			_parent.localToGlobal(globTL);
			// bottom right point
			var globBR:Object = {x:_x+bg_mc._width,y:_y+bg_mc._height};
			_parent.localToGlobal(globBR);
			
// writeEmbededObject(_embededObject,"flashObject"+Math.round(Math.random(100000))+"_"+(nextObjectId++).toString(),(globBR.x - globTL.x)*jsxscale,(globBR.y - globTL.y)*jsyscale);
			
			/**/
			// build object tag
			var txt:String = OBJECT_TAG;
			//txt = replace(txt,"<<id>>",newId);
			txt = replace(txt,"<<urlMedia>>",_embededObject);
			txt = replace(txt,"<<width>>",((globBR.x - globTL.x)*jsxscale).toString());
			txt = replace(txt,"<<height>>",((globBR.y - globTL.y)*jsyscale).toString());
			// display the embeded object
			_htmlText = txt;
			//htmlText = txt;
			synchAsJsValue("_htmlText", "HtmlText");
			/*
			synchAsJsValue("jsx", "X");
			synchAsJsValue("jsy", "Y");
			synchAsJsValue("jswidth", "Width");
			synchAsJsValue("jsheight", "Height");
			*/
			//_jsx = _jsy = _jswidth = _jsheight = undefined;
		}
	}
	public function get embededObject():String
	{
		return _embededObject;
	}

	/**
	 * location to be displayed in the component
	 */
	[Inspectable]
	private var _location:String;
	public function get location():String 
	{
		return _location;
	}
	public function set location(v:String)
	{
		_location = v;
		synchAsJsValue("_location", "Location");
	}
	/**
	 * htmlText to be displayed in the component
	 * writable only if embededObject is not set
	 */
	[Inspectable]
	private var _htmlText:String;
	public function get htmlText():String 
	{
		return _htmlText;
	}
	public function set htmlText(v:String)
	{
		_htmlText = v;
		synchAsJsValue("_htmlText", "HtmlText");
	}
	/**
	 * visibility
	 */
	private var _jsvisible:Boolean;
	public function get jsvisible():Boolean
	{
		return _jsvisible;
	}
	public function set jsvisible(v:Boolean)
	{
		if (_jsvisible != v)
		{
			_jsvisible = v;
			synchAsJsValue("jsvisible", "Visible");
		}
	}
	/**
	 * position
	 */
	private var _jsx:Number;
	public function get jsx():Number
	{
		return _jsx;
	}
	public function set jsx(v:Number)
	{
		if (_jsx != Math.round(v))
		{
			_jsx = Math.round(v);
			synchAsJsValue("jsx", "X");
		}
	}
	private var _jsy:Number;
	public function get jsy():Number
	{
		return _jsy;
	}
	public function set jsy(v:Number)
	{
		if (_jsy != Math.round(v))
		{
			_jsy = Math.round(v);
			synchAsJsValue("jsy", "Y");
		}
	}
	/**
	 * dimentions
	 **/
	private var _jswidth:Number;
	public function get jswidth():Number
	{
		return _jswidth;
	}
	public function set jswidth(v:Number)
	{
		if (_jswidth != Math.round(v))
		{
			_jswidth = Math.round(v);
			synchAsJsValue("jswidth", "Width");
		}
	}
	private var _jsheight:Number;
	public function get jsheight():Number
	{
		return _jsheight;
	}
	public function set jsheight(v:Number)
	{
		if (_jsheight != Math.round(v))
		{
			_jsheight = Math.round(v);
			synchAsJsValue("jsheight", "Height");
		}
	}
	/**
	 * x and y scale of the swf file
	 * between 0 and 1
	 */
	public var jsxscale:Number = 1;
	public var jsyscale:Number = 1;
	/**
	 * x and y position of the swf file in the browser
	 * in pixels
	 */
	public var jsxoffset:Number = 0;
	public var jsyoffset:Number = 0;
	/**
	 * id for this frame
	 */
	private var idFrame:String;
	
	/**
	 * index used for ids of frames
	 */
	private static var indexIdFrame:Number = 0;
	
	/**
	 * 
	 */
	private static var isJsApiInitilized:Boolean = false;
	
	/////////////////////////////////////////////
	//////////////	methods		/////////////////
	/////////////////////////////////////////////
	/**
	 * constructor
	 */
	public function onLoad() 
	{
		// patch for bug input text fields in firefox because of wmode
		//JSTextReader.enableForAllTextFields();
		
		// store instance ref
		if (!_allFrames) _allFrames = new Array;
		_allFrames.push(this);
		
		// debug
		if (ALLOW_DEBUG == false && _parent._tf)
			_parent._tf.text = "Debug mode turned OFF";

		// init of js API
		initJsApi();
		
		super.onLoad();

		// background clip takes the component size
		bg_mc._width = _width;
		bg_mc._height = _height;
		_xscale = 100;
		_yscale = 100;
		
		// initialize Stage
		//Stage.align = "TL";
		//Stage.scaleMode = "noScale";
		// debug
		bg_mc._visible = _backgroundVisible;
		bg_mc._alpha = 80;
		
		// initialize the timer
		//intervalId = setInterval(Utils.createDelegate(this, checkChanges), jsRefreshInterval);
		onEnterFrame = checkChanges;
		
		// create a new id for this frame
		idFrame = className+"-"+(indexIdFrame++).toString();
		
		// create js frame
		addJsFrame();
		
		// debug
		//location = "http://google.com";
		//htmlText = "http://google.com";
		embededObject = embededObject;
		location = location;
		htmlText = htmlText;
		
		/*
		jswidth = jswidth;
		jsheight = jsheight;
		jsy = jsy;
		jsx = jsx;
		*/

		// setup the frame
		checkChanges();
		
		// display the frame
		enterDom();
	}
	/**
	 * destructor
	 */
	public function onUnload() 
	{
		//_root.frameUnloaded_str += idFrame + "<br>";

		if (intervalId>=0) clearInterval(intervalId);
		removeJsFrame();

		// store instance ref
		for (var idx = 0; idx < _allFrames.length; idx++)
		{
			if (_allFrames[idx] == this)
				_allFrames.splice(idx, 1);
		}
	}

	static function resizeAllAsFrames (stageW:Number,stageH:Number,winW:Number,winH:Number) 
	{
		for (var idx = 0; idx < _allFrames.length; idx++)
		{
			_allFrames[idx].onFrameResize(stageW, stageH, winW, winH);
		}
	}
	/**
	 * called by javascript when window is resized
	 * compute the x and y scale of the swf file
	 * Stage object could not be used because of the limitation to scaleMode = noScale cases
	 * @param	stageW	stage width
	 * @param	stageH	stage height
	 * @param	winW	browser window width
	 * @param	winH	browser window height
	 */
	function onFrameResize(stageW:Number,stageH:Number,winW:Number,winH:Number) 
	{

		// stage size
		if (Stage.scaleMode == "exactFit" || Stage.scaleMode == "showAll" || _root.forceScaleMode == "exactFit" || _root.forceScaleMode == "showAll")
		{
			jsxscale = stageW / Stage.width;
			jsyscale = stageH / Stage.height;
		}
		// keep the smallest scale
		if (Stage.scaleMode == "showAll" || _root.forceScaleMode =="showAll")
		{
			if (jsxscale > jsyscale) jsxscale = jsyscale;
			else jsyscale = jsxscale;
		}
		// stage position = centered 
		if ((Stage.scaleMode == "noScale" || Stage.scaleMode == "showAll" || _root.forceScaleMode ==  "noScale"|| _root.forceScaleMode == "showAll") && (!Stage.align || Stage.align == "" || _root.forceAlign == ""))
		{
			//jsxoffset = (winW - stageW) / 2;
			//jsyoffset = (winH - stageH) / 2;
			jsxoffset = -_global.getSilex().application.stageRect.left;
			jsyoffset = -_global.getSilex().application.stageRect.top;
		}
		
		checkChanges();
		// synchronise frame position
		//synchAsJsValue("jsheight", "Height");
		//synchAsJsValue("jswidth", "Width");
	}
	/**
	 * checkChamges and forward it to the frame
	 */
	//private var enterDomDelay:Number = 5;
	public function checkChanges() 
	{
		// display the frame after a while
/*		if (enterDomDelay == 0)
		{
			enterDom();
			enterDomDelay = -1;
		}
		else
			if (enterDomDelay > 0)
				enterDomDelay--;
			else*/
			{
				
				// init of js API
				/*if (!isJsApiInitilized)
				{
					isJsApiInitilized = true;
					initJsApi();
				}*/
				
				// background clip takes the component size
				bg_mc._width = _width;
				bg_mc._height = _height;
				_xscale = 100;
				_yscale = 100;
				
				// compute position and size in global coordinates
				// top left point
				var globTL:Object = {x:_x,y:_y};
				_parent.localToGlobal(globTL);
				// bottom right point
				var globBR:Object = {x:_x+bg_mc._width,y:_y+bg_mc._height};
				_parent.localToGlobal(globBR);
				
				// update frame attributes
				jsx = globTL.x*jsxscale + jsxoffset;
				jsy = globTL.y*jsyscale + jsyoffset;
				jswidth = (globBR.x - globTL.x)*jsxscale;
				jsheight = (globBR.y - globTL.y) * jsyscale;

				// visibility of the frame
				var isVisible:Boolean = true;
				if (isFrameVisible)
				{
					// visibility of all containers
					var ptr:MovieClip = this;
					while (ptr && ptr._visible == true)
						ptr = ptr._parent;

					if (ptr) isVisible = ptr._visible;
				}
				else
					isVisible = false;
				
				jsvisible = isVisible;
			}
	}
	/**
	 * replace
	 * string util function from silex source code
	 */
	public function replace(chaine_str:String,a_remplacer_str:String,remplacement_str:String):String{
		var res_str:String=new String("");
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
	
	/////////////////////////////////////////////
	//// methods to be overriden in derived classes	////
	/////////////////////////////////////////////
	/**
	 * write the oobject tag in the frame
	 * @param	urlMedia	swf file url
	 * @param	w			width in the html page coordinate system
	 * @param	h			height in the html page coordinate system
	 */
/*	private function writeEmbededObject(urlMedia:String, newId:String, w:Number, h:Number) 
	{
		throw(new Error("writeEmbededObject not implemented (this is a virtual class)"));
	}
*/
	/**
	 * Initialize the JS API
	 */
	private function initJsApi()
	{
		throw(new Error("initJsApi not implemented (this is a virtual class)"));
	}
	/**
	 * Create the JsFrame object
	 */
	private function addJsFrame()
	{
		throw(new Error("addJsFrame not implemented (this is a virtual class)"));
	}
	/**
	 * Delete the JsFrame object
	 */
	private function removeJsFrame()
	{
		throw(new Error("removeJsFrame not implemented (this is a virtual class)"));
	}
	/**
	 * Modify a frame attributes in js
	 */
	public function synchAsJsValue(asProp:String, jsProp:String)
	{
		throw(new Error("synchAsJsValue not implemented (this is a virtual class)"));
	}
	/**
	 * Display the frame after init
	 */
	public function enterDom() 
	{
		throw(new Error("enterDom not implemented (this is a virtual class)"));
	}
}