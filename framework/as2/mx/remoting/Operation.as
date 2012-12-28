//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.Service;
import mx.remoting.PendingCall;
import mx.rpc.Responder;

/**
 * Operation works as a layer between Service and PendingCall to
 * keep a reference to a custom responder.
 **/
class mx.remoting.Operation
{
    public function Operation(methodName:String, parent:Service)
    {
        __service = parent;
        __responder = parent.responder;
        __methodName = methodName;
        __invokationName = __service.name + "." + methodName;
        __request = new Object();
        __arguments = new Array();
    }

    /**
        Create any arguments from the request structure, which is needed for data binding, then send.
    */
    function createThenSend(Void):PendingCall
    {
        createArguments();
        return send();
    }

    /**
        Create a PendingCall to manage the responders and send the request.
    */
    function send(Void):PendingCall
    {
        __service.log.logInfo("Invoking " + __methodName + " on " + __service.name);	
	// did the user give a default client when he created this NetServiceProxy?
		var result:PendingCall = new PendingCall(__service,__methodName);
		result.responder = __responder;

        //Copy args before modifying
        var inputArgs:Array = null;
        if (__arguments == null)
            inputArgs = new Array();
        else
            inputArgs = __arguments.concat();

        //Calculate this every time as the service name may have been updated...
        __invokationName = __service.name + "." + __methodName;

        //Prepend args with invokation target and our pending call
        inputArgs.unshift( __invokationName, result );

		//Send our call through our Connection
		__service.connection.call.apply( __service.connection, inputArgs );

		return result;
    }

    /**
       Only sets up the arguments... send() must be called to
       actually send the request. This method's name is modelled on the WebServices
       approach... although it's pretty meaningless to Flash Remoting.
    */
    function invoke(a:Array):Void
    {
        __arguments = a;
    }

    public function get responder ():Responder
    {
        return __responder;
    }

    public function set responder (r:Responder):Void
    {
        __responder = r;
    }

    public function get request():Object
    {
        return __request;
    }

    public function set request(r:Object):Void
    {
        __request = r;
    }

    /**
    The name of the method this operation represents.
    */
    public function get name ():String
    {
        return __methodName;
    }

    /**
    Creates arguments from the request.
    */
    private function createArguments():Void
    {
        if (__request != null)
        {
            __arguments = new Array();

            //[Pete] Copy request args to our own arguments array. This code
            //was taken from SOAP based RemoteObject.

          
	    // gather up the current request values and put into an array
            // called arguments for the invoker service.
            for (var v in __request)
            {
                if (v != "arguments")
                {
                    //use unshift because for..in goes "last added first"
                    __arguments.unshift(__request[v]);
                }
            }
	}
    }

    private var __request : Object;
    private var __invokationName : String;
    private var __service : Service;
    private var __responder : Responder;
    private var __arguments : Array;
    private var __methodName : String;
}
