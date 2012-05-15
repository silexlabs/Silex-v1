class mx.data.types.ZipCode extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["String"];
	}
	
	static var version = "2.0.0.0";
	var wrongLengthError = "Zip code must be 5 digits or 5+4 digits.";	
	var invalidCharError = "Invalid characters in your zip code.";
	var wrongFormatError = "The zip+4 extension must be formatted like '12345-6789'.";
	
	function validate(value)
	{
		var valid = "0123456789-";
		var hyphencount = 0;
		var len = value.toString().length;

		if ((len != 5) && (len != 10))
			this.validationError(this.wrongLengthError);
			
		for (var i=0; i < len; i++) {
			var temp = "" + value.substring(i, i+1);
			if (temp == "-") hyphencount++;
			if (valid.indexOf(temp) == "-1") {
				this.validationError(this.invalidCharError);
				return;
			}
		}
		
		if ((hyphencount > 1) || ((len==10) && ""+value.charAt(5)!="-")) {
			this.validationError(this.wrongFormatError);
		}
	}
}