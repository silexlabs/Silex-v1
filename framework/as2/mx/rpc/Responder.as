//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

interface mx.rpc.Responder {
	function onResult( result:mx.rpc.ResultEvent ):Void;
	function onFault( fault:mx.rpc.FaultEvent ):Void;
}