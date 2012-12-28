//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.CuePoint;

/**
 * ICuePointHolder defined the functions that a holder of cue points
 * must implement. Streaming media players will implement this interface.
 *
 * @author Andrew Guldman
 */
interface mx.controls.streamingmedia.ICuePointHolder
{
	/**
	 * @return An array of CuePoint objects. All the CuePoints associated
	 * with this object.
	 */
	function getCuePoints():Array;
	/**
	 * @return An array of CuePoint objects. All the CuePoints associated
	 * with this object.
	 */
	function setCuePoints(cps:Array):Void;

	/**
	 * @param pointName The name of the cue point to find.
	 * @return The CuePoint associated with this object that has the given 
	 * name.
	 */
	function getCuePoint(pointName:String):CuePoint;
	/**
	 * Add the given cue point.
	 * @param aName The name of the CuePoint to add.
	 * @param aTime The time of the CuePoint to add.
	 */
	function addCuePoint(aName:String, aTime:Number):Void;
	/**
	 * Add the given cue point.
	 * @param aCuePoint The CuePoint to add.
	 */
	function addCuePointObject(aCuePoint:CuePoint):Void;
	/**
	 * Remove the given cue point.
	 * @param aCuePoint The CuePoint to remove.
	 */
	function removeCuePoint(aCuePoint:CuePoint):Void;
	/**
	 * Remove all the CuePoints.
	 */
	function removeAllCuePoints():Void;



}
