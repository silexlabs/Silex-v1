/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/


/**
 * Name : Text.as
 * Package : ui.players
 * Version : 0.8
 * Date :  2007-08-03
 */
	 
import org.silex.ui.players.PlayerBase;
import org.silex.core.Utils;
import TextField.StyleSheet;

[Event("onChanged")]
[Event("onKillFocus")]
[Event("onSetFocus")]
[Event("onScroller")]

// only when editable:
[Event("onRelease")]
[Event("onPress")]
class org.silex.ui.players.Text extends PlayerBase {

	//dimensions
	var __width:Number;
	var __height:Number;
	//contenerTxt_txt
	/**
	 * deprecated, only for compatibility. not true!!! A.S.
	 */
	var contenerTxt_txt:TextField;
	/**
	 * the text field object of the player
	 */
	var tf:TextField;
	var dummy_mc:MovieClip;
	//var listenerTxt_obj:Object;
	var myCSS:StyleSheet = null;
	var cssUrl_str:String;
	
	//scrollbar
	var _scrollbar:Boolean;
	var scrollbar_mc;
	var _scrollBarWidth:Number;
	var scrollbarDelay_obj:Object;
	
	/**
	 * text format
	 * object containing key/value pairs for the textfield text format
	 * useful when the text is an input text and you want it to have a given formating
	 * @example	{bold:true,color:FFFFFF,size:12}
	 */
	private var _textFormat:Array;
	public function get textFormat ():Array
	{
		return _textFormat;
	}
	public function set textFormat(val:Array)
	{
		_textFormat = val;
		updateTextFormat();
	}
	/**
	 * apply the text format
	 */
	private function updateTextFormat():Void 
	{
		// extract key/value pairs
		var associativeFormatArray:Array = new Array;
		
		for (var idx:Number = 0; idx < _textFormat.length; idx++)
		{
			// split the "=" separated data
			var temp_array:Array = _textFormat[idx].split("=");
			var key_str:String = temp_array[0];
			var value_str:String = temp_array[1];
			
			// put it in associative array
			associativeFormatArray[key_str] = value_str;
		}
		
		var temp_tf:TextFormat = contenerTxt_txt.getTextFormat();
		
		if (associativeFormatArray.align!=undefined) temp_tf.align = associativeFormatArray.align;
		if (associativeFormatArray.blockIndent!=undefined) temp_tf.blockIndent = parseFloat(associativeFormatArray.blockIndent);
		if (associativeFormatArray.bold!=undefined) temp_tf.bold = associativeFormatArray.bold == "true";
		if (associativeFormatArray.bullet!=undefined) temp_tf.bullet = associativeFormatArray.bullet == "true";
		if (associativeFormatArray.color!=undefined) temp_tf.color = parseInt(associativeFormatArray.color,16);
		if (associativeFormatArray.font!=undefined) temp_tf.font = associativeFormatArray.font;
		if (associativeFormatArray.indent!=undefined) temp_tf.indent = parseFloat(associativeFormatArray.indent);
		if (associativeFormatArray.italic!=undefined) temp_tf.italic = associativeFormatArray.italic == "true";
		if (associativeFormatArray.kerning!=undefined) temp_tf["kerning"] = associativeFormatArray.kerning == "true";
		if (associativeFormatArray.leading!=undefined) temp_tf.leading = parseFloat(associativeFormatArray.leading);
		if (associativeFormatArray.leftMargin!=undefined) temp_tf.leftMargin = parseFloat(associativeFormatArray.leftMargin);
		if (associativeFormatArray.letterSpacing!=undefined) temp_tf["letterSpacing"] = parseFloat(associativeFormatArray.letterSpacing);
		if (associativeFormatArray.rightMargin!=undefined) temp_tf.rightMargin = parseFloat(associativeFormatArray.rightMargin);
		if (associativeFormatArray.size != undefined) temp_tf.size = parseFloat(associativeFormatArray.size);
		if (associativeFormatArray.tabStops != undefined) 
		{
			var tabStops:Array = associativeFormatArray.tabStops.split(",");
			temp_tf.tabStops = new Array;
			for (var idx:Number = 0; idx < tabStops.length; idx++)
			{
				temp_tf.tabStops[idx] = parseInt(tabStops[idx]);
			}
		}
		if (associativeFormatArray.underline!=undefined) temp_tf.underline = associativeFormatArray.underline == "true";
		if (associativeFormatArray.url!=undefined) temp_tf.url = associativeFormatArray.url;

		
		contenerTxt_txt.setTextFormat(temp_tf);
	}
	
