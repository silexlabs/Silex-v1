package org.silex;

class PageLoader
{
	public static function getPage(publicationName : String, deeplink : String, callBack : {htmlCode : String, bgColor: String, jsCode : String, cssCode : String}->Void)
	{
		var remoting = haxe.remoting.HttpAsyncConnection.urlConnect("?/" + publicationName);
		remoting.HTMLRenderingEngine.render.call(["/"+ publicationName + "/" + deeplink], callBack);
	}
	
	public static function getPagePreview(publicationName : String, deeplink : String, callBack : js.Dom.Image->Void)
	{
		var image : js.Dom.Image = untyped js.Lib.document.createElement("img");
		image.src ="cgi/scripts/get_page_preview.php?id_site=" + publicationName + "&page=" + deeplink;
		image.onload = function (ev : js.Dom.Event) { callBack(image);};
	}
}