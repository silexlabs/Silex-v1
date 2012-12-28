/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.html;

import haxe.Template;
import org.silex.serverApi.ServerConfig;
import php.io.File;
import php.Lib;
import org.silex.serverApi.SiteEditor;
import org.silex.serverApi.helpers.Env;
import org.silex.serverApi.RootDir;
import org.silex.serverApi.ServerContent;
import org.silex.serverApi.PluginManager;
import org.silex.serverApi.HookManager;
import org.silex.serverApi.ConfigEditor;
import org.silex.serverApi.FileSystemTools;
import org.silex.serverApi.FileSystemItem;
import org.silex.serverApi.Logger;

import php.Web;
import php.FileSystem;

using org.silex.filters.FilterManager;
using org.silex.hooks.HookManager;

// needed for saving & reading seo v2 format
// removed as creates errors when called from /cgi/includes/site_editor.php
//import org.silex.core.seo.Utils;

@appliedFilters(["template-index-head", "template-index-body", "template-index-footer", "template-context"])
class SilexIndex
{
	static var idSite : String = "";
	static var deeplink : String = "";
	
	static var serverConfig : ServerConfig;
	static var siteEditor : SiteEditor;
	static var serverContent : ServerContent;
	static var pluginManager : PluginManager;
	static var hookManager : HookManager;
	static var configEditor : ConfigEditor;
	static var fileSystemTools : FileSystemTools;
	
	static var flashVars = new Hash<String>();
	static var flashParam = new Hash<String>();
	
	//Pathes to templates
	//static var pathToMainTemplate = "templates/index/doMain.html";
	static var pathToTemplateHead = "templates/index/head.html";
	static var pathToTemplateBody = "templates/index/body.html";
	static var pathToTemplateFooter = "templates/index/footer.html";
	static var pathToRedirectToInstaller = "templates/index/redirectInstaller.html";
	static var pathToNotFoundIsNotFound = "templates/index/notFoundIsNotFound.html";

	public static var silexApiJsScriptFolderUrl : String;
	
	//preloadFileListConf
	public static var websitePreloadFileList : String;

	//Fonts
	public static var websiteFonts : String;
	
