/*This file is part of Silex - see http://projects.silexlabs.org/?/silex
Silex is © 2010-2011 Silex Labs and is released under the GPL License:
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.core;
import org.silex.core.seo.Utils;
import org.silex.serverApi.RootDir;
import org.silex.serverApi.ServerConfig;
import org.silex.serverApi.SiteEditor;

/**
 * Class managing accessors resolution
 * 
 * @author Raphael Harmel
 * @version 1.0
 * @date   2011-06-15
 */

class AccessorManager 
{
	// class _instance
	private static var _instance:AccessorManager;
	
	// accessor separation character
	private static var _accessorSeparator:String;
	
	// accessors is filled with all default accessors objects and their corresponding values
	public var accessors:Dynamic;
	
	// this method should not be used directly to instanciate the class. getInstance should be used instead
	private function new(idSite:String)
	{
		// gets serverConfig to access getContentFolderForPublication(), silex client & server parameters
		var serverConfig:ServerConfig = new ServerConfig();
		var siteEditor:SiteEditor = new SiteEditor();
		
		// fill accessors with rootUrl
		Reflect.setField(accessors.silex, 'rootUrl', RootDir.rootUrl);
		
		// config is used to store all initial config
		var config:Dynamic = null;
		
		// fill config with id_site
		Reflect.setField(config, 'id_site', idSite);
		
		// fill config with initialContentFolderPath
		Reflect.setField(config, 'initialContentFolderPath', serverConfig.getContentFolderForPublication(idSite));

		// fill config with silex client parameters
		for (parameter in serverConfig.silexClientIni.keys())
		{
			Reflect.setField(config, parameter, serverConfig.silexClientIni.get(parameter));
		}
		
		// fill config with silex server parameters
		for (parameter in serverConfig.silexServerIni.keys())
		{
			Reflect.setField(config, parameter, serverConfig.silexServerIni.get(parameter));
		}
		
		// fill config with website parameters
		var websiteConfig:Hash<String> = siteEditor.getWebsiteConfig(idSite);
		if (websiteConfig != null)
		{
			for (parameter in websiteConfig.keys())
			{
				Reflect.setField(config, parameter, websiteConfig.get(parameter));
			}
		}
		
		// fill accessors with config
		Reflect.setField(accessors.silex, 'config', config);
		
		_accessorSeparator = Reflect.field(accessors.silex.config, 'accessorsSepchar');	
	}
	
	// singleton
	public static function getInstance(idSite:String)
	{
		if (_instance == null)
		{
			_instance = new AccessorManager(idSite);
		}
		return _instance;
	}
	
	/**
	 * Use the accessors delimiters paterns to split the input string into an array.
	 * 
	 * @param	inputString	a string containing accessors
	 * @param	leftTag		[[optional]]left delimiter, (( by default
	 * @param	rightTag	[[optional]]right delimiter, )) by default
	 * @return	the array of strings containing accessors
	 */
	public static function splitTags(inputString:String, leftTag:String = "((", rightTag:String = "))") : Array<String> 
	{
		
		// tmpArray is used to store the string splited on "((" for text that should be removed if the accessor has no value
		var tmpArray:Array<String>;

		// result array
		var resultArray:Array<String> = new Array();
		var cleanedResultArray:Array<String> = new Array();

		// split on leftTag
		tmpArray = inputString.split(leftTag);

		// split on rightTag
		for(element in tmpArray)
		{
			if (element != "")
			{
				// gets the position of the first occurence of rightTag
				var rightTagPos:Int = element.indexOf(rightTag);
				// if rightTag is existing
				if ( (rightTagPos != -1) )
				{
					// push the element data between leftTag & rightTag to resultArray
					resultArray.push(element.substr(0, rightTagPos));
					
					// push the element data after rightTag to resultArray
					if (rightTagPos + rightTag.length < element.length)
						resultArray.push(element.substr(rightTagPos+rightTag.length));
				}
				// if no right tag (either starting string, either non-closed tag), push element to resultArray
				else
					resultArray.push(element);
			}
		}
		return resultArray;
	}

	/**
	 * Use the accessors delimiters paterns to split the input string into an array and reveal the accessors in it.
	 * 
	 * @param	inputString	a string containing accessors
	 * @param	leftTag		left delimiter, << by default
	 * @param	rightTag	right delimiter, >> by default
	 * @param	separator	accessor delimiter, . by default
	 * @return	the array of strings containing accessors
	 */
	public static function splitAndRevealTags(inputString:String, accessorsList:Dynamic, ?separator:String) : Array<Dynamic>
	{
		// if separator is not defined, set it to _accessorSeparator
		if ( separator == null) separator = _accessorSeparator;

		// tmpArray is used to store the string splited on "<<" for text that should be removed if the accessor has no value
		var tmpArray:Array<String>;

		// result array
		var resultArray:Array<String> = new Array();
		var cleanedResultArray:Array<String> = new Array();
		var revealedElement:String;
		//var leftTagExists:Bool = true;
		
		var leftTagArray:Array<String> = new Array<String>();
		
		// get left and right tags from accessorList
		var leftTag:String = getTarget('silex.config.accessorsLeftTag', accessorsList);
		var rightTag:String = getTarget('silex.config.accessorsRightTag', accessorsList);
		
		// if inputString contains at least one leftTag, start revealing process
		if ( inputString.indexOf(leftTag) != -1 )
		{
			//leftTagExists = true;
			// split on leftTag
			tmpArray = inputString.split(leftTag);

			// split on rightTag
			for(element in tmpArray)
			{
				if (element != "")
				{
					// gets the position of the first occurence of rightTag
					var rightTagPos:Int = element.indexOf(rightTag);
					// if rightTag is existing
					if (rightTagPos != -1)
					{
						// gets the stringToReveal between leftTag & rightTag
						var stringToReveal:String = element.substr(0, rightTagPos);
						// resolve and push stringToReveal to resultArray
						revealedElement = getTarget(stringToReveal, accessorsList, separator);
						resultArray.push(revealedElement);
						
						// push the element data after rightTag to resultArray
						if (rightTagPos + rightTag.length < element.length)
							resultArray.push(element.substr(rightTagPos+rightTag.length));
					}
					// if no right tag (either starting string, either non-closed tag), push element to resultArray
					else
						resultArray.push(element);
				}
			}
		}
		// if inputString does not contain a leftTag, return inputString
		else
		{
			resultArray.push(inputString);
		}
		
		return resultArray;

	}

