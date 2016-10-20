package com.sayaku 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author sayaku
	 */
	public class SerialEvent extends Event
	{
		public static const GET_DATA:String = "GET_DATA";
		public var data:Object;
		
		public function SerialEvent(type:String,bubbles:Boolean=false,data:Object=null,cancelable:Boolean=false) 
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		
	}

}