	public static function main(): Void
	{
		//Lib.print(RootDir.rootUrl);
		Env.setIncludePath(Env.getIncludePath() + Env.pathSeparator + RootDir.rootPath);
		Env.setIncludePath(Env.getIncludePath() + Env.pathSeparator + RootDir.rootPath + "cgi/library");
		Env.setIncludePath(Env.getIncludePath() + Env.pathSeparator + RootDir.rootPath + "cgi/includes");

		//Some needed includes
		untyped __call__("require_once", 'cgi/includes/ComponentManager.php');
		untyped __call__("require_once", 'cgi/includes/ComponentDescriptor.php');
		
		var isDefaultWebsite = false;
		var doRedirect = false;
		var url : String;
		var deeplink : String = "";
		var idSite : String;
		
		//URL Decode (query string should always be url encoded)
		url = Web.getParamsString();
		url = url.split("&")[0];
		url = StringTools.urlDecode(url);
		//Retrieve site name from URL (deeplinks)
		if(url.indexOf("/") == 0)
		{
			//Defines URL string, removing trailing /
			if(url.charAt(url.length-1) == "/")
			{
				url = url.substr(0, url.length -1);
			}
			//Remove / at the beginning
			url = url.substr(1, url.length-1);
			var tab_url = url.split("/");
			idSite = tab_url.shift();
			deeplink = tab_url.join("/");
			//If we have a deeplink we will need to do a redirection in JS
			if(deeplink != "")
				doRedirect = true;
		} else //Retrieve site name from GET/POST parameters
		{
			idSite = Web.getParams().get("id_site");
			if(idSite == null)
				isDefaultWebsite = true;
		}
		SilexIndex.idSite = idSite;
		SilexIndex.deeplink = deeplink;
		trace("idSite: " + Std.string(idSite));
		trace("deeplink: " + Std.string(deeplink));
		trace("isDefaultWebsite: " + Std.string(isDefaultWebsite)); 
		
		//Check if installer has been run.
		if(!FileSystem.exists("conf/pass.php"))
		{
			//Installer has not been run, output redirect HTML code.
			redirectToInstaller();
			return;
		}
		
		//instanciating needed classes
		var serverConfig = new ServerConfig();
		var serverContent = new ServerContent();
		var siteEditor = new SiteEditor();
		var fst = new FileSystemTools();
		var hookManager = HookManager.getInstance();
		var pluginManager = new PluginManager();
		var configEditor = new ConfigEditor();
		//var logger = new Logger();
		
		//Calculate JS folder URL
		silexApiJsScriptFolderUrl = RootDir.rootUrl + serverConfig.silexServerIni.get("JAVASCRIPT_FOLDER");
		trace("silexApiJsScriptFolderUrl: " + Std.string(silexApiJsScriptFolderUrl)); 
		trace("RootDir.rootPath: " + Std.string(RootDir.rootPath));
		
		if(isDefaultWebsite)
		{
			idSite = serverConfig.silexServerIni.get("DEFAULT_WEBSITE");
		} else if(idSite == serverConfig.silexServerIni.get("DEFAULT_WEBSITE"))
		{
			isDefaultWebsite = true;
		}
		
		//PASS POST AND GET DATA TO FLASH AND JS
		//CHANGED: Implemented some escaping for values
		// values to pass to javascript (will call eval("$varName = 'value'; ..."))
		var js_str = "";
		// values to pass to the html template (not used anymore, json)
		var fv_js_object = "";
		// values passed to Flash, object which will be added to flashvars
		var fv_object = {};
		for(key in Web.getParams().keys())
		{
			if(key.indexOf("/") != -1) continue;
			if(fv_js_object != "") fv_js_object +=",\n";
			fv_js_object += key + " : '" + StringTools.replace(StringTools.replace(Web.getParams().get(key), "\\", "\\\\"), "'", "\\'") + "'";
			Reflect.setField(fv_object, key, Web.getParams().get(key));
			js_str += "$" + key + " = '" + StringTools.replace(StringTools.replace(Web.getParams().get(key), "\\", "\\\\"), "'", "\\'") + "'; ";
		}
		//Retrieve website configuration
		var websiteConfig = siteEditor.getWebsiteConfig(idSite);
				
		//Find renderer to be used
		var renderer : String;
		renderer = Web.getParams().get("format");
		if(renderer == null || renderer == "")
		{
			if(websiteConfig != null)
				renderer = websiteConfig.get("defaultFormat");
		}
		if(renderer == null || renderer == "")
		{
			renderer = "flash";
		}
		// if the user wants to auto login, we switch to flash version
		if(Web.getParams().get("autologin") == "1")
		{
			renderer = "flash";
		}
		
		//Create server plugins
		var silexPluginsConf = configEditor.readConfigFile(serverConfig.silexServerIni.get("SILEX_PLUGINS_CONF"), "phparray");
		pluginManager.createActivePlugins(silexPluginsConf, hookManager);
		
		//Is the website not found?
		//CHANGED: Now respects HTTP status code defined by RFC 2616
		if(websiteConfig == null)
		{
			//select the not found handler website .
			websiteConfig = siteEditor.getWebsiteConfig(serverConfig.silexServerIni.get("DEFAULT_ERROR_WEBSITE"));
			//Reset deeplink
			//deeplink = "";
			
			//If the notfound website is not found, output the error template and exit.
			if(websiteConfig == null)
			{
				notFoundIsNotFound(serverConfig.silexServerIni.get("DEFAULT_ERROR_WEBSITE"));
				return;
			}
			idSite = serverConfig.silexServerIni.get("DEFAULT_ERROR_WEBSITE");
			
			//Set HTTP return code to 404 and let silex continue to display the not found handler website.
			//NOTE: For Google Chrome and IE up-to 6 (included) to display it when status is 404, the returned body has to be > 512bytes
			Web.setReturnCode(404);
			
			//return;
		}
		
		//Create website-specific plugins
		var websiteConfigPlugins = websiteConfig.get("PLUGINS_LIST");
		pluginManager.createActivePlugins(websiteConfig, hookManager);
		
		//Support for haxe remoting.
		var remotingContext = new haxe.remoting.Context();
		remotingContext = remotingContext.applyFilters({}, "index-remoting-context");
		if(haxe.remoting.HttpConnection.handleRequest(remotingContext))
			return;
		
		var websiteTitle = websiteConfig.get("htmlTitle");

		
		//Replaces "@" by "," in PRELOAD_FILE_LIST from config.txt
		var preloadFileListConf = websiteConfig.get("PRELOAD_FILES_LIST");
		var preloadFiles = new Array<String>();
		if(preloadFileListConf != null && preloadFileListConf != "")
		{
			for(preloadFile in preloadFileListConf.split("@"))
				preloadFiles.push(preloadFile);
			websitePreloadFileList = preloadFiles.join(",");
		}
		
		//Fonts
		var fontList = websiteConfig.get("FONTS_LIST");
		var fonts = new Array<String>();
		if(fontList != null && fontList != "")
		{
			for(fontFile in fontList.split("@"))
				fonts.push(serverConfig.silexServerIni.get("FONTS_FOLDER") + fontFile + "_import.swf");
			websiteFonts = fonts.join(",");
		}

		var favicon = "";
		if(websiteConfig.get("htmlIcon") != null && websiteConfig.get("htmlIcon") != "")
		{
			favicon = '<link rel="shortcut icon" href="' + websiteConfig.get("htmlIcon") + '"><link rel="icon" href="' + websiteConfig.get("htmlIcon") + '">';
		}

		var mainRssFeed = "";
		if(websiteConfig.get("mainRssFeed") != null && websiteConfig.get("mainRssFeed") != "")
		{
			mainRssFeed = '<link rel="alternate" type="application/rss+xml" title="RSS" href="' + websiteConfig.get("mainRssFeed") + '">';
		}
		
		var websiteKeywords = websiteConfig.get("htmlKeywords");
		trace("websiteKeywords:" + websiteKeywords);
		var defaultLanguage = websiteConfig.get("DEFAULT_LANGUAGE");
		
		var linksUrlBase = 	if(serverConfig.silexServerIni.get("USE_URL_REWRITE") == "true")
							{
								RootDir.rootUrl + idSite + "/";
							} else
							{
								RootDir.rootUrl + "?/" + idSite + "/";
							};
		
		//SEO
		//TODO: ATM texts are hard coded. Maybe just pass SEO data to template handlers and let them deal with it.
		var seoDataHomePage = siteEditor.getSectionSeoData(idSite, websiteConfig.get("CONFIG_START_SECTION"), linksUrlBase);
		var seoData;
		trace("debug: " + deeplink);
		if(deeplink != null && deeplink != "")
		{
			trace("siteEditor");
			seoData = siteEditor.getSectionSeoData(idSite, deeplink, linksUrlBase);
		} else
		{
			trace("seoDataHomePage");
			seoData = seoDataHomePage;
			deeplink = "";
		}
		
		//This var holds the part of the title that displays layers
		var subLayersTitle : String;
		subLayersTitle = "";
		subLayersTitle = seoData.get("title");
		
		trace(seoData);
//		untyped __php__("var_dump($seoData)");
		var htmlTitle = websiteConfig.get("htmlTitle");
		var htmlDescription = seoData.get("description");
		
		
		if(websiteConfig.exists("htmlDescription"))
		{
			htmlDescription = websiteConfig.get("htmlDescription");
		} else
			htmlDescription = "";
		
		var htmlTags = StringTools.urlDecode(seoData.get("tags"));
		var htmlEquivalent = "<H4>This page content</H4><br/>" + seoData.get("htmlEquivalent");
		var htmlHeaderKeywords = websiteKeywords + seoDataHomePage.get("description");
		var htmlKeywords = "<H4>Website keywords</H4><br/>" + websiteKeywords 
							+ "<H4>This page keywords</H4><br/>" + seoDataHomePage.get("description");
		
		//Link to homepage
		var htmlLinks = "<h1>navigation</h1>" + idSite + " > " + deeplink + '<h4><a href="' + linksUrlBase 
						+ websiteConfig.get("CONFIG_START_SECTION") + '/">Home page: ' + seoDataHomePage.get("title") + '</a></h4>';
		//Links of this page
		htmlLinks += '<H4>Links of this page (' + seoData.get("title") + ')</H4>';
		if(seoData.get("links") != null)
		{
			htmlLinks += seoData.get("links");
		}
		
		//Loader config
		var loaderPath : String;
		if((loaderPath = websiteConfig.get("loaderPath")) == null)
			loaderPath = "loaders/default.swf";
			
		//Lib.println(fromHashToAnonymous(serverConfig.silexServerIni));

		//This is the object that will be passed as context to the template.
		if(Std.parseInt(websiteConfig.get("flashPlayerVersion")) < 8)
			websiteConfig.set("flashPlayerVersion", "8");
		
		var templateContext =	{
									rootPath : RootDir.rootPath,
									rootUrl : RootDir.rootUrl,
									websiteConfig : fromHashToAnonymous(websiteConfig),
									serverConfig : fromHashToAnonymous(serverConfig.silexServerIni),
									clientConfig : fromHashToAnonymous(serverConfig.silexClientIni),
									seoData : fromHashToAnonymous(seoData),
									idSite : idSite,
									silexApiJsScriptFolderUrl : silexApiJsScriptFolderUrl,
									js_str : js_str,
									deeplink : deeplink,
									loaderPath : loaderPath,
									contentFolderForPublication : serverConfig.getContentFolderForPublication(idSite),
									languagesList : serverContent.getLanguagesList(),
									doRedirect : doRedirect,
									defaultLanguage : defaultLanguage,
									fv_js_object : fv_js_object,
									version :  File.getContent("version.txt"),
									htmlTitle : htmlTitle,
									htmlDescription : htmlDescription,
									htmlTags : htmlTags,
									htmlEquivalent : htmlEquivalent,
									htmlHeaderKeywords : htmlHeaderKeywords,
									htmlKeywords : htmlKeywords,
									isDefaultWebsite : isDefaultWebsite,
									websiteFonts : websiteFonts,
									websitePreloadFileList : websitePreloadFileList,
									websiteConfigPlugins : websiteConfigPlugins,
									subLayersTitle : subLayersTitle,
									renderer : renderer,
									shouldDisplayRenderer : renderer != "flash"
								};
		
		//Lib.println("Calling filter");
		templateContext = templateContext.applyFilters({}, "template-context");
		//Lib.println(Std.string(templateContext));
		
		var templateMacros = {
			nowDate : formatNowDate,
			addToFlashVars : addToFlashVars,
			addToFlashParam: addToFlashParam,
			printFlashParam: printFlashParam,
			flashVarsAsParamString: flashVarsAsParamString,
			flashParamAsParamString: flashParamAsParamString,
			fromHashToArrayOfPair:fromHashToArrayOfPair,
			getFlashParam:getFlashParam,
			getFlashParamAsArrayOfPair : getFlashParamAsArrayOfPair,
			getFlashParamAsHTML:getFlashParamAsHTML,
			callHooks:callHooks,
			printFlashVars:printFlashVars,
			encodeUrl:encodeUrl,
		};
		
		
		
		// call the hooks which need to modify templateContext
		hookManager.callHooks("pre-index-head", [templateContext]);
		//Lib.println(templateContext);
//		var template = new Template(File.getContent(pathToMainTemplate));
		populateFlashVars(templateContext, fv_object);
		//Lib.print(template.execute(templateContext,	templateMacros));
		
		//Do the rendering of the three parts.
		var templateHead = new Template(File.getContent(pathToTemplateHead.applyFilters(templateContext, "template-index-head")));
		Lib.print(templateHead.execute(templateContext,	templateMacros));
		var templateBody = new Template(File.getContent(pathToTemplateBody.applyFilters(templateContext, "template-index-body")));
		Lib.print(templateBody.execute(templateContext,	templateMacros));
		var templateFooter = new Template(File.getContent(pathToTemplateFooter.applyFilters(templateContext, "template-index-footer")));
		Lib.print(templateFooter.execute(templateContext,	templateMacros));
	}
	
