/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.model.vo.VideoMessageVO;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class VideoMessageProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "VideoMessageProxy";

		private var _streaming:Boolean;	// is camera streaming currently?
		private var _recording:Boolean;	// is camera recording currently?
		private var _synchro:Array;

		public function VideoMessageProxy(data:Object = null) {
			super(NAME, data);
			
		}

		override public function onRegister():void {
			trace("VideoMessageProxy:: onRegister:" );
			_synchro = new Array();
		}

		public function deRegisterAllClients():void
		{
			_synchro.length = 0;
		}
		public function registerClient( s:String ):void
		{
			_synchro.push( s );
		}
		public function set streaming( _s:Boolean ):void
		{
			_streaming = _s;
		}
		public function get streaming():Boolean
		{
			return _streaming;
		}
		public function set recording( _r:Boolean ):void
		{
			_recording = _r;
		}
		public function get recording():Boolean
		{
			return _recording;
		}
		
		public function get vo():VideoMessageVO {
			return data as VideoMessageVO;
		}

	}
}