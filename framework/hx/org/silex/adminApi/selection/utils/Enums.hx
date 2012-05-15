/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.utils;

/**
 * a utils class containing all the enums foud in the SelectionManager
 * @author Yannick DOMINGUEZ
 */

 /**
  * Lists all the States of the uiManager 
  */
enum SelectionStates {
	
	/**
	 * The state used when no components are selected
	 */
	Unselected;
	
	/**
	 * The state used when at least one component is selected
	 */
	Selected;
	
	/**
	 * The state used when the user moves one/many components
	 */
	Translating;
	
	/**
	 * The state used when the user rotates one/many components
	 */
	Rotating;
	
	/**
	 * The state used when the user scales one/many components
	 */
	Scaling;
	
	/**
	 * The state used when the user draws a zone
	 */
	Drawing;
	
	/**
	 * The state used when the user moves the pivot point
	 */
	TranslatingPivotPoint;
	
	/**
	 * The state used whent the user moves the selection with the keyboard arrows keys
	 */
	KeyboardTranslating;
	
	/**
	 * The state used when the user logs out and the selection tool must no longer react to interaction
	 */
	Disabled;
}

/**
 * Lists the different position that can be occupied by the pivot point
 */
enum PivotPointPositions {
	
	TopLeft;
	Top;
	TopRight;
	Right;
	BottomRight;
	Bottom;
	BottomLeft;
	Left;
	Center;
}

/**
 * Lists all the available type of transformations
 */
enum TransformTypes {
	TranslationTransformType;
	KeyboardTranslationTransformType;
	RotationTransformType;
	ScalingTransformType;
	DrawingTransformType;
	PivotPointTranslationTransformType;
}

class Enums 
{

	public function new() 
	{
		
	}
	
}