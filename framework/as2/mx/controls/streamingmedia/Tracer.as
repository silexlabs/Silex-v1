//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
 * Send all trace statements through this class so they can easily be 
 * universally turned off.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.Tracer
{
	private static var DEBUG:Boolean = false;
	public static function trace(message:String):Void
	{
		/*
		trace("Tracer.trace: caller=" + arguments.caller);
		for (var member in arguments.caller)
		{
			trace("  " + member + "=" + arguments.caller[member]);
		}
		trace("Tracer.trace: caller.prototype=" + arguments.caller.prototype);
		for (var member in arguments.caller.prototype)
		{
			trace("  " + member + "=" + arguments.caller.prototype[member]);
		}
		*/
		if (DEBUG)
		{
			trace(message);
		}
	}
}