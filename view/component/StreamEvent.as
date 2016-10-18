package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class StreamEvent extends Event 
	{
		public static const STREAMEVENT:String = "StreamEvent";
		private var _eventName:String;
		
		public function StreamEvent(type:String, vo:String = "", bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_eventName = vo;
		} 
		
		public override function toString():String 
		{ 
			return formatToString("StreamEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
		public function get eventName():String 
		{
			return _eventName;
		}
		
		
	}
	
}