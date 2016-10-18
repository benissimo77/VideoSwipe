package com.videoswipe.view.component
{
	import com.videoswipe.model.vo.FriendVO;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * (c) Ben Silburn 2013
	 */
	public class FriendView extends Sprite
	{
		[Embed (source = "assets/led-green.png")]
		private static var StatusLight:Class;

		public static const WIDTH:int = 256;
		public static const HEIGHT:int = 32;
		
		private var _friendVO:FriendVO;
		private var _userimage:Loader;
		private var _selector:Shape;	// for LISTs - dropdown selector image
		private var _username:TextField;
		private var _statusLight:Bitmap;
		
		public function FriendView( _f:FriendVO = null) 
		{
			initView();
			if (_f) friendVO = _f;
		}
		
		private function initView():void
		{
			// IMAGE
			_userimage = new Loader();
			_userimage.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
            _userimage.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			_userimage.x = 2;
			_userimage.y = 2;
			addChild(_userimage);
			
			// SELECTOR
			_selector = new Shape();
			_selector.graphics.clear();
			_selector.graphics.beginFill(0, 0);
			_selector.graphics.drawCircle(0, 0, 6);
			_selector.graphics.endFill();
			_selector.graphics.beginFill(0x0000ff, 1);
			_selector.graphics.moveTo(-3, -4);
			_selector.graphics.lineTo(5, 0);
			_selector.graphics.lineTo(-3, 4);
			_selector.graphics.endFill();
			_selector.x = 15;	// centre sprite around its registration point so it can be rotated on the spot
			_selector.y = 15;

			// USERNAME
			_username = new TextField();
			_username.x = 2 + 28 + 2;
			_username.y = 8;
			_username.width = 160;
			_username.height = 20;
			_username.multiline = false;
			_username.defaultTextFormat = new TextFormat("Verdana", 12, 0x0000c0);
			_username.selectable = false;
			addChild(_username);
			
			// STATUS LIGHT
			_statusLight = new StatusLight();
			_statusLight.width = _statusLight.height = 8;
			_statusLight.x = WIDTH - _statusLight.width - 8;
			_statusLight.y = HEIGHT / 2 - _statusLight.height / 2;

			this.mouseChildren = false;	// all mouse events will come from this object
			this.name = "friendView";
		}
		
		private function drawView():void
		{
			drawUnselected();	// draws background for when mouse NOT over
			_username.text = _friendVO.name;

			var url:String = "https://graph.facebook.com/" + _friendVO.uid + "/picture";
			// for friendVO of type FRIEND we load an image, for type LIST we display a dropdown selector
			if (_friendVO.type == FriendVO.FRIEND) {
				_userimage.load( new URLRequest( url ));
			} else if (_friendVO.type == FriendVO.LIST) addChild(_selector);
			
			setOnlineStatus( _friendVO );
        }

		public function setOnlineStatus( _f:FriendVO ):void
		{
			if (this.contains(_statusLight)) removeChild(_statusLight);
			if (_f.connected || _f.live) {
				addChild(_statusLight);
			}
		}
        private function completeHandler(event:Event):void {
            //trace("completeHandler: " + event);
			_userimage.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
            _userimage.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_userimage.width = 28;
			_userimage.height = 28;
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            //trace("ioErrorHandler: " + event);
        }

		private function drawUnselected():void
		{
			var _col:int = 0xeeeeff;
			if (_friendVO.type == FriendVO.LIST) _col = 0xbbbbee;
			graphics.clear();
			graphics.lineStyle(0, 0xeeeeff, 1);
			graphics.beginFill(_col, 0.4);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
		}
		private function drawSelected():void
		{
			graphics.clear();
			graphics.lineStyle(0, 0xeeeeff, 1);
			graphics.beginFill(0x8888dd, 0.4);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
		}
		// PUBLIC GETTER/SETTERS
		public function get uid():String
		{
			return _friendVO.uid;
		}
		public function set friendVO( _f:FriendVO):void
		{
			_friendVO = _f;
			drawView();
		}
		public function get friendVO():FriendVO
		{
			return _friendVO;
		}
		public function set selected(b:Boolean):void
		{
			if (b) {
				drawSelected();
			} else {
				drawUnselected();
			}
		}
		public function set open(b:Boolean):void
		{
			_friendVO.open = b;
			_selector.rotation = b ? 90 : 0;
		}
		public function get open():Boolean
		{
			return _friendVO.open;
		}
		private function get connected():Boolean {
			return _friendVO.connected;
		}
		private function set connected(b:Boolean):void {
			_friendVO.connected = b;
		}
		private function get live():Boolean {
			return _friendVO.live;
		}
		private function set live( b:Boolean):void
		{
			_friendVO.live = b;
		}
		
	}

}