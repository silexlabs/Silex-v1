/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/////////////////////////////////////////////////////////////////
//Decodes a UTF8 formated string
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
}
//it is a private function for internal use in utf8Decode function 
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
}
/////////////////////////////////////////////////////////////////
function cSilex()
{
// called after initialization of its attributes :	this.init();
}
cSilex.prototype._timerID;
cSilex.prototype._currentHashValue;
cSilex.prototype._id_site;
cSilex.prototype._siteTitle;
cSilex.prototype._putIdSiteInHash = true;
cSilex.prototype._startHashWithSlash = true;
cSilex.prototype.firebug=false;//true;

// popup function
cSilex.prototype.pop = function($url,$width,$height,$fullscreen)
{
	$config='toolbar=no, menubar=no, resizable=no, location=no, directories=no, status=no';
	if ($fullscreen == true){
		$config+=", fullscreen=yes";
	}
	else{
		$config+=',height='+$height+', width='+$width;
	}
	//alert($config);
	window.open ($url, null, config=$config);
}

// *************
// functions for Deeplinking
cSilex.prototype.init = function($flashvarsObj,$defaultIdSite,$defaultSectionName,$siteTitle,$forceHashValue,$putIdSiteInHash)
{
	// init hash
	cSilex.prototype._putIdSiteInHash = $putIdSiteInHash;
	cSilex.prototype._forceHashValue = $forceHashValue;
	cSilex.prototype._currentHashValue=getUrlHash();
	cSilex.prototype._timerID = setInterval("cSilex.prototype.checkUrlHash()", 500);

	// get id_site from hash or from params
	cSilex.prototype._id_site=getIdFromHash();
	//trace(cSilex.prototype._id_site+" - "+cSilex.prototype._currentHashValue+" - "+top.location.hash.toString()+" - "+cSilex.prototype._forceHashValue);
	
	// open default website if needed
	if (!cSilex.prototype._id_site || cSilex.prototype._id_site==""){
		cSilex.prototype._id_site=$defaultIdSite;
		setUrlHash($defaultSectionName);
	}
	//alert(cSilex.prototype._id_site+" - "+cSilex.prototype._currentHashValue);
	
	// init tracking
//	cSilex.prototype.phpmyvisitesSiteNumber=""; // for phpMyVisites
//	cSilex.prototype._uacct = ""; // for google analytics
//	cSilex.prototype.CM_CLIENT = ""; // for CyberEstat

	// case of a page linked to a specific page (<=> as if there was a hash value)
	if (cSilex.prototype._currentHashValue=="" && $defaultSectionName) cSilex.prototype._currentHashValue=$defaultSectionName;

	// init silex
	//document.getElementById('silex').SetVariable('silex_exec_str','set_path:'+cSilex.prototype._currentHashValue);
	$flashvarsObj.initialPath = cSilex.prototype._currentHashValue;
	//alert("initialPath = "+cSilex.prototype._currentHashValue);

	/*
	// debug
	//alert("init : "+cSilex.prototype._currentHashValue+"-"+$defaultSectionName);
	document.getElementById("hash_txt").value=cSilex.prototype._currentHashValue;
	/**/
	
	// website title
	if ($siteTitle){
		cSilex.prototype._siteTitle=$siteTitle;
		document.title=cSilex.prototype._siteTitle;
	}
	else
		cSilex.prototype._siteTitle=document.title;

	// tag section
	if (cSilex.prototype._currentHashValue=="") this.tagSection("start");
	else this.tagSection(cSilex.prototype._currentHashValue);


	return cSilex.prototype._id_site;
}
openSilexPage = function($hashValue)
{
	trace('openSilexPage ('+$hashValue+')');
	document.getElementById('silex').SetVariable('silex_exec_str','open:'+$hashValue);
	silexNS.HookManager.callHooks({type:"openSilexPage",hashValue:$hashValue});
}
cSilex.prototype.checkUrlHash = function()
{
	// check site id 
	$id_site=getIdFromHash();
	if ($id_site!=cSilex.prototype._id_site){
		trace("checkUrlHash - "+$id_site+" difers from "+cSilex.prototype._id_site);
		document.getElementById('silex').SetVariable('silex_exec_str','openWebsite:'+$id_site);
		return;
	}
	
	// check deep link
	// removes the # from hash
	$hashValue=getUrlHash();

	if (this._currentHashValue!=$hashValue && $hashValue)
	{
		// sends the new path to silex
		/**/
		//trace("checkUrlHash open silex page: "+this._currentHashValue+"!="+$hashValue);
		openSilexPage($hashValue);
		//document.getElementById('silex').SetVariable('silex_exec_str','open:'+$hashValue);
		/*
		// Debug
		document.getElementById("hash_txt").value=$hashValue;
		/**/

		this._currentHashValue=$hashValue;
		
		// opens history.swf
		//document.getElementById("ascom").location='history.php?targetPath_str='+$hashValue;
		//document.getElementById("ascom").innerHTML="<IFRAME SRC='history.php?targetPath_str="+$hashValue+"' width=100% height=100% />";
	}
}
// called by org.silex.core.deeplink::changeWebsite (after org.silex.core.interpreter::openWebsite for example)
cSilex.prototype.changeWebsite = function($id_site){
	//alert ("changeWebsite "+cSilex.prototype._id_site+" -> "+$id_site);
	cSilex.prototype._id_site=$id_site;
	setUrlHash("");
}
// called by silex when an icone is pressed
cSilex.prototype.changeSection = function($sectionName,$pageTitle)
{
	//trace("changeSection "+$sectionName+" - "+$pageTitle);
	if (this._currentHashValue!=$sectionName)
	{
		/**/
		// Debug
		//trace("changeSection "+this._currentHashValue+"!="+$sectionName);
		/**/

		//unFocus.History.addHistory($sectionName);

		// Modify the url
		this._currentHashValue=$sectionName; // set _currentHashValue so that this change is not detected by checkUrlHash
		setUrlHash($sectionName);

		// tag
		this.tagSection($sectionName);
	}

	// website title
	$sep=" \u2022 ";
	if (this._siteTitle && this._siteTitle!="")
		$title=this._siteTitle;
	else
		$title = cSilex.prototype._id_site;
		
	if ($pageTitle)
		document.title=utf8Decode($pageTitle)+$sep+$title;
	else
		document.title=$sectionName+$sep+$title;
}
cSilex.prototype.tagSection = function($sectionName)
{
	silexNS.HookManager.callHooks({type:"tagSection",sectionName:$sectionName});

	//trace("fenetre de debugage - tagSection "+$sectionName);
	// loads stats frame
/*	if (this.phpmyvisitesSiteNumber && this.phpmyvisitesSiteNumber!="")
	{
		//alert("tag with phpMyVisites : "+this.phpmyvisitesSiteNumber+" - "+this.phpmyvisitesURL+" - "+$sectionName);
		pmv_log(this.phpmyvisitesSiteNumber, this.phpmyvisitesURL, cSilex.prototype._id_site+"/"+$sectionName, Array());
	}
	// call google analytics script
	if (this._uacct && this._uacct!="")
	{
		//alert("urchinTracker("+$sectionName+")");
		//trace("urchinTracker("+$sectionName+")");
		_uacct = this._uacct;
		urchinTracker(cSilex.prototype._id_site+"/"+$sectionName);
		//alert("fenetre de debugage - tagSection google anal "+$sectionName+" - "+this._uacct);
	}
	// CyberEstat
	if (this.CM_CLIENT && this.CM_CLIENT!="")
	{
		$sectionName=$sectionName.replace(/-/g,"");
		this.logCyberEstat(cSilex.prototype._id_site+"/"+$sectionName);
	}
*/
}
cSilex.prototype.tagCurrentSection = function()
{
	this.tagSection(getUrlHash());
}