	private static function populateFlashVars(params : Dynamic, fv_object:Dynamic)
	{
					addToFlashParam(null, "movie", params.rootUrl + params.loaderPath+"?flashId=silex");
					addToFlashParam(null, "src", params.rootUrl + params.loaderPath + "?flashId=silex");
					addToFlashParam(null, "type","application/x-shockwave-flash");
					addToFlashParam(null, "bgColor", params.websiteConfig.bgColor);
					addToFlashParam(null, "bgcolor", params.websiteConfig.bgColor);
					addToFlashParam(null, "pluginspage", "http://www.adobe.com/products/flashplayer/");
					addToFlashParam(null, "scale", "noscale");
					addToFlashParam(null, "swLiveConnect", "true");
					addToFlashParam(null, "AllowScriptAccess", "always");
					addToFlashParam(null, "allowFullScreen", "true");
					addToFlashParam(null, "quality", "best");
					addToFlashParam(null, "wmode", "transparent");
					addToFlashVars(null, "ENABLE_DEEPLINKING", "false");
					addToFlashVars(null, "DEFAULT_WEBSITE", params.serverConfig.DEFAULT_WEBSITE);
					addToFlashVars(null, "id_site", params.idSite);
					addToFlashVars(null, "rootUrl", params.rootUrl);
					addToFlashVars(null, "php_website_config_file", params.contentFolderForPublication + params.idSite + "/" + params.serverConfig.WEBSITE_CONF_FILE);
					addToFlashVars(null, "config_files_list", params.contentFolderForPublication + params.idSite + "/" + params.serverConfig.WEBSITE_CONF_FILE + "," + params.serverConfig.SILEX_CLIENT_CONF_FILES_LIST);
					addToFlashVars(null, "flashPlayerVersion",if(params.websiteConfig.flashPlayerVersion!=null) params.websiteConfig.flashPlayerVersion else "7");
					addToFlashVars(null, "CONFIG_START_SECTION",if(params.websiteConfig.CONFIG_START_SECTION!=null) params.websiteConfig.CONFIG_START_SECTION else "start");
					addToFlashVars(null, "SILEX_ADMIN_AVAILABLE_LANGUAGES",params.languagesList);
					addToFlashVars(null, "SILEX_ADMIN_DEFAULT_LANGUAGE", params.serverConfig.SILEX_ADMIN_DEFAULT_LANGUAGE);
					addToFlashVars(null, "htmlTitle", params.htmlTitle);
					addToFlashVars(null, "wmode", "transparent");

					var preloadFilesList = params.websiteConfig.layoutFolderPath + params.websiteConfig.initialLayoutFile;
					//PreloadFileList
					if(websitePreloadFileList != null && websitePreloadFileList != "")
					{
						preloadFilesList += "," + websitePreloadFileList;
					}
					//fonts
					if(websiteFonts != null && websiteFonts != "")
					{
						preloadFilesList += "," + websiteFonts;
					}
					addToFlashVars(null, "preload_files_list", preloadFilesList);
					addToFlashVars(null, "forceScaleMode", "showAll");
					addToFlashVars(null, "initialContentFolderPath", params.contentFolderForPublication);
					addToFlashVars(null, "silex_result_str", "_no_value_");
					addToFlashVars(null, "silex_exec_str", "_no_value_");
					
					// add values passed as $_GET params, stored in fv_object
					var propName:String;
					for( propName in Reflect.fields(fv_object) )
						addToFlashVars(null, propName, Reflect.field(fv_object, propName));
					
					addToFlashParam(null, "FlashVars", flashVarsAsParamString(null));
	}
	