     /**
	  * constructor
	  * @return void
	  */
     public function Text(){
     	super();
     	// inheritance
     	typeArray.push("org.silex.ui.players.Text");
		//scrollbar
		//scrollbar_mc = this.attachMovie('UIScrollBar', 'scrollbar_mc', this.getNextHighestDepth(), { _visible:false, _targetInstanceName:"contenerTxt_txt" } );
		//scrollbar_mc.visible = false;
		//css
		myCSS = new TextField.StyleSheet();
		myCSS.onLoad = Utils.createDelegate(this, formatText);
    }
	

	/**
	 * function _populateProperties. load all editable properties for Silex
	 * @return void
	 */
	function _populateProperties():Void{
		super._populateProperties();
		//editableProperties
		editableProperties.unshift(   
			{ name :"html" , 			description:"PROPERTIES_LABEL_ENABLE_HTML", 					type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"htmlText" , 		description:"PROPERTIES_LABEL_LABEL", 					type: silexInstance.config.PROPERTIES_TYPE_RICHTEXT		, defaultValue: playerContainer.text_str, isRegistered:true, group:"attributes" },
			{ name :"width" ,			description:"PROPERTIES_LABEL_WIDTH", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: defaultSize		, isRegistered:true	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"height" , 			description:"PROPERTIES_LABEL_HEIGHT", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: defaultSize		, isRegistered:true , minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"embedFonts" , 		description:"PROPERTIES_LABEL_ENABLE_EMBEDDED_FONTS", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"cssUrl" , 			description:"PROPERTIES_LABEL_CSS_URL",					type: silexInstance.config.PROPERTIES_TYPE_URL 			, defaultValue: ''	, isRegistered:true, group:"parameters" },
			{ name :"scrollbar" , 		description:"PROPERTIES_LABEL_ENABLE_SCROLL_BAR", 			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
//			{ name :"typeWriterEffectSpeed" , description:silexInstance.config.PROPERTIES_LABEL_TYPE_WRITER_EFFECT_SPEED, 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER	, defaultValue: 0	, isRegistered:true, group:"parameters" },
			{ name :"scrollBarWidth" , 		description:"PROPERTIES_LABEL_SCROLL_BAR_WIDTH", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: 16	, isRegistered:true, group:"parameters" },
			{ name :"selectable" , 		description:"PROPERTIES_LABEL_IS_SELECTABLE",				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"multiline" , 		description:"PROPERTIES_LABEL_IS_MULTILINE",				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
			//{ name :"textColor" , 		description:silexInstance.config.PROPERTIES_LABEL_="textColor",				type: silexInstance.config.PROPERTIES_TYPE_COLOR		, defaultValue: ""		, isRegistered:true, group:"others" },
			//{ name :"textHeight" , 		description:silexInstance.config.PROPERTIES_LABEL_="textHeight",				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: ""		, isRegistered:true ,minValue:+1,  	maxValue: +100, group:"others"},
			//{ name :"autoSize" , 		description:silexInstance.config.PROPERTIES_LABEL_="autoSize",					type: silexInstance.config.PROPERTIES_TYPE_URL			, defaultValue: "none"	, isRegistered:true, group:"others" },
			{ name :"border" , 			description:"PROPERTIES_LABEL_HAS_BORDER",					type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"parameters" },
			{ name :"borderColor" , 	description:"PROPERTIES_LABEL_BORDER_COLOR",				type: silexInstance.config.PROPERTIES_TYPE_COLOR		, defaultValue: "" 		, isRegistered:true, group:"parameters" },
			//{ name :"antiAliasType" , 	description:silexInstance.config.PROPERTIES_LABEL_="antiAliasType",			type: silexInstance.config.PROPERTIES_TYPE_URL			, defaultValue: "normal", isRegistered:true, group:"others" },
			{ name :"background" , 		description:"PROPERTIES_LABEL_HAS_BACKGROUND",			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"parameters" },
			{ name :"backgroundColor" , description:"PROPERTIES_LABEL_BACKGROUND_COLOR",			type: silexInstance.config.PROPERTIES_TYPE_COLOR		, defaultValue: ""		, isRegistered:true, group:"parameters" },
			//{ name :"condenseWhite" , 	description:silexInstance.config.PROPERTIES_LABEL_="condenseWhite",			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"maxChars" , 		description:"PROPERTIES_LABEL_MAX_NUMBER_OF_CHARACTERS",			type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: undefined		, isRegistered:true , minValue:1,  	maxValue:5000, group:"parameters"},
			{ name :"mouseWheelEnabled",description:"PROPERTIES_LABEL_ENABLE_MOUSE_WHEEL",		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"password" , 		description:"PROPERTIES_LABEL_IS_PASSWORD",			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"restrict" , 		description:"PROPERTIES_LABEL_ALLOWED_CHARACTERS",		type: silexInstance.config.PROPERTIES_TYPE_URL			, defaultValue: ""		, isRegistered:true, group:"others" },
			{ name :"type" , 			description:"PROPERTIES_LABEL_INPUT_TYPE",				type: silexInstance.config.PROPERTIES_TYPE_URL			, defaultValue: "dynamic"	, isRegistered:true, group:"others" },
			{ name :"wordWrap" , 		description:"PROPERTIES_LABEL_WORD_WRAP",					type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"others" },
			{ name :"textFormat" , 		description:"PROPERTIES_LABEL_TEXT_FORMAT_ARRAY",					type: silexInstance.config.PROPERTIES_TYPE_ARRAY	, isRegistered:true, group:"parameters" }
		);	
	}
	
	/**
	 * function _populateEvents. load all events for Silex
	 * @return void
	 */
	function _populateEvents():Void{
		super._populateEvents();
		//availableEvents
		this.availableEvents.push(
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_CHANGED, 		description : "on changed"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_KILLFOCUS,		description : "on kill focus"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SETFOCUS, 		description : "on set focus"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SCROLLER, 		description : "on scroll"}	
        );		
	}
	
	/**
	 * function _populateMethods. load all events for Silex
	 * @return void
	 */
	function _populateMethods():Void{
		super._populateMethods();
		//availableMethods
		this.availableMethods.push(
			{modifier:"SCROLL_UP", 		description : "play sound"		, parameters: new Array() },
			{modifier:"SCROLL_DOWN",	description : "pause sound"		, parameters: new Array() },
			{modifier:"SCROLL_TO", 		description : "stop sound"		, parameters: new Array( {name:"scrollTo", description:"scroll to ", type:silexInstance.config.PROPERTIES_TYPE_TEXT}) }
        );
		
	}
	
	function _initAfterRegister(){
		super._initAfterRegister();
		//text format
		formatText();	
		//scrollbar
		//scrollbar_mc = this.attachMovie('UIScrollBar', 'scrollbar_mc', this.getNextHighestDepth(), { _visible:false, _targetInstanceName:"contenerTxt_txt" } );
		//scrollbar_mc.visible = false;
		// redraw on next frame, the time for the scroll bar to be instanciated
		//silexInstance.sequencer.doInNFrames(10,Utils.createDelegate(this,redraw));

	/*	scrollbarDelay_obj=new Object;
		scrollbarDelay_obj.onEnterFrame=mx.utils.Utils.createDelegate(this,redraw);
		silexInstance.sequencer.addEventListener("onEnterFrame",scrollbarDelay_obj);*/
		//scrollbar_mc.doLater(this, "redraw");
		//silexInstance.sequencer.addItem(null,mx.utils.Utils.createDelegate(this,redraw));
		//onEnterFrame=redraw;
		
		
		//events
		tf = contenerTxt_txt;
		contenerTxt_txt.onChanged 		= Utils.createDelegate(this, _onChanged);
		contenerTxt_txt.onKillFocus 	= Utils.createDelegate(this, _onKillFocus);
		contenerTxt_txt.onScroller 		= Utils.createDelegate(this, _onScroller);
		contenerTxt_txt.onSetFocus 		= Utils.createDelegate(this, _onSetFocus);		
		
		//redraw();
	}
	
	/**
	 * set/get tabEnabled
	 * @param 	Boolean		tabEnabled player
	 * @return  void|Boolean
	 */ 
	public function set tabEnabled(value_bool:Boolean):Void {
		contenerTxt_txt.tabEnabled = value_bool;			
	}
	
	public function get tabEnabled():Boolean {
		return contenerTxt_txt.tabEnabled;		
	}
	
	/**
	 * set/get tabIndex
	 * @param 	Number		tabIndex player
	 * @return  void|Number
	 */ 
	public function set tabIndex(numValue:Number):Void {
		contenerTxt_txt.tabIndex = numValue;			
	}
	
	public function get tabIndex():Number {
		return contenerTxt_txt.tabIndex;		
	}
	//////////////////////////////////////////
	// FUNCTIONS FOR AS IN SILEX COMMANDS (INTERFACE FUNCTIONS)
	/** scrollUp 
	 * scrolls up one line
	 */
	function scrollUp () {
		contenerTxt_txt.scroll--;
	}
	/** scrollDown 
	 * scrolls down one line
	 */
	function scrollDown () {
		contenerTxt_txt.scroll++;
	}
	/** scrollTo 
	 * scrolls up or down n lines
	 * @example scrollTo("+10")
	 */
	function scrollTo (val:String) {
		contenerTxt_txt.scroll=silexInstance.interpreter.modify_val(contenerTxt_txt.scroll,val);
	}
	//////////////////////////////////////////
	
	/** 
	  * wrappers function
	  */
	function SCROLL_UP(){
		scrollUp();
	}
	
	function SCROLL_DOWN(){
		scrollDown();
	}
	
	function SCROLL_TO(val_str:String){
		scrollTo(val_str);
	}
	
	
	//text format
	function formatText(){
		
		if(cssUrl && cssUrl != ''){
			contenerTxt_txt.styleSheet = myCSS;
			contenerTxt_txt.embedFonts = embedFonts;
			
		}else{
			contenerTxt_txt.styleSheet = null;
			contenerTxt_txt.embedFonts = embedFonts;
		}
	}
	
	/**
	 * setEditable
	 * encapsulate set editable
	 * @param 	Boolean		moderation or not 
	 * @return  void
	 */
	public function set isEditable(allowEdit:Boolean){
//	public function setEditable(allowEdit:Boolean):Void {
		//_root.getUrl("ui.players.Text redraw setEditable "+allowEdit);
		_isEditable = allowEdit;
		if( !_isEditable){
			_visible = visibleOutOfAdmin && temporarilyVisible;	
		}else{
			_visible = temporarilyVisibleInAdminMode;
		}
		
		if(!allowEdit){
			//delete dummy and get focus back to the textfield 
			if (dummy_mc) 
			{
				dummy_mc.onRelease = undefined;
				Utils.removeDelegate(this, _onRelease);
				
				dummy_mc.onPress = undefined;
				Utils.removeDelegate(this, _onPress);
				
				dummy_mc.removeMovieClip();
			}
			dummy_mc = undefined;
		}else{
			if (dummy_mc == undefined)
			{
				//create dummy movieClip to prevent focus in textfield
				dummy_mc = this.attachMovie('setEditableClip','dummy_mc',this.getNextHighestDepth());
				dummy_mc._alpha = 0;
				dummy_mc._width = width;
				dummy_mc._height = height;
				dummy_mc._x = contenerTxt_txt._x;
				dummy_mc._y = contenerTxt_txt._y;
				//events
				dummy_mc.onRelease		= Utils.createDelegate(this, _onRelease);
				dummy_mc.onPress 		= Utils.createDelegate(this, _onPress);
			}
		}
	}
	
	public function get isEditable():Boolean
	{
		return _isEditable;
	}
	 	
	
	/**
	 * function redraw
	 * @return void
	 */
	function redraw()
	{
		
		 //hide/show
/*		 if (scrollbar && contenerTxt_txt.text.length > 0)
		 {
			 //hide if full text is visible
			 if (contenerTxt_txt.maxscroll>contenerTxt_txt.scroll && contenerTxt_txt.maxscroll > 1)
			 {
				if (!scrollbar_mc)
				{
					scrollbar_mc = this.attachMovie('UIScrollBar', 'scrollbar_mc', this.getNextHighestDepth(), { _targetInstanceName:"contenerTxt_txt" , _visible:false} );
					silexInstance.sequencer.addItem(null,mx.utils.Utils.createDelegate(this,updateScrollBar));
					//silexInstance.sequencer.doInNextFrame(Utils.createDelegate(this,updateScrollBar));
					silexInstance.sequencer.doInNFrames(2,Utils.createDelegate(this,updateScrollBar));
					//silexInstance.sequencer.doInNFrames(4,Utils.createDelegate(this,updateScrollBar));
					silexInstance.sequencer.doInNFrames(8,Utils.createDelegate(this,updateScrollBar));
				}
				//scrollbar_mc._visible = true;
				//ajuste scroll / text
				 scrollbar_mc._x  = contenerTxt_txt._x + __width;
				 scrollbar_mc._y  = contenerTxt_txt._y ;
				 scrollbar_mc.setSize(scrollBarWidth, height);
				scrollbar_mc._width=scrollBarWidth;
				// Définition du champ de texte cible.
				scrollbar_mc.setScrollTarget(contenerTxt_txt);
					scrollbar_mc.invalidate();
			 }else{
				 if (scrollbar_mc)
				 {
					scrollbar_mc._visible = false;
					removeMovieClip(scrollbar_mc);
					scrollbar_mc = undefined;
				 }
			 }
		}else{
			 if (scrollbar_mc)
			 {
				scrollbar_mc._visible = false;
				 removeMovieClip(scrollbar_mc);
				 scrollbar_mc = undefined;
			 }
		}*/
		if (dummy_mc)
		{
			dummy_mc._width = width;
			dummy_mc._height = height;
			dummy_mc._x = contenerTxt_txt._x;
			dummy_mc._y = contenerTxt_txt._y;
		}
		if(typeWriterEffectSpeed>0){
			silexInstance.utils.applyTypeWriterEffect(contenerTxt_txt,formatedText_str,typeWriterEffectSpeed,Utils.createDelegate(this,redraw));
		}
		else{
			silexInstance.utils.removeTypeWriterEffect(contenerTxt_txt);
			contenerTxt_txt.htmlText=formatedText_str;
		}
		// fix the bug of the last \n which is allways inserted at the end
		if (multiline==false)
		{
			//contenerTxt_txt.text = silexInstance.utils.replace(contenerTxt_txt.text, "\n", "");
			//contenerTxt_txt.text = silexInstance.utils.replace(contenerTxt_txt.text, " ", " ");
			contenerTxt_txt.text = contenerTxt_txt.text;
		}

		//scrollbar_mc.invalidate();
		//onEnterFrame=undefined;
/*		if ((scrollbar_mc instanceof mx.controls.UIScrollBar)==true){
			if (scrollbarDelay_obj.hasBeenSeenAllready==true)
				silexInstance.sequencer.removeEventListener("onEnterFrame",scrollbarDelay_obj);
			else
				scrollbarDelay_obj.hasBeenSeenAllready=true;
		}*/
		//scrollbar_mc.addEventListener("load",{load:mx.utils.Utils.createDelegate(this,redraw)});
		TEXT = formatedText_str;
		
		//
		updateScrollBar();
		
		updateTextFormat();
	}
	function updateScrollBar()
	{
		//hide/show
/*		if (scrollbar_mc && scrollbar==true && contenerTxt_txt.text.length > 0 && contenerTxt_txt.maxscroll!=undefined && contenerTxt_txt.maxscroll > 1)
		{
			
			//scrollbar_mc.invalidate();
			scrollbar_mc._visible = true;
			
			//ajuste scroll / text
			scrollbar_mc._x  = contenerTxt_txt._x + __width;
			scrollbar_mc._y  = contenerTxt_txt._y ;
			scrollbar_mc.setSize(scrollBarWidth, height);
			
			// Définition du champ de texte cible.
			//scrollbar_mc.setScrollTarget(contenerTxt_txt);
		}
		else
		{
			if (scrollbar_mc)
			{
				scrollbar_mc._visible = false;
				//removeMovieClip(scrollbar_mc);
				//scrollbar_mc = undefined;
			}
		}*/
		if (_scrollbar==true && contenerTxt_txt.text.length > 0 && contenerTxt_txt.maxscroll > 1)
		{
			if (!scrollbar_mc)
			{
				scrollbar_mc = this.attachMovie('UIScrollBar', 'scrollbar_mc', this.getNextHighestDepth());
				scrollbar_mc.setScrollTarget(contenerTxt_txt);
				
			}
			scrollbar_mc.setSize(scrollBarWidth, height);
			scrollbar_mc._x  = contenerTxt_txt._x + __width;
			scrollbar_mc._y  = contenerTxt_txt._y ;

			/*
			scrollbar_mc._x  = contenerTxt_txt._x + __width;
			scrollbar_mc._y  = contenerTxt_txt._y ;
			scrollbar_mc.setSize(scrollBarWidth, height);
			scrollbar_mc.setScrollTarget(contenerTxt_txt);
			scrollbar_mc.setScrollProperties(textHeight,0,contenerTxt_txt.maxscroll);
			*/
			//scrollbar_mc.invalidate();
		}
		else
		{
			if (scrollbar_mc != undefined)
			{
				removeMovieClip(scrollbar_mc);
				scrollbar_mc.removeMovieClip();
			}
			scrollbar_mc = undefined;
		}
	}
	var TEXT:String="";
/*	bug because same name as the class :
	function get TEXT():String{
		return formatedText_str;
	}
	function set TEXT(str:String){
		formatedText_str=str;
	}
	*/
	function get formatedText():String{
		return contenerTxt_txt.htmlText;
	}
	function set formatedText(str:String) {
		
		contenerTxt_txt.htmlText=str;

		//refresh player
		redraw();
	}
	
	
	var typeWriterEffectSpeed:Number=0;
	
	
	// to be documented : onRelease event
	function _onRelease()
	{
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_RELEASE ,target:this, textField:contenerTxt_txt});
	}
	
	function _onPress()
	{
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_PRESS ,target:this, textField:contenerTxt_txt});
	}

	
	
	/**
	 * set/get rotation
	 * @param 	Number		show/hide
	 * @return  void|Number
	 */ 
	 
	public function set rotation( value_num:Number):Void{
		contenerTxt_txt._rotation = value_num;
	}
	
	public function get rotation():Number{
		return contenerTxt_txt._rotation;
	}
	
	
	/**
	 * set/get 	html
	 * @param 	Boolean		rich text
	 * @return  void|Boolean
	 */ 
	public function set html(value_bool:Boolean):Void {
		if (contenerTxt_txt.html!=value_bool)
		{
			contenerTxt_txt.html = value_bool;			
			//refresh
			redraw()
		}
	}
	
	public function get html():Boolean {
		return contenerTxt_txt.html;		
	}
	
	 // The dynamic text field variable
	 var formatedText_str:String;
	 // the property storage
	 var _htmlText:String;
	/**
	 * set/get 	text
	 * @param 	String		text
	 * @return  void|String
	 */
	public function set htmlText(value_str:String):Void 
	{
		if (value_str == undefined)
		{
			value_str = "";
		}
		
		_htmlText=value_str;
		// format the text with accessors etc
		var _str:String=silexInstance.utils.revealAccessors(_htmlText,this);
		formatedText_str = silexInstance.utils.revealWikiSyntax(_str);
		

		//refresh player
		redraw();
		//scrollbar_mc.doLater(scrollbar_mc,"invalidate");
		//silexInstance.sequencer.addItem(null, mx.utils.Utils.createDelegate(this, redraw));
		silexInstance.sequencer.doInNFrames(10,Utils.createDelegate(this,redraw));
	}
	public function get htmlText():String
	{
		return _htmlText;		
	}
	
	/*
	 * processWikiLinkTagCallback 
	 * callback function for asfunction calls
	 * see org.silex.core.utils for details
	 */
	function processWikiLinkTagCallback (escapedCommands_str:String) {
		silexInstance.utils.processWikiLinkTagCallback(escapedCommands_str);
	}
	
		
	/**
	 * function set/get width
	 * @param 	Number		
	 * @return  void|Number
	 */ 
	function set width( value_num:Number):Void{
		if (value_num == undefined) value_num = defaultSize;
		__width=value_num;
		contenerTxt_txt._width = value_num;
		//refresh
		redraw();
	}
	
	function get width ():Number{
		return __width;
	}
	
	
	
	/**
	 * function set/get height
	 * @param 	Number		
	 * @return  void|Number
	 */ 
	function set height( value_num:Number):Void{
		if (value_num == undefined) value_num = defaultSize;
		__height=value_num;
		contenerTxt_txt._height = value_num;
		//refresh
		redraw();
	}
	
	function get height ():Number{
		return __height;
	}
	
	
	
	/**
	 * function set/get antiAliasType
	 * @param 	String		text
	 * @return  void|String
	 */ 
	function set antiAliasType( value_str:String):Void{
		contenerTxt_txt.antiAliasType = value_str;
	}
	
	function get antiAliasType ():String{
		return contenerTxt_txt.antiAliasType;
	}
	
	
	
	/**
	 * function set/get autosize
	 * @param 	String		text
	 * @return  void|Object
	 */ 
	function set autoSize( value_str:Object):Void{
		contenerTxt_txt.autoSize = value_str;
		//refresh
		redraw();
	}
	
	function get autoSize ():Object{
		return contenerTxt_txt.autoSize;
	}
	
	
	
	/**
	 * function set/get background
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set background( value_bool:Boolean):Void{
		contenerTxt_txt.background = value_bool;
	}
	
	function get background ():Boolean{
		return contenerTxt_txt.background;
	}
	
	
	/**
	 * function set/get cssUrl
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set cssUrl( value_str:String):Void {
		if (value_str != cssUrl_str)
		{
			cssUrl_str = value_str;
			myCSS.clear();
			if (value_str != "")
			{
				myCSS.load(cssUrl_str);
			}
		}			
		//refresh
		redraw()
	}
	
	function get cssUrl ():String{
		return cssUrl_str;
	}
	
	
	
	
	/**
	 * function set/get backgroundColor
	 * @param 	Number	
	 * @return  void|Number
	 */ 
	function set backgroundColor( value_num:Number):Void{
		contenerTxt_txt.backgroundColor = value_num;
	}
	
	function get backgroundColor ():Number{
		return contenerTxt_txt.backgroundColor;
	}
	
	
	
	/**
	 * function set/get selectable
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set selectable( value_bool:Boolean):Void{
		contenerTxt_txt.selectable = value_bool;
	}
	
	function get selectable ():Boolean{
		return contenerTxt_txt.selectable;
	}	
	
	
	
	
	/**
	 * function set/get border
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set border( value_bool:Boolean):Void{
		contenerTxt_txt.border = value_bool;
	}
	
	function get border ():Boolean{
		return contenerTxt_txt.border;
	}	
	
	
	
	/**
	 * function set/get borderColor
	 * @param 	Number	
	 * @return  void|Number
	 */ 
	function set borderColor( value_num:Number):Void{
		contenerTxt_txt.borderColor = value_num;
	}
	
	function get borderColor ():Number{
		return contenerTxt_txt.borderColor;
	}
	
	
	
	/**
	 * function set/get condenseWhite
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set condenseWhite( value_bool:Boolean):Void{
		contenerTxt_txt.condenseWhite = value_bool;
		//refresh
		redraw()
	}
	
	function get condenseWhite ():Boolean{
		return contenerTxt_txt.condenseWhite;
	}
	
	
	
	/**
	 * function set/get embedFonts
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set embedFonts( value_bool:Boolean):Void{
		contenerTxt_txt.embedFonts = value_bool;
		//refresh
		redraw()
	}
	
	function get embedFonts ():Boolean{
		return contenerTxt_txt.embedFonts;
	}
	
	
	
	
	
	/**
	 * function set/get maxChars
	 * @param 	Number		
	 * @return  void|Number
	 */ 
	function set maxChars( value_num:Number):Void{
		contenerTxt_txt.maxChars = value_num;
		//refresh
		redraw()
	}
	
	function get maxChars ():Number{
		return contenerTxt_txt.maxChars;
	}
	
	
	
	/**
	 * function set/get mouseWheelEnabled
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set mouseWheelEnabled( value_bool:Boolean):Void{
		contenerTxt_txt.mouseWheelEnabled = value_bool;
	}
	
	function get mouseWheelEnabled ():Boolean{
		return contenerTxt_txt.mouseWheelEnabled;
	}
	
	
	
	
	/**
	 * function set/get multiline
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set multiline( value_bool:Boolean):Void{
		contenerTxt_txt.multiline = value_bool;
		//refresh
		redraw()
	}
	
	function get multiline ():Boolean{
		return contenerTxt_txt.multiline;
	}
	
	
	
	/**
	 * function set/get password
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set password( value_bool:Boolean):Void{
		contenerTxt_txt.password = value_bool;
	}
	
	function get password ():Boolean{
		return contenerTxt_txt.password;
	}
	
	
	
	/**
	 * function set/get borderColor
	 * @param 	String	
	 * @return  void|String
	 */ 
	function set restrict( value_str:String):Void{
		contenerTxt_txt.restrict = value_str;
	}
	
	function get restrict ():String{
		return contenerTxt_txt.restrict;
	}
	
	
	
	/**
	 * function set/get textColor
	 * @param 	Number	
	 * @return  void|Number
	 */ 
	function set textColor( value_num:Number):Void{
		contenerTxt_txt.textColor = value_num;
	}
	
	function get textColor ():Number{
		return contenerTxt_txt.textColor;
	}
	
	
	
	/**
	 * function set/get textHeight
	 * @param 	Number	
	 * @return  void|Number
	 */ 
	function set textHeight( value_num:Number):Void{
		contenerTxt_txt.textHeight = value_num;
		//refresh
		redraw()
	}
	
	function get textHeight ():Number{
		return contenerTxt_txt.textHeight;
	}
		
		
		
	/**
	 * function set/get type
	 * @param 	String	
	 * @return  void|String
	 */ 
	function set type( value_str:String):Void{
		contenerTxt_txt.type = value_str;
	}
	
	function get type():String{
		return contenerTxt_txt.type;
	}
	
	
	
	/**
	 * function set/get wordWrap
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set wordWrap( value_bool:Boolean):Void{
		contenerTxt_txt.wordWrap = value_bool;
		//refresh
		redraw()
	}
	
	function get wordWrap ():Boolean{
		return contenerTxt_txt.wordWrap;
	}
	
	

	
	/*
	 *  setter/getter scrollbar
	 */
	
	function set scrollbar (value_bool:Boolean):Void{
		//assign
		this._scrollbar = value_bool;
		//refresh
		redraw();
	}	
	function get scrollbar ():Boolean{
		return this._scrollbar;
	}
	/*
	 *  setter/getter scrollBarWidth
	 */
	function set scrollBarWidth(value:Number):Void{
		//assign
		_scrollBarWidth=value;
		//refresh
		redraw();
	}	
	function get scrollBarWidth ():Number{
		return _scrollBarWidth;
	}

	
	/**
	 * function _onChanged
	 * @param	TextField	changed TextField
	 * @return 	void
	 */
	function _onChanged (changedField_txt:TextField):Void{

		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_CHANGED ,target:this, textField:changedField_txt });
	}
	
	/**
	 * function _onKillFocus
	 * @param	Object	new Focus
	 * @return 	void
	 */
	function _onKillFocus (newFocus_obj:Object):Void{
		// stop listening to keyboard events
		Key.removeListener(this);
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_KILLFOCUS ,target:this, focus:newFocus_obj });
	}
	
	/**
	 * function _onScroller
	 * @param	TextField	scrolled TextField
	 * @return 	void
	 */
	function _onScroller (scrolledField_txt:TextField):Void{
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_SCROLLER ,target:this, textField:scrolledField_txt });
	}
	
	function onKeyDown()
	{
		var eventName:String = "on";
		switch (Key.getCode()) 
		{
			case Key.ALT:
				eventName += "Alt";
			break;
			case Key.BACKSPACE:
				eventName += "Backspace";
			break;
			case Key.CAPSLOCK:
				eventName += "Capslock";
			break;
			case Key.CONTROL:
				eventName += "Control";
			break;
			case Key.DELETEKEY:
				eventName += "Delete";
			break;
			case Key.DOWN:
				eventName += "Down";
			break;
			case Key.END:
				eventName += "End";
			break;
			case Key.ENTER:
				eventName += "Enter";
			break;
			case Key.ESCAPE:
				eventName += "Escape";
			break;
			case Key.HOME:
				eventName += "Home";
			break;
			case Key.INSERT:
				eventName += "Insert";
			break;
			case Key.LEFT:
				eventName += "Left";
			break;
			case Key.PGDN:
				eventName += "Pgdn";
			break;
			case Key.PGUP:
				eventName += "Pgup";
			break;
			case Key.RIGHT:
				eventName += "Right";
			break;
			case Key.SHIFT:
				eventName += "Shift";
			break;
			case Key.SPACE:
				eventName += "Space";
			break;
			case Key.TAB:
				eventName += "Tab";
			break;
			case Key.UP:
				eventName += "Up";
			break;
		}
		dispatch({type:eventName,target:this});
	}
	/**
	 * function _onSetFocus
	 * @param	Object	old Focus
	 * @return 	void
	 */
	function _onSetFocus (oldFocus_obj:Object):Void {
		// listen to keyboard events
		Key.addListener(this);
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_SETFOCUS ,target:this, focus:oldFocus_obj});
	}
	
	/**
	 * function loadMedia
	 * @param 	string	media url 
	 * @return 	void
	 */
	public function loadMedia(url_str:String):Void{
		//TODO : remplacer par methode globale
		//core.utils.loadMedia();
	}

	/**
	 * function unloadMedia
	 * @return 	void
	 */
	public function unloadMedia():Void {
		super.unloadMedia();
		htmlText = '';
	}

	// **
	// override PlayerBase class :
	// setGlobalCoordTL sets coordinates of the media
	// it substracts the registration point coords to coord
	// and apply the new coordinates to the player
	function setGlobalCoordTL(coord:Object){
		// to local
		this.layerInstance.globalToLocal(coord);
		
		// apply the new coordinates to the player
		_x=coord.x;
		_y=coord.y;
	}
	function setGlobalCoordBR(coord:Object){
		// to local
		this.layerInstance.globalToLocal(coord);
		// get width and height
		coord.x=coord.x-_x;
		coord.y=coord.y-_y;

		// apply the new coordinates to the player
		width=coord.x;
		height = coord.y;
		
		if(scrollbar_mc)
			scrollbar_mc.setSize(scrollBarWidth, height);
	}
	function getGlobalCoordTL(){
		// from global coords
		var coordTL:Object={x:_x,y:_y};
	
		// to global
		this.layerInstance.localToGlobal(coordTL);
		
		return coordTL;
	}
	function getGlobalCoordBR(){
		// from global coords
		var coordBR:Object={x:width+_x,y:height+_y};
	
		// to global
		this.layerInstance.localToGlobal(coordBR);
		
		return coordBR;
	}
	
	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	function getSeoData(url_str:String):Object {
		var res_obj:Object = super.getSeoData();
		var seo_str:String = htmlText;
		
		// clean up for seo
		seo_str = silexInstance.utils.replace(seo_str, "|", " ");
		seo_str = silexInstance.utils.replace(seo_str, "@", " [at] ");
		
		// keywords
		res_obj.text=silexInstance.utils.getRawTextFromHtml(seo_str);

		// html equivalent
		res_obj.htmlEquivalent="<p>"+seo_str+"</p>";
		
		return res_obj;
	}
	/*	//override PlayerBase method
	function getHtmlTags(url_str:String):Object {
		var res_obj:Object=new Object;
		res_obj.keywords = descriptionText+","+htmlText;
		res_obj.description = descriptionText;
		res_obj.context = getUiContext();
		//html 
		if (htmlText){
			var htmlContent = '<div>';
			htmlContent +=  htmlText;//formatedText_str;
			htmlContent += '</div>';		
			//assign
			res_obj.htmlEquivalent = htmlContent;
		}
		return res_obj;
	}
*/
}