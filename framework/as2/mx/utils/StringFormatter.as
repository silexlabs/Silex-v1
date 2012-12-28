/**
  The formatting class provides a mechanism for displaying and saving data in the specified format. The constructor 
	accepts the format and an array of tokens and uses these values to create the data structures to support the formatting
	during data retrieval and saving. 
	
	@param	format string containing the desired format
	@param	tokens string containing the character tokens within the specified format string that will be replaced during
					data formatting operations.
	@param	extractTokenFunc string containing the name of the token accessor method to call when formatting for display.
					The method signature is <i>value: anything, tokenInfo:{ token:id, begin:start, end:finish }</i>  This method 
					must return a string representation of value for the specified tokenInfo.
	@param	infuseTokenFunc string containing the name of the token mutator method to call when the token data should be
					infused into a value. The method signature is <i>tokenData: string, tokenInfo: { token:id, begin:start, end:finish }, 
					value: anything</i>  This	method must update value for the tokenData and tokenInfo specified i.e. infuse tokenData 
					into value.
	@param	obj reference to the object that the extractTokenFunc and infuseTokenFunc methods exist on
	@access private
	@author	Jason Williams
*/
class mx.utils.StringFormatter 
{
	var __extractToken;
	var __infuseToken;
	var __tokenInfo;
	var __format: Function;
	
	function StringFormatter( format, tokens, extractTokenFunc, infuseTokenFunc ) {
	
		this.setFormat( format, tokens );
		this.__extractToken = extractTokenFunc;
		this.__infuseToken = infuseTokenFunc;
	}

/**
	Extracts a value from the formatted data specified and stores it in the result value specified.  The formatted data
	specified is treated as a string, this method uses the current format and tokens specified to read through the given
	data to derive the result.  The calculation of result is delegated to the infuseTokenFunc currently specified.  This
	method is called with the current token data and the value specified here in result, it is up to the infuseTokenFunc 
	to "infuse" the data passed to it into the result.
	
	@param	formattedData string containing the data to convert or extract and infuse into result
	@param	result reference to the data that will be extracted from the formattedData specified.
	@access private
	@author	Jason Williams
*/
	function extractValue ( formattedData, result ) {

		if( result != null ) {
			var tokenInf = null;
			for( var i=0; i<this.__tokenInfo.length; i++ ) {
				tokenInf = this.__tokenInfo[i];
				this.__infuseToken( formattedData.substring( tokenInf.begin, tokenInf.end ), tokenInf, result );
			} // for
		}
	}

/**
  Returns the specified value formatted with the current format settings.  The specified value is not interpreted
	by this method, instead the current readTokenFunc is called with the value given here and the current token being
	processed.  The value returned from that method will be inserted into the format and returned.
	
	@param	value contains the value to apply formatting to
	@return string containing the specified value formatted using the current format settings
	@access private
	@author	Jason Williams
*/
	function formatValue( value ) {
		var result="";
		if( value != null ) {
			var curTokenInfo = this.__tokenInfo[0];
			result = this.__format.substring( 0, curTokenInfo.begin )+ this.__extractToken( value, curTokenInfo );
			
			var lastTokenInfo = curTokenInfo;
			for( var i=1; i<this.__tokenInfo.length; i++ ) {
				curTokenInfo = this.__tokenInfo[i];
				result += this.__format.substring( lastTokenInfo.end, curTokenInfo.begin )+ this.__extractToken( value, curTokenInfo );
				lastTokenInfo = curTokenInfo;
			} // for
		}
		return( result );
	}

/**
  Returns this formatter's current format string.
	
	@return	string containing the current format string.
	@access private
	@author	Jason Williams
*/
	function getFormat() {
		
		return( this.__format );
	}

/**
  Sets the new formatting to the specified value.
	
	@param	format string containing the desired format
	@param	tokens comma delimited string containing the character tokens within the specified format string that 
					will be replaced during	data formatting operations.
	@example	Sets the formatting for a date to display two digits for the month, two for the day, and four for the year.
						myFormatter.setFormat( "MM/DD/YYYY", "M, Y, D");
	@access private
	@author	Jason Williams
*/
	function setFormat( format, tokens ) {
		if( format != this.__format ) {
			this.__format = format;
			// recalculate token information
			var tokenValues = tokens.split( "," );
			this.__tokenInfo = new Array();
			var start = 0;
			var finish = 0;
			var index = 0;
			for( var i=0; i<tokenValues.length; i++ ) {
				start = format.indexOf( tokenValues[i] );
				if(( start >= 0 ) && ( start < format.length )) { 
					finish = format.lastIndexOf( tokenValues[i] );
					finish = finish >=0 ? finish +1 : start +1;
					this.__tokenInfo.splice( index, 0, { token:tokenValues[i], begin:start, end:finish });
					index++;
				} // if the token is found
			} // for
			
			// sort the token information so that we can interate inorder<-- very important!
			this.__tokenInfo.sort( compareValues );
		} // if change is required
	}
	
	function compareValues( a, b ) {
		
		if( a.begin < b.begin )
			return( -1 );
		else
			if( a.begin > b.begin )
				return( 1 );
			else
				return( 0 );
	}
	
}