/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/* 
*************************************************
    SILEX API 2004-2005
**************************************************
   Title:       Interpreter.as
   Description: interpretes online commands 

   Copyright:   Copyright (c) 2004
   Author:      Alex. H. lex@silex.tv
   Version:     1
*/
/**
 * This class is used to execute SILEX commands. It is a singleton pattern.
 */
//import mx.remoting.*;
//import mx.rpc.*;

import org.silex.core.InterpreterHooks;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;

class org.silex.core.Interpreter
{
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;
	/**
	 * Constructor.
	 * @param	api	reference to silex main Api object (org.silex.core.Api)
	 */
	function Interpreter(api:org.silex.core.Api) {
		// api reference
		silex_ptr=api;
		
	}

	/**
	 * Call the method corresponding to the desired command.
	 * @param command_str	a source, method and parameters like relative.path.to.source.method:param1,param2,...
	 * @param initialSource_mc		movie from which comes the command (source is relative to this parameter)
	 * @return	true if no error occured
	 */
    function exec(command_str:String,initialSource_mc:Object):Boolean
    {
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(InterpreterHooks.EXEC_START_HOOK_UID, arguments);
        if (!command_str || command_str==""){
            return false;
		}

		
		// /////////////////////////
		// = operator
		// replace x.y=z by x.set:y,z
		var equalOperatorIndex:Number=command_str.indexOf("=");
		var columnOperatorIndex:Number=command_str.indexOf(":");
		
		// if there is "=" and no ":"
		// or a "=" before any ":"
		if ((equalOperatorIndex>=0 && columnOperatorIndex<0) || (equalOperatorIndex>0 && equalOperatorIndex<columnOperatorIndex)){
			var res_str:String="";
			// extract x.y
			var targetVariablePath_str:String=command_str.slice(0,equalOperatorIndex);
			// insert "=" between x and y
			var targetVariableIdx:Number=targetVariablePath_str.lastIndexOf(".")+1;
			if (targetVariableIdx>0)
				res_str=targetVariablePath_str.slice(0,targetVariableIdx);
			res_str+="set:"+targetVariablePath_str.slice(targetVariableIdx)+",";

				
			// extract z
			var value_str:String=command_str.slice(equalOperatorIndex+1);
			// transform it to x.set:y
			res_str+=value_str;
			
			command_str=res_str;
		}
			
		
		// /////////////////////////
		// separate the command and the arguments
		var command_array:Array=extract(command_str);

		// separate method from source path and get the source object
		var methodName_str:String;
		var source_mc:Object;
		var lastDotIndex:Number=command_array[0].lastIndexOf(".");
		if (lastDotIndex>0){
			// separate method from source path
			var relativePath_str:String=command_array[0].substring(0,lastDotIndex);
			methodName_str=command_array[0].substring(lastDotIndex+1);
			
			// get the source object
			source_mc=updateSource(initialSource_mc,relativePath_str);
		}
		else{
			methodName_str=command_array[0];
			source_mc=initialSource_mc;
		}

		// convert accessors into values in the command and in each parameter
		for (var idx:Number = 0; idx < command_array.length; idx++)
		{
			command_array[idx] = silex_ptr.utils.revealAccessors(command_array[idx],source_mc);
		}

		// build params_array
		var params_array:Array=command_array;
		// remove command from params_array
		params_array.shift();
		
		// here we have:
		// source_mc			relative.path.to.source object
		// methodName_str		method
		// params_array			[param1,param2,...]
		//TODO not sure this is right. Maybe better to do only one return and use that?
		hookManager.callHooks(InterpreterHooks.EXEC_END_HOOK_UID, null);
		
		// call the method on the source object
		if (source_mc[methodName_str]){
			return source_mc[methodName_str].apply(source_mc,params_array);
//			return true;
		}
		// call the method on the interpreter
		if (this[methodName_str]){
			return this[methodName_str].apply(source_mc,params_array)
//			return true;
		}
		return null;
//		return false;
    }
	/**
	 * Find a movie clip corresponding to a path relatively to a source clip.
	 * @private
	 * @param	source_mc	source clip
	 * @param	path_str	path relative to the source clip
	 * @return	movie clip corresponding to a path relatively to a source clip
	 */
	private function updateSource (source_mc:Object,path_str:String):Object {
		// find the movie clip corresponding to the path relatively from the source
		if (path_str){
			var tmp_mc:Object;

			//if (!(tmp_mc=silex_ptr.application.getPlayerByName(path_str)))
				tmp_mc=_global.getSilex(source_mc).utils.getTarget(source_mc,path_str);

			// if it was found, take it as the source
			if (tmp_mc) source_mc=tmp_mc;
		}
		return source_mc;
	}
	
