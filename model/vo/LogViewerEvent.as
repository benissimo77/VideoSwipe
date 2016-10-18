package com.videoswipe.model.vo 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class LogViewerEvent extends Event
	{
		public static const EVENT:String = "event";
		public static const DOLOGITEM:String = "nextlogitem";

		public var event:String;
		public var data:Object;

		public function LogViewerEvent( event : String , data : Object = null)
		{
			super( EVENT , true, true );
			this.event = event;
			this.data = data;
		}
			
	}

}