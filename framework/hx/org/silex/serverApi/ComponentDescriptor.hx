/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.ComponentDescriptorExtern;

class ComponentDescriptor
{
	var componentDescriptorExtern : ComponentDescriptorExtern;
	
	/**
	*  The component's name.
	*/
	public var componentName(getComponentName, setComponentName) : String;
	/**
	* The URL of the AS2 version of the component.
	*/ 
	public var as2Url(getAs2Url, setAs2Url) : String;
	/**
	* The URL of the HTML5 version of the component.
	*/ 
	public var html5Url(getHTML5Url, setHTML5Url) : String;
	/**
	*  The component's class name.
	*/
	public var className(getClassName, setClassName) : String;
	
	/**
	 * The metaData contained in the descriptor
	 */
	public var metaData(getMetaData, setMetaData) : Hash<Dynamic>;
	
	/**
	*  The component's component root
	*/
	public var componentRoot(getComponentRoot, setComponentRoot) : String;
	
	/**
	*  The component's specific editor url
	*/
	public var specificEditorUrl(getSpecificEditorUrl, setSpecificEditorUrl) : String;
	/**
	*  List of properties.
	*/
	public var properties(getProperties, setProperties) : Hash<Dynamic>;
	
	public function new(?descriptor : ComponentDescriptorExtern)
	{
		if((componentDescriptorExtern = descriptor) == null)
			componentDescriptorExtern = new ComponentDescriptorExtern();
	}
	
	private function getComponentName() : String
	{
		return componentDescriptorExtern.componentName;
	}
	
	private function setComponentName(value : String) : String
	{
		return componentDescriptorExtern.componentName = value;
	}
	
	private function getAs2Url() : String
	{
		return componentDescriptorExtern.as2Url;
	}
	
	private function setAs2Url(value : String) : String
	{
		return componentDescriptorExtern.as2Url = value;
	}

	private function getHTML5Url() : String
	{
		return componentDescriptorExtern.html5Url;
	}
	
	private function setHTML5Url(value : String) : String
	{
		return componentDescriptorExtern.html5Url = value;
	}
	
	private function getClassName() : String
	{
		return componentDescriptorExtern.className;
	}
	
	private function getMetaData() : Hash<Dynamic>
	{
		return php.Lib.hashOfAssociativeArray(componentDescriptorExtern.metaData);
	}
	
	private function setMetaData(value : Hash<Dynamic>): Hash<Dynamic>
	{
		componentDescriptorExtern.metaData = php.Lib.associativeArrayOfHash(value);
		return value;
	}
	
	private function setClassName(value : String)
	{
		return componentDescriptorExtern.className = value;
	}
		
	private function getComponentRoot() : String
	{
		return componentDescriptorExtern.componentRoot;
	}
	
	private function setComponentRoot(value : String)
	{
		return componentDescriptorExtern.componentRoot = value;
	}		
	
	private function getSpecificEditorUrl() : String
	{
		return componentDescriptorExtern.specificEditorUrl;
	}
	
	private function setSpecificEditorUrl(value : String)
	{
		return componentDescriptorExtern.specificEditorUrl = value;
	}
	
	private function getProperties() : Hash<Dynamic>
	{
		return php.Lib.hashOfAssociativeArray(componentDescriptorExtern.properties);
	}
	
	private function setProperties(value : Hash<Dynamic>)
	{
		componentDescriptorExtern.properties = php.Lib.associativeArrayOfHash(value);
		return value;
	}	
}