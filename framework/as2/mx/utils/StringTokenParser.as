/*
   Title:       Macromedia Firefly Components
   Description: A set of data components that use XML and HTTP for transferring data between a Flash MX client and a server.
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc
   Author:		Jason Williams & Mark Rausch
   Version:     2.0
*/


/**
  The parser class provides the functionality to extract strings, integers, floats, and symbols from
  a string.  
	
  @param	source string buffer with the tokens to be parsed
  @param	[skipChars] Array of characters that should be treated as white space i.e. ignored
  @author	Jason Williams & Mark Rausch
*/
class mx.utils.StringTokenParser {
	
	//StringTokenParser constructor
	function StringTokenParser(source:String, skipChars:String) {
		this._source = source;
		this._skipChars = (skipChars == undefined) ? null : skipChars;
	} //StringTokenParser contructor

	//Static class constants
	public static var tkEOF:Number = -1;
	public static var tkSymbol:Number = 0;
	public static var tkString:Number = 1;
	public static var tkInteger:Number = 2;
	public static var tkFloat:Number = 3;

	
	//---------------------------------------------------------------------------------------
	//                                      Properties
	//---------------------------------------------------------------------------------------
	public function get token():String {return this._token;}
	
	
	//---------------------------------------------------------------------------------------
	//                                     Public methods
	//---------------------------------------------------------------------------------------

	/**
	  Returns the current character position within the source string.
		
	  @return	integer containing the current index in the source being parsed.
	  @author	Jason Williams
	*/
	public function getPos():Number {
		return( this._index );
	}


	/**
	  Parses the string at the current location and returns the type of token.  This method extracts the
	  next token in the string and stores it in the token property.
		
	  @return	the token type, which can be one of the following values
								<li>StringTokenParser.tkSymbol</li> indicates the current token is a symbol
								<li>StringTokenParser.tkEOF</li> indicates there are no more tokens in the buffer
								<li>StringTokenParser.tkString</li> indicates the current token is a string 
								<li>StringTokenParser.tkInteger</li> indicates the current token is an integer
								<li>StringTokenParser.tkFloat</li> indiciates the current token is a float
		
	  @example
			// create an array so we can trace what kind of token was found
			var KINDS:Array = new Array( "tkSymbol", "tkString", "tkInteger", "tkFloat" );
			var t:String = "Here_123Text _ is some text@/ 1234.5e+6 1566 \"my string\" 'another string'";
			var q:StringTokenParser = new StringTokenParser( t );
			var tk:Number = q.nextToken();
			while( tk != StringTokenParser.tkEOF ) {
				trace( KINDS[tk]+"="+ q.token );
				tk = q.nextToken();
			}
			// outputs
				tkSymbol=Here_123Text
				tkSymbol=_
				tkSymbol=is
				tkSymbol=some
				tkSymbol=text
				tkSymbol=@
				tkSymbol=/
				tkFloat=1234.5e+6
				tkInteger=1566
				tkString=my string
				tkString=another string			
				
	  @author	Jason Williams
	*/
	public function nextToken():Number {
		var i:Number;
		var p:Number; 
		var j:Number = this._source.length;
		this.skipBlanks();
		if ( this._index >= j ) 
			return( tkEOF );
			
		p= this._source.charCodeAt( this._index );
		// A..Z, a..z, _, catch all for high ascii 192-7923
		if((( p >= 65 ) && ( p <= 90 )) || (( p >= 97 ) && ( p <= 122 )) || (( p >= 192 ) && ( p <= Number.POSITIVE_INFINITY)) || ( p == 95 )) {
			i=this._index;
			this._index++;
			p= this._source.charCodeAt( this._index );
			// A..Z, a..z, 0..9, _, high ascii chars 192-7923
			while(((( p >= 65 ) && ( p <= 90 )) || (( p >= 97 ) && ( p <= 122 )) || (( p >=48 ) && ( p <=57 )) || (( p >= 192 ) && ( p <= Number.POSITIVE_INFINITY)) || ( p == 95 )) && ( this._index < j )) {
				this._index++;
				p= this._source.charCodeAt( this._index );
			}
			this._token = this._source.substring( i, this._index ); 
			return( tkSymbol );
		}
		else
		  // ", '
			if(( p== 34 ) || ( p== 39 )) {
				this._index++;
				i= this._index;
				p= this._source.charCodeAt( i );
				while((( p!= 34 ) && ( p != 39 )) && ( this._index < j )) {
					this._index++;
					p= this._source.charCodeAt( this._index );
				}
				this._token= this._source.substring( i, this._index );
				this._index++;
				return( tkString );
			}
			else
				// -, 0..9
				if(( p == 45 ) || (( p >=48 ) && ( p <=57 ))) {
					var kind:Number = tkInteger;
					i=this._index;
					this._index++;
					p= this._source.charCodeAt( this._index );
					//  0..9
					while((( p >=48 ) && ( p <=57 )) && ( this._index < j )) {
						this._index++;
						p= this._source.charCodeAt( this._index );
					}
					if( this._index < j ) {
						// 0..9, ., +, -, e, E
						if((( p >=48 ) && ( p <=57 )) || ( p == 46 ) || ( p == 43 ) || ( p == 45 ) || ( p == 101 ) || ( p == 69 ))
							kind= tkFloat;
						while(((( p >=48 ) && ( p <=57 )) || ( p == 46 ) || ( p == 43 ) || ( p == 45 ) || ( p == 101 ) || ( p == 69 )) && ( this._index < j )) {
							this._index++;
							p= this._source.charCodeAt( this._index );
						} // while
					} // if
					this._token = this._source.substring( i, this._index );
					return( kind );
				}
				else {
					this._token =this._source.charAt( this._index );
					this._index++;
					return( tkSymbol );
				}
	} //function nextToken()
	

	//---------------------------------------------------------------------------------------
	//                                    Private methods
	//---------------------------------------------------------------------------------------
	
	/**
	  Skips the blanks at the current location in the string buffer.
		
	  @author	Jason Williams
	*/
	private function skipBlanks() {
		if( this._index < this._source.length ) {
			var ch:String = this._source.charAt( this._index );
			while(( ch == " " ) || (( this._skipChars != null ) && skipChar( ch )))  {
				this._index++;
				ch = this._source.charAt( this._index );
			} // while
		} // if
	}
	
	
	/**
	  Skips the blanks at the current location in the string buffer.
		
	  @return 	boolean indicating whether or not the char passed in is skippable
	  @author	Jason Williams
	*/
	private function skipChar( ch:String ):Boolean {
		for( var i:Number=0; i < this._skipChars.length; i++ )
			if( ch == this._skipChars[i] )
				return( true );
		return( false );
	}
	
	//---------------------------------------------------------------------------------------
	//                                  Private member vars
	//---------------------------------------------------------------------------------------
	private var _source:String;
	private var _index:Number = 0;
	private var _skipChars:String;
	private var _token:String = "";
	
	
}