	/**
	 * Takes series of commands separated by '\n', i.e a line break.
	 * Returns an array of objects which are a model of the commands.
	 * Used by ui.players.Abstract.
	 * Used by toolbox.Actions.
	 * Here, specifier means "onRelease" in the command "onRelease myCommand:myParam1,myParam2".
	 * @example	buildActionArrayFromString("onRelease alert:test of alert\nonRollOut nameOfPlayer.hide:") will return [{modifier:"onRelease", functionName:"alert", parameters:array("test of alert")},{modifier:"onRollOut", functionName:"hide", parameters:array("nameOfPlayer")}]
	 * @param	_str	commands separated by '\n', i.e a line break
	 * @return			an array of objects which are a model of the commands
	 */
	function buildActionArrayFromString(_str:String):Array {
		var commands_array:Array=_str.split("\r");

		// result variable
		var res_array:Array=new Array;

		// for each command line
		for (var idx:Number=0;idx<commands_array.length;idx++){
			var commandLine_str:String=commands_array[idx];
			if (commandLine_str!=""){
				// reult vars
				var specifier_str:String;
				var functionName_str:String;
				var parameters_array:Array;
				// useful vars
				var idxSpecifierSpace:Number=commandLine_str.indexOf(" ");
				var equalOperatorIndex:Number=commandLine_str.indexOf("=");
				var idxSemiCol:Number=commandLine_str.indexOf(":");
				
				// operator '='
				// if there is "=" and no ":"
				// or a "=" before any ":"
				if ((equalOperatorIndex>=0 && idxSemiCol<0) || (equalOperatorIndex>0 && equalOperatorIndex<idxSemiCol)){
					// it is "=" operator
					specifier_str=commandLine_str.slice(0,idxSpecifierSpace);
					
					// command
					functionName_str=commandLine_str.slice(idxSpecifierSpace+1);
					
					// params
					parameters_array=[];
				}
				else{
					// if idxSpecifierSpace is not before semicolun, there is no specifier
					if (idxSemiCol>-1 && idxSpecifierSpace>idxSemiCol)
						idxSpecifierSpace=-1;
					// specifier
					if (idxSpecifierSpace>-1)
						specifier_str=commandLine_str.slice(0,idxSpecifierSpace);
					else idxSpecifierSpace=-1;
					
					// command
					if (idxSemiCol>0)
						functionName_str=commandLine_str.slice(idxSpecifierSpace+1,idxSemiCol);
					else{
						// no semi column => to the end
						functionName_str=commandLine_str.slice(idxSpecifierSpace+1);
					}
					
					// params
					if (idxSemiCol>-1)
						parameters_array=commandLine_str.slice(idxSemiCol+1).split(",");
					else parameters_array=[];
				}

				
				// result in an object
				res_array.push({modifier:specifier_str, functionName:functionName_str, parameters:parameters_array});
			}
		}
		return res_array;
	}
    /**
 	 * Separates name of function from the params.
 	 * @param	command_str		a command
	 * @return	array of strings where first element is the command name and the other ones are the arguments of the command
	 */
    function extract(command_str:String):Array
    {
        var ret_array:Array=new Array;

        if (!command_str || command_str=="")
            return null;
            

        var indice_num=command_str.indexOf(":");
        if (indice_num>=0)
        {// Command with a ':'
            // command extraction
            ret_array[0]=command_str.substr(0,indice_num);

            // params extraction
            var tmp_array:Array=(command_str.substr(indice_num+1)).split(",");
            // Concat in the result array
            for(var i=0;i<tmp_array.length;i++)
            {
                ret_array[i+1]=tmp_array[i];
            }
        }
        else
        {// Command without a ':' => no params
            ret_array[0]=command_str;
        }
        return ret_array;
    }// extract(command_str:String):Array
    /**
 	 * Check if a number has to be incremented or decremented.
 	 * @param	arg_var_num		the input number
 	 * @param	val_str			the modifier
 	 * @return	the resulting number
	 * @example	modify_val(5,"+1") returns 6
	 * @example	modify_val(2,"-3") returns -1
	 * @example	modify_val(1,"8") returns 8
	 * @example	modify_val(2,"8") returns 8
     */
    function modify_val(arg_var_num:Number,val_str:String):Number
    {// val_str peut etre relative (avec +/- devant la valeur) ou absolue
        var var_num:Number=Number(arg_var_num);// result variable 
        if (val_str && val_str!="")
        {
            if (val_str.indexOf("+")==0 || val_str.indexOf("-")==0)
                var_num+=parseInt(val_str);
            else 
                var_num=parseInt(val_str);
        }
        return var_num;
    }    
    /////////////////////////////////////////////////
    // COMMANDS
	// in these methods, "this" is the source object
    /////////////////////////////////////////////////
	/**
	 * Open a URL.
	 * @param url_str		the url to be opened
	 * @param target_str		[optional] targeted window ("_blank","_self",...)
	 * @example				openUrl:http://silex.tv
	 * @example				openUrl:http://silex.tv,_self
	 * @example				openUrl:./install/,_self
    */
    function openUrl(url_str:String,target_str:String){
        if (!target_str) target_str="_blank";
        _root.getURL(url_str,target_str);
    }    
	
    /**
	 * Open a URL
	 * @param url_str		url beginning with '//' since because the command is http:+arguments
	 * @param target_str		[optional] targeted window ("_blank","_self",...)
	 * @example				http://silex.tv
	 * @example				http://silex.tv,_self
    */
    function http(url_str:String,target_str:String){
        if (!target_str) target_str="_blank";
        _root.getURL("http:"+url_str,target_str);
    }    

    /**
	 * Open a programm to write an email to the specified adress.
	 * @param	adress_str	mail adress
	 * @example	mailto:contact@silex.tv
    */
    function mailto(adress_str:String, subject_str : String, body_str : String){
		var loadVars = new LoadVars();
		if(subject_str != undefined)
		{
			loadVars.subject = subject_str;
		}
		
		if(body_str != undefined)
		{
			loadVars.body = body_str;
		}
        _root.getURL("mailto:"+adress_str + "?" + loadVars.toString(),"_self");
    }    

