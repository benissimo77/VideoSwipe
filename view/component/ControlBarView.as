package com.videoswipe.view.component 
{
	import com.greensock.TweenLite;
	import com.videoswipe.model.vo.ControlBarEvent;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	/**
	 * 
	 * Ben Silburn 
	 */
	public class ControlBarView extends GlassSprite
	{
		[Embed(source="assets/ctrl-fullscreen.png")]
		private static var fullscreenClass:Class;
		[Embed(source="assets/ctrl-over-fullscreen.png")]
		private static var fullscreenClassOver:Class;
		[Embed(source="assets/ctrl-play.png")]
		private static var playClass:Class;
		[Embed(source="assets/ctrl-over-play.png")]
		private static var playClassOver:Class;
		[Embed(source="assets/ctrl-pause.png")]
		private static var pauseClass:Class;
		[Embed(source="assets/ctrl-over-pause.png")]
		private static var pauseClassOver:Class;
		[Embed(source="assets/ctrl-prev.png")]
		private static var prevClass:Class;
		[Embed(source="assets/ctrl-over-prev.png")]
		private static var prevClassOver:Class;
		[Embed(source="assets/ctrl-next.png")]
		private static var nextClass:Class;
		[Embed(source="assets/ctrl-over-next.png")]
		private static var nextClassOver:Class;

		private static const SLIDERPADDING:int = 8;
		private static const SKINFILE:String = "unlimblue.zip";

		private var _player:Object;
		private var buttonClips:Dictionary = new Dictionary();
		private var _loadCount:int = 1;
		private var _scrubbing:Boolean = false;	// set to true when we are time scrubbing
		private var _timer:Timer;	// for updating timeThumb and volume

		// controlbar assets
		private var playButton:SimpleButton;
		private var pauseButton:SimpleButton;
		private var fullscreenButton:SimpleButton;
		private var durationText:TextField;
		private var positionText:TextField;
		private var timeRail:Sprite;
		private var timeProgress:Shape;
		private var timeThumb:Sprite;
		private var volumeButton:SmallSlider;
		
		public function ControlBarView( _p:Object = null ) 
		{
			trace("ControlBarView:: ControlBarView:" );
			if (!_p) {
				_p = { getDuration:function():int { return 1; }, getCurrentTime:function():int { return 0;} };
			}
			_player = _p;
			initView();
		}
		
		private function initView():void
		{
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			var _tf:TextFormat = TF.defaultTF;
			_tf.size = 13;
			_tf.align = TextFormatAlign.LEFT;
			_tf.color = 0xe1e1e1;
			_tf.bold = true;
			durationText = new TextField( );
			durationText.defaultTextFormat = _tf;
			durationText.multiline = false;
			durationText.autoSize = TextFieldAutoSize.LEFT;
			durationText.selectable = false;
			durationText.height = 20;
			positionText = new TextField( );
			positionText.mouseEnabled = false;
			positionText.defaultTextFormat = _tf;
			positionText.multiline = false;
			positionText.autoSize = TextFieldAutoSize.NONE;
			positionText.selectable = false;
			positionText.width = 72;	// 72 gives enough space even for long video clips
			positionText.height = 20;

			// we no longer load from a ZIP file, just call createButtons directly
			//loadZip();
			createButtons();
			redraw();
			itemPaused();	// initial state
		}

		// PUBLIC FUNCTIONS
		public function set player( _p:Object):void
		{
			_player = _p;
		}
		public function onPlayerStateChange( _s:Object ):void
		{
			var _state:int = _s.state;
			if (_state == -1) {
				// unstarted
				itemNotPlaying();
			}
			if (_state == 0) {
				// video item ended
			}
			if (_state == 1) {
				// video item playing, update controlbar
				itemPlaying();
			}
			if (_state == 2) {
				// video item paused
				itemPaused();
			}
			if (_state == 3) {
				// buffering
			}
			if (_state == 5) {
				// video item cued
			}
		}
		public function stopScrub():void
		{
			_scrubbing = false;
		}

		
		// PRIVATE FUNCTIONS
		private function itemPlaying( ):void
		{
			trace("ControlBarView:: itemPlaying:", _player.getDuration() );
			durationText.text = numberToDuration( _player.getDuration() );
			durationText.y = Math.floor((_height - durationText.height) / 2);
			_timer.start();
			positionText.visible = true;
			timeThumb.visible = true;
			playButton.visible = false;
			pauseButton.visible = true;
		}
		private function itemPaused():void
		{
			_timer.stop();
			pauseButton.visible = false;
			playButton.visible = true;
		}
		private function itemNotPlaying():void
		{
			trace("ControlBarView:: itemNotPlaying:" );
			durationText.text = "--:--";
			durationText.y = Math.floor((_height - durationText.height) / 2);
			positionText.visible = false;
			timeThumb.visible = false;
		}

		private function numberToDuration(n:int):String
		{
			var _s:int = n % 60;
			var _m:int = (n / 60) % 60;
			var _h:int = Math.floor(n / 3600);
			
			return	( _h > 0 ? String(_h) + ":" : "") +
					( (_h > 0 && _m < 10) ? "0" + String(_m) : String(_m)) + ":" +
					( _s < 10 ? "0" + String(_s) : String(_s) );
		}

		private function thumbPositionAsTime():int
		{
			return Math.floor((timeThumb.x - timeRail.x) * _player.getDuration() / timeRail.width);
		}
		
		// ZIP LOADING NO LONGER DONE
		// KEEP HERE FOR REFERENCE (FOR A WHILE...)
		/*
		private function loadZip():void
		{
			zip = new FZip();
			zip.addEventListener( Event.COMPLETE, zipLoaded );
			zip.load( new URLRequest( SKINFILE) );
		}
		
		private function zipLoaded(e:Event):void
		{
			//trace("ControlBarView:: zipLoaded:", zip.getFileCount());
			zip.removeEventListener( Event.COMPLETE, zipLoaded );

			var file:FZipFile;

			_loadCount = zip.getFileCount();
			for (var i:int = zip.getFileCount(); i--; ) {
				file = zip.getFileAt(i);
				var loader:Loader = new Loader();
				loader.name = file.filename;
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, pngLoaded );
				loader.loadBytes(file.content);
			}
		}
		private function pngLoaded(e:Event):void
		{
			e.currentTarget.removeEventListener( Event.COMPLETE, pngLoaded );
			var _l:Loader = e.currentTarget.loader as Loader;
			buttonClips[_l.name] = _l.content;	// type Bitmap
			_loadCount--;
			if (_loadCount == 0) {
				createButtons();
				redraw();
			}
		}
		*/
		private function createButtons():void
		{
			playButton = new SimpleButton( new playClass(), new playClassOver(), null, new playClass() );
			pauseButton = new SimpleButton( new pauseClass(), new pauseClassOver(), null, new pauseClass() );
			fullscreenButton = new SimpleButton( new fullscreenClass(), new fullscreenClassOver(), null, new fullscreenClass() );

			timeRail = new Sprite();
			timeProgress = new Shape();
			timeThumb = new Sprite();
			
			volumeButton = new SmallSlider( "speaker" );
			volumeButton.setSize(28, 120);

			addChild(pauseButton);
			addChild(playButton);
			addChild(durationText);
			addChild(timeProgress);
			addChild(timeRail);
			addChild(timeThumb);
			addChild(positionText);
			addChild(volumeButton);
			addChild(fullscreenButton);

			if (CONFIG::screengrab) {
				removeChild(pauseButton);
				removeChild(playButton);
			}
			
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, playClicked);
			pauseButton.addEventListener(MouseEvent.MOUSE_DOWN, pauseClicked);
			fullscreenButton.addEventListener(MouseEvent.CLICK, fullscreenClicked);
			timeThumb.addEventListener(MouseEvent.MOUSE_DOWN, startTimeScrub);
			timeRail.addEventListener(MouseEvent.MOUSE_DOWN, timeRailClicked);
		}

		override public function redraw():void
		{
			trace("ControlBarView:: redraw:");
			showGlass();

			timeThumb.graphics.clear();
			timeThumb.graphics.lineStyle(1, Theme.EDGETINT, 1);
			timeThumb.graphics.moveTo(0, 0);
			timeThumb.graphics.lineTo(0, _height);

			playButton.x = SLIDERPADDING;
			pauseButton.x = playButton.x;
			timeRail.x = playButton.x + playButton.width + SLIDERPADDING;;
			timeRail.y = 0;
			timeProgress.x = timeRail.x;
			timeProgress.y = 0;
			timeThumb.x = timeRail.x;
			timeThumb.y = 0;
			positionText.x = timeRail.x;
			positionText.y = Math.floor((_height - positionText.height) / 2);

			// now work backwards from right edge
			fullscreenButton.x = _width - fullscreenButton.width - SLIDERPADDING;
			volumeButton.x = fullscreenButton.x - volumeButton.width;
			volumeButton.y = 32; // not ideal - reg point is the base of the icon used in the volume slider...
			durationText.x = volumeButton.x - 72 - SLIDERPADDING;	// 72 is space for text

			// timeRail is now the space between the left buttons and the right
			var timeRailWidth:int = durationText.x - SLIDERPADDING - timeRail.x;
			timeRail.graphics.clear();
			timeRail.graphics.lineStyle(0, 0, 0);
			timeRail.graphics.beginFill(0x000, 0);
			timeRail.graphics.drawRect(0, 0, timeRailWidth, _height);
			timeRail.graphics.endFill();
			timeRail.graphics.lineStyle(0, Theme.EDGETINT, 1);
			timeRail.graphics.moveTo(0, 0);
			timeRail.graphics.lineTo(0, _height);
			timeRail.graphics.moveTo( timeRailWidth, 0);
			timeRail.graphics.lineTo( timeRailWidth, _height);
		}

		private function playClicked(e:MouseEvent = null):void
		{
			trace("ControlBarView:: playClicked:");
			dispatchEvent( new ControlBarEvent(ControlBarEvent.PLAY) );
		}
		private function pauseClicked(e:MouseEvent = null):void
		{
			trace("ControlBarView:: pauseClicked:");
			dispatchEvent( new ControlBarEvent(ControlBarEvent.PAUSE) );
		}
		private function fullscreenClicked(e:MouseEvent = null):void
		{
			trace("ControlBarView:: fullscreenClicked:");
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}

		private function timeRailClicked(e:MouseEvent):void
		{
			timeThumb.x = this.mouseX;
			startTimeScrub();
			//dispatchEvent( new ControlBarEvent(ControlBarEvent.SEEK, { seekTo:thumbPositionAsTime() } ));
		}
		private function startTimeScrub(e:MouseEvent = null):void
		{
			trace("ControlBarView:: startScrub:");
			_scrubbing = true;
			timeThumb.startDrag(true, new Rectangle(timeRail.x, timeThumb.y, timeRail.width, 0));
			timeThumb.stage.addEventListener(MouseEvent.MOUSE_UP, stopTimeScrub);
		}
		// stopTimeScrub
		// NOTE: we DON'T set _scrubbing to false here even though we stop dragging
		// this is set once the server has responded - prevents the control head jumping around for the half second
		private function stopTimeScrub(e:MouseEvent = null):void
		{
			trace("ControlBarView:: stopScrub:");
			//_scrubbing = false;
			timeThumb.stopDrag();
			timeThumb.stage.removeEventListener(MouseEvent.MOUSE_UP, stopTimeScrub);
			dispatchEvent( new ControlBarEvent(ControlBarEvent.SEEK, { seekTo:thumbPositionAsTime() } ));
		}

		// timerHandler
		// runs every 100ms updates the timeThumb / scrubber
		// different if we are scrubbing than if video playing...
		private function timerHandler(e:TimerEvent):void
		{
			var _progress:Number = _player.getCurrentTime() / _player.getDuration();
			var _w:int = Math.floor( timeRail.width * _progress );
			if (_w != timeProgress.width) {
				timeProgress.graphics.clear();
				timeProgress.graphics.beginFill( Theme.TEXTFACEBOOKFILL, Theme.GLASSALPHA );
				timeProgress.graphics.drawRect(0, 1, _w, _height-1);
				timeProgress.graphics.endFill();
			}
			var _currentTime:int;
			if (_scrubbing) {
				_currentTime = thumbPositionAsTime();
			} else {
				_currentTime = _player.getCurrentTime();
				timeThumb.x = timeRail.x + _w;
			}
			positionText.text = numberToDuration( _currentTime );
			positionText.x = timeThumb.x + SLIDERPADDING + Math.floor( _currentTime / _player.getDuration() * (durationText.width + 2 * SLIDERPADDING) * -1);
		}

	}

}