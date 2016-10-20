package com.sayaku 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author sayaku
	 */
	public class SerialPort extends EventDispatcher
	{
		private var _nativeSerial:NativeSerialPort;
		private var _portName:String;
		private var _updateFPS:int = 1;//設定偵測頻率,每秒偵測一次(safe)
		private var _updateTimer:Timer;
		private var _maxBuffer:int = 4096;
		private var _readBuffer:ByteArray;
		private var _buffer:ByteArray;
		private var _callBackFunction:Function;

		private static var _instance:SerialPort;
		
		public function SerialPort(s:Singleton) 
		{
			_nativeSerial = NativeSerialPort.Instance;
			_readBuffer = new ByteArray();
			for (var i:int = 0; i < _maxBuffer; i++) 
			{
				_readBuffer.writeByte(0);
			}
			_readBuffer.position = 0;
			_updateTimer = new Timer(1000 /_updateFPS);
			
		}
		
		public static function get instance():SerialPort
		{
			return _instance ||= new SerialPort(new Singleton);
		}
		
		public static function get nativeSerialPort():NativeSerialPort
		{
			return instance._nativeSerial;
		}
		
		//偵測頻率
		public function get updateFPS():int 
		{
			return _updateFPS;
		}
		
		public function set updateFPS(value:int):void 
		{
			_updateTimer.delay = 1000 / _updateFPS;
			_updateFPS = value;
		}
		
		public static function initialize(portName:String="COM1",baudRate:int=9600,callBackFunction:Function=null):SerialPort
		{
			instance.init(portName, baudRate);
			instance._callBackFunction = callBackFunction;
			instance.addEventListener(SerialEvent.GET_DATA, instance._callBackFunction);
			instance._updateTimer.addEventListener(TimerEvent.TIMER, instance.updateTimerTick);
			instance._updateTimer.start();
			return instance;
		}
		
		private function init(portName:String="COM1",baudRate:int=9600):void
		{
			_portName = portName;
			_nativeSerial.openPort(portName, baudRate);
		}
		
		private function updateTimerTick(e:TimerEvent):void 
		{
			//trace("timer");
			_readBuffer.position = 0;
			var bytesRead:int = _nativeSerial.update( _portName,_readBuffer) as int;
			_readBuffer.position = 0;
			//trace(bytesRead);
			updateBuffer(bytesRead)
		}
		
		private function updateBuffer( bytesRead:int):void
		{
			
			if (bytesRead > 0)
			{
				_buffer = new ByteArray();
				
				_readBuffer.readBytes(_buffer, 0, bytesRead);
				
				
				//var s:String = _buffer.toString().replace(/^\s+|\s+$/g, '');//過濾各種空白符號
				
				//trace("trace:" + s + ",length:" + s.length);
				var sArr:Array = _buffer.toString().split(/\n/g);
				if (sArr.length >= 3) {
				    //資訊去頭去尾	
					this.dispatchEvent(new SerialEvent(SerialEvent.GET_DATA, true, sArr[1]));
				}
				
				
				_readBuffer.clear();
				for (var i:int = 0; i < _maxBuffer; i++) 
			    {
				_readBuffer.writeByte(0);
			    }
			    _readBuffer.position = 0;
				
				
			}
			
		}
		
		public static function dispose():void
		{
			instance.removeEventListener(SerialEvent.GET_DATA, instance._callBackFunction);
			nativeSerialPort.closePort(instance._portName);
			instance._updateTimer.removeEventListener(TimerEvent.TIMER, instance.updateTimerTick);
			instance._updateTimer.stop();
		}	
		
	}

}
class Singleton{}