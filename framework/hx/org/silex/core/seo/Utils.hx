/*This file is part of Silex - see http://projects.silexlabs.org/?/silex
Silex is © 2010-2011 Silex Labs and is released under the GPL License:
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * class used to gather utility methods concerning SEO
 * 
 * @author	Raphael Harmel
 * @version 1.0
 * @date   2011-07-12
 */

package org.silex.core.seo;

import org.silex.core.seo.Constants;
import org.silex.core.seo.LayerSeo;
import org.silex.core.seo.LayerSeoAggregatedModel;
import org.silex.serverApi.RootDir;
import org.silex.serverApi.ServerConfig;
import org.silex.serverApi.externs.ServerConfigExtern;
import php.Lib;
import php.NativeArray;
 
class Utils
{
	// seo properties separators
	static var TITLE_SEPARATOR:String = ' - ';
	static var DESCRIPTION_SEPARATOR:String = '. ';
	static var TAGS_SEPARATOR:String = ',';
	static var HTML_EQUIVALENT_SEPARATOR:String = '';

	/**
	 * This init metho loads 'silex_server/rootdir.php' and sets all needed include pathes
	 */
	private static function __init__()
	{
		// loads rootdir.php file which defines ROOTPATH constant and $ROOTURL variable
		untyped __call__('require_once', 'rootdir.php');
		// set include path to silex_server
		untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH)');
		// needed for Zend Library +++
		untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library")');
	}
	
	/**
	 * This method is used to get the seo informations of a specific page.
	 * A page can be defined by multiple layers like /start/child/grandChild
	 * 
	 * @param	id_site
	 * @param	deeplink
	 * @param	?urlBase
	 * @return
	 */
	public static function getPageSeoData(idSite : String, deeplink : String, ?urlBase : String) : LayerSeoAggregatedModel
	{
		//untyped __call__('print_r', idSite + ' - ' + deeplink + ' - ' + urlBase + "\n");
		var serverConfig:ServerConfig = new ServerConfig();
		
		// seo file path
		var layerSeoFilePath:String;
		// aggregated page seo data
		var pageSeoData:LayerSeoAggregatedModel = createLayerSeoAggregatedModel();
		// array of the layers aggregated seo data corresponding to this page
		var layerSeoAggregatedDataArray:Array<LayerSeoAggregatedModel> = new Array<LayerSeoAggregatedModel>();
		// one of these layer aggregated seo data
		//var layerSeoAggregatedData:LayerSeoAggregatedModel = null;
		var layerSeoAggregatedData:LayerSeoAggregatedModel = createLayerSeoAggregatedModel();
		var layerSeo:LayerSeoModel;
		// array containing all layers names used by the page
		var layersNames:Array<String> = new Array<String>();
		// one of these layer names
		var layerName:String;
		var layerDeeplink:String = '';
		
		var titleArray:Array<String> = new Array<String>();
		var descriptionArray:Array<String> = new Array<String>();
		var tagsArray:Array<String> = new Array<String>();
		var htmlEquivalentArray:Array<String> = new Array<String>();

		
		// split deeplink to have all needed layerNames
		layersNames = deeplink.split('/');
		
		// for each layerName
		for (layerName in layersNames)
		{
			// build needed deeplink
			layerDeeplink += layerName + '/';
			// build layerSeo File Path dynamically and change layer value each time
			layerSeoFilePath = RootDir.rootPath + serverConfig.getContentFolderForPublication(idSite) + idSite + '/' + layerName + Constants.SEO_FILE_EXTENSION;
			//untyped __call__('print_r', layerSeoFilePath + "\n");
			// get layerSeoModel corresponding to xml seo file. remove the last characte ('/') from the deeplink.
			layerSeo = LayerSeo.readLayerSeoModel(layerSeoFilePath, layerDeeplink.substr(0, layerDeeplink.length - 1));
			
			// aggregate layerSeoModel
			layerSeoAggregatedData = aggregateLayerSeoData(layerSeo, layerDeeplink, urlBase);
			
			// add aggregated layerSeoModel to layerSeoAggregatedDataArray
			layerSeoAggregatedDataArray.push(layerSeoAggregatedData);
		}
			
		// for each layerSeoAggregatedDataArray element
		for (layerSeoAggregatedData in layerSeoAggregatedDataArray)
		{
			// fill properties arrays
			titleArray.push(layerSeoAggregatedData.title);
			descriptionArray.push(layerSeoAggregatedData.description);
			tagsArray.push(layerSeoAggregatedData.tags);
			htmlEquivalentArray.push(layerSeoAggregatedData.htmlEquivalent);
			
			// add all links values to pageSeoData property values
			for (childLayer in layerSeoAggregatedData.subLayers)
			{
				pageSeoData.subLayers.push(childLayer);
			}
		}
		
		// fill deeplink
		pageSeoData.deeplink = deeplink;
			
		// Aggregate properties arrays
		pageSeoData.title = titleArray.join(TITLE_SEPARATOR);
		pageSeoData.description = descriptionArray.join(DESCRIPTION_SEPARATOR);
		pageSeoData.tags = tagsArray.join(TAGS_SEPARATOR);
		pageSeoData.htmlEquivalent = htmlEquivalentArray.join(HTML_EQUIVALENT_SEPARATOR);
		
		return pageSeoData;
	}
	
	/**
	 * This method is used to get the seo informations of a specific page.
	 * A page can be defined by multiple layers like /start/child/grandChild
	 * 
	 * @param	id_site
	 * @param	deeplink
	 * @param	?urlBase
	 * @return
	 */
	public static function getPageSeoDataAsPhpArray(idSite : String, deeplink : String, ?urlBase : String) : NativeArray
	{
		// aggregated page seo data
		var pageSeoData:LayerSeoAggregatedModel = getPageSeoData(idSite, deeplink, urlBase);
		
		// convert result to PHP Native Array
		return layerSeoAggregatedModel2PhpArray(pageSeoData);
	}
	
	/**
	 * This methods takes a LayerSeoModel and aggregates its component seo data
	 * 
	 * @param	layerSeo
	 */
	public static function aggregateLayerSeoData(layerSeo:LayerSeoModel, deeplink:String, ?urlBase:String):LayerSeoAggregatedModel
	{
		//var layerSeoAggregatedData:LayerSeoAggregatedModel = null;
		//layerSeoAggregatedData.subLayers = new Array<ComponentSeoLinkModel>();
		var layerSeoAggregatedData:LayerSeoAggregatedModel = createLayerSeoAggregatedModel();
		
		//public var title:String;
		//public var deeplink:String;
		var descriptionArray:Array<String> = new Array<String>();
		var tagsArray:Array<String> = new Array<String>();
		var htmlEquivalentArray:Array<String> = new Array<String>();
		var linksArray:Array<String> = new Array<String>();
		var childLayersArray:Array<ComponentSeoLinkModel> = new Array<ComponentSeoLinkModel>();
		
		if (Reflect.hasField(layerSeo, 'title'))
		{
			layerSeoAggregatedData.title = layerSeo.title;
			
		}
		layerSeoAggregatedData.deeplink = deeplink.substr(0,deeplink.length-1);
		if (Reflect.hasField(layerSeo, 'description')) layerSeoAggregatedData.description = layerSeo.description;
		
		// get seo properties for all components and store them to corresponding arrays
		for (component in layerSeo.components)
		{
			if (Reflect.hasField(component, 'description')) descriptionArray.push(component.description);
			if (Reflect.hasField(component, 'tags')) tagsArray.push(component.tags);
			if (Reflect.hasField(component, 'htmlEquivalent')) htmlEquivalentArray.push(component.htmlEquivalent);
			
			for (link in component.links)
			{
				//linksArray.push(link);
				linksArray.push('<A HREF="' + urlBase + deeplink + link.deeplink + '">' + link.title + '</A>');
				childLayersArray.push(link);
				layerSeoAggregatedData.subLayers.push(link);
				//layerSeoAggregatedData.subLayers.push(Lib.toPhpArray(link));
			}
			
		}
		// Aggregate component properties arrays
		layerSeoAggregatedData.description = descriptionArray.join(DESCRIPTION_SEPARATOR);
		layerSeoAggregatedData.tags = tagsArray.join(TAGS_SEPARATOR);
		layerSeoAggregatedData.htmlEquivalent = htmlEquivalentArray.join(HTML_EQUIVALENT_SEPARATOR);
		if (linksArray.length != 0)
		{
			layerSeoAggregatedData.links = "<ul><li>" + linksArray.join("</li><li>") + "</li></ul>";
		}
		layerSeoAggregatedData.subLayers = childLayersArray;
		
		return layerSeoAggregatedData;
	}
	
	/**
	 * converts a LayerSeoAggregatedModel to a Php Native Array.
	 * 
	 * inputs: a LayerSeoAggregatedModel
	 * output: an Php Native Array
	 */
	public static function layerSeoAggregatedModel2PhpArray(layerSeoAggregatedModel:LayerSeoAggregatedModel):NativeArray
	{
		var layerSeoAggregatedHash:Hash<Dynamic> = new Hash<Dynamic>();
		var layerSeoAggregatedNativeArray:NativeArray = null;
		var subLayersArray:Array<Dynamic> = null;
		var subLayersNativeArray:NativeArray = null;
		var linkHash:Hash<String> = null;
		var linkNativeArray:NativeArray = null;
		
		// for all layerSeo's properties
		for(layerSeoAggregatedModelProp in Constants.LAYER_SEO_AGGREGATED_PROPERTIES.iterator())
		{
			layerSeoAggregatedHash.set(layerSeoAggregatedModelProp, Reflect.field(layerSeoAggregatedModel, layerSeoAggregatedModelProp));
		}
		// if there is at least one subLayer
		if (layerSeoAggregatedModel.subLayers.length != 0)
		{
			subLayersArray = new Array<Dynamic>();
			// for each subLayers
			for (link in layerSeoAggregatedModel.subLayers)
			{
				linkHash = new Hash<String>();
				// add all properties & values
				for (linkProp in Constants.COMPONENT_LINK_PROPERTIES.iterator())
				{
					if (Reflect.field(link, linkProp) != null)
					{
						linkHash.set(linkProp, Reflect.field(link, linkProp));
					}
				}
				// add and convert back to Php Native Array
				linkNativeArray = Lib.associativeArrayOfHash(linkHash);
				subLayersArray.push(linkNativeArray);
				subLayersNativeArray = Lib.toPhpArray(subLayersArray);
			}
			subLayersArray.push(subLayersNativeArray);
		}
		// add and convert back to Php Native Array
		layerSeoAggregatedHash.set(Constants.CHILD_LAYERS_NODE_NAME, subLayersNativeArray);
		layerSeoAggregatedNativeArray = Lib.associativeArrayOfHash(layerSeoAggregatedHash);

		return layerSeoAggregatedNativeArray;
	}
	
	/**
	*  This function creates an empty ComponentSeoModel object.
	*/
	public static function createComponentSeoModel() : ComponentSeoModel
	{
		var obj =
			{
			   tags : "",
			   specificProperties : new Hash<String>(),
			   playerName : "",
			   links : new Array<ComponentSeoLinkModel>(),
			   iconIsIcon : "",
			   htmlEquivalent : "",
			   description : "",
			   className : "",
			};

		return obj;
	}
	
	/**
	*  This function creates an empty ComponentSeoLinkModel object.
	*/
	public static function createComponentSeoLinkModel() : ComponentSeoLinkModel
	{
		var obj =
			{
			   title : "",
			   link : "",
			   deeplink : "",
			   description : ""
			};

		return obj;
	}
	
	/**
	*  This function creates an object instanciated that correspond to the type LayerSeoModel. All of its fields
	*  are correctly initialized.
	*/
	public static function createLayerSeoModel() : LayerSeoModel
	{
		var obj =
			{
				title : "",
				description : "",
				pubDate : "",
				components: new Array<ComponentSeoModel>(),
			};

		return obj;
	}

	/**
	*  This function creates an empty LayerSeoAggregatedModel object.
	*/
	public static function createLayerSeoAggregatedModel() : LayerSeoAggregatedModel
	{
		var obj =
			{
				title: "",
				deeplink: "",
				description: "",
				tags: "",
				htmlEquivalent: "",
				links: "",
				subLayers: new Array<ComponentSeoLinkModel>()
			};

		return obj;
	}
	
	/**
	 * Converts a html string to its text equivalent
	 * Does not remove existing accessors
	 * 
	 * @param	html
	 * @return	equivalent text
	 */
	public static function html2Text(html:String):String
	{
		// define html regular expression which should be removed
		var htmlRegExpr:EReg = ~/<([\/A-Z0-9\s="#-]*>)/ig;
		// define space regular expression which should be removed
		var spaceRegExpr:EReg = ~/( )+/g;
		
		// replace regular expressions in html with a space
		var text:String = htmlRegExpr.replace(html, ' ');
		text = StringTools.rtrim(StringTools.ltrim(spaceRegExpr.replace(text, ' ')));
		
		return text;
	}
	
}
