package org.silex;

/**
*  This is an extern class pointing to the cSilex class defined in deeplink.js
*/
@:native("cSilex") extern class CSilex
{
	public function new() : Void;

	/**
	*  Opens a popup.
	*/
	public function pop(url : String, width : Int, height : Int, fullscreen : Bool) : Void;

	/**
	*  Initializes the instance.
	*  If forceHashValue is true, uses site id and section name from the hash value.
	*  If putIdSiteInHash is true, writes id site and section name in the hash.
	*/
	public function init(flashvarsObj : Dynamic, defaultIdSite : String, defaultSectionName : String,
		siteTitle : String, forceHashValue : Bool, putIdSiteInHash : Bool) : String;
	public function checkUrlHash() : Void;

	/**
	*  Navigates to another website.
	*/
	public function changeWebsite(idSite : String) : Void;

	/**
	*  Navigates to a new section.
	*/
	public function changeSection(sectionName : String, pageTitle : String) : Void;

	/**
	*  Emits the "tagSection" hook.
	*  Mainly used by stat tracking plugins.
	*/
	public function tagSection(sectionName : String) : Void;

	/**
	*  Calls tagSection with the current section.
	*/
	public function tagCurrentSection() : Void;
}