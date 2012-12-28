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
class mx.controls.streamingmedia.behaviors.NamedFrameCuePointListener
{
	private var _targetClip:MovieClip;
	private var _stop:Boolean;


	/**
	 * Create a listener on the specified cue point holder.
	 *
	 * @param The holder of cue points
	 * @param targetClip The intended target of the listener
	 * @param shouldStop True to generate a gotoAndStop; false for gotoAndPlay
	 */
	public static function initializeListener(
		holder:ICuePointHolder, aTarget:MovieClip, shouldStop:Boolean)
	{
		if (aTarget == null)
		{
			// If no target is specified, assume the holder is a movie clip
			// and use its parent.
			aTarget = MovieClip(holder)._parent;
		}
		// Create the listener object
		var listener:NamedFrameCuePointListener =
			new NamedFrameCuePointListener(aTarget, shouldStop);
		// Have the listener listen for cuePoint events
		holder["addEventListener"]("cuePoint", listener);
	}

	/**
	 * Constructor.
	 *
	 * @param aTarget The clip which has the named frames corresponding to the
	 * cuePoint names.
	 * @param shouldStop If true, then gotoAndStop will be called; otherwise
	 * gotoAndPlay will.
	 */
	public function NamedFrameCuePointListener(aTarget:MovieClip, shouldStop:Boolean)
	{
		_targetClip = aTarget;
		_stop = shouldStop;
	}

	/**
	 * Listen for cuePoint events and move the playhead to the frame
	 * with the same name as the cuePoint.
	 */
	public function handleEvent(ev:Object):Void
	{
		Tracer.trace("NamedFrameCuePointListener: event handled! type=" + ev.type + ", target=" + ev.target);
		if (ev.type == "cuePoint")
		{
			Tracer.trace("cuePoint event!");
			if (_stop)
			{
				_targetClip.gotoAndStop(ev.cuePointName);
			}
			else
			{
				_targetClip.gotoAndPlay(ev.cuePointName);
			}
		}
		else
		{
			Tracer.trace("Event other than cuePoint event. Ignore it.");
		}
	}

}