class mx.data.types.Obj extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["Object"];
	}

	function settableTypes() : Array /* of String */
	{
		return [null];
	}

	function validate(value)
	{	
		var loc = new Array();
		if (this.location instanceof Array)
		{
			loc = loc.concat(this.location);
		}
		else if (this.location != null)
		{
			// !!@ not implemented -indexed locations
			return;
		}
				
		for (var i = 0; i < this.type.elements.length; i++)
		{
			var element = this.type.elements[i];
			if (element.name == "[n]")
			{
				// !!@ not implemented - we don't validate arrays
				continue;
			}
			
			var field: mx.data.binding.DataType = 
				this.component.getField(this.property, loc.concat(element.name));
			var messages: Array = field.validateAndNotify(null, true);
			//Debug.trace("mx.data.types.Obj.validate messages", messages);

			for (var j in messages)
			{
				this.validationError(element.name + ":" + messages[j]);
			}
		}
	}
}
