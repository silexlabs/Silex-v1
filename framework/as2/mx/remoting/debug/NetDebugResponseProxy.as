import mx.remoting.debug.events.NetDebugReceiveCall;
import mx.remoting.debug.events.NetDebugResult;
import mx.remoting.debug.events.NetDebugStatus;

intrinsic class mx.remoting.debug.NetDebugResponseProxy extends Object
{
   public function NetDebugResponseProxy(source:Object, original:Object);
   public function __resolve(name:String):Function;
   private var _originalNR:Object;
   private var _sourceNC:Object;
   public function onDebugEvents(debugevents:Array):Void;
   public function onResult(resultobj:Object):Void;
   public function onStatus(statusobj:Object):Void;
};
