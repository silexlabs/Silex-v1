package org.silex;

using org.silex.hooks.HookManager;
using org.silex.filters.FilterManager;

class Silex
{
	private var deeplinkManager : CSilex;

	#if debug
	private static var hookName : js.Dom.Text;
	private static var hookArg : js.Dom.Text;
	private static var raiseHookButton : js.Dom.Button;
	private static var debugBar : js.Dom.HtmlDom;
	#end
	
	public static function main()
	{
		var silex = new Silex();
		//In debug mode, add facility to call hooks.
		#if debug
		debugBar = js.Lib.document.createElement("div");
		debugBar.style.position="fixed";
		debugBar.style.top="0px";
		hookName = untyped js.Lib.document.createElement("input");
		hookName.type = "text";
		hookArg = untyped js.Lib.document.createElement("input");
		hookArg.type = "text";
		raiseHookButton = untyped js.Lib.document.createElement("button");
		raiseHookButton.innerHTML = "Raise!";
		raiseHookButton.onclick = function (e : js.Dom.Event)
		{
			org.silex.hooks.HookManager.callHooks(hookName.value, hookArg.value);
		};
		debugBar.appendChild(hookName);
		debugBar.appendChild(hookArg);
		debugBar.appendChild(raiseHookButton);
		js.Lib.document.body.appendChild(debugBar);
		#end
	}
	
	/**
	*  Opens a new sub-layer on top of already opened sub-layers.
	*/
	public function open(layer : String)
	{
		//Get subLayer's HTML code
		PageLoader.getPage("mySite", layer, openPhase2);
	}
	
	private function openPhase2(data : {htmlCode : String, bgColor: String, jsCode : String, cssCode : String})
	{
		var stage : js.Dom.HtmlDom = untyped js.Lib.document.getElementsByClassName("SILEXStage")[0];
		var el = js.Lib.document.createElement("div");
		el.innerHTML = data.htmlCode;
		stage.appendChild(el);
		//Run JS Code
		var scriptTags = el.getElementsByTagName("script");
		for(i in 0...scriptTags.length)
		{
			var scriptTag = scriptTags[i];
			js.Lib.eval(untyped scriptTag.text);
		}
		//Change background
		js.Lib.document.body.style.backgroundColor = data.bgColor;
	}
	
	public function openPage(page : String)
	{
		"silex-before-getPage".callHooks(page);
		PageLoader.getPage("mySite", page, setContent);
		//ADD: setContent (preview)
	}
	
	public function filterDeeplink(value: Dynamic, context : Dynamic) : Dynamic
	{
		
	}
	
	public function new()
	{
		//deeplinkManager = new CSilex();
		//Register hooks
		"silex-openPage".addHook(openPage, 0);
		"silex-open".addHook(open, 0);
		//Register filters
		"silex-deeplink".addFilter(filterDeeplink, 0);
	}
	
	private function setContainerContent(data: {htmlCode: String, container: js.Dom.HtmlDom})
	{
		data.container.innerHTML = data.htmlCode;
	}
	
	private function setContent(data : {htmlCode : String, bgColor: String, jsCode : String, cssCode : String})
	{
		var contentContainer : js.Dom.HtmlDom = untyped js.Lib.document.getElementsByClassName("SILEXStage")[0];
		contentContainer = contentContainer.applyFilters({}, "htmlContainer");
		//Change HTML content
		contentContainer.innerHTML = data.htmlCode;
		//Run JS Code
		var scriptTags = contentContainer.getElementsByTagName("script");
		for(i in 0...scriptTags.length)
		{
			var scriptTag = scriptTags[i];
			js.Lib.eval(untyped scriptTag.text);
		}
		//Change background
		js.Lib.document.body.style.backgroundColor = data.bgColor;
	}
}