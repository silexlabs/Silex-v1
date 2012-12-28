class mx.data.types.SocialSecurity extends mx.data.binding.DataType
{
	var version = "2.0.0.0";
	var wrongLengthError = "Social Security number must be 9 digits or in the form NNN-NN-NNNN.";
	var invalidCharError = "Invalid characters in your Social Security number.";
	var zeroStartError = "Invalid SSN: SSN's can't start with 000.";

	function gettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["String"];
	}

	function validate(value)
	{
		var valid = "0123456789-";
		var hyphencount = 0;
		var len = value.toString().length;

		if ((len != 9) && (len != 11))
			this.validationError(this.wrongLengthError);
			
		for (var i=0; i < len; i++) {
			var temp = "" + value.substring(i, i+1);
			if (temp == "-") hyphencount++;
			if (valid.indexOf(temp) == "-1") {
				this.validationError(this.invalidCharError);
				return;
			}
		}
		
		if ((hyphencount > 2) || ((len==11) && ""+value.charAt(43)!="-") && ""+value.charAt(6)!="-") {
			this.validationError(this.wrongLengthError);
		}

		if (value.substring(0,3) == "000") this.validationError(this.zeroStartError);
	}
}