    /**
	 * Open the browser download dialog box.
	 * @param	initialFileName_str	initial file name
	 * @param	finalFileName_str	[optional] final file name
	 * @example	download:PJ.doc
	 * @example	download:cv2008.doc,alexandre_hoyau_cv.doc
    */
    function download(initialFileName_str:String,finalFileName_str:String, forceDownload : String){
		
		// **
		// downloads media from the content root
       /* YES : 
       var tmp_str:String="_blank";
       if(extract_array[2]) tmp_str=extract_array[2];
       getURL(extract_array[1],tmp_str);
       */ 

		// **
		// ouverture de la fenetre "voulez vous ouvrir ou enregistrer ce fichier" seulement
		
		// retrieve final name from initial name if needed
        if(!finalFileName_str) 
            finalFileName_str=initialFileName_str.slice(initialFileName_str.lastIndexOf("/")+1);

		// start the download
        var tmp_lv:LoadVars=new LoadVars;
        tmp_lv.initial_name=initialFileName_str;
        tmp_lv.final_name=finalFileName_str;
		if(forceDownload=="false")
			tmp_lv.force_download="false";
		else
			tmp_lv.force_download="true";
        
		if(forceDownload=="false")
		{
			tmp_lv.send(_global.getSilex().config.SCRIPT_DOWNLOAD,"_blank","GET");
		} else
		{
       		tmp_lv.send(_global.getSilex().config.SCRIPT_DOWNLOAD,"downloadFrame","GET");
		}
    }// download(extract_array:Array,source_mc);

    /**
	 * Execute a javascript command.
	 * @param	parameters	javascript instructions
	 * @example	javascript:alert("test");
    */
    function javascript(){
        _global.getSilex(this).com.jsCall(arguments.join(","));
    }
    /**
	 * Set a variable value
	 * @param propertyName_str		name of the property to modify - this can be a path
	 * @param value_str			boolean, number or string - value for the property (number may use +/- for relative or exact value)
	 * @example        set:_x,-15
	 * @example        intro_mc.set:_height,+15
	 * @example        _parent.set:_rotation,15
	 * @example        premier_enfant_mc.objPage_mc.objPage_mc.set:_rotation,+15
	 * @example        silex.set:fscom_support_bool_str,true
	 */
    function set(propertyName_str:String,value_str){
		// find the movie clip corresponding to targetObjectPath_str
		//var source_mc:Object=_global.getSilex(this).interpreter.updateSource(this,targetObjectPath_str);
		var source_mc:Object=this;
		var propertyType_str:String = typeof(source_mc[propertyName_str]);
			
		/*
		// guess the property type if needed
		if (propertyType_str == undefined)
		{
			if (parseInt(value_str).toString() == value_str.toString())
				propertyType_str = "number";
			else propertyType_str = "string";
			
		}*/

		switch (propertyType_str){
			case "number":
				source_mc[propertyName_str]=_global.getSilex(this).interpreter.modify_val(source_mc[propertyName_str],value_str);
				break;
			case "boolean":
				source_mc[propertyName_str]=(value_str.toLowerCase()=="true");
				break;
			case "string":
				// remove propertyName_str from arguments
				var temp_array:Array=arguments;
				temp_array.shift();
				// aply new value
				source_mc[propertyName_str]=temp_array.join(","); 
				break;
			default:
				source_mc[propertyName_str] = value_str;
		}
    }
    /** 
	 * Delete a variable.
	 * @param propertyName_str		name of the property to modify
	 * @example							silex.dbdata_obj.del:customer_array (<=> logout)
	 */
    function del(propertyName_str:String)
    {
		// find the movie clip corresponding to targetObjectPath_str
		//var source_mc:Object=_global.getSilex(this).interpreter.updateSource(this,targetObjectPath_str);
		var source_mc:Object=this;

		delete source_mc[propertyName_str];
    }
    /**
	 * Show a clip or a player.
	 * @param targetObjectPath_str	path to the object which contains the property to modify
	 * @example        show:aaa
	 * @example        aaa.show
	 */
    function show(targetObjectPath_str:String)
    {
		var source_mc:Object=_global.getSilex(this).interpreter.updateSource(this,targetObjectPath_str);
        source_mc._visible=true;
    }
    /* ---------------------------------------------------------
	 * Method:       hide
	 * @param targetObjectPath_str	path to the object which contains the property to modify
	 * @example        hide:aaa
	 * @example        aaa.hide
	*/
    function hide(targetObjectPath_str:String)
    {
		var source_mc:Object=_global.getSilex(this).interpreter.updateSource(this,targetObjectPath_str);
		source_mc._visible=false;
    }
    /**
	 * Output something in a message box.
	 * @param parameters		text to alert
	 * @example				alert:mon message
	 */
    function alert(){
		_global.getSilex(this).utils.alert(arguments.join(","));
    }
    /** 
	 * Output something at the bottom of the screen.
	 * @param parameters		text to alert
	 * @example				alertSimple:my message
	*/
    function alertSimple(){
		_global.getSilex(this).utils.alertSimple(arguments.join(","));
    }
    /**
     * alertTypeof alerts the type of the argument. Useful for testing.
     * @example		display "object": alertTypeof:<<split:. silex.config.version>>
     */
    function alertTypeof(nouv){
		_global.getSilex().interpreter.exec("alert:type is "+typeof(nouv),this);
	}
	
