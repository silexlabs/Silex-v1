/*
	this file is part of SILEX
	SILEX : RIA developement tool - see http://silex-ria.org/

	SILEX is (c) 2004-2007 Alexandre Hoyau and is released under the GPL License:

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License (GPL)
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
	
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.listModels.Messages;
import org.silex.adminApi.PublicationModel;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.util.ObjectDumper;
import org.silex.core.Interpreter;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;
import org.silex.adminApi.listedObjects.PropertyProxy;
import org.silex.ui.UiBase;
import org.silex.core.UtilsHooks;

class SelectionTool extends mx.core.UIComponent{
	
	private static var SELECTION_TOOL_ID:String = "selectionTool";
	
	var silex_ptr/*:org.silex.core.Api*/;
	// **
	// UI
	var sizeUiTL:MovieClip;
	var sizeUiTR:MovieClip;
	var sizeUiBL:MovieClip;
	var sizeUiBR:MovieClip;
	var sizeUiL:MovieClip;
	var sizeUiT:MovieClip;
	var sizeUiR:MovieClip;
	var sizeUiB:MovieClip;
//	var centerUiPos:MovieClip;
	var centerUiRot:MovieClip;
	
	var isMoving:Boolean = false;
	var isKeyMoving:Boolean = false;
	var isRoatating:Boolean=false;
	var isDragging:Boolean=false;
	
	var bg_mc:MovieClip;
	
	var drag_mc:MovieClip;
	
	var draggedButton:MovieClip;
	
	var selectedBorderMc:MovieClip;
	
	//when the selection is moved, save the starting x coord
	var selectionMovedStartPos:Object;
	
	/**
	 * an array containing references to the selected components
	 */
	private var _selectedComponents:Array;
	
	var pivot:Object; // pivot in bg_mc coordinates
	
	//check if the mouse is currently down
	var isMouseDown:Boolean; 
	
	function onMouseDown() {
			
    	this.isMouseDown = true;
		
	};
		
	function onMouseUp() {
    	this.isMouseDown = false;
		stopBackgroundDrag();
	
	
	};
	
	function onSelectionKeyDown() {
		
		
		var distance:Number = 1;
		if (Key.isDown(Key.SHIFT))
		{
			distance = 10;
		}
		
		if (Key.isDown(Key.CONTROL))
		{
			distance = 100;
		}
		
		
		switch (Key.getCode())
		{
			case Key.UP:
			if (isKeyMoving == false)
			{
				selectionMovedStartPos = {top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height};
			}
			isKeyMoving = true;
			bg_mc._y -= distance;
			//this.moveSelection();
			break;
			
			case Key.DOWN:
			if (isKeyMoving == false)
			{
				selectionMovedStartPos = {top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height};
			}
			isKeyMoving = true;
			bg_mc._y += distance;
			//this.moveSelection();
			break;
			
			case Key.LEFT:
			if (isKeyMoving == false)
			{
				selectionMovedStartPos = {top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height};
			}
			isKeyMoving = true;
			bg_mc._x -= distance;
			//this.moveSelection();
			break;
			
			case Key.RIGHT:
			if (isKeyMoving == false)
			{
				selectionMovedStartPos = {top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height};
			}
			isKeyMoving = true;
			bg_mc._x += distance;
			
			//this.moveSelection();
			break;
		}
		uiPlacementRefresh();
		
		
			
	}
	
	function onSelectionKeyUp() {
		switch(Key.getCode())
		{
			case Key.UP:
			case Key.DOWN:
			case Key.RIGHT:
			case Key.LEFT:
			isKeyMoving = false;
			this.moveSelection();
			selectionMovedStartPos = { top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height };
			break;
		}
		
	}
	
	// constructor
	function SelectionTool()
	{
		silex_ptr=_global.getSilex(this);

		// menu tool
		_parent.isNotSeenByMenuTool=true; // so that it is not used by the menu
		
		var mouseListener:Object = new Object();


		Mouse.addListener(this);

		Key.addListener(this);
		
		pivot={x:0,y:0};
	}
	
	

	function onMouseMove()
	{
		if (this.isMoving == true)
		{
			if (Key.isDown(Key.SHIFT))
			{
				bg_mc._y = selectionMovedStartPos.top;
			}
			
			else if (Key.isDown(Key.CONTROL))
			{
				bg_mc._x = selectionMovedStartPos.left;
			}
			this.uiPlacementRefresh();
		}
		
		if (this.isDragging == true)
		{
			this.setBgFromUi(draggedButton);
			this.uiPlacementRefresh();
		}
		
		

	}

	function startBackgroundDrag()
	{
		HookManager.getInstance().callHooks(UtilsHooks.DIALOG_START_HOOK_UID);
		this.isMoving = true;
		selectionMovedStartPos = {top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height};
		bg_mc.startDrag();
	}
	
	function stopBackgroundDrag()
	{
		if (this.isMoving == true)
		{		
			HookManager.getInstance().callHooks(UtilsHooks.DIALOG_END_HOOK_UID);
			bg_mc.stopDrag();
				// move media
			this.moveSelection();
			this.isMoving = false;
		}
	}
	
	function startResize(target:MovieClip)
	{
		HookManager.getInstance().callHooks(UtilsHooks.DIALOG_START_HOOK_UID);
		//silex_ptr.utils.trace("toolbox.SelectionTool sizeUiTL startDrag"+this);
		// lock drag horizontally or vertically
		selectionMovedStartPos = {top:drag_mc._y, left:drag_mc._x, right:drag_mc._width, bottom:drag_mc._height};
		draggedButton = target;
		
		var vert_num:Number=undefined;
		if (target["isResizeW"]!=true){
			// vert_num=this._parent._x;
		}
		
		var horiz_num:Number=undefined;
		if (target["isResizeH"]!=true){
			// horiz_num=this._parent._y;
		}
		
		var dragRect:Object;
		
		switch(target){
			case sizeUiBR:
				dragRect = { left: drag_mc._x, top:drag_mc._y, right:Stage.width, bottom:Stage.height };
				break;
				
			case sizeUiT:
				dragRect = { left: drag_mc._x , top:-10000, right:drag_mc._width + drag_mc._x, bottom:drag_mc._y + drag_mc._height };
				break;
				
			case sizeUiL:
				dragRect = { left: -10000, top:drag_mc._y, right:drag_mc._width + drag_mc._x, bottom:drag_mc._height + drag_mc._y };
				break;
			case sizeUiR:
				dragRect = { left: drag_mc._x, top:drag_mc._y, right:10000, bottom:drag_mc._height + drag_mc._y };
				break;
				
			case sizeUiB:
				dragRect = { left: drag_mc._x, top:drag_mc._y, right:drag_mc._width + drag_mc._x, bottom:10000 };
				break;
				
			case sizeUiTL:
				dragRect = { left: -10000, top:-10000, right:drag_mc._width + drag_mc._x, bottom:drag_mc._y + drag_mc._height };
				break;
				
			case sizeUiBL:
				dragRect = { left: -10000, top:drag_mc._y, right:drag_mc._width + drag_mc._x, bottom:10000 };
				break;
			case sizeUiTR:
				dragRect = { left: drag_mc._x, top:-10000, right:10000, bottom:drag_mc._y + drag_mc._height };
				break;
		}
			
		
		target.startDrag(true, dragRect.left, dragRect.top, dragRect.right, dragRect.bottom);
		this.isDragging=true;
		
	}
	
	function stopResize(target:MovieClip)
	{
		HookManager.getInstance().callHooks(UtilsHooks.DIALOG_END_HOOK_UID);
			// stop drag
			target.stopDrag();
			this.isDragging=false;			
			
			// resize media
			this.resizeSelection();
	}
	
	// called from fla file
	function onLoad()
	{
		super.onLoad();
		var delegate:Function = Utils.createDelegate(this, onDataChanged);
		SilexAdminApi.getInstance().components.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, delegate);
		SilexAdminApi.getInstance().properties.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, Utils.createDelegate(this, onPropertiesDataChanged));
		silex_ptr.application.addEventListener("resize", delegate);
		
		
		refresh();

		// **
		// mouse pointer

		// ** ** **
		// UI events
		
		sizeUiTR["isResizeH"]=sizeUiTR["isResizeW"]=true;
		sizeUiBL["isResizeH"]=sizeUiBL["isResizeW"]=true;
		sizeUiBR["isResizeH"]=sizeUiBR["isResizeW"]=true;
		sizeUiTL["isResizeH"]=sizeUiTL["isResizeW"]=true;
		sizeUiL["isResizeW"]=true;
		sizeUiT["isResizeH"]=true;
		sizeUiR["isResizeW"]=true;
		sizeUiB["isResizeH"]=true;

		// **
		// start

		bg_mc.onPress = Utils.createDelegate(this, startBackgroundDrag);
		
		sizeUiTR._btn.onPress = Utils.createDelegate(this, startResize, sizeUiTR);
		sizeUiBL._btn.onPress = Utils.createDelegate(this, startResize, sizeUiBL);
		sizeUiBR._btn.onPress = Utils.createDelegate(this, startResize, sizeUiBR);
		sizeUiL._btn.onPress = Utils.createDelegate(this, startResize, sizeUiL );
		sizeUiT._btn.onPress = Utils.createDelegate(this, startResize, sizeUiT);
		sizeUiR._btn.onPress = Utils.createDelegate(this, startResize, sizeUiR);
		sizeUiB._btn.onPress = Utils.createDelegate(this, startResize, sizeUiB);
		sizeUiTL._btn.onPress = Utils.createDelegate(this, startResize, sizeUiTL);
		
	
		// Horizontal and Vertical resize
		sizeUiL._btn.onRelease = 
		sizeUiL._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiL);
		sizeUiR._btn.onRelease =
		sizeUiR._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiR);
		sizeUiT._btn.onRelease = 
		sizeUiT._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiT);
		sizeUiB._btn.onRelease = 
		sizeUiB._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiB);
		sizeUiBR._btn.onRelease = 
		sizeUiBR._btn.onReleaseOutside =  Utils.createDelegate(this, stopResize, sizeUiBR);
		sizeUiBL._btn.onRelease = 
		sizeUiBL._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiBL);
		sizeUiTR._btn.onRelease = 
		sizeUiTR._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiTR);
		sizeUiTL._btn.onRelease = 
		sizeUiTL._btn.onReleaseOutside = Utils.createDelegate(this, stopResize, sizeUiTL);
		
		var keyListener:Object = new Object();
		keyListener.onKeyDown = Utils.createDelegate(this, onSelectionKeyDown);
		keyListener.onKeyUp = Utils.createDelegate(this, onSelectionKeyUp);
		Key.addListener(keyListener);
		
		
	}
	
	private function onPropertiesDataChanged(event:AdminApiEvent):Void
	{
		if (event.data != SELECTION_TOOL_ID)
		{
			refresh();
		}
		
	}
	
	private function onDataChanged(event:Object):Void{
		refresh();	
	}
	
	function setBgFromUi(refToBtn:MovieClip) {
		var opositCorner_mc:MovieClip;
		var deltaX:Number = ( refToBtn._x - bg_mc._x);
		var deltaY:Number = ( refToBtn._y - bg_mc._y);
		
		switch(refToBtn){
			case sizeUiTL:
				opositCorner_mc = sizeUiBR;
				bg_mc._x = refToBtn._x;
				bg_mc._y = refToBtn._y;
				break;
				
			case sizeUiT:
				opositCorner_mc = sizeUiBR;
				bg_mc._y = refToBtn._y;
				break;
				
			case sizeUiL:
				opositCorner_mc = sizeUiBR;
				bg_mc._x = refToBtn._x;
				break;
			case sizeUiR:
			case sizeUiB:
			case sizeUiBR:
				opositCorner_mc=sizeUiTL;
				break;
			case sizeUiBL:
				opositCorner_mc = sizeUiTR;
				bg_mc._x = refToBtn._x;
				
				break;
			case sizeUiTR:
				opositCorner_mc = sizeUiBL;
				bg_mc._y = refToBtn._y;
				break;
		}
		
		// store position of the pivot
		var pivotPosPercentX:Number;
		var pivotPosPercentY:Number;
		pivotPosPercentX=pivot.x/bg_mc._width;
		pivotPosPercentY=pivot.y/bg_mc._height;
		
		// apply width and height
		if (refToBtn["isResizeH"]==true)
		{
			var h:Number=Math.abs(refToBtn._y-opositCorner_mc._y);
			//silex_ptr.utils.trace("toolbox.SelectionTool setBgFromUi H "+h);
			if (Key.isDown(Key.SHIFT))
			{
				
				var newPercentage =  h / bg_mc._height;
				bg_mc._width = (bg_mc._width * newPercentage);
				
				
				//bg_mc._y = bg_mc._y + yDelta;
			}
			// apply height
			bg_mc._height=h ;
		}
		if (refToBtn["isResizeW"]==true)
		{
			var w:Number=Math.abs(refToBtn._x-opositCorner_mc._x);
			//silex_ptr.utils.trace("toolbox.SelectionTool setBgFromUi W "+w);
			if (Key.isDown(Key.SHIFT))
			{
				
				var newPercentage = w / bg_mc._width ;
				bg_mc._height = (bg_mc._height * newPercentage) ;
				
				
				
				//bg_mc._x = bg_mc._x + xDelta;
			}
			// apply width
			bg_mc._width=w ;
		}
		// move in function of the pivot position
		var newPivotPosX:Number=bg_mc._width*pivotPosPercentX;
		var newPivotPosY:Number=bg_mc._height*pivotPosPercentY;
		var offsetPivotX:Number=newPivotPosX-pivot.x;
		var offsetPivotY:Number=newPivotPosY-pivot.y;
		//silex_ptr.utils.trace("toolbox.SelectionTool setBgFromUi "+w);
		// replace pivot at its position
		bg_mc._x-=offsetPivotX;
		bg_mc._y-=offsetPivotY;
	}
	
	function displaySelectableComponents():Void
	{
		selectedBorderMc.removeMovieClip();
		var selectableComponents:Array = SilexAdminApi.getInstance().components.getData()[0];
		
		
		for (var i:Number = 0; i < selectableComponents.length ; i++)
		{
			var aleaName:String = "border_" + String(Math.round(Math.random() * 1000));
			var selectableComponentsBorder:MovieClip = selectedBorderMc.attachMovie("SelectionBorder", aleaName, selectedBorderMc.getNextHighestDepth());
			
			var component:UiBase = selectableComponents[i].getComponent();
			
			// from local
			var coordTL:Object={x:component._x, y:component._y  };
			var coordBR:Object={x:component._x + component._width ,y:component._y+ component._height };
			
			// to global
			localToGlobal(coordTL);
			localToGlobal(coordBR);
			
			selectableComponentsBorder._x = coordTL.x;
			selectableComponentsBorder._y = coordTL.y;
			selectableComponentsBorder._width = 100;
			selectableComponentsBorder._height = 100;
			
		}
		
	}
	
	function setSelectedComponentsListeners(selectedComponents:Array):Void
	{
			for (var i:Number = 0; i < selectedComponents.length; i++)
			{
				var selectedComponent:UiBase = selectedComponents[i];
				selectedComponent.addEventListener("stopAdminMove", Utils.createDelegate(this, onStopAdminMove));
				selectedComponent.addEventListener("startAdminMove", Utils.createDelegate(this, onStartAdminMove));
			}
	}
	
	function unsetSelectedComponentsListeners(selectedComponents:Array):Void
	{
			for (var i:Number = 0; i < selectedComponents.length; i++)
			{
				var selectedComponent:UiBase = selectedComponents[i];
				selectedComponent.removeEventListener("stopAdminMove", Utils.getDelegate(this, onStopAdminMove));
				selectedComponent.removeEventListener("startAdminMove", Utils.getDelegate(this, onStartAdminMove));
				Utils.removeDelegate(this, onStopAdminMove);
				Utils.removeDelegate(this, onStartAdminMove);
			}
	}
	
	function onStartAdminMove():Void
	{
	//	HookManager.getInstance().callHooks(UtilsHooks.DIALOG_START_HOOK_UID);
	}
	
	function onStopAdminMove():Void
	{
	//	HookManager.getInstance().callHooks(UtilsHooks.DIALOG_END_HOOK_UID);
		refresh();
		var properties:Object = SilexAdminApi.getInstance().properties.getSortedData([ComponentProxy.createFromComponent(getSelectedPlayer()[0]).uid], ["x", "y","width","height", "rotation"], "name")[0];
		var xproperty:PropertyProxy = properties.x;
		xproperty.updateCurrentValue(xproperty.currentValue, SELECTION_TOOL_ID);
		//moveSelection();
	}
	
	function refresh()
	{		
		//trace("selection tool refreshing");
		//trace ("mouseDown : "+this.isMouseDown);
		unsetSelectedComponentsListeners(_selectedComponents);
		
		if (isDragging == true || isMoving == true || isRoatating == true) return;

		//Removing isSelected from components that were selected
		for(var i=0;i < _selectedComponents.length; i++)
		{
			_selectedComponents[i].isSelected = false;
		}
		
		if (getSelectedPlayer().length == 0)
		{
			_visible = false;
			return;
		}

		// put this toolbox behind the other toolboxes
		_parent.swapDepths(0);//_parent._parent.getNextHighestDepth());

		// get selection
		var player_mcs:Array = getSelectedPlayer();
		setSelectedComponentsListeners(player_mcs);
		_selectedComponents = player_mcs;
		//silex_ptr.utils.trace("toolbox.SelectionTool playersToolboxChange "+player_mc);
		
		//displaySelectableComponents();
		// **
		// context menu
		// emptyContextMenu(bg_mc);

		// **
		//
		if (player_mcs.length > 0)
		{
			_visible = true;
			
			var refTop:Number = 50000;
			var refLeft:Number = 50000;
			var refBottom:Number = -50000;
			var refRight:Number = -50000;
			
			
			
			//propertiesArray.reverse();
			
			for (var i:Number = 0; i < player_mcs.length; i++)
			{
				
				var player:UiBase = player_mcs[i];
				var properties:Object = SilexAdminApi.getInstance().properties.getSortedData([ComponentProxy.createFromComponent(player).uid], ["x", "y","width","height", "rotation"], "name")[0];
				
				var propertyProxyX:PropertyProxy = properties.x;
				var propertyProxyY:PropertyProxy = properties.y;
				var propertyProxyWidth:PropertyProxy = properties.width;
				var propertyProxyHeight:PropertyProxy = properties.height;
				var propertyProxyRotation:PropertyProxy = properties.rotation;
				
				var point1:Object = new Object();
				point1.x = Number(propertyProxyX.currentValue) + Number(propertyProxyWidth.currentValue) * Math.cos(Number(propertyProxyRotation.currentValue) * (Math.PI / 180));
				point1.y = Number(propertyProxyY.currentValue) + Number(propertyProxyWidth.currentValue) * Math.sin(Number(propertyProxyRotation.currentValue) * (Math.PI / 180));
				
				var point2:Object = new Object();
				point2.x = Number(propertyProxyX.currentValue) + Number(propertyProxyWidth.currentValue) * Math.cos(Number(propertyProxyRotation.currentValue) * (Math.PI / 180)) - Number(propertyProxyHeight.currentValue) * Math.sin(Number(propertyProxyRotation.currentValue) * (Math.PI / 180));
				point2.y = Number(propertyProxyY.currentValue) + Number(propertyProxyHeight.currentValue) * Math.cos(Number(propertyProxyRotation.currentValue) * (Math.PI / 180)) + Number(propertyProxyWidth.currentValue) * Math.sin(Number(propertyProxyRotation.currentValue) * (Math.PI / 180));
				
				var point3:Object = new Object();
				point3.x = Number(propertyProxyX.currentValue) - Number(propertyProxyHeight.currentValue) * Math.sin(Number(propertyProxyRotation.currentValue) * (Math.PI / 180));
				point3.y = Number(propertyProxyY.currentValue) + Number(propertyProxyHeight.currentValue) * Math.cos(Number(propertyProxyRotation.currentValue) * (Math.PI /  180));
				
				var point4:Object = new Object();
				point4.x = Number(propertyProxyX.currentValue);
				point4.y = Number(propertyProxyY.currentValue);
				
				var componentBounds:Array = new Array(point1, point2, point3, point4);
				

				if (isNaN(player.width) == true || isNaN(player.height) == true || player._width == undefined || player._height == undefined
				|| player._width == 0 || player._height == 0)
				{	
					player._yscale = 100;
					player._xscale = 100;
				}
				
				if (player._width == 0 || player._height == 0)
				{
					player._width = 1;
					player._height = 1;
				}
				
				for (var j:Number = 0; j < componentBounds.length; j++)
				{
					if (componentBounds[j].x < refLeft)
					{
						refLeft = componentBounds[j].x;
					}
					
					if (componentBounds[j].y < refTop)
					{
						refTop = componentBounds[j].y;
					}
								
					if (componentBounds[j].y > refBottom)
					{
						refBottom = componentBounds[j].y;
					}
							
					if (componentBounds[j].x > refRight)
					{
						refRight = componentBounds[j].x;
					}
				}
				
			
				//Setting isSelected on component
				player.isSelected = true;
			}
			
			
			
			
		
		
				
				var silexScaleX:Number = (silex_ptr.application.sceneRect.right - silex_ptr.application.sceneRect.left) / silex_ptr.config.layoutStageWidth ;
				var silexScaleY:Number = (silex_ptr.application.sceneRect.bottom - silex_ptr.application.sceneRect.top) / silex_ptr.config.layoutStageHeight;
				
				refLeft =  refLeft * silexScaleX;
				refTop = refTop * silexScaleY;
				refRight = refRight * silexScaleX;
				refBottom = refBottom * silexScaleY;
			
			refLeft = refLeft + silex_ptr.application.sceneRect.left;
			refTop = refTop + silex_ptr.application.sceneRect.top;
			refRight = refRight + silex_ptr.application.sceneRect.left;
			refBottom = refBottom + silex_ptr.application.sceneRect.top;
			
		
			
			// apply transform
			bg_mc._x=refLeft;
			bg_mc._y=refTop;
			bg_mc._width=refRight-refLeft;
			bg_mc._height=refBottom-refTop; 
			
			
			
			if (bg_mc._width == undefined || bg_mc._width<=0) bg_mc._width = 1;
			if (bg_mc._height == undefined || bg_mc._height<=0) bg_mc._height = 1;
			uiPlacementRefresh();
			
			
			if(this.isMouseDown == true)
			{
				startBackgroundDrag();
			}
		}
		else
		{
			_visible=false;
		}
	}
	function getSelectedPlayer():Array
	{
		//this is just to avoid polluting traces! get rid of, don't commit!!
		//return null;
		var selectedComponentIds:Array = SilexAdminApi.getInstance().components.getSelection();
		//trace("selectedComponentIds : "+ selectedComponentIds);
		
	//	trace("getSelectedPlayer. uid : " + selectedComponentId);
		var componentProxiesInFirstSelectedLayer:Array = SilexAdminApi.getInstance().components.getData()[0];
		
		var selectedComponentsArray:Array = new Array();
		//find selected component in this. Sould be in a function on ListModelBase.

		for(var i:Number = 0; i < componentProxiesInFirstSelectedLayer.length; i++){
			var proxy:ComponentProxy = componentProxiesInFirstSelectedLayer[i];
			for (var j:Number = 0; j < selectedComponentIds.length; j++)
			{
				if (proxy.uid == selectedComponentIds[j]) {
					if (proxy.getIsVisual() == true)
					{
						selectedComponentsArray.push(proxy.getComponent());
					}
					
					
				}
			}
			
		}	
		return selectedComponentsArray;
	}

	// UI events
	function resizeSelection()
	{
		var player_mcs:Array = getSelectedPlayer();
		
		var player_mcsLength:Number = player_mcs.length;
		
		var propertyProxies:Array = new Array();
		var groupCoordTL:Object = { x: 10000, y:10000 };
		
		var xScale:Number = drag_mc._width / selectionMovedStartPos.right ;
		var yScale:Number = drag_mc._height / selectionMovedStartPos.bottom ;
		
		
		
		for (var i = 0; i < player_mcsLength; i++)
		{
					
			var player_mc:UiBase = player_mcs[i];
			var properties:Object = SilexAdminApi.getInstance().properties.getSortedData([ComponentProxy.createFromComponent(player_mc).uid], ["x", "y","width","height", "rotation"], "name")[0];
			var xPropertyProxy:PropertyProxy;
			var yPropertyProxy:PropertyProxy;
			var heightPropertyProxy:PropertyProxy;
			var widthPropertyProxy:PropertyProxy;
			var rotationPropertyProxy:PropertyProxy;
			
			var editablePropertiesLength:Number = player_mc.editableProperties.length;
			
			
			xPropertyProxy = properties.x;
			yPropertyProxy = properties.y;
			heightPropertyProxy = properties.height;
			widthPropertyProxy = properties.width;
			rotationPropertyProxy = properties.rotation;
			
			var playerHeight:Number = Number(heightPropertyProxy.currentValue);
			var playerWidth:Number = Number(widthPropertyProxy.currentValue);
			var playerX:Number = Number(xPropertyProxy.currentValue);
			var playerY:Number = Number(yPropertyProxy.currentValue);
			
			if (playerX < groupCoordTL.x)
			{
				groupCoordTL.x = playerX;
			}
			
			if (playerY < groupCoordTL.y)
			{
				groupCoordTL.y = playerY;
			}
			
			propertyProxies.push( { height:heightPropertyProxy, width:widthPropertyProxy, x:xPropertyProxy, y:yPropertyProxy, rotation:rotationPropertyProxy } );
			
		}
		
		
	
		
		if (SilexAdminApi.getInstance().publicationModel.getScaleMode() == PublicationModel.SHOW_ALL || 
		SilexAdminApi.getInstance().publicationModel.getScaleMode() == PublicationModel.PIXEL)
		{	
			var silexScaleX:Number = (silex_ptr.application.sceneRect.right - silex_ptr.application.sceneRect.left) / silex_ptr.config.layoutStageWidth  ;
			var silexScaleY:Number = (silex_ptr.application.sceneRect.bottom - silex_ptr.application.sceneRect.top) / silex_ptr.config.layoutStageHeight;
			var dragDeltaX:Number = (drag_mc._x - selectionMovedStartPos.left) *  (1/ silexScaleX);
			var dragDeltaY:Number = (drag_mc._y - selectionMovedStartPos.top) * (1/ silexScaleY);
		}
		
		else
		{
			var dragDeltaX:Number = (drag_mc._x - selectionMovedStartPos.left) ;
			var dragDeltaY:Number = (drag_mc._y - selectionMovedStartPos.top) ;
		}
		
		
		var deltaX:Number = groupCoordTL.x - (groupCoordTL.x * xScale);
		var deltaY:Number = groupCoordTL.y - (groupCoordTL.y * yScale);
		
		
		for (var i:Number = 0; i < propertyProxies.length; i++)
		{
			/**trace("cos : " + Math.cos(Number(propertyProxies[i].rotation.currentValue) * (Math.PI / 180)));
			trace("sin : " + Math.sin(Number(propertyProxies[i].rotation.currentValue) * (Math.PI / 180)));
			trace("total width : " + (propertyProxies[i].width.currentValue * xScale) );
			trace("total height : " + (propertyProxies[i].height.currentValue * yScale) );
			trace("total width cos : " + (propertyProxies[i].width.currentValue * xScale) * Math.sin(Number(propertyProxies[i].rotation.currentValue) * (Math.PI / 180)));
			trace("total height sin : " + (propertyProxies[i].height.currentValue * yScale) * Math.cos(Number(propertyProxies[i].rotation.currentValue) * (Math.PI / 180)));*/
			
			
			trace ("x scale : " + xScale);
			trace("y scale : " + yScale);
			propertyProxies[i].x.updateCurrentValue((propertyProxies[i].x.currentValue * xScale) + deltaX +  (dragDeltaX), SELECTION_TOOL_ID);
			propertyProxies[i].y.updateCurrentValue((propertyProxies[i].y.currentValue * yScale) + deltaY  + (dragDeltaY), SELECTION_TOOL_ID);
			propertyProxies[i].height.updateCurrentValue((propertyProxies[i].height.currentValue * yScale)  , SELECTION_TOOL_ID);
			propertyProxies[i].width.updateCurrentValue((propertyProxies[i].width.currentValue * xScale), SELECTION_TOOL_ID );
			
			var player_mc:UiBase = player_mcs[i];
			player_mc.dispatch( { type:"resize", target:this } );
		}
		

		
		bg_mc._x = drag_mc._x;
		bg_mc._y = drag_mc._y;
		uiPlacementRefresh();
		
		refresh();
		
	}
	
	function moveSelection()
	{
		var player_mcs:Array = getSelectedPlayer();
		
		var player_mcsLength:Number = player_mcs.length;
		
		var silexScaleX:Number = (silex_ptr.application.sceneRect.right - silex_ptr.application.sceneRect.left) / silex_ptr.config.layoutStageWidth  ;
		var silexScaleY:Number = (silex_ptr.application.sceneRect.bottom - silex_ptr.application.sceneRect.top) / silex_ptr.config.layoutStageHeight ;
		if (SilexAdminApi.getInstance().publicationModel.getScaleMode() == PublicationModel.SHOW_ALL || 
		SilexAdminApi.getInstance().publicationModel.getScaleMode() == PublicationModel.PIXEL)
		{
			var xDelta:Number = (drag_mc._x - selectionMovedStartPos.left) *  (1/ silexScaleX);
			var yDelta:Number = (drag_mc._y - selectionMovedStartPos.top) * (1/ silexScaleY);
		}
		
		else
		{
			xDelta = drag_mc._x - selectionMovedStartPos.left;
			yDelta = drag_mc._y -  selectionMovedStartPos.top;
		}
		
		
		for (var i = 0; i < player_mcsLength; i++)
		{
					
			var player_mc:UiBase = player_mcs[i];
			var properties:Object = SilexAdminApi.getInstance().properties.getSortedData([ComponentProxy.createFromComponent(player_mc).uid], ["x", "y"], "name")[0];
			var xPropertyProxy:PropertyProxy;
			var yPropertyProxy:PropertyProxy;
			
			
			xPropertyProxy = properties.x;
			yPropertyProxy = properties.y;

			xPropertyProxy.updateCurrentValue(xPropertyProxy.currentValue + xDelta, SELECTION_TOOL_ID );
			yPropertyProxy.updateCurrentValue(yPropertyProxy.currentValue + yDelta, SELECTION_TOOL_ID);
			
		}
		
		for (var i = 0; i < player_mcsLength; i++)
		{
			var player_mc:UiBase = player_mcs[i];
			
			player_mc.dispatch( { type:"move", target:this } );
		}
	
		bg_mc._x = drag_mc._x;
		bg_mc._y = drag_mc._y;
		uiPlacementRefresh();
		refresh();
	}
	
	function rotateSelection(angle:Number)
	{
		if (!angle) angle=centerUiRot._rotation;
		
		var player_mc:MovieClip=getSelectedPlayer()[0];
		player_mc.rotation+=angle;

		// set layout as dirty
		silex_ptr.application.getLayout(player_mc).isDirty=true;
		SilexAdminApi.getInstance().properties.signalDataChanged();
	}


	function uiPlacementRefresh()
	{
		var x:Number= bg_mc._x;//-bg_mc._width/2;
		var y:Number = bg_mc._y;//-bg_mc._height/2;
		
		var objCoord:Object = { x:bg_mc._x, y:bg_mc._y, width:bg_mc._width, height:bg_mc._height };
		
		var hookType:String;		
		
		if (this.isMoving == true)
		{
			hookType = "componentMoved";
		}
		
		if (this.isDragging == true)
		{
			hookType = "componentResized";
		}
		
		HookManager.getInstance().callHooks(hookType, objCoord);	
		
		drag_mc._x = objCoord.x;
		drag_mc._y = objCoord.y;
		drag_mc._width = objCoord.width;
		drag_mc._height = objCoord.height;

		sizeUiTL._x=x;
		sizeUiTL._y=y;
		sizeUiTR._x=x+bg_mc._width;
		sizeUiTR._y=y;
		sizeUiBL._x=x;
		sizeUiBL._y=y+bg_mc._height;
		sizeUiBR._y=y+bg_mc._height;
		sizeUiBR._x=x+bg_mc._width;
		sizeUiL._x=x;
		sizeUiL._y=y+bg_mc._height/2;
		sizeUiT._x=x+bg_mc._width/2;
		sizeUiT._y=y;
		sizeUiR._x=x+bg_mc._width;
		sizeUiR._y=y+bg_mc._height/2;
		sizeUiB._x=x+bg_mc._width/2;
		sizeUiB._y=y+bg_mc._height;

		
		
		centerUiRot._x=bg_mc._x;
		centerUiRot._y=bg_mc._y;
	}
}