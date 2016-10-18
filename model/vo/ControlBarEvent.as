package com.videoswipe.model.vo 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class ControlBarEvent extends Event
	{
		public static const EVENT:String = "event";
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const SEEK:String = "seek";
		public static const VOLUME:String = "volume";
		public static const FULLSCREEN:String = "fullscreen";

		public var event:String;
		public var data:Object;

		public function ControlBarEvent( event : String , data : Object = null)
		{
			super( EVENT , true, true );
			this.event = event;
			this.data = data;
		}
			
	}

}