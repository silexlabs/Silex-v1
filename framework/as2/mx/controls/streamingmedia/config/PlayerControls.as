//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.Label;
import mx.controls.RadioButton;
import mx.controls.RadioButtonGroup;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.config.PlayerControls
{
	private var controlsLabel:Label;
	private var placementGroup:RadioButtonGroup;
	private var topRadioButton:RadioButton;
	private var bottomRadioButton:RadioButton;
	private var leftRadioButton:RadioButton;
	private var rightRadioButton:RadioButton;
	private var policyLabel:Label;
	private var policyGroup:RadioButtonGroup;
	private var onRadioButton:RadioButton;
	private var offRadioButton:RadioButton;
	private var autoRadioButton:RadioButton;

	private var policyListener:Object;
	private var placementListener:Object;
	
	public function PlayerControls()
	{
		init();
	}
	
	/**
	 * Initialize from the constructor
	 */
	private function init():Void
	{
	}
	
	private function initOnFrame1():Void
	{
		var x:Object = _root.xch;
		
		// Initial control values
		// Initialize controlPlacement group
		if (x.controlPlacement == "top")
		{
			// Select the top radio button
			topRadioButton.setSelected(true);
		}
		else if (x.controlPlacement == "left")
		{
			// Select the left radio button
			leftRadioButton.setSelected(true);
		}
		else if (x.controlPlacement == "right")
		{
			// Select the right radio button
			rightRadioButton.setSelected(true);
		}
		else
		{
			// bottom is default
			x.controlPlacement = "bottom";
			bottomRadioButton.setSelected(true);
		}

		// Initialize policyGroup
		if (x.controllerPolicy == "on")
		{
			onRadioButton.setSelected(true);
		}
		else if (x.controllerPolicy == "off")
		{
			onRadioButton.setSelected(true);
		}
		else
		{
			// auto is default
			x.controllerPolicy = "auto";
			autoRadioButton.setSelected(true);
		}

		policyListener = new Object();
		policyListener.form = this;
		policyListener.click = function(ev)
		{
//			Tracer.trace("policyListener: " + ev.target);
			this["form"].handlePolicy();
		};
		policyGroup = this[ onRadioButton.groupName ];
		policyGroup["addEventListener"]("click", policyListener);

		placementListener = new Object();
		placementListener.form = this;
		placementListener.click = function(ev)
		{
//			Tracer.trace("placementListener: " + ev.target);
			this["form"].handleControlPlacement();
		};
		placementGroup = this[ topRadioButton.groupName ];
		placementGroup["addEventListener"]("click", placementListener);

	}

	
	public function handlePolicy():Void
	{
		// The policy has been changed.
		var policy:String = getPolicy();
//		Tracer.trace("new policy=" + policy);
		updateData("controllerPolicy", policy);
	}
	
	public function handleControlPlacement():Void
	{
		var pos:String = getPlacement();
//		Tracer.trace("position=" + pos);
		updateData("controlPlacement", pos);
	}
	
	/**
	 * Update a data item to the xch object.
	 */
	public function updateData(name:String, value:Object):Void
	{
		Tracer.trace("PlayerControls.updateData: " + name + "=" + value);
		_root.xch[name] = value;
	}

	/**
	 * @return The selected policy
	 */
	private function getPolicy():String
	{
		var policy:String = "";

		if (onRadioButton.selected)
		{
			policy = onRadioButton.data;
		}
		else if (offRadioButton.selected)
		{
			policy = offRadioButton.data;
		}
		else if (autoRadioButton.selected)
		{
			policy = autoRadioButton.data;
		}
//		Tracer.trace("PlayerControls.getPolicy: " + policy);

		return policy;
	}
	

	/**
	 * @return The selected control position.
	 */
	private function getPlacement():String
	{
		var placement:String = "";
		if (topRadioButton.selected)
		{
			placement = topRadioButton.data;
		}
		else if (bottomRadioButton.selected)
		{
			placement = bottomRadioButton.data;
		}
		else if (leftRadioButton.selected)
		{
			placement = leftRadioButton.data;
		}
		else if (rightRadioButton.selected)
		{
			placement = rightRadioButton.data;
		}

//		Tracer.trace("PlayerControls.getPlacement: " + placement);
		return placement;
	}

}