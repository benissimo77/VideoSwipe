package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class CameraEvent extends Event 
	{
		public static const CAMERASTREAMING:String = "CameraStreaming";
		private var _streaming:Boolean;
		
		public function CameraEvent(type:String, vo:Boolean = false, bubbles:Boolean=true, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_streaming = vo;
		} 
		
		public override function clone():Event 
		{ 
			return new CameraEvent(type, streaming, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CameraEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get streaming():Boolean
		{
			return _streaming;
		}
		
		
	}
	
}