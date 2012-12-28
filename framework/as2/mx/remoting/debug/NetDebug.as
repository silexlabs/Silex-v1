import mx.remoting.debug.events.NetDebugTrace;
import mx.remoting.debug.GlobalLocalConnection;
import mx.remoting.debug.events.NetDebugError;
import mx.remoting.debug.NetDebugConfig;
import mx.remoting.debug.events.NetDebugFailedSendError;
import mx.remoting.debug.commands.GetConfig;
import mx.remoting.debug.events.NetDebugStatus;
import mx.remoting.debug.events.NetDebugTraceNetServices;

intrinsic class mx.remoting.debug.NetDebug extends Object
{
   public function NetDebug();
   private var _config:mx.remoting.debug.NetDebugConfig;
   private var _glc:mx.remoting.debug.GlobalLocalConnection;
   private var _ncs:Array;
   private var _nextNewId:Number;
   private function _trace(traceobj:Object):Void;
   private function _traceNetServices(who:String, severity:String, number:Number, message:String):Void;
   public function addNetConnection(nc:NetConnection):Number;
   public function getConfig():mx.remoting.debug.NetDebugConfig;
   static public function getNetDebug():mx.remoting.debug.NetDebug;
   static public function globalOnStatus(statusobj:Object):Void;
   static public function initialize():Boolean;
   static private var ndSingleton:mx.remoting.debug.NetDebug;
   public function onEvent(eventObj:Object):Boolean;
   public function onEventError(errorObj:Object):Boolean;
   public function onReceiveCommand(commandobj:Object):Void;
   public function onReceiveError(errorobj:Object):Void;
   public function removeNetConnection(nc:NetConnection):Void;
   public function requestNewConfig():Boolean;
   public function sendCommand(commandobj):Boolean;
   public function sendDebugEvent(eventobj:Object):Boolean;
   public function sendStatus(statusobj:Object):Boolean;
   static public function stripNCDEventToMinmal(ev:Object):Object;
   static public function trace(obj:Object):Void;
   static public function traceNetServices(who:String, severity:String, number:Number, message:String):Void;
   public function updateConfig(config:Object):Void;
   static var version:String;
};
