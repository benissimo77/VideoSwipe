package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import fl.controls.Button;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author 
	 */
	public class NetConnectionView extends Sprite
	{
		public const HEIGHT:int = 60;
		private var _userimage:Loader;
		private var _connect:Button;
		private var _username:TFTextField;
		private var _statusText:TFTextField;
		private var _status:int;	// holds the current connection status (an enum)
		private var _connectionLight:ConnectionLight;
		private var _connectionURL:String;

		public function NetConnectionView() 
		{
			trace("NetConnectionView:: NetConnectionView: hello.");
			initView();
		}
		
		private function initView():void
		{
			// CONNECT BUTTON
			_connect = new Button();
			_connect.name = "connect";
			_connect.label = "CONNECT";
			_connect.height = 28;
			addChild(_connect);
			// USERNAME TEXT
			_username = new TFTextField();
			_username.colour = 0xffffff;
			addChild(_username);
			// USER IMAGE
			_userimage = new Loader();
			addChild(_userimage);
			// STATUS
			_statusText = new TFTextField();
			_statusText.text = "You are currently offline";
			_statusText.autoSize = TextFieldAutoSize.RIGHT;
			_statusText.width = 360;
			_statusText.height = 16;
			//addChild(_statusText);
			// CONNECTION LIGHT
			_connectionLight = new ConnectionLight();
			_connectionLight.width = 20;
			_connectionLight.height = 20;
			addChild(_connectionLight);
			_connectionURL = "";
			setStatus( AppConstants.OFFLINE );
			
		}
		
		public function set username(u:String):void
		{
			_username.text = u;
			_username.width = _username.textWidth + 4;
		}
		public function set userimage(i:String):void
		{
			_userimage.load( new URLRequest("https://graph.facebook.com/" + i + "/picture") );
			_userimage.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded);
		}
		public function set connectionURL(u:String):void
		{
			_connectionURL = u;
		}
		
		public function get status():int 
		{
			return _status;
		}
		public function setStatus(s:int):void
		{
			_status = s;
			_connectionLight.setStatus(s);
			_connect.enabled = true;
			if (s == AppConstants.OFFLINE) {
				_statusText.text = "You are currently offline";
				_connect.label = "CONNECT";
			} else if (s == AppConstants.CONNECTING) {
				_statusText.text = "Attempting to connect...";
				_connect.enabled = false;
			} else if (s == AppConstants.ONLINE) {
				_statusText.text = _connectionURL;
				_connect.label = "DISCONNECT";
			}
		}
		private function imageLoaded(e:Event):void
		{
			_userimage.contentLoaderInfo.removeEventListener( Event.COMPLETE, imageLoaded );
			_userimage.width = 24;
			_userimage.height = 24;
			_username.x = _userimage.x + _userimage.width + 4;
		}
		public function setWidth(_w:int):void
		{
			trace("NetConnectionView:: setWidth:", _w);
			_connectionLight.x = 8;
			_connectionLight.y = 8;
			_connect.x = _connectionLight.x + _connectionLight.width + 4;
			_connect.y = 4;
			_userimage.x = _connect.x + _connect.width + 4;
			_userimage.y = 6;
			_username.x = _userimage.x;	// this will be moved when image is loaded
			_username.y = _userimage.y + 4;
			_statusText.x = _w - _statusText.width - 4;
			_statusText.y = _connect.y + _connect.height + 4;
		}
	}

}