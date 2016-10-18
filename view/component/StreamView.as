package com.videoswipe.view.component
{
	import com.adobe.utils.StringUtil;
	import com.videoswipe.model.vo.ControlBarEvent;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * StreamView
	 * view component for displaying video streams, creates basic video object and adds decoration
	 * eg border round video, name of stream, mouse event handlers etc
	 * @author Ben Silburn
	 */
	public class StreamView extends GlassSprite
	{
		protected var _video:Video; // protected so that classes that extend streamView can access video object
		protected var _uid:String;	// holds the uid of this user, to identify state changes with user changing state
		protected var _streamname:String;
		protected var _background:Loader; // background holds the facebook profile pic of user
		protected var _volume:SmallSlider; // slider to control volume of this stream
		protected var _streaming:Boolean;	// are we streaming now? (overridden by camera view)
		private var _ns:NetStream;
		private var _border:Sprite;
		private var _streambanner:Sprite;
		private var _versionBanner:Sprite;
		private var _state:SynchroBar; // a graphical representation of the state of this clients youTube player
		private var _duration:int; // (CURRENTLY NOT USED) cache the duration of the current video item for the synchro bar
		private var _version:String = "";
		private var _w:Number = 160;
		private var _h:Number = 120;
		
		public function StreamView(_nc:NetConnection)
		{
			_streaming = true;	// regular stream view is always streaming
			_ns = new NetStream(_nc);
			initView();
			setSize( _w, _h);	// force an initial size, which will also cause a redraw
			mouseOut(); // set initial state, simulates the state when no mouse over
		}
		
		private function initView():void
		{
			trace("StreamView:: initView:");
			
			_ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			var c:Object = new Object();
			c.onMetaData = function(o:Object):void
			{
				trace("NS.onMetaData: " + o.duration);
			}
			_ns.client = c;

			_background = new Loader();
			addChild(_background);
			_video = new Video(_w, _h);
			addChild(_video);
			_video.attachNetStream(_ns);

			_border = new Sprite();
			_streambanner = new Sprite();
			_versionBanner = new Sprite();
			
			addVolumeSlider();	// initialise _volume var
			addChild(_volume);

			addChild(_border);
			//addChild(_streambanner);
			//addChild(_versionBanner);
			_state = new SynchroBar();
			addChild(_state);
			this.addEventListener(MouseEvent.ROLL_OVER, mouseOver);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseOut);
			_volume.addEventListener(ControlBarEvent.EVENT, onVolumeChange);
		}
		
		// this fn can be overridden to use a different icon for the slider
		protected function addVolumeSlider():void
		{
			_volume = new SmallSlider("speaker");
			_volume.setSize(24, _h - 16);
			_volume.x = _w - 22;
			_volume.y = _h - 8;
			addChild(_volume);
		}
		
		protected function netStatusHandler(e:NetStatusEvent):void
		{
			//trace("StreamView:: netStatusHandler:", e.info.code);
			dispatchEvent( new StreamEvent("StreamEvent", e.info.code ));
			
			switch (e.info.code) {
				
				default:
					break;
			}
		}

		// add user profile pic
		// when the uid of this streamView is set, we load a background image of the users profile pic
		private function addUserProfilePicture( _s:String ):void
		{
			// load the user profile pic to serve as a background image
			_background.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			_background.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_background.load(new URLRequest("https://graph.facebook.com/" + _s + "/picture"));
		}
		// addStreamName
		// accepts a string and places it into a banner format (grey background) in neat text
		// the holder sprite (_streambanner) is always at 0,0 relative to video, background and label are placed accordingly
		private function addStreamName(_s:String):void
		{
			trace("StreamView:: addStreamName:", _s );
			
			var tf:TextFormat = new TextFormat();
			tf.font = "Verdana";
			tf.bold = true;
			tf.size = 18;
			var t:TextField = new TextField();
			t.multiline = false;
			t.text = _streamname;
			t.autoSize = "right";
			t.setTextFormat(tf);
			t.x = 0;
			t.y = 0;
			_streambanner.graphics.clear();
			_streambanner.graphics.beginFill(0xaaaaaa, 0.7);
			_streambanner.graphics.drawRect(0, 0, t.textWidth + 12, t.textHeight + 4);
			_streambanner.graphics.endFill();
			while (_streambanner.numChildren > 0)
			{
				_streambanner.removeChildAt(0);
			}
			_streambanner.addChild(t);
			//addChild(_streambanner);
			placeStreamBanner();
		}
		
		public function addVersion(v:Number):void
		{
			_version = String(v);
			drawVersion();
		}
		
		private function drawVersion():void
		{
			var tf:TextFormat = new TextFormat();
			tf.font = "Verdana";
			tf.bold = true;
			tf.size = 12;
			var t:TextField = new TextField();
			t.multiline = false;
			t.text = _version;
			t.autoSize = "right";
			t.setTextFormat(tf);
			t.x = 0;
			t.y = 4;
			t.width = _w - 8;
			while (_versionBanner.numChildren > 0)
			{
				_versionBanner.removeChildAt(0);
			}
			_versionBanner.addChild(t);
		}
		
		override public function redraw():void
		{
			_w = _width;
			_h = _height;

			// fill out this sprite so it will catch all mouse events
			this.graphics.clear();
			this.graphics.beginFill(0x000, 0);
			this.graphics.drawRect(0, 0, _w, _h);
			this.graphics.endFill();
			
			_video.width = _w;
			_video.height = _h;

			_state.scaleX = _state.scaleY = _w / 160;
			_state.x = 0;
			_state.y = _h + 2;

			_volume.setSize(24, _h - 16);
			//_volume.x = _w - 22;
			//_volume.y = _h - 8;
			_volume.x = 20;
			_volume.y = _h - 8;
			
			placeStreamBanner();
			drawVersion();
			mouseOut(); // resets the border
		}
		
		private function imageLoaded(e:Event):void
		{
			_background.contentLoaderInfo.removeEventListener( Event.COMPLETE, imageLoaded );
			_background.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, IOErrorHandler );
			_background.width = _w;
			_background.height = _h;
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("StreamView:: IOErrorHandler:" );
		}
		public function destroy():void
		{
			_ns.attachAudio(null); // don't know if this actually does anything!
			_ns.attachCamera(null);
			_ns.close();
		}
		
		protected function onVolumeChange(e:ControlBarEvent):void
		{
			trace("StreamView:: onVolumeChange:", e.data.volume);
			_ns.soundTransform = new SoundTransform(e.data.volume / 100);
		}
		
		private function placeStreamBanner():void
		{
			_streambanner.scaleX = _streambanner.scaleY = 1;
			_streambanner.scaleX = _streambanner.scaleY = _w / _streambanner.width;
			if (_streambanner.scaleX > 1)
				_streambanner.scaleX = _streambanner.scaleY = 1;
			_streambanner.x = _w - _streambanner.width - 6
			_streambanner.y = _h - _streambanner.height - 6;
		}
		
		private function drawBorder(_b:Sprite, _thickness:Number):void
		{
			var _offset:Number = _thickness / 2;
			_b.graphics.lineStyle(_thickness, 0x0000c0, 1, false, LineScaleMode.NONE);
			_b.graphics.drawRect(_offset, _offset, _w - _thickness, _h - _thickness);
		}
		
		public function mouseOver(e:MouseEvent = null):void
		{
			drawBorder(_border, 4);
			_volume.visible = true;
		}
		
		public function mouseOut(e:MouseEvent = null):void
		{
			_border.graphics.clear();
			drawBorder(_border, 1);
			_volume.visible = false;
		}
		
		// GETTER/SETTERS
		public function get streamname():String
		{
			return _streamname;
		}
		
		public function set streamname(s:String):void
		{
			_streamname = s;
			addStreamName(s);
		}
		
		public function get netStream():NetStream
		{
			return _ns;
		}
		
		public function set duration(value:int):void
		{
			_duration = value;
			_state.setDuration(value);
		}
		
		public function get state():SynchroBar
		{
			return _state;
		}
		
		public function get streaming():Boolean 
		{
			return _streaming;
		}
		
		public function get uid():String 
		{
			return _uid;
		}
		
		public function set uid(value:String):void 
		{
			_uid = value;
			addUserProfilePicture(value);
		}
		// stream stopped publishing - chance to react
		// returns boolean whether this view should be destroyed
		// can be overridden prevent camera view from being destroyed
		// when user stops publishing stream
		public function destroyMeOnStreamStop():Boolean
		{
			return true;
		}
	
	}

}