// ************
function WriteLayer(ID,parentID,sText) 
{// marche pour div like : 		<div id="googleAnalFrame" name="googleAnalFrame" />
	 if (document.layers) {
	   var oLayer;
	   if(parentID){
	     oLayer = eval('document.' + parentID + '.document.' + ID + '.document');
	   }else{
	     oLayer = document.layers[ID].document;
	   }
	   oLayer.open();
	   oLayer.write(sText);
	   oLayer.close();
	 }
	 else if (parseInt(navigator.appVersion)>=5 && navigator.appName=="Netscape") {
	   document.getElementById(ID).innerHTML = sText;
	 }
	 else if (document.all) document.all[ID].innerHTML = sText
}
// include function does not work in IE
function include(fileName) 
{
    if (document.getElementsByTagName) {
        Script = document.createElement("script");
        Script.type = "text/javascript";
        Script.src = fileName;
        Body = document.getElementsByTagName("BODY");
        if (Body) {
            Body[0].appendChild(Script);
        }
    }
}
// *******************
// code for google analytics
/*
cSilex.prototype.setTrackingCode=function(uacct)
{
	// 		<script type="text/javascript" src="http://www.google-analytics.com/urchin.js"></script>
	// 		<div id="googleAnalFrame" name="googleAnalFrame"></div>
	// does not work in IE : include("http://www.google-analytics.com/urchin.js");
	// WriteLayer("googleAnalFrame","",'<script src="http://www.google-analytics.com/urchin.js" type="text/javascript"></script>');
	this._uacct=uacct;
	_uacct=uacct;
}
*/
//********************
// functions for phpMyVisite
/*
cSilex.prototype.setPhpmyvisites = function($phpmyvisitesURL,$phpmyvisitesSiteNumber)
{
	this.phpmyvisitesSiteNumber=$phpmyvisitesSiteNumber;
	this.phpmyvisitesURL=$phpmyvisitesURL;
	//alert("setPhpmyvisites "+$phpmyvisitesURL+" - "+$phpmyvisitesSiteNumber);
	//	include($phpmyvisitesURL+"silex_phpmyvisites.js");
	//cSilex.prototype.phpmyvisitesSiteNumber=$phpmyvisitesSiteNumber;
}
// http://www.phpmyvisites.net/ 
// License GNU/GPL (http://www.gnu.org/copyleft/gpl.html)
function pmv_log(pmv_site, pmv_url, pmv_pname, pmv_vars)
{
	function plugMoz(pmv_pl) {
		if (pmv_tm.indexOf(pmv_pl) != -1 && (navigator.mimeTypes[pmv_pl].enabledPlugin != null))
			return '1';
		return '0';
	}
	function plugIE(pmv_plug){
		pmv_find = false;
		//document.write('<SCR' + 'IPT LANGUAGE=VBScript>\n on error resume next \n pmv_find = IsObject(CreateObject("' + pmv_plug + '"))</SCR' + 'IPT>\n');
		WriteLayer("stats","",'<SCR' + 'IPT LANGUAGE=VBScript>\n on error resume next \n pmv_find = IsObject(CreateObject("' + pmv_plug + '"))</SCR' + 'IPT>\n');
		if (pmv_find) return '1';
		return '0';
	}
	var pmv_jav='0'; if(navigator.javaEnabled()) pmv_jav='1';
	var pmv_agent = navigator.userAgent.toLowerCase();
	var pmv_moz = (navigator.appName.indexOf("Netscape") != -1);
	var pmv_ie= (pmv_agent.indexOf("msie") != -1);
	var pmv_win = ((pmv_agent.indexOf("win") != -1) || (pmv_agent.indexOf("32bit") != -1));
	
	if (!pmv_win || pmv_moz){
		pmv_tm = '';
		for (var i=0; i < navigator.mimeTypes.length; i++)
			pmv_tm += navigator.mimeTypes[i].type.toLowerCase();
		var pmv_dir = plugMoz("application/x-director");
		var pmv_fla = plugMoz("application/x-shockwave-flash");
		var pmv_pdf = plugMoz("application/pdf");
		var pmv_qt = plugMoz("video/quicktime");
		var pmv_rea = plugMoz("audio/x-pn-realaudio-plugin");
		var pmv_wma = plugMoz("application/x-mplayer2");
	} else if (pmv_win && pmv_ie){
		var pmv_dir = plugIE("SWCtl.SWCtl.1");
		var pmv_fla = plugIE("ShockwaveFlash.ShockwaveFlash.1");
		var pmv_pdf = '0'; 
		if (plugIE("PDF.PdfCtrl.1") == '1' || plugIE('PDF.PdfCtrl.5') == '1' || plugIE('PDF.PdfCtrl.6') == '1') 
			pmv_pdf = '1';
		var pmv_qt = plugIE("QuickTimeCheckObject.QuickTimeCheck.1");
		var pmv_rea = plugIE("rmocx.RealPlayer G2 Control.1");
		var pmv_wma = plugIE("MediaPlayer.MediaPlayer.1");
	}
	
	var getvars='';
	for (var i in pmv_vars){
		if (!Array.prototype[i]){
			getvars = getvars + '&a_vars['+ escape(i) + ']' + "=" + escape(pmv_vars[i]);
		}
	}
	pmv_do = document; 
	pmv_da = new Date();
	try {rtu = top.pmv_do.referrer;} catch(e) {
		try {rtu = pmv_do.referrer;} catch(E) {rtu = '';}
	}
	
	src = pmv_url;
	src += '?url='+escape(pmv_do.location)+'&pagename='+escape(pmv_pname)+getvars;
	src += '&id='+pmv_site+'&res='+screen.width+'x'+screen.height+'&col='+screen.colorDepth;
	src += '&h='+pmv_da.getHours()+'&m='+pmv_da.getMinutes()+'&s='+pmv_da.getSeconds();
	src += '&flash='+pmv_fla+'&director='+pmv_dir+'&quicktime='+pmv_qt+'&realplayer='+pmv_rea;
	src += '&pdf='+pmv_pdf+'&windowsmedia='+pmv_wma+'&java='+pmv_jav+'&ref='+escape(rtu);

	//pmv_do.writeln('<img src="'+src+'" alt="phpMyVisites" style="border:0" />');
	WriteLayer("stats","",'<img src="'+src+'" alt="phpMyVisites" style="border:0" />');
}*/
// pmv_log(phpmyvisitesSiteNumber, phpmyvisitesURL, pagename, a_vars);