	/**
	 * load a clip
	 * @param url the url of the clip to load, relative to the silex root url
	 * @param target the target path
	 * @param childName(optional) the name of child to create in the clip found at target path. If not set a random name is found
	 * @example load_clip:plugins,plugins/simple_admin_tool/stage_element.swf
	 * */
	function load_clip(url:String, target:String, childName:String):Void{
		var targetClip:MovieClip = _global.getSilex(this).utils.getTarget(null, target);
		if(!childName || (childName == '')){
			var my_date:Date = new Date();
			childName = "random_" + Math.round(my_date.getTime());
		}
		var child:MovieClip = targetClip[childName]; 
		if(!child){
			child = targetClip.createEmptyMovieClip(childName, targetClip.getNextHighestDepth()); 
		}
		
		var loader:MovieClipLoader = new MovieClipLoader();
		//_global.getSilex(this).utils.alert("load_clip. target : " + target + ", url : " + url + ", targetClip : " + targetClip + ", childName : " + childName);
		loader.loadClip(_global.getSilex(this).rootUrl + url, child);
		
	}
	
	/**
	 * unload a clip
	 * @param target the target path
	 * @example unload_clip:plugins.sceneBorder_mc
     * note: never tested, but should come in handy.
	 * */
	function unload_clip(target:String):Void{
		var targetClip:MovieClip = _global.getSilex(this).utils.getTarget(null, target);
		targetClip.unloadMovie();
		var loader:MovieClipLoader = new MovieClipLoader();
		_global.getSilex(this).utils.alert("unload_clip. target : " + target + ", targetClip : " + targetClip);
		
	}
	
	
    /** 
	 * Sends a component's html text to a script (for printing or send by mail).
	 * @param scriptUrl_str		script url
	 * @param target_str			[optional] target window : _blank (default), _self, or a frame id
	 * @param isHtml_str			[optional] boolean: true (default) or false (= raw text only)
	 * @param params_str			[optional] parameters to pass to the script (url style)
	 * @param usePostMethod_str	[optional] method used to send data: true => POST (default) or false => GET
	 * @example					onRelease declared_name.send_text:php/sendMail.php,,to=lex@silex.tv&from=lex@silex.tv&title=test
	 * @example					onRelease Text1.send_text:cgi/scripts/log_command.php,,,logFileName=test001.txt
	 * @example					onRelease Text1.send_text:cgi/scripts/print.php
	*/
    function send_text(scriptUrl_str:String,target_str:String,isHtml_str:String,params_str:String,usePostMethod_str:String)
    {
		// get the source object
		//var source_mc:Object=_global.getSilex(this).interpreter.updateSource(this,targetObjectPath_str);
		var source_mc:Object=this;

		// retrieve the text to send
		var htmlText_str:String=source_mc.htmlText;
		
		// default target
		if (!target_str) target_str="_blank"

		// html text or raw text
		var isHtml:Boolean=(isHtml_str.toLowerCase()=="true");
		if (!isHtml) htmlText_str=_global.getSilex(this).utils.getRawTextFromHtml(htmlText_str);
		
		// use post or get
		var postOrGet_str:String="POST";
		if (usePostMethod_str.toLowerCase()=="false") postOrGet_str="GET";

		// build object with text and parameters
		var tmp_lv:LoadVars=new LoadVars;
		tmp_lv.onData(params_str);
		tmp_lv.htmlText_str=escape(htmlText_str);

		// send the text and params
        tmp_lv.send(scriptUrl_str,target_str,postOrGet_str)
	}
	
	/**
	* Prints the specified zone of the specified MovieClip
	* zone should be of type {x: Number, y: Number, width: Number, height: Number}
	* Note that coordinates should be given in FLASH coordinates, not SILEX ones.
	*/
	function print(mc: MovieClip, zone: Object)
	{
		var pj = new PrintJob();

		pj.start();
		
		//Calculate scales that would be needed for each dimensiosn (<1 means we need to reduce)
		var xNeededScale = pj.pageWidth / zone.width;
		var yNeededScale = pj.pageHeight / zone.height;
		
		//Select the scale that requires the biggest deformation and ONLY if it's down-sizing.
		if(xNeededScale < 1 && xNeededScale <= yNeededScale)
		{
			mc._xscale = mc._yscale = xNeededScale * 100; //MC scales are based on 100
		} else if(yNeededScale < 1 && yNeededScale < xNeededScale)
		{
			mc._xscale = mc._yscale = yNeededScale * 100; //MC scales are based on 100
		}
		if(pj.addPage(mc, {xMin: zone.x, xMax: zone.width + zone.x, yMin: zone.y, yMax: zone.height + zone.y}, {printAsBitmap:true}) == false)
		{
			silex_ptr.interpreter.alert("Error. Could not add page to print.");
			return;
		}
		if(pj.send() == false)
		{
			silex_ptr.interpreter.alert("Error. Unable to send print job to printer.");
			return;			
		}
	}
	