	private static function escapeHTML(resolve : String->Dynamic, str : String) : String
	{
		return StringTools.htmlEscape(str);
	}
	
	/**
	 * Macro that returns the encoded URL.
	 * @param	resolve
	 * @return
	 */
	private static function encodeUrl(resolve: String->Dynamic, str : String) : String
	{
		return StringTools.urlEncode(str);
	}
	
	/**
	 * Macro used to call an hook in the "old" system (pre-v1.6.2).
	 * @param	resolve
	 * @param	hookName
	 */
	private static function callHooks(resolve: String->Dynamic, hookName : String)
	{
		//ob things are here to allow plugins to output html code using echo and integrating it
		//in the flow of template
		untyped __call__("ob_start");
		HookManager.getInstance().callHooks(hookName, [SilexIndex.idSite, SilexIndex.deeplink]);
		var ret = untyped __call__("ob_get_contents");
		untyped __call__("ob_end_clean");
		return ret;
	}
	
	/**
	 * Macro that returns the list of flash parameters.
	 * @param	resolve
	 * @return
	 */
	private static function getFlashParam(resolve: String->Dynamic) : Hash<String>
	{
		return flashParam;
	}
	
	/**
	 * Macro that returns an array of objects with a key field and a value field.
	 * @param	resolve
	 */
	private static function getFlashParamAsArrayOfPair(resolve : String->Dynamic)
	{
		return fromHashToArrayOfPair(null, getFlashParam(null));
	}
	
