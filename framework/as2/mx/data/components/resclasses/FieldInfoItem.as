//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  The FieldInfoItem class defines a class that stores values for the RDBMSResolver's fieldInfo 
  collection property
  
  @author	Mark Rausch
*/
class mx.data.components.resclasses.FieldInfoItem extends Object {

	//------------------Public Methods----------------
	public function FieldInfoItem(fldName:String, ownName:String, key:Boolean) {
		fieldName = fldName;
		ownerName = ownName;
		isKey = key;
	}

	//-----------------Public Members----------------
	[Inspectable(defaultValue="")]
	public var fieldName:String;

	[Inspectable(defaultValue="")]
	public var ownerName:String;

	[Inspectable(defaultValue="true")]
	public var isKey:Boolean;
}