// *********************
// CyberEstat
/*
cSilex.prototype.logCyberEstat=function($sectionName)
{
//	var _str='<script language="javascript">CM_CLIENT = "'+this.CM_CLIENT+'";CM_SECTION1 = "'+this.CM_SECTION1+'";CM_RUBRIQUE = "'+this.CM_SECTION1+'_'+$sectionName+'";alert("CyberEstat in the frame");</script><script language="javascript" src="http://js.cybermonitor.com/france5.js"></script>';
//	var _str='<img src="http://forum.telecharger.01net.com/data/globaldata/avatars/119178.gif" />';
	var _str='<img src="http://stat3.cybermonitor.com/'+this.CM_CLIENT+'_v?R='+this.CM_SECTION1+'_'+$sectionName+'&S=total;'+this.CM_SECTION1+'">';
	//trace("CyberEstat : "+_str);
	WriteLayer("CyberEstat","",_str);
}
*/
// get/set hash value
// in safari it does not contains the #
function setUrlHash($sectionName)
{
	//trace('setUrlHash ( '+$sectionName+' )');
	$sectionName = escape($sectionName);
	
	
	// from "start/b" to "aaa/start/b"
	if(cSilex.prototype._putIdSiteInHash==true){
		$sectionName=cSilex.prototype._id_site+"/"+$sectionName;
	}
	
	// from "aaa/start/b" to "/aaa/start/b"
	if(cSilex.prototype._startHashWithSlash==true && $sectionName.indexOf("/")!=0){
		$sectionName="/"+$sectionName;
	}

	// detect if browser = safari then don't add the '#'
	try
	{
		if (navigator.userAgent.toLowerCase().indexOf('safari') != -1)
			top.location.hash=$sectionName;
		else
			top.location.hash="#"+$sectionName;
	}
	catch($e)
	{
		// no access to url hash
		trace('setUrlHash('+$sectionName+') ERROR: '+$e);
		cSilex.prototype._forceHashValue = $sectionName;
	}
}
// hash = from 1st slash to end (but not trailing slash)
function getUrlHash()
{
	if (cSilex.prototype._forceHashValue)
		return cSilex.prototype._forceHashValue;
		
	var $res;
	// retrieve hash value from url 
	try
	{
		$res = (top.location.hash.toString());
	}
	catch($e)
	{
		// no access to url hash
		//alert($e);
		$res="";
	}
		
	// detect if browser = safari then don't remove the '#'
	//if (navigator.userAgent.indexOf('Safari') == -1)
	if ($res.indexOf("#") == 0)
		$res=$res.substring(1);
	
	// remove trailing "/"
	if ($res.lastIndexOf("/")==$res.length-1)
		$res=$res.substring(0,$res.length-1);

	// eventually remove the starting slash
	if ($res.indexOf("/")==0)
		$res=$res.substring(1);

	// if only id_site and no hash, adss a slash after id_site
	if ($res.indexOf("/")==-1)
		$res=$res+"/";

	if (cSilex.prototype._putIdSiteInHash==true){
		// from "aaa/start/b" to "start/b"
		$res=$res.substring($res.indexOf("/")+1);
	}

//	trace('getUrlHash returns '+$res);
	// return
	return unescape($res);
}
// id_site = from start to 1st slash
function getIdFromHash()
{
	var $res;
	
	if(cSilex.prototype._putIdSiteInHash==false && cSilex.prototype._id_site){
		//trace('getIdFromHash returns '+cSilex.prototype._id_site);
		return cSilex.prototype._id_site;
	}

	// retrieve hash value from url or from parameter
	if (cSilex.prototype._forceHashValue)
		return cSilex.prototype._forceHashValue;

	try
	{
		$res = top.location.hash.toString();
	}
	catch($e)
	{
		// no access to url hash
		//alert($e);
		$res="";
	}

	// detect if browser = safari then don't remove the '#'
	//if (navigator.userAgent.indexOf('Safari') == -1)
	if ($res.indexOf("#") == 0)
		$res=$res.substring(1);

	// if only id_site and no hash, ads a slash after id_site
	if ($res.indexOf("/")==-1)
		$res=$res+"/";
		
	// eventually remove the starting slash
	if ($res.indexOf("/")==0)
		$res=$res.substring(0,1);
	
	// from "aaa/start/b" to "aaa"
	$res=$res.substring(0,$res.indexOf("/"));

	// return
	return $res;
}

// *******************
function trace(aMessage) 
{
//  var consoleService = Components.classes["@mozilla.org/consoleservice;1"].getService(Components.interfaces.nsIConsoleService);
//  consoleService.logStringMessage("SILEX - " + aMessage);
//	Components.utils.reportError("SILEX - " + aMessage);
	// window.dump("SILEX - " + aMessage);
	// toJavaScriptConsole();
	//alert("SILEX - " + aMessage);
	if(cSilex.prototype.firebug==true)
		console.log(aMessage);
}
