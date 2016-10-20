package
{
	import com.sayaku.SerialEvent;
	import com.sayaku.SerialPort;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author sayaku
	 */
	public class Main extends Sprite 
	{
		
		public function Main() 
		{
		    SerialPort.initialize("COM4", 2400, onGetData);
			
			//移除請使用SerialPort.dispose();
		}
		
		private function onGetData(e:SerialEvent):void 
		{
			trace("rfid:"+e.data);
		}
		
		
		
	}
	
}