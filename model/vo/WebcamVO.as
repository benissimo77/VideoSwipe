package com.videoswipe.model.vo
{
	import flash.media.Camera;

	public class WebcamVO
	{
		private var _cam:Camera;
		private var _name:String;					// the name of the stream (usually the token of this client)
		private var _width:Number = 320;			// width of the camera
		private var _height:Number = 240;			// height of the camera
		private var _fps:Number = 12;				// fps
		private var _bandwidth:Number = 120;		// bandwidth
		private var _quality:Number = 30;			// quality (0-100)
		private var _codec:String = "";

		public function set camera(cam:Camera):void {
			trace("WebcamVO:: camera:", cam.width, cam.height );
			_cam = cam;
			
			_cam.setMode(cam.width, cam.height, _fps);
			
			_cam.setQuality(_bandwidth * 1024 / 8, 0);	//bandwidth is measured in kbps
			if (_bandwidth == 0) {
				_cam.setQuality(0, 100);					//max quality no matter how much bandwidth
			}
		}
		public function get camera():Camera {
			return _cam;
		}
		public function set streamname(name:String):void {
			_name = name;
		}
		public function get streamname():String {
			return _name;
		}
		public function set width(w:Number):void {
			_width = w;
			_cam.setMode(w, _height, _fps);
		}
		public function get width():Number {
			return _width;
		}
		public function set height(h:Number):void {
			_height = h;
			_cam.setMode(_width, h, _fps);
		}
		public function get height():Number {
			return _height;
		}
		public function get fps():Number {
			return _fps;
		}
		public function get bandwidth():Number {
			return _bandwidth;
		}
		public function get quality():Number {
			return _quality;
		}
		public function set codec(c:String):void {
			_codec = c;
		}
		public function get codec():String {
			return _codec;
		}
		
	}
}