	/** 
	 * Open the browser print dialog.
	 * !!! Works only with one page long text... 
	 * For several pages use : onRelease Text1.send_text:cgi/scripts/print.php.
	 * Print the content of a text field.
	 * @param textField			text field name
	 * @param useHtml			[optional] keep formatting - default = true
	 * @param useBgColor			[optional] print on bg color - default = true
	*/
	function printText(textField,useHtml,useBgColor){
		if (arguments.length>0) {

			var containerToPrint:MovieClip=_root.createEmptyMovieClip("containerToPrint",_root.getNextHighestDepth());
			containerToPrint._x=-50000;
			containerToPrint.createTextField("_tf",100,0,0,100,100);
			containerToPrint._tf.type = "dynamic";
			containerToPrint._tf.wordWrap=true;
			containerToPrint._tf.html=true;
			containerToPrint._tf.multiline=true;
	
			//for (var idx:Number=0;idx<arguments.length;idx++)
			{
				//var source_mc:Object=_global.getSilex(this).utils.getTarget(this,arguments[idx]);
				var source_mc:Object=_global.getSilex(this).utils.getTarget(this,textField);
				if (source_mc.htmlText){
					if (useHtml=="false") 
						containerToPrint._tf.htmlText=_global.getSilex(this).utils.getRawTextFromHtml(source_mc.htmlText);
					else
						containerToPrint._tf.htmlText=source_mc.htmlText;
					//containerToPrint._tf.htmlText+=source_mc.htmlText+"<br>";
				}
			}
							
			// create PrintJob object
			var _pj:PrintJob = new PrintJob();

			// display print dialog box, but only initiate the print job
			// if start returns successfully.
			if (_pj.start()) {
				// set correct dimentions
				if (_pj.orientation == "portrait"){
					containerToPrint._tf.autoSize="left";
					containerToPrint._tf._width=600;
				}
				else{
					containerToPrint._tf.autoSize="top";
					containerToPrint._tf._height=600;
				}
				
				// set background
				if (useBgColor!="false"){
					//var w:Number=containerToPrint._tf._width;
					//var h:Number=containerToPrint._tf._height;
					var w:Number=_pj.pageWidth;
					var h:Number=_pj.pageHeight;
					
					var square_mc:MovieClip=containerToPrint.createEmptyMovieClip("square_mc", 0);
					square_mc.beginFill(parseInt(_global.getSilex().config.bgColor,16));
					square_mc.moveTo(0, 0);
					square_mc.lineTo(w, 0);
					square_mc.lineTo(w, h);
					square_mc.lineTo(0, h);
					square_mc.lineTo(0, 0);
					square_mc.endFill();
				}
				
				// add specified area to print job
			    // repeat once for each page to be printed
			    _pj.addPage(containerToPrint);
				
			    // send pages from the spooler to the printer, but only if one or more
			    // calls to addPage() was successful. You should always check for successful 
			    // calls to start() and addPage() before calling send().
				_pj.send();  // print page(s)
			}
			delete _pj;
			_root.removeMovieClip(containerToPrint);
		}
	}
	
    /**
	 * Logs a message on the server - use cgi/scripts/log_command.php.
	 * @param logFileName_str			lof file's name
	 * @param message_str			message to be logged
	 * @example					onRelease log:test001.txt,test message
	 * @example					onRelease Text1.log:test001.txt
	 */
    function log(logFileName_str:String,message_str:String)
    {
		// get the source object
		//var source_mc:Object=_global.getSilex(this).interpreter.updateSource(this,targetObjectPath_str);
		var source_mc:Object=this;

		// retrieve the text to send
		var htmlText_str:String="";
		if (source_mc.htmlText)
			htmlText_str+=source_mc.htmlText;
		if (message_str)
			htmlText_str+=message_str;
		
		// html text or raw text
		// htmlText_str=_global.getSilex(this).utils.getRawTextFromHtml(htmlText_str);
		
		// use post or get
		var postOrGet_str:String="POST";
		//if (usePostMethod_str.toLowerCase()=="false") postOrGet_str="GET";

		// build object with text and parameters
		var tmp_lv:LoadVars=new LoadVars;
		tmp_lv.logFileName=logFileName_str;
		tmp_lv.htmlText_str=escape(htmlText_str);
		
		// send the text and params
		tmp_lv.onLoad=function(success:Boolean){
			if (!success || this.result!="done"){
				_global.getSilex().utils.alert(_global.getSilex().utils.revealAccessors(_global.getSilex().config.SCRIPT_ERROR,{file:_global.getSilex().constants.SCRIPT_LOG,message:this.result}));
			}
		};
        // tmp_lv.send(_global.getSilex(this).constants.SCRIPT_LOG,"_blank",postOrGet_str)
        //tmp_lv.sendAndLoad("uuu",tmp_lv,postOrGet_str)
        tmp_lv.sendAndLoad(_global.getSilex(this).constants.SCRIPT_LOG,tmp_lv,postOrGet_str)
	}
	/** 
	 * close current website and open an other website on the same server
	 */
	function openWebsite(id_site:String){
		id_site=_global.getSilex(this).utils.cleanID(id_site);
		_global.getSilex(this).application.openWebsite(id_site);
	}
	/**
	 * Open an internal link.
	 * @param sectionName_str	section name 
	 * @example				open:test section - open relative path in child
	 * @example				open:/start/section/page - open absolute path
	 */
	function open(sectionName_str:String){
		// clean section
		sectionName_str=_global.getSilex(this).utils.cleanID(sectionName_str);
		
		// relative path <=> do not begin with a '/' or a start
		if (sectionName_str.indexOf("/")!=0 && sectionName_str.indexOf(_global.getSilex(this).config.CONFIG_START_SECTION)!=0){
			var layout/*:org.silex.core.Layout*/=_global.getSilex(this).application.getLayout(this);
			sectionName_str=_global.getSilex(this).deeplink.getLayoutPath(layout)+"/"+sectionName_str;
		}

		if (sectionName_str.indexOf("/")==0) sectionName_str=sectionName_str.substr(1);
		_global.getSilex(this).deeplink.setHash(sectionName_str);
		_global.getSilex(this).deeplink.currentPath=sectionName_str;
		// layout file
		/*
		var layout:org.silex.core.Layout=silex_ptr.application.getLayout(source_mc);
		var layoutFileName_str:String=extract_array[2];
		if (!layoutFileName_str) layoutFileName_str=layout.layoutFileName;

		silex_ptr.application.openSection(sectionName_str,layoutFileName_str,targetLayout);
		*/
	}
    /**
	 * Close the layout opened by calling mc.
	 * @example	monclip.close
	 */
	function close(){
		var layout/*:org.silex.core.Layout*/=_global.getSilex(this).application.getLayout(this);
		layout.closeChild();
		//var parentLayout:org.silex.core.Layout=_global.getSilex(this).application.getLayout(layout._parent._parent);
		//parentLayout.closeChild();
	}
	//////////////////////////////////////////////////////////////////////////////////////
	// Cyber e stats (www.estat.com/)
	//////////////////////////////////////////////////////////////////////////////////////
    /**
	 * Configures the tag system to prepare tag command calls.
	 * Used for cyberestat statistics logs.
	 * @param serial_str	serial (client id) - number
	 * @param class_str		class (website id) - string
	 * @example				tag_config:08637,france5_education_judaisme
	 * @example				tag_config:08637,france5_lesite_lesjustes
	 */
    function tag_config(serial_str:String,class_str:String){
		if (!_root.tag_mc){
			_root.createEmptyMovieClip("tag_mc",_root.getNextHighestDepth());
			_root.tag_mc.createEmptyMovieClip("container_mc",_root.tag_mc.getNextHighestDepth());
		}
		_root.tag_mc.serial_str=serial_str;
		_root.tag_mc.class_str=class_str;
	}
    /**
	 * Call the cyberestat tag system (of mediametrie estat).
	 * @param pageName_str	page name
	 * @example					tag:rubrique1
	 */
    function tag(pageName_str:String){
		var rnd_num:Number=random(100000);
		if (!_root.tag_mc){
			return;
		}
		var page_str:String=_root.tag_mc.class_str+"_"+pageName_str;
		var url_str:String="http://prof.estat.com/cgi-bin/swf/"+_root.tag_mc.serial_str+"?n="+rnd_num+"&page="+page_str+"&class="+_root.tag_mc.class_str;
		_root.tag_mc.container_mc.loadMovie(url_str);
	}
	
