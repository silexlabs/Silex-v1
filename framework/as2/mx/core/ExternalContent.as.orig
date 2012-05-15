//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;
import mx.events.UIEventDispatcher;
import mx.core.View;

class mx.core.ExternalContent
{

	// list of things waiting to be emptied
	// key is instanceID
	// value is { obj: , url: , complete: }
	var prepList:Object;

	// list of things currently loading
	// key is instanceID
	// value is { obj: , url: , complete: }
	var loadList:Object;

	// list of things completely loaded.
	// key is instanceID
	// value is {obj: , url: , complete: }
	var	loadedList:Object;

	var numChildren:Number;

	var doLater:Function;
	var childLoaded:Function;
	var createObject:Function;
	var dispatchEvent:Function;

	function loadExternal(url:String, placeholderClassName:String, instanceName:String, depth:Number, initProps:Object):MovieClip
	{
		var newObj:MovieClip;
		newObj = createObject(placeholderClassName, instanceName, depth, initProps);

		// Make an alias for ordered access
		//trace("View.createChild: this[" + numChildren + "] = " + newObj);
		this[View.childNameBase + numChildren] = newObj;

		if (prepList == undefined)
			prepList = new Object();
		prepList[instanceName] = { obj: newObj, url: url, complete: false, initProps: initProps };
		prepareToLoadMovie(newObj);

		return newObj;
	}

	// request to empty the contents before loading new content
	function prepareToLoadMovie(obj:MovieClip):Void
	{
		obj.unloadMovie();
		doLater(this, "waitForUnload");
	}

	// checkt to see if we're empty
	function waitForUnload():Void
	{
		var i:String;
		for (i in prepList)
		{
			var x:Object = prepList[i];
			if (x.obj.getBytesTotal() == 0)
			{
				if (loadList == undefined)
					loadList = new Object();
				loadList[i] = x;
				x.obj.loadMovie(x.url);
				delete prepList[i];
				doLater(this, "checkLoadProgress");
			}
			else
			{
				doLater(this, "waitForUnload");
			}
		}
	}

	// now that we're loading new content, see how we're doing
	function checkLoadProgress():Void
	{
		var contentLoading = false;
		var i:String;
		for (i in loadList)
		{
			var x:Object = loadList[i];
			x.loaded = x.obj.getBytesLoaded();
			x.total = x.obj.getBytesTotal();
			if (x.total > 0)
			{
				x.obj._visible = false;
				dispatchEvent({type: "progress", target: x.obj, current: x.loaded, total: x.total});
				if (x.loaded == x.total) 
				{
					if (loadedList == undefined)
						loadedList = new Object();
					loadedList[i] = x;
					delete loadList[i];
					doLater(this, "contentLoaded");
				}
			}
			else if (x.total == -1)
			{
				// sometimes you get a -1 before it starts loading
				if (x.failedOnce != undefined)
				{
					x.failedOnce++;
					if (x.failedOnce > 3)
					{
						dispatchEvent({type: "complete", target: x.obj, current: x.loaded, total: x.total});
						//trace("total == -1 loaded = " + x.loaded);
						delete loadList[i];
						delete x;
					}
				}
				else
				{
					x.failedOnce = 0;
				}
			}
			contentLoading = true;
		}
		if(contentLoading)
		{
			doLater(this, "checkLoadProgress");
		}
	}
	
	// completely loaded. Had to wait for a bit to make sure _width and _height were set correctly.
	function contentLoaded():Void
	{
		var	i:String;
		for (i in loadedList)
		{
			var x:Object = loadedList[i];
			//trace("loaded..." + i);

			x.obj._visible = true;
			x.obj._complete = true;

			// Initialize properties, only when loading external movies.
			var prop:String;
			for (prop in x.initProps)
				x.obj[prop] = x.initProps[prop];

			childLoaded(x.obj);
			dispatchEvent({type: "complete", target: x.obj, current: x.loaded, total: x.total});
			delete loadedList[i];
			delete x;
		}
	}

	// anything that gets loadmovie'd is just a movieclip.  There's no way to make it a component except by doing this
	function convertToUIObject(obj:MovieClip):Void
	{
		if (obj.setSize == undefined)
		{
			var	ui:Object = UIObject.prototype;

			obj.addProperty("width", ui.__get__width, null);
			obj.addProperty("height", ui.__get__height, null);

			obj.addProperty("left", ui.__get__left, null);
			obj.addProperty("x", ui.__get__x, null);

			obj.addProperty("top", ui.__get__top, null);
			obj.addProperty("y", ui.__get__y, null);

			obj.addProperty("right", ui.__get__right, null);

			obj.addProperty("bottom", ui.__get__bottom, null);

			// add other things to the MovieClip so it looks more like a UIObject
			obj.addProperty("visible", ui.__get__visible, ui.__set__visible);

			obj.move = UIObject.prototype.move;
			obj.setSize = UIObject.prototype.setSize;
			obj.size = UIObject.prototype.size;
			UIEventDispatcher.initialize(obj);
		}
	}

	static function enableExternalContent():Void
	{
	}

	static function classConstruct():Boolean
	{
		var v = View.prototype;
		var p = ExternalContent.prototype;
		v.loadExternal = p.loadExternal;
		v.prepareToLoadMovie = p.prepareToLoadMovie;
		v.waitForUnload = p.waitForUnload;
		v.checkLoadProgress = p.checkLoadProgress;
		v.contentLoaded = p.contentLoaded;
		v.convertToUIObject = p.convertToUIObject;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var ViewDependency = View;
}