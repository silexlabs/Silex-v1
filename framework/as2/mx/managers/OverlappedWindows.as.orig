//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.managers.SystemManager;
import mx.core.UIComponent;

class mx.managers.OverlappedWindows
{
	// callback from interval to check for idle
	static function checkIdle(Void):Void
	{
		// if 10 intervals go by w/o any activity then we're idle
		if (SystemManager.idleFrames > 10)
		{
			SystemManager.dispatchEvent({type:"idle"});
		}
		else
			SystemManager.idleFrames ++;
	}

	// our override of addEventListener.  Only create idle events if someone is listening
	static function __addEventListener(e:String, o:Object, l:Function):Void
	{
		if (e == "idle")
		{
			if (SystemManager.interval == undefined)
				SystemManager.interval = setInterval(SystemManager.checkIdle, 100);
		}
		SystemManager._xAddEventListener(e, o, l);
	}

	// our override of removeEventListener.
	static function __removeEventListener(e:String, o:Object, l:Function):Void
	{
		if (e == "idle")
		{
			if (SystemManager._xRemoveEventListener(e, o, l) == 0)
				clearInterval(SystemManager.interval);
		}
		else
			SystemManager._xRemoveEventListener(e, o, l);
	}

	// track mouse clicks to see if we change top-level forms
	static function onMouseDown(Void):Void
	{
		// reset the idle counter
		SystemManager.idleFrames = 0;
		SystemManager.isMouseDown = true;

		var newTarget:MovieClip = _root;
		var depth:Number = undefined;
		var x:Number = _root._xmouse;
		var y:Number = _root._ymouse;

		if (SystemManager.form.modalWindow == undefined)
		{
			// activate a window if we need to
			if (SystemManager.forms.length > 1)
			{
				var l:Number = SystemManager.forms.length;
				var i:Number;
				for (i = 0; i < l; i++)
				{
					var p:MovieClip = SystemManager.forms[i];

					if (p._visible)
					{
						if (p.hitTest(x, y))
						{
							if (depth == undefined)
							{
								depth = p.getDepth();
								newTarget = p;
							}
							else
							{
								if (depth < p.getDepth())
								{
									depth = p.getDepth();
									newTarget = p;
								}
							}
						}
					}
				}
				if (newTarget != SystemManager.form)
				{
					SystemManager.activate(newTarget);
				}
			}
		}
		var z:MovieClip = SystemManager.form;
		z.focusManager._onMouseDown();
	}

	// track mouse moves in order to determine idle
	static function onMouseMove(Void):Void
	{
		SystemManager.idleFrames = 0;
	}

	// track mouse moves in order to determine idle
	static function onMouseUp(Void):Void
	{
		SystemManager.isMouseDown = false;
		SystemManager.idleFrames = 0;
	}

	// activation is totally managed by the SystemManager
	static function activate(f:MovieClip):Void
	{
		if (SystemManager.form != undefined)
		{
			if (SystemManager.form != f && SystemManager.forms.length > 1)
			{
				// switch the active form
				var z:MovieClip = SystemManager.form;
				z.focusManager.deactivate();
			}
		}
		SystemManager.form = f;
		f.focusManager.activate();
	}

	// activation is totally managed by the SystemManager
	static function deactivate(f:MovieClip):Void
	{
		if (SystemManager.form != undefined)
		{
			// if there's more tha one form and this is it, find a new form
			if (SystemManager.form == f && SystemManager.forms.length > 1)
			{
				var z:MovieClip = SystemManager.form;
				z.focusManager.deactivate();
				var l:Number = SystemManager.forms.length;
				var i:Number;
				var newForm:MovieClip;
				for (i = 0; i < l; i++)
				{
					if (SystemManager.forms[i] == f)
					{
						// use the first form above us in taborder, or the first one below.
						for (i = i+1; i < l; i++)
						{
							// remember the highest visible window.
							if (SystemManager.forms[i]._visible == true)
							{
								newForm = SystemManager.forms[i];
							}
						}
						SystemManager.form = newForm;
						break;
					}
					else
					{
						// remember the highest visible window.
						if (SystemManager.forms[i]._visible == true)
						{
							newForm = SystemManager.forms[i];
						}
					}
				}
				var z:MovieClip = SystemManager.form;
				z.focusManager.activate();
			}
		}
	}

	// register a window containing a focus manager
	static function addFocusManager(f:UIComponent):Void
	{
		SystemManager.forms.push(f);
		SystemManager.activate(f);
	}

	// unregister a window containing a focus manager
	static function removeFocusManager(f:UIComponent):Void
	{
		var l:Number = SystemManager.forms.length;
		var i:Number;
		for (i = 0; i < l; i++)
		{
			if (SystemManager.forms[i] == f)
			{
				if (SystemManager.form == f)
					SystemManager.deactivate(f);
				SystemManager.forms.splice(i, 1);
				return;
			}
		}

	}

	static var initialized:Boolean = false;
	static function enableOverlappedWindows():Void
	{
		if (!initialized)
		{
			initialized = true;
			SystemManager.checkIdle = OverlappedWindows.checkIdle;
			SystemManager.__addEventListener = OverlappedWindows.__addEventListener;
			SystemManager.__removeEventListener = OverlappedWindows.__removeEventListener;
			SystemManager.onMouseDown = OverlappedWindows.onMouseDown;
			SystemManager.onMouseMove = OverlappedWindows.onMouseMove;
			SystemManager.onMouseUp = OverlappedWindows.onMouseUp;
			SystemManager.activate = OverlappedWindows.activate;
			SystemManager.deactivate = OverlappedWindows.deactivate;
			SystemManager.addFocusManager = OverlappedWindows.addFocusManager;
			SystemManager.removeFocusManager = OverlappedWindows.removeFocusManager;
		}
	}
	static var SystemManagerDependency = SystemManager;
}