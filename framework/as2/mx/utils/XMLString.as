//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


class mx.utils.XMLString {
	
	/**
	  Initializes the data structures needed to perform escapes and unescapes
	*/
	function XMLString() {
		escChars = {};
		escChars["<"] = "&lt;";
		escChars[">"] = "&gt;";
		escChars["'"] = "&apos;";
		escChars["\""]= "&quot;";
		escChars["&"] = "&amp;";
		unescChars = {};
		unescChars["&amp;"]="&";
		unescChars["&apos;"]="'";
		unescChars["&quot;"]="\"";
		unescChars["&lt;"]="<";
		unescChars["&gt;"]=">";
	}
	
	/**
	  Escapes the specified string and returns one that is XML safe. i.e.
	  removes any < > & ' characters and replaces them with the corresponding
	  &gt; etc.
	  
	  @param	val String containing the data to escape
	  @return	String containing the newly escaped string
	*/
	public static function escape( val:String ):String {
		var result:String="";
		var c;
		for( var i:Number=0; i<val.length; i++ ) {
			c =val.charAt( i );
			if( escChars[c] != undefined )
				result += escChars[c];
			else
				result += c;
		}
		return( result );
	}
	
	/**
	  Unescapes the specified string and returns one that has all previously escaped characters
	  to their normal state. i.e. removes any &gt; &quot; sequences and replaces them with the 
	  corresponding > ' etc.
	  
	  @param	val String containing the data to unescape
	  @return	String containing the newly unescaped string
	*/
	public static function unescape( val:String ):String {
		var indx:Number=0;
		var seqLen:Number=0;
		var lstIndx:Number=0;
		if( val != null ) {
			for( var i in unescChars ) {
				seqLen= String( i ).length;
				indx=val.indexOf( i, 0 );
				lstIndx=indx;
				while( indx != -1 ) {
					val = val.substring( 0, indx ) + unescChars[i] + val.substring( indx+seqLen );
					indx= val.indexOf( i, 0 );
					if( lstIndx == indx )
						indx =-1;
					lstIndx= indx;
				}
			}
		}
		return( val );
	}
	
	private static var escChars:Object;
	private static var unescChars:Object;
	private static var _ref:XMLString = new XMLString();
}