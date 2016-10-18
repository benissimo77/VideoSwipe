package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class NetConnectionVO 
	{
		private static const _defaultApp:String = "_";
		private static const _defaultInst:String = "lounge";
		
		private var _netConnectionURL:String;
		private var _application:String;
		private var _applicationInstance:String;
		private var _facebookVO:FacebookVO;	// cache a local copy of the facebookVO to access user info
		private var _token:String;		// secure token used to connect (we currently use the facebook uid)
		private var _connected:Boolean;	// logs whether we are actually connected or not
		private var _inLounge:Boolean;	// true if we are in the lounge application
		
		public function NetConnectionVO() 
		{
			_netConnectionURL = "rtmp://fms01.video4all.nl:80";
			_application = _defaultApp;
			_applicationInstance = _defaultInst;	// default arrival point, can be overridden
			_token = "";
			_connected = false;
			_inLounge = true;
		}
		
		// PUBLIC GETTER/SETTERS
		public function set room(r:String):void
		{
			var split:Array = r.split("/");
			application = split[0];
			applicationInstance = "";
			if (split.length > 1) applicationInstance = split[1];
			_inLounge = false;
			if (application == _defaultApp && applicationInstance == _defaultInst) _inLounge = true;
		}
		public function set lounge(b:Boolean):void
		{
			_inLounge = b;
			if (b) {
				application = _defaultApp;
				applicationInstance = _defaultInst;
			}
		}
		public function get lounge():Boolean
		{
			return _inLounge;
		}
		public function get applicationInstance():String 
		{
			return _applicationInstance;
		}
		
		public function set applicationInstance(value:String):void 
		{
			_applicationInstance = value;
		}
		
		public function get application():String 
		{
			return _application;
		}
		public function set application(value:String):void 
		{
			_application = value;
		}

		public function get netConnectionURL():String
		{
			return _netConnectionURL;
		}
		
		public function get connected():Boolean 
		{
			return _connected;
		}
		
		public function set connected(value:Boolean):void 
		{
			_connected = value;
		}
		public function set uid(_s:String):void
		{
			_facebookVO.uid = _s;
		}
		public function get uid():String 
		{
			return _facebookVO.uid;
		}
		
		public function get username():String 
		{
			return _facebookVO.name;
		}
		public function get friendlist():FriendlistVO
		{
			return _facebookVO.friends;
		}
		
		private function get facebookVOX():FacebookVO 
		{
			return _facebookVO;
		}
		
		public function set facebookVO(value:FacebookVO):void 
		{
			_facebookVO = value;
		}
		
		
		
	}

}