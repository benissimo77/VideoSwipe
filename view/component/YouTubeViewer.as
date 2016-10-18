package com.videoswipe.view.component 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	/**
	 * ...
	 * @author 
	 */
	public class YouTubeViewer extends Sprite
	{

		private static const EMBEDDEDPLAYER:String = "http://www.youtube.com/v?version=3";
		private static const CHROMELESSPLAYER:String = "http://www.youtube.com/apiplayer?version=3";
		private static const DAILYMOTIONPLAYER:String = "http://www.dailymotion.com/swf?enableApi=1&chromeless=1";

		private var _loader:Loader = new Loader();	// youTube player is loaded into this
		private var _screenGuard:Sprite;			// covers youTube player to catch all mouse events

		private var _width:int = 320;	// cache a local copy of the player width and height
		private var _height:int = 240;
		
		public function YouTubeViewer() 
		{
			this.name = "ytView";

			// The player SWF file on www.youtube.com needs to communicate with your host
			// SWF file. Your code must call Security.allowDomain() to allow this
			// communication.
			if (!CONFIG::tablet) {
				Security.allowDomain("www.youtube.com");
				Security.allowDomain("ytimg.com");
				//Security.allowDomain("www.dailymotion.com");
			}

			_loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit);
			_loader.load(new URLRequest( CHROMELESSPLAYER ));
//			_loader.load(new URLRequest( DAILYMOTIONPLAYER ));
		}

		// the viewer is now set up
		public function setSize(w:int, h:int):void
		{
			_width = w;
			_height = h;
			redraw();
		}

		private function onLoaderInit(e:Event):void
		{
			trace("YouTubeViewer:: onLoaderInit: hello.");
			_loader.contentLoaderInfo.removeEventListener(Event.INIT, onLoaderInit);
			addChild(_loader);
			// screenguard is important! otherwise mouse doesn't show...
			_screenGuard = new Sprite();
			_screenGuard.name = "canvas";
			addChild(_screenGuard);
			
			player.addEventListener("onReady", onPlayerReady);
		}

		private function onPlayerReady(event:Event):void {
			// Event.data contains the event parameter, which is the Player API ID
			trace("YouTubeViewer:: onPlayerReady:", Object(event).data);

			player.removeEventListener("onReady", onPlayerReady);

			// Once this event has been dispatched by the player, we can use
			// cueVideoById, loadVideoById, cueVideoByUrl and loadVideoByUrl
			// to load a particular YouTube video.
			dispatchEvent( new Event(Event.INIT) );
			redraw();

			// dummy - just to test the playing of a video...
			//player.loadVideoById("xqj7vz");	// sample daily motion video
			//player.loadVideoById("hvZJI8rerWA");	// sample youtube video
		}

		private function redraw():void
		{
			if (loader && player && player.setSize) {
				player.setSize(_width, _height);
			}
			if (_screenGuard) {
				drawScreenguard();
			}
		}
		private function drawScreenguard():void
		{
			_screenGuard.graphics.clear();
			_screenGuard.graphics.beginFill(0x000, 0);
			_screenGuard.graphics.drawRect(0, 0, _width, _height);
			_screenGuard.graphics.drawRect(_width, _height-48, _width*-0.50, -44);	// remove a chunk to allow user to click away ads
			_screenGuard.graphics.endFill();
		}

		// keyHandler
		// only used in 'screengrab' mode - allows viewer to be tweaked around to get
		// best image for promotional screenshots
		public function keyHandler(e:KeyboardEvent):void
		{
			trace("YouTubeViewer:: keyHandler:", e.keyCode );
			switch (e.keyCode) {
				
				case 37:
					this.x -= 12;
					break;
				case 39:
					this.x += 12;
					break;
				case 38:
					this.y -= 8;
					break;
				case 40:
					this.y += 8;
					break;
				case 79:
					_width += 16;
					redraw();
					break;
				case 73:
					_width -= 16;
					redraw();
					break;
				case 74:
					_height -= 9;
					redraw();
					break;
				case 75:
					_height += 9;
					redraw();
					break;
					
			}
		}
		//
		// GETTER / SETTERS
		//
		private function get player():Object
		{
			return _loader.content;
		}
		public function get loader():Loader 
		{
			return _loader;
		}
	}

}