	/**
	 * Retrieves a Dynamic from its path
	 * This Haxe version is a light version of the as2 org.silex.core.Utils.getTarget one, because it is used only by seo
	 * 
	 * @param	pathString		the target path
	 * @param	accessorsList	the accessors list used to reveal the accessor
	 * @param	separator	accessor delimiter, . by default
	 * @return the targeted Dynamic
	 */
	public static function getTarget(pathString:String, accessorsList:Dynamic, ?separator:String) : Dynamic
	{
		// if separator is not defined, set it to _accessorSeparator
		if ( separator == null) separator = _accessorSeparator;

		// if pathString is empty, return null
		if ( pathString==null || pathString=="" || pathString=="." )
		{
			return null;
		}
		
		// get a path array from the path string
		var pathArray:Array<String> = pathString.split(separator);
		
		// define the temporary target
		var target:Dynamic = accessorsList;
		
		// reach the targeted element
		for (element in pathArray)
		{
			if (Reflect.field(target,element) != null)
				target=Reflect.field(target, element);
			else
			{
				return null;
			}
		}
		return target;
	}

	
	/**
	 * Takes toBeRevealed string and resolves its accessors using accessorsList.
	 * "Resolve" means to replace each accessor by its equivalent string value.
	 * 
	 * example1:
	 * 		if accessor is '<<DataSelector1.selectedItem.title>>'
	 * 		and accessorsList:{DataSelector1=>selectedItem=>title:"layer1",silex.config=>version:"v1.6.1"},
	 * 			=> result will be 'layer1'
	 * example2:
	 * 		"my text is for <<dbdata.name1>>!!! not for <<dbdata.name2>> ((nor for <<dbdata.name3>>!!!))" becomes
	 * 			=> "my text is for valueName1!!! not for valueName2 nor for valueName3!!!" if all name variables exist
	 * 			=> "my text is for valueName1!!! not for valueName2" if only dbdata.name1 & dbdata.name2 exists
	 * 			=> "" if only dbdata.name1 or dbdata.name2 exists
	 * 			=> "nor for valueName3!!!" if only dbdata.name3 exists
	 * 
	 * @param	toBeRevealed		the string to be revealed, containing accessors ("((...<<path.to.a.variable>>...))")
	 * @param	accessorsList		the accessors list used to reveal the accessor
	 * @param	separator			accessor delimiter, . by default
	 * @return	Dynamic				the resolved accessor, which can be a string, an array<Dynamic> or a Hash<Dynamic>
	 */
	public static function revealAccessors(toBeRevealed:String, accessorsList:Dynamic, ?separator:String) : Dynamic
	{
		// if accessor is empty or null, return empty string
		if ( (toBeRevealed == null) || (toBeRevealed == '') ) return '';
		
		// decode enventual html entities
		//toBeRevealed = Utils.htmlEntitiesDecode(toBeRevealed);
		
		// if separator is not defined, set it to _accessorSeparator
		if ( separator == null) separator = _accessorSeparator;
		
		// split the given accessor using _accessorSeparator
		//var toBeRevealedSplited:Array<String> = toBeRevealed.split(_accessorSeparator);
		// split the given accessor using separator
		var toBeRevealedSplited:Array<String> = toBeRevealed.split(separator);
		
		// tempArray1 is used to store the string splited on "((" and "))", corresponding to the text that should be removed if the accessor has no value
		var tempArray1:Array<String> = new Array<String>();
		// tempArray2 is used to store the string splited on "<<" and ">>", corresponding to the accessors values
		var tempArray2:Array<Dynamic> = new Array<Dynamic>();
		var resultArray:Array<String> = new Array<String>();

		// flag used to determine the return value type (string, object or array of objects
		var hasStringInIt:Bool=false;

		// split on ((
		tempArray1 = splitTags(toBeRevealed);
		
		// replaces accessors by data on each element
		for(element1 in tempArray1)
		{
			tempArray2 = splitAndRevealTags(element1, accessorsList, separator);

			for (element2 in tempArray2)
			{
				resultArray.push(element2);
				switch(Type.typeof(element2))
				{
					case TClass(c):
						switch(Type.getClassName(c))
						{
							case "String":
								// in this case, return value type should be string
								hasStringInIt = true;
							default:
						}
					default:
				}
			}
		}
		
		var result:Dynamic;
		// if return value type should be string
		if (hasStringInIt == true)
		{
			// return value is string
			result = resultArray.join("");
		}
		else if (resultArray.length>1)
		{
			// return value is array of objects
			result = resultArray;
		}
		else
		{
			// return value is an object
			result = resultArray[0];
		}
		return result;
	}
}