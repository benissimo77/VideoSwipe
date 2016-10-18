package com.videoswipe.model
{
	import flash.media.Camera;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	/**
	 * LayoutsModel
	 * 
	 * @author Ben Silburn
	 */
	public class CameraListModel extends Proxy implements IProxy
	{
		public static const NAME:String = "CameraListModel";
		public static const UPDATE:String = NAME + "Update";
		
		private var _cameras:Array;
		private var _active:uint = 0;
		private var _nCameras:uint = 0 ;
		
		public function CameraListModel():void
		{
			trace("CameraListModel: hello.");
            super( NAME, Number(0) );
			
			_cameras = Camera.names;
			trace("CameraListModel:: retrieving list of cameras..." + _cameras.length + " found.");
			if (_cameras.length > 0) {
				var cam:Camera = Camera.getCamera();	// this is only needed in order to retrieve the index of the default camera
				_active = cam.index;
				if (CONFIG::tablet) {
					if (_cameras.length > 1) {
						_active = 1;
					}
				}
			}
		}
		
		public function getCamera(i:uint):Camera
		{
			if (i >= _cameras.length) {
				return null;
			} else {
				return Camera.getCamera(String(i));
			}
		}
		public function getCameras():Array
		{
			return _cameras;
		}
		public function getActive():uint
		{
			return _active;
		}
		public function getActiveCamera():Camera {
			return getCamera(_active);
		}

		public function setActive(n:uint):void
		{
			if (n > _cameras.length) {
				// error - don't update
			} else {
				_active = n;
			}
			this.update();
		}

		protected function update():void
		{
			sendNotification(UPDATE);
		}

	}
	
}