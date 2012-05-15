/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

@:native("site_editor") extern class SiteEditorExtern
{
	private static function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/site_editor.php");
		null;
	}
	
	public function new() : Void;
	
	/**
	*  Finds and returns SEO informations about a page.<br/>
	*  If several layers are composing the deeplink all data are merged.
	*/
	public function getSectionSeoData(id_site : String, deeplink : String, ?urlBase : String) : php.NativeArray;
	/**
	*  Writes xmlData into xmlFileName.
	*/
	public function writeSectionData(xmlData : String, xmlFileName : String, sectionName : String, id_site: String, seoObject : php.NativeArray, domObject : Dynamic) : String;
	/**
	*  Stores seo data from seoObject in the file corresponding to sectionName and websiteContentFolderPath.
	*/
	public function storeSeoData(websiteContentFolderPath : String, sectionName : String, seoObject : php.NativeArray) : String;
	/**
	*  Called by duplicateSection, renameSection...
	*/
	private function operateSection(siteName : String, oldSectionName : String, newSectionName : String, action : String) : String;
	/**
	*  Renames oldSectionName in siteName to newSectionName.
	*/
	public function renameSection(siteName : String, oldSectionName : String, newSectionName : String) : String;
	/**
	*  Duplicates oldSectionName from siteName to newSectionName.
	*/
	public function duplicateSection(siteName : String, oldSectionName : String, newSectionName : String) : String;
	/**
	*  Creates newSectionName in siteName.
	*/
	public function createSection(siteName : String, newSectionName : String) : String;
	/**
	*  Deletes sectionName in siteName.
	*/
	public function deleteSection(siteName : String, sectionName : String) : Void;
	/**
	*  Saves xmlContent and xmlContentPublished into the corresponding files depending on siteName.
	*/
	public function savePublicationStructure(siteName : String, xmlContent : String, xmlContentPublished : String) : String;
	/**
	*  Loads and returns either the published version or the unpublished version of PublicationStructure of siteName.
	*/
	public function loadPublicationStructure(siteName : String, ?isPublishedVersion : Bool) : String;
	/**
	*  Do not use, we are trying to get rid of it.
	*/
	public function parse_client_site_ini_file(filePath : String) : php.NativeArray;
	/**
	*  Return's id_site's configuration.
	*/
	public function getWebsiteConfig(id_site : String, ?mergeWithServerConfig : Bool) : php.NativeArray;
	/**
	*  Delete the whole id_site Website (Publication).
	*/
	public function deleteWebsite(id_site : String) : Bool;
	/**
	*  Creates a new website (Publication) named id_site.
	*/
	public function createWebsite(id_site : String) : Bool;
	/**
	*  Renames website (Publication) from id_site to new_id.
	*/
	public function renameWebsite(id_site : String, new_id : String) : Bool;
	/**
	*  Saves websiteInfo.
	*/
	public function writeWebsiteConfig(websiteInfo : php.NativeArray, id_site : String) : Bool;
	/**
	*  Duplicates id_site as newName.
	*/
	public function duplicateWebsite(id_site : String, newName : String) : String;
	/**
	*  Called by duplicateWebsite.
	*/
	private function doDuplicateWebsite(folder : String, newFolder : String) : Bool;
	/**
	*  Return type is Dynamic since it can be a php.NativeArray or a String in case of error.
	*/
	public function getSiteThumb(siteName : String) : Dynamic;
	/**
	*  Return type is Dynamic since it can be a php.NativeArray or a String in case of error.
	*/
	public function getPagePreview(siteName : String, pageName : String) : Dynamic;
	
}