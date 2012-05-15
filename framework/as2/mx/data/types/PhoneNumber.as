class mx.data.types.PhoneNumber extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["String"];
	}

	var version = "2.0.0.0";
	var wrongLengthError = "Your telephone number must be 10 digits in length.";
	var invalidCharError = "Invalid characters in your phone number.";

	function validate (value)
	{
		var valid = "0123456789-()+ ";
		var len = value.toString().length;
		var digitLen = 0;
		for (var i=0; i < len; i++) {
			var temp = "" + value.substring(i, i+1);
			if (valid.indexOf(temp) == "-1") {
				this.validationError(this.invalidCharError);
				return;
			}
			if (valid.indexOf(temp) <= 9)
				digitLen++;
		}
		
		if (digitLen != 10)
			this.validationError(this.wrongLengthError);
	}
}