	/**
	 * Macro that returns params tags representing the flashParams.
	 * @param	resolve
	 * @return
	 */
	private static function getFlashParamAsHTML(resolve : String->Dynamic) : String
	{
		var res = "";
		for (k in flashParam.keys())
		{
			if(k != "src" && k != "pluginspage")
				res += "\n<param name=\"" + k + "\" value=\"" + flashParam.get(k) + "\"/>";
		}
		return res;
	}
	
	/**
	 * Macro
	 * @param	resolve
	 * @param	key
	 * @param	value
	 * @return
	 */
	private static function addToFlashVars(resolve : String->Dynamic, key : String, value : String) : String
	{
		flashVars.set(key, value);
		return "";
	}

	/**
	 * Macro
	 * @param	resolve
	 * @param	key
	 * @param	value
	 * @return
	 */
	private static function addToFlashParam(resolve : String->Dynamic, key : String, value : String) : String
	{
		flashParam.set(key, value);
		return "";
	}
	
	
	private static function printFlashParam(resolve : String->Dynamic) : String
	{
		var resA = new Array<String>();
		for (k in flashParam.keys())
		{
			resA.push(k + ":" + "\"" + flashParam.get(k) + "\"");
		}
		
		return "{" + resA.join(",") + "}";
	}
	
