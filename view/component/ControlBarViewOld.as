package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.ControlBarEvent;
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	import flash.display.Bitmap;
	import flash.display.Loader;
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
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	/**
	 * 
	 * Ben Silburn 
	 */
	public class ControlBarView extends Sprite
	{
		private static const SLIDERPADDING:int = 8;
		private static const SKINFILE:String = "unlimblue.zip";

		private var _player:Object;
		private var zip:FZip;
		private var buttonClips:Dictionary = new Dictionary();
		private var _loadCount:int = 1;
		private var _width:int = 320;	// width of the viewer (determines how long the timerail will be)
		private var _scrubbing:Boolean = false;	// set to true when we are time scrubbing
		private var _volumeDragging:Boolean = false;	// set to true when we are dragging the volume slider
		private var _volumeTimer:Timer;	// we measure time taken between start and stop volume scrub, if <120ms then its a click
		private var _timer:Timer;	// for updating timeThumb and volume

		// controlbar assets
		private var playButton:SimpleButton;
		private var pauseButton:SimpleButton;
		private var fullscreenButton:SimpleButton;
		private var durationText:TextField;
		private var timeProgress:Bitmap;
		private var timeRail:Sprite;
		private var timeThumb:Sprite;
		private var volumeRail:Sprite;
		private var volumeProgress:Sprite;
		private var volumeMask:Sprite;	// used to mask the vol clip to give appearance of sliding over background
		
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
			_volumeTimer = new Timer(120, 1);
			durationText = new TextField();
			var durTF:TextFormat = new TextFormat("Verdana", 10, 0xffffff, { bold:true } );
			durationText.defaultTextFormat = durTF;
			durationText.multiline = false;
			durationText.width = 48;
			durationText.height = 16;
			loadZip();
		}

		// PUBLIC FUNCTIONS
		public function set player( _p:Object):void
		{
			_player = _p;
		}
		public function setSize( w:int, h:int ):void
		{
			_width = w;
			layoutControlBar();
		}
		public function setScrub( s:Number ):void
		{
			if (!_scrubbing) {
				timeThumb.x = timeRail.x + s * timeRail.width;
			}
		}
		public function onPlayerStateChange(_state:int):void
		{
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
		public function itemPlaying( ):void
		{
			trace("ControlBarView:: itemPlaying:", _player.getDuration() );
			durationText.text = numberToDuration( _player.getDuration() );
			if (_player.getDuration() < 60) durationText.text = "0:" + durationText.text;
			_timer.start();
			playButton.visible = false;
			pauseButton.visible = true;
		}
		public function itemPaused():void
		{
			_timer.stop();
			pauseButton.visible = false;
			playButton.visible = true;
		}
		public function itemNotPlaying():void
		{
			durationText.text = "--:--";
		}

		private function numberToDuration(n:int):String
		{
			if (n < 10) return "0" + String(n);
			else if (n < 60) return String(n);
			else if (n < 3600) return String(Math.floor(n / 60)) + ":" + numberToDuration(n % 60);
			else return String(Math.floor(n/3600)) + ":" + numberToDuration(n % 3600);
		}

		// PRIVATE FUNCTIONS
		private function thumbPositionAsTime():Number
		{
			return (timeThumb.x - timeRail.x) * _player.getDuration() / timeRail.width;
		}
		private function maskPositionAsVolume():int
		{
			return  (volumeMask.x - volumeRail.x) * 100 / volumeRail.width;
		}
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
				layoutControlBar();
			}
		}
		private function createButtons():void
		{
			playButton = new SimpleButton( buttonClips["playButton.png"], buttonClips["playButtonOver.png"], buttonClips["playButton.png"], buttonClips["playButton.png"] );
			pauseButton = new SimpleButton( buttonClips["pauseButton.png"], buttonClips["pauseButtonOver.png"], buttonClips["pauseButton.png"], buttonClips["pauseButton.png"] );
			fullscreenButton = new SimpleButton( buttonClips["fullscreenButton.png"], buttonClips["fullscreenButtonOver.png"], buttonClips["fullscreenButton.png"], buttonClips["fullscreenButton.png"] );

			timeRail = new Sprite();
			timeRail.addChild(buttonClips["timeSliderRail.png"]);
			timeThumb = new Sprite();
			var t:Bitmap = buttonClips["timeSliderThumb.png"];
			t.x = t.width / -2;
			timeThumb.addChild(t);
			timeProgress = buttonClips["timeSliderProgress.png"];

			volumeRail = new Sprite();
			volumeRail.addChild( buttonClips["volumeSliderRail.png"] );
			volumeRail.scaleX = 1.5;
			volumeProgress = new Sprite();
			volumeProgress.scaleX = 1.5;
			volumeProgress.addChild( buttonClips["volumeSliderProgress.png"] );
			volumeMask = new Sprite();
			volumeMask.graphics.beginFill(0x000, 1);
			volumeMask.graphics.drawRect(0, 0, -volumeRail.width, volumeRail.height);
			volumeMask.graphics.endFill();
			volumeProgress.mask = volumeMask;

			addChild(buttonClips["background.png"]);
			addChild(buttonClips["capLeft.png"]);
			addChild(buttonClips["capRight.png"]);
			addChild(pauseButton);
			addChild(playButton);
			addChild(timeRail);
			addChild(timeThumb);
			addChild(durationText);
			addChild(volumeRail);
			addChild(volumeProgress);
			addChild(volumeMask);
			addChild(fullscreenButton);

			playButton.addEventListener(MouseEvent.CLICK, playClicked);
			pauseButton.addEventListener(MouseEvent.CLICK, pauseClicked);
			fullscreenButton.addEventListener(MouseEvent.CLICK, fullscreenClicked);
			timeThumb.addEventListener(MouseEvent.MOUSE_DOWN, startTimeScrub);
			timeRail.addEventListener(MouseEvent.CLICK, timeRailClicked);
			volumeProgress.addEventListener(MouseEvent.MOUSE_DOWN, startVolumeScrub);
			volumeRail.addEventListener(MouseEvent.MOUSE_DOWN, startVolumeScrub);
			
		}

		private function layoutControlBar():void
		{
			trace("ControlBarView:: layoutControlBar:");

			// since its possible that this fn could be called before all assets are loaded just check first...
			if (_loadCount > 0) return;
			
			buttonClips["capLeft.png"].x = 0;
			buttonClips["background.png"].width = _width - buttonClips["capLeft.png"].width * 2;
			buttonClips["background.png"].x = buttonClips["capLeft.png"].width;
			buttonClips["capRight.png"].x = _width - buttonClips["capRight.png"].width;
			
			playButton.x = buttonClips["background.png"].x;
			pauseButton.x = playButton.x;
			timeRail.x = playButton.x + playButton.width + SLIDERPADDING;;
			timeRail.y = Math.floor((playButton.height - timeRail.height) / 2);
			timeRail.width = buttonClips["background.png"].width - playButton.width - fullscreenButton.width - volumeRail.width - durationText.width - 6 * SLIDERPADDING;
			timeThumb.x = timeRail.x;
			timeThumb.y = Math.floor(timeRail.y + (timeRail.height - timeThumb.height) / 2);
			durationText.x = timeRail.x + timeRail.width + SLIDERPADDING;
			durationText.y = Math.floor(timeRail.y + (timeRail.height - durationText.height) / 2);
			volumeRail.x = volumeProgress.x = durationText.x + durationText.width + SLIDERPADDING;
			volumeMask.x = volumeRail.x + volumeRail.width;	// full volume
			fullscreenButton.x = volumeMask.x + SLIDERPADDING;
		}

		private function timerHandler(e:TimerEvent):void
		{
			if (_player.getDuration() > 0) {
				setScrub( _player.getCurrentTime() / _player.getDuration() );
			}
			if (_volumeDragging) {
				dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, { volume:maskPositionAsVolume() } ));
			}
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
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		private function timeRailClicked(e:MouseEvent):void
		{
			timeThumb.x = this.mouseX;
			dispatchEvent( new ControlBarEvent(ControlBarEvent.SEEK, { seekTo:thumbPositionAsTime() } ));
		}
		private function startTimeScrub(e:MouseEvent = null):void
		{
			trace("ControlBarView:: startScrub:");
			_scrubbing = true;
			timeThumb.startDrag(true, new Rectangle(timeRail.x, timeThumb.y, timeRail.width, 0));
			timeThumb.stage.addEventListener(MouseEvent.MOUSE_UP, stopTimeScrub);
		}
		private function stopTimeScrub(e:MouseEvent = null):void
		{
			trace("ControlBarView:: stopScrub:");
			_scrubbing = false;
			timeThumb.stopDrag();
			timeThumb.stage.removeEventListener(MouseEvent.MOUSE_UP, stopTimeScrub);
			dispatchEvent( new ControlBarEvent(ControlBarEvent.SEEK, { seekTo:thumbPositionAsTime() } ));
		}
		private function startVolumeScrub(e:MouseEvent = null):void
		{
			trace("ControlBarView:: startVolumeScrub:");
			_volumeDragging = true;
			_volumeTimer.reset();
			_volumeTimer.start();
			volumeMask.startDrag(false, new Rectangle(volumeRail.x, volumeRail.y, volumeRail.width, 0))
			volumeMask.stage.addEventListener(MouseEvent.MOUSE_UP, stopVolumeScrub);
		}
		private function stopVolumeScrub(e:MouseEvent = null):void
		{
			trace("ControlBarView:: stopVolumeScrub:", volumeMask.x );
			volumeMask.stopDrag();
			_volumeDragging = false;
			volumeMask.stage.removeEventListener(MouseEvent.MOUSE_UP, stopVolumeScrub);

			// its possible user simply clicked the volume rail/mask in which case we want to just set the volume to the point of the click
			// ie if time since start scrub is <120ms then this counts as a click
			if (_volumeTimer.running) {
				volumeMask.x = volumeRail.x + Math.min(volumeRail.mouseX * volumeRail.scaleX, volumeRail.width);
			}
			//dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, { volume:maskPositionAsVolume() } ));
			// since we have the player object we just adjust the volume directly...
			_player.setVolume( maskPositionAsVolume() );
		}
	}

}