    /**
	 * Convert an array or elements of an array or object to a string.
	 * @param	separator		what to put between elements. ex: ","
	 * @param	subElementName	[optional] path to the sub-element in each array element. The function works a like Array.join if this parameter is not given
	 */
    function flatten(separator:String, subElementName:String):String{
		var ret:String = "";
		for(var key in this){
			var element = this[key];
			var part:String = null;
			if(subElementName != undefined){
				part = element[subElementName].toString();
			}else{
				part = element.toString();
			}
			if(part != undefined){
				ret += separator + part;
			}
		}
		if(ret.length > 0){ 
			//remove first separator
			ret = ret.substr(separator.length);
		}
		
		return ret;
	}
	
    /**
	 * Call a webservice and returns the result
	 * The result is placed in <<silex.lastResult>> - either fault object (use lastResult.faultstring) or service call result
	 * and the specified success or error event is thrown
	 * @param	serviceName_str
	 * @param	successEvent	event thrown after a successfull call
	 * @param	errorEvent		event thrown on an error
	 * @param	other params	passed to the webservice
	 * @example					onRelease serviceCall:duplicate,onDuplicateSuccess,onDuplicateFailed,default,duplicatedDefault
	 * @example					onDuplicateSuccess alert:onDuplicateSuccess
	 * @example					onDuplicateFailed alert:onDuplicateFailed
	 */
    function serviceCall(serviceName_str:String, successEvent:String, errorEvent:String)
	{
		// remove serviceName_str, successEvent and errorEvent from the arguments list
		arguments.splice(0, 3);
		// store the arguments for the call
		var callArgumentsArray:Array = arguments;
		
		// pointer to silex API
		var silex_ptr=_global.getSilex(this);
		
		
		// build a call object
		var responder_obj:Object = new Object;
		// success callback
		responder_obj.onResult=function(re){
			this.callback(re,this.successEvent);
		};
		// error callback
		responder_obj.onError=function( fault:Object ){
			// this.silex_ptr.utils.alert(silex_ptr.utils.revealAccessors(silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function 
			this.callback(fault,this.errorEvent);
		};
		// store result and dispatch appropriate event
		responder_obj.callback = function(result,eventType:String)
		{
			this.silex_ptr.lastResult = result;
			if (this.callerObject.dispatch)
			{
				// case of a silex player
				this.callerObject.dispatch( { type:eventType, target:this.callerObject } );
			}
			else
				this.callerObject.dispatchEvent( { type:eventType, target:this.callerObject } );
		};
		responder_obj.silex_ptr = silex_ptr;
		responder_obj.callerObject = this;
		responder_obj.successEvent = successEvent;
		responder_obj.errorEvent = errorEvent;

		//var pc:PendingCall = silex_ptr.com.dataExchange_service[serviceName_str].apply(this,callArgumentsArray);
		//pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		
		// build the params in order to call silex_ptr.com.connection.call(silex_ptr.config.DataExchangeServiceName + "." + serviceName_str,responder_obj,...)
		callArgumentsArray.unshift(responder_obj);
		callArgumentsArray.unshift(silex_ptr.config.DataExchangeServiceName + "." + serviceName_str);
		silex_ptr.com.connection.call.apply(silex_ptr.com.connection, callArgumentsArray);
		
    }
	/**
	 * call the service to retrieve silex latest version number
	 * the player which is the source of the call will dispatch an onLatestSilexVersion event
	 */
	public function getLatestSilexVersion()
	{
		_global.getSilex().com.getLatestSilexVersion(Utils.createDelegate(this, function(version:String) { this.silexInstance.config.latestSilexVersion = version; this.dispatch( { type:"onLatestSilexVersion", target:this } ); } ));
	}
}// class Interpreter
    /* ---------------------------------------------------------
	 * Method:       open
	 * @param    extract_array[1]=xml file name without extention, 
	 * @param    extract_array[2]=[optional] "none" or layout url or child layout number, 
	 * @param    extract_array[3]= [optional] Object in which to open the section (self,parent,child),
	 * @example        ouvrir:test,none,child 
	 * @example        open:test,none,child,fiches_
	*/
	// TO DO: use openPage(arg_chemin_str:String,arg_nomFichier_str:String,arg_urlGabarit_str:String,arg_objCible_mc:MovieClip):Boolean
