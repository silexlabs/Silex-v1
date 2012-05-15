//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.ICuePointHolder;
import mx.controls.streamingmedia.Tracer;

/**
 * This class is a listener for cuePoint events that will move the playhead
 * of the specified clip to a named frame with the same name as the cuePoint.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.behaviors.ObjectCuePointListener
{


	/**
	 * Create a listener on the specified cue point holder.
	 *
	 * @param holder The holder of cue points
	 * @param listener Specifies the listener object: either an arbitrary
	 * object (optionally a movie clip), the relative path to an object 
	 * (a string), or the name of a class.
	 */
	public static function initializeListener(holder:ICuePointHolder, listener)
	{
		// The original listener parameter, before it gets manipulated
		var orig = listener;

		if ( isListener(listener) )
		{
			// listener is the actual listener object
			// We are done
		}
		else if ( isListener( eval(listener) ) )
		{
			// listener is a string path to the listener
			listener = eval(listener);
		}
		else if ( isListener( eval("this." + listener) ) )
		{
			// listener is a string path to the listener
			listener = eval("this." + listener);
		}
		else
		{
			// See if listener is the name of the class
			// This takes some fancy footwork...
			// Parse the packages of the the class name
			var namePieces:Array = listener.split(".");
			var classObj = _global[namePieces[0]];
			for (var ix:Number = 1; ix < namePieces.length; ix++)
			{
				classObj = classObj[namePieces[ix]];
			}
			// The class must have a no-args constructor
			listener = new classObj();

			if (! isListener(listener))
			{
				// Still not a listener.
				// Give up and throw an error.
				throw new Error("The listener " + orig + 
					" is not listening for CuePoint events.");
			}
		}
		// Have the listener listen for cuePoint events
		holder["addEventListener"]("cuePoint", listener);
	}

	/**
	 * @param o See if the parameter is listening for cue point events.
	 * @return True if the parameter is listening; false if not.
	 */
	private static function isListener(o):Boolean
	{
		var isListening = 
			( (o.handleEvent instanceof Function) || 
				(o.cuePointHandler instanceof Function) ||
				(o.cuePoint instanceof Function) );
		Tracer.trace(o + " is " + ( isListening ? "" : "not " ) + 
			"listening for cue point events.");

		return isListening;
	}

	/**
	 * Constructor.
	 */
	public function ObjectCuePointListener()
	{
	}

}