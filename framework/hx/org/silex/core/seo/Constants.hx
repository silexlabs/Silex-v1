/*This file is part of Silex - see http://projects.silexlabs.org/?/silex
Silex is © 2010-2011 Silex Labs and is released under the GPL License:
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * class used to gather all seo constants
 * 
 * @author	Raphael Harmel
 * @version 1.0
 * @date   2011-07-12
 */

package org.silex.core.seo;

class Constants
{
	// seo file extension
	public static var SEO_FILE_EXTENSION:String = '.seodata.xml';
	
	// LayerSeoModel Properties
	public static inline var LAYER_SEO_PROPERTIES = ['title', 'description', 'pubDate'];
	
	// ComponentSeoModel Properties
	public static inline var COMPONENT_GENERIC_PROPERTIES = ['playerName', 'className', 'iconIsIcon', 'htmlEquivalent', 'tags', 'description'];
	
	// ComponentSeoLinkModel Properties
	public static inline var COMPONENT_LINK_PROPERTIES = ['title', 'link', 'deeplink', 'description'];
	
	// LayerSeoAggregatedModel Properties
	public static var LAYER_SEO_AGGREGATED_PROPERTIES:Array<String> = ['title', 'deeplink', 'description', 'tags', 'htmlEquivalent', 'links'];
	public static var CHILD_LAYERS_NODE_NAME:String = 'subLayers';
}