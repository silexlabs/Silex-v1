//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  Static class with methods for performing copies of in memory objects
  including nested properites arrays etc.
*/
class mx.utils.ObjectCopy {
	
	public static function copy( refObj:Object ):Object {
		var result:Object = new Function( refObj.__proto__.constructor)();
		copyProperties( result, refObj );
		return( result );
	} // copy
	
	public static function copyProperties( dstObj:Object, srcObj:Object ):Void {
		var to:String;
		for( var i in srcObj ) {
			to=typeof( srcObj[i] );
			if( to != "function" ) {
				if( to == "object" ) {
					if( srcObj[i] instanceof Array ) {
						var p:Array = new Array();
						var q:Array = srcObj[i];
						for( var j:Number=0; j<q.length; j++ )
							p[j]= q[j];
						dstObj[i] = p;
					}
					else
						if( srcObj[i] instanceof String )
							dstObj[i] = new String( srcObj[i] );
						else
							if( srcObj[i] instanceof Number )
								dstObj[i] = new Number( srcObj[i] );
							else
								if( srcObj[i] instanceof Boolean )
									dstObj[i] = new Boolean( srcObj[i] );
								else
									dstObj[i] = copy( srcObj[i] );
				}
				else
					dstObj[i] = srcObj[i];
			} // if not a function
		} // for
	} // copyProperties
}