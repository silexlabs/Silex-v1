/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.SiteEditorExtern;

class SiteEditor
{
	var siteEditorExtern : SiteEditorExtern;
	
	public function new()
	{
		siteEditorExtern = new SiteEditorExtern();
	}
	
	/**
	*  Finds and returns SEO informations about a page.<br/>
	*  If several layers are composing the deeplink, all layers data are merged.
	*/
	public function getSectionSeoData(id_site : String, deeplink : String, ?urlBase : String) : Hash<Dynamic>
	{
		var tmp:Hash<Dynamic> = null;
		var sectionSeoData:Dynamic = siteEditorExtern.getSectionSeoData(id_site, deeplink, urlBase);

		tmp = php.Lib.hashOfAssociativeArray(sectionSeoData);
		var layers : Array<Dynamic>;
		if (tmp.get("subLayers") != null)
		{
			layers = php.Lib.toHaxeArray(tmp.get("subLayers"));
			for(i in 0...layers.length)
			{
				layers[i] = php.Lib.hashOfAssociativeArray(layers[i]);
			}
		}

		return tmp;
	}
	/**
	*  Writes xmlData into xmlFileName.
	*/
	public function writeSectionData(xmlData : String, xmlFileName : String, sectionName : String, id_site: String, seoObject : Hash<String>, domObject : Dynamic) : String
	{
		return siteEditorExtern.writeSectionData(xmlData, xmlFileName, sectionName, id_site, php.Lib.associativeArrayOfHash(seoObject), domObject);
	}
	/**
	*  Stores seo data from seoObject in the file corresponding to sectionName and websiteContentFolderPath.
	*/
	public function storeSeoData(websiteContentFolderPath : String, sectionName : String, seoObject : Hash<String>) : String
	{
		return siteEditorExtern.storeSeoData(websiteContentFolderPath, sectionName, php.Lib.associativeArrayOfHash(seoObject));
	}
	/**
	*  Called by duplicateSection, renameSection...
	*/
/*	private function operateSection(siteName : String, oldSectionName : String, newSectionName : String, action : String) : String
	{

	}
*/
	/**
	*  Renames oldSectionName in siteName to newSectionName.
	*/
	public function renameSection(siteName : String, oldSectionName : String, newSectionName : String) : String
	{
		return siteEditorExtern.renameSection(siteName, oldSectionName, newSectionName);
	}
	/**
	*  Duplicates oldSectionName from siteName to newSectionName.
	*/
	public function duplicateSection(siteName : String, oldSectionName : String, newSectionName : String) : String
	{
		return siteEditorExtern.duplicateSection(siteName, oldSectionName, newSectionName);
	}
	/**
	*  Creates newSectionName in siteName.
	*/
	public function createSection(siteName : String, newSectionName : String) : String
	{
		return siteEditorExtern.createSection(siteName, newSectionName);
	}
	/**
	*  Deletes sectionName in siteName.
	*/
	public function deleteSection(siteName : String, sectionName : String) : Void
	{
		return siteEditorExtern.deleteSection(siteName, sectionName);
	}
	/**
	*  Saves xmlContent and xmlContentPublished into the corresponding files depending on siteName.
	*/
	public function savePublicationStructure(siteName : String, xmlContent : String, xmlContentPublished : String) : String
	{
		return siteEditorExtern.savePublicationStructure(siteName, xmlContent, xmlContentPublished);
	}
	/**
	*  Loads and returns either the published version or the unpublished version of PublicationStructure of siteName.
	*/
	public function loadPublicationStructure(siteName : String, ?isPublishedVersion : Bool) : String
	{
		return siteEditorExtern.loadPublicationStructure(siteName, isPublishedVersion);
	}
	/**
	*  Do not use, we are trying to get rid of it.
	*/
	public function parse_client_site_ini_file(filePath : String) : Hash<String>
	{
		return php.Lib.hashOfAssociativeArray(siteEditorExtern.parse_client_site_ini_file(filePath));
	}
	/**
	*  Return's id_site's configuration.
	*/
	public function getWebsiteConfig(id_site : String, ?mergeWithServerConfig : Bool) : Null<Hash<String>>
	{
		var tmp;
		if((tmp = siteEditorExtern.getWebsiteConfig(id_site, mergeWithServerConfig)) != null)
			return php.Lib.hashOfAssociativeArray(tmp);
		return null;
	}
	/**
	*  Delete the whole id_site Website (Publication).
	*/
	public function deleteWebsite(id_site : String) : Bool
	{
		return siteEditorExtern.deleteWebsite(id_site);
	}
	/**
	*  Creates a new website (Publication) named id_site.
	*/
	public function createWebsite(id_site : String) : Bool
	{
		return siteEditorExtern.createWebsite(id_site);
	}
	/**
	*  Renames website (Publication) from id_site to new_id.
	*/
	public function renameWebsite(id_site : String, new_id : String) : Bool
	{
		return siteEditorExtern.renameWebsite(id_site, new_id);
	}
	/**
	*  Saves websiteInfo.
	*/
	public function writeWebsiteConfig(websiteInfo : Hash<String>, id_site : String) : Bool
	{
		return siteEditorExtern.writeWebsiteConfig(php.Lib.associativeArrayOfHash(websiteInfo), id_site);
	}
	/**
	*  Duplicates id_site as newName.
	*/
	public function duplicateWebsite(id_site : String, newName : String) : String
	{
		return siteEditorExtern.duplicateWebsite(id_site, newName);
	}
	/**
	*  Called by duplicateWebsite.
	*/
/*	private function doDuplicateWebsite(folder : String, newFolder : String) : Bool
	{

	}
*/
	/**
	*  Return type is Dynamic since it can be a php.NativeArray or a String in case of error.
	*/
	public function getSiteThumb(siteName : String) : Dynamic
	{
		return siteEditorExtern.getSiteThumb(siteName);
	}
	/**
	*  Return type is Dynamic since it can be a php.NativeArray or a String in case of error.
	*/
	public function getPagePreview(siteName : String, pageName : String) : Dynamic
	{
		return siteEditorExtern.getPagePreview(siteName, pageName);
	}
}