	private static function printFlashVars(resolve : String->Dynamic) : String
	{
		var resA = new Array<String>();
		for (k in flashVars.keys())
		{
			resA.push(k + ":" + "\"" + flashVars.get(k) + "\"");
		}
		
		return "{" + resA.join(",") + "}";
	}
	
	/**
	 * Macro
	 * @param	resolve
	 * @return
	 */
	private static function formatNowDate(resolve : String->Dynamic) : String
	{
		return Date.now().toString();
	}
	
	/**
	 * Macro
	 * @param	resolve
	 * @return
	 */
	private static function flashVarsAsParamString(resolve : String->Dynamic) : String
	{
		var eachString = new Array<String>();
		for (k in flashVars.keys())
		{
			eachString.push(k + "=" + flashVars.get(k));
		}

		return eachString.join("&");
	}

	
	/**
	 * Macro
	 * @param	resolve
	 * @return
	 */
	private static function flashParamAsParamString(resolve : String->Dynamic) : String
	{
		var eachString = new Array<String>();
		for (k in flashParam.keys())
		{
			eachString.push(k + "=\"" + flashParam.get(k)+"\"");
		}

		return eachString.join(" ");
	}
	
	private static function fromHashToAnonymous(h : Hash<Dynamic>)
	{
		var res = { };
		for (k in h.keys())
		{
			Reflect.setField(res, k, h.get(k));
		}
		
		return res;
	}
	
	private static function fromHashToArrayOfPair(resolve: String->Dynamic, h : Hash<Dynamic>) : Array<{key : String, value : String}>
	{
		var res = new Array<{key : String, value : String}>();
		
		for (k in h.keys())
		{
			var tmp = { key : k, value : h.get(k)};
			res.push(tmp);
		}
		
		return res;
	}
	
	/**
	 * This function is called when the installer hasn't been run in order to redirect to it.
	 */
	private static function redirectToInstaller()
	{
		var temp = new haxe.Template(File.getContent(pathToRedirectToInstaller));
		var root = RootDir.rootUrl;
		if(root == null) root = "";
		Lib.print(temp.execute({ROOTURL : root}));
	}
	
	/**
	*  This is called when the website responsible for handling not found errors cannot be found.
	*/
	//CHANGED: Returns HTTP Error code 500 (since this can be considered as a configuration error)
	private static function notFoundIsNotFound(notFoundName : String)
	{
		var temp = new haxe.Template(File.getContent(pathToNotFoundIsNotFound));
		if(notFoundName == null) notFoundName = "";
		Web.setReturnCode(500);
		Lib.print(temp.execute({notFoundName : notFoundName}));
	}
}