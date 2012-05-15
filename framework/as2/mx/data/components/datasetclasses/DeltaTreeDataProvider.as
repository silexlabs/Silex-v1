//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.components.datasetclasses.Delta;
import mx.data.components.datasetclasses.DeltaItem;
import mx.data.components.datasetclasses.DeltaPacket;
import mx.utils.Iterator;

/**
  This class provides the DeltaPacket information in XML format for
  the Tree component.
*/
class mx.data.components.datasetclasses.DeltaTreeDataProvider extends Object {
	
	static function getDataProvider( dp:DeltaPacket ):XML {
		var treeXML:String = "<node label='["+ dp.getTransactionId()+ "]'>";
		var kinds:Array = ["Property", "Method" ];
		var ops:Array = ["Added", "Removed", "Modified" ];
		var dpi:Iterator = dp.getIterator();
		var d:Delta;
		var di:DeltaItem;
		var cl:Array;
		var info:String;
		var src:Object;
		while( dpi.hasNext()) {
			d= Delta(dpi.next());
			treeXML += "<delta label='["+d.getId()+ "] "+ops[d.getOperation()]+"'>";
			src=d.getSource();
			info = "<node label='source'>";
			for( var i in src )
				if(( typeof( src[i] ) != "function" ) && ( i != "__ID__" ))
					info += "<property label='"+i +"="+src[i]+"'/>";
			info += "</node>";
			treeXML += info;
			cl= d.getChangeList();
			if( cl.length > 0 ) {
				treeXML += "<delta_items label='delta items'>";
				for( var i:Number= 0; i<cl.length; i++ ) {
					treeXML += "<delta_item label='"+ kinds[cl[i].kind]+ "'><node label='"+cl[i].name+"'>";
					if( cl[i].kind == DeltaItem.Property )
						 treeXML += "<node label='oldValue="+ cl[i].oldValue+ "'/><node label='newValue="+cl[i].newValue+"'/>";
					else {
						treeXML += "<node label='arguments'>";
						var args:Array= cl[i].argList;
						for( var j:Number=0; j<args.length; j++ )
							treeXML += "<node label='"+args[j]+ "'/>";
						treeXML += "</node>"; 
					} // else
					treeXML += "</node></delta_item>";
				} // for
				treeXML += "</delta_items>";
			}
			treeXML += "</delta>";
		} // while
		treeXML += "</node>";
		//trace( treeXML );
		return( new XML( treeXML ));
	}
}