/*    function open(extract_array:Array,source_mc)
    {
		// determine where to open
		// grand parent
        var gab_root_root_gr=silex_ptr.getGabaritRoot(silex_ptr.getGabaritRoot(silex_ptr.getGabaritRoot(source_mc._parent)._parent)._parent).silexGabaritRoot;
		// parent
        var gab_root_gr=silex_ptr.getGabaritRoot(silex_ptr.getGabaritRoot(source_mc._parent)._parent).silexGabaritRoot;
        // self
        var gr=silex_ptr.getGabaritRoot(source_mc._parent).silexGabaritRoot;


		if (silex_ptr.adresse_array.length==0 && gr.get_tab_anims_length()>0)
        {// Ici, on veut lancer une icone alors qu une autre est en cours de lancement. Hors cas de lancement auto a partir de adresse_array
            // blocage pour empecher le bordel...
			if ((extract_array[3] && extract_array[3]!="child") || gr.objPage_mc.silexGabaritRoot)
				return;
        }
		//_root.getURL("applyPathPending_str="+silex_ptr.applyPathPending_str+" - adresse_array="+silex_ptr.adresse_array,"_blank");

		
		// ** MD LEX 230506
		if (!extract_array[2])
		{// set default value
			if (!extract_array[3] || extract_array[3]=="" || extract_array[3]=="self" || extract_array[3]==".")
			{// SELF
				if(gab_root_gr.sufix_gabarits_str) // child layout number 1
					extract_array[2]="1";
			}
			else
				if (extract_array[3]=="parent" || extract_array[3]==".." || extract_array[3]=="../" || extract_array[3]=="precedant")
				{// PARENT

					if(gab_root_root_gr.sufix_gabarits_str) // child layout number 1
						extract_array[2]="1";
				}
				else
				{// CHILD
					if(gr.sufix_gabarits_str) // child layout number 1
						extract_array[2]="1";
				}


			// if still not set, same layout
			if (!extract_array[2])
				extract_array[2]="none"
		}
		// child layout number
		if (parseInt(extract_array[2])>0)
		{
			if (!extract_array[3] || extract_array[3]=="" || extract_array[3]=="self" || extract_array[3]==".")
			{// SELF
				extract_array[2]=gab_root_gr.chemin_gabarits_str+parseInt(extract_array[2])+gab_root_gr.sufix_gabarits_str;
			}
			else
				if (extract_array[3]=="parent" || extract_array[3]==".." || extract_array[3]=="../" || extract_array[3]=="precedant")
				{// PARENT
					extract_array[2]=gab_root_root_gr.chemin_gabarits_str+parseInt(extract_array[2])+gab_root_root_gr.sufix_gabarits_str;
				}
				else
				{// CHILD
					extract_array[2]=gr.chemin_gabarits_str+parseInt(extract_array[2])+gr.sufix_gabarits_str;
				}
		}
		else
			if (extract_array[2]=="none")
			{// url passee en param:extract_array[2]
				// same layout
				extract_array[2]=gr.urlGabarit_str;			
			}
		
        
            if (!extract_array[3] || extract_array[3]=="" || extract_array[3]=="self" || extract_array[3]==".")
            {
                // Dans le meme gabarit
                var temp=new Object;
                temp.chemin_str=gr.chemin_str;
                temp.nomFichier_str=gr.nomFichier_str;
                temp.urlGabarit_str=gr.urlGabarit_str;
                temp.current_topic_id_str=gr.current_topic_id_str;

				if (!gab_root_gr.silex_ouvir_array) gab_root_gr.silex_ouvir_array=new Array; 
                gab_root_gr.silex_ouvir_array.push(temp);
                
                silex_ptr.ouvrir(silex_ptr.premier_enfant_mc.silexGabaritRoot.chemin_str,xmlname_str,extract_array[2],gr._parent,xmlname_str,no_dbdata_bool);
            }
            else 
            {
                if (extract_array[3]=="parent" || extract_array[3]==".." || extract_array[3]=="../" || extract_array[3]=="precedant")
                {
                    // Dans le gabarit parent
                    silex_ptr.ouvrir(silex_ptr.premier_enfant_mc.silexGabaritRoot.chemin_str,xmlname_str,extract_array[2],gab_root_gr._parent,xmlname_str,no_dbdata_bool);
                }
                else 
                {
                    // Dans le gabarit enfant
                    if(gr.objPage_mc && gr.objPage_mc.silexGabaritRoot)
                    {// Pour retour
                        var temp=new Object;
                        temp.chemin_str=gr.objPage_mc.silexGabaritRoot.chemin_str;
                        temp.nomFichier_str=gr.objPage_mc.silexGabaritRoot.nomFichier_str;
                        temp.urlGabarit_str=gr.objPage_mc.silexGabaritRoot.urlGabarit_str;
                        temp.current_topic_id_str=gr.objPage_mc.silexGabaritRoot.current_topic_id_str;

						if (!gr.silex_ouvir_array) gr.silex_ouvir_array=new Array; 
                        gr.silex_ouvir_array.push(temp);
                    }

                    if(!gr.objPage_mc)
                    {
                        gr._parent.createEmptyMovieClip("objPage_mc",gr._parent.getNextHighestDepth());
                        gr.objPage_mc=gr._parent.objPage_mc;
                    }
                    if (extract_array[3]=="child" || extract_array[3]=="enfant" || extract_array[3]=="suivant" || extract_array[3]=="next")
                        silex_ptr.ouvrir(silex_ptr.premier_enfant_mc.silexGabaritRoot.chemin_str,xmlname_str,extract_array[2],gr.objPage_mc,xmlname_str,no_dbdata_bool);
                }
            }
	}*/
	
    /* ---------------------------------------------------------
	 * Method:       open_icone
	 * @param    extract_array[1]= [optional] icone number (default = 1), 
	 * @param    extract_array[2]= [optional] layout level (default = self), 1st layout is number 1, valid values : [1,100]
	 * @example        open_icone:1
	 * @example        open_icone:1,3
    */
/*    function open_icone(extract_array:Array,source_mc)
    {
		var silex_ptr=_global.getSilex(source_mc);
      
		// get the layout root wich contains the icone to open
		var source_gr=silex_ptr.getGabaritRoot(source_mc).silexGabaritRoot;

		if (extract_array[2])
		{
			// get the layout level
			var layout_num:Number=modify_val(source_gr.gabarit_num+1,extract_array[2]);//parseInt(extract_array[2]);
			if (layout_num<=0 || layout_num>100) return;
			
			// go to the designed layout
			var tmp_mc:MovieClip=silex_ptr.premier_enfant_mc;
			for (var idx:Number=1;idx<layout_num;idx++)
			{
				tmp_mc=tmp_mc.silexGabaritRoot.objPage_mc;
			}
			
			// layout root
			if (tmp_mc)
				source_gr=tmp_mc.silexGabaritRoot;
		}

		// default value for icone number
		if (!extract_array[1]) extract_array[1]="1";
				
		// find the icone in icones array
		var icone_mc:MovieClip;
		for (idx in source_gr.tabIcones)
			if (source_gr.tabIcones[idx]._name==source_gr.prefix_icones_str+extract_array[1])
				icone_mc=source_gr.tabIcones[idx];

		// opens the icone
		source_gr.lance_icone(icone_mc);
    }
*/	
    /* ---------------------------------------------------------
	 * Method:       back
	 * @param    extract_array[1]= (+/-)number of times to come back
	 * @param    extract_array[2]= [optional] dbdata (or none)/no_dbdata => do not pass current dbdata_obj to the new page (default=none=pass the dbdata)
	 * @example        back:-5
	 * @example        back:0
    */
/*    function back(extract_array:Array,source_mc)
    {
		var current_index_num:Number=gab_root_gr.silex_ouvir_array.length;
        var new_index_num:Number=-1;
        
        if (_global.getSilex(source_mc).adresse_array.length==0 && _global.getSilex(source_mc).getGabaritRoot(source_mc).silexGabaritRoot.get_tab_anims_length()>0)
        {// Ici, on veut lancer une icone alors qu une autre est en cours de lancement. Hors cas de lancement auto a partir de adresse_array
            // blocage pour empecher le bordel...
            return;
        }
        if (current_index_num<=0)
        {
            return;
        }
        if (extract_array[1])
        {
            if (extract_array[1].indexOf("+")==0 || extract_array[1].indexOf("-")==0)
            {
                new_index_num=current_index_num+parseInt(extract_array[1]);
            }
            else new_index_num=parseInt(extract_array[1]);
            if (new_index_num<0) new_index_num=0;
        }
        // A FAIRE: cas du '+' => avance dans un tableau 'suivant'
        var temp_obj=gab_root_gr.silex_ouvir_array.pop();
        while (new_index_num>-1 && gab_root_gr.silex_ouvir_array.length>new_index_num)
        {
            temp_obj=gab_root_gr.silex_ouvir_array.pop();
        }
		
		var no_dbdata_bool:Boolean=true;
		//if (!extract_array[2] || extract_array[2]=="none" || extract_array[2]=="dbdata")
		if (extract_array[2]=="no_dbdata" || extract_array[2]=="no-dbdata" || extract_array[2]=="nodbdata" || extract_array[2]=="false")
			no_dbdata_bool=false;
			
        _global.getSilex(source_mc).ouvrir(temp_obj.chemin_str,temp_obj.nomFichier_str,temp_obj.urlGabarit_str,_global.getSilex(source_mc).getGabaritRoot(source_mc),temp_obj.current_topic_id_str,no_dbdata_bool);
    }
	*/
