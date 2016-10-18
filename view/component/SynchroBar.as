package com.videoswipe.view.component 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class SynchroBar extends XSprite
	{
		[Embed(source="assets/synchrotext.png")]
		private var synchroClass:Class;
		[Embed(source="assets/synchroready.png")]
		private var synchroReadyClass:Class;
		
		private var _synchro:Bitmap;
		private var _base:Shape;
		private var _playing:Shape;
		private var _buffering:Shape;
		private var _bufferMask:Shape;
		private var _cued:Bitmap;
		private var _jewel:Shape;
		private var _timer:Timer;
		private var _state:int;	// cache the current
		private var _dur:Number;	// cache the duration of this item
		private var _progress:Number; // store the progress of this stream
		
		public function SynchroBar() 
		{
			initView();
			// start with a default, though we should expect a setSize from outside
			setSize(160, 6);
		}

		private function initView():void
		{
			_base = new Shape();
			_synchro = new Bitmap();
			_playing = new Shape();
			_buffering = new Shape();
			_bufferMask = new Shape();
			_cued = new Bitmap();
			_jewel = new Shape();
			
			
			// synchro layer holds a graphic graphic background
			_synchro = new synchroClass();
			_cued = new synchroReadyClass();
			
			addChild(_synchro);
			//addChild(_base);
			addChild(_playing);
			addChild(_cued);
			addChild(_buffering);
			addChild(_bufferMask);
			addChild(_jewel);
			addChild(_cued);
			
			/*
			_playing.y = 8;
			_buffering.y = 16;
			_bufferMask.y = 16;
			_cued.y = 24;
			*/
		
			_buffering.mask = _bufferMask;
			
			_timer = new Timer(1000, 0);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			// set to a default initial state, just in case we don't get anything from the player
			playerStateChange( { state:-1, dur:0, progress:0 } );
		}	
		
		public function playerStateChange(_s:Object):void
		{
			trace("SynchroBar:: playerStateChange:", _s.state, _s.progress, _s.dur);
			// reset things before setting new state
			_timer.stop();

			switch (_s.state) {

				case -1:
					// unstarted
					_synchro.visible = true;
					_base.visible = false;
					_playing.visible = false;
					_buffering.visible = false;
					_cued.visible = false;
					_jewel.visible = false;
					break;

				case 0:
					// video item ended
					_base.visible = false;
					_playing.visible = false;
					_buffering.visible = false;
					_synchro.visible = false;
					_cued.visible = true;
					break;

				case 1:
					// video item playing
					_synchro.visible = true;
					_playing.visible = true;
					_buffering.visible = false;
					_cued.visible = false;
					_jewel.visible = true;
					_timer.start();
					break;

				case 2:
					// video item paused
					_synchro.visible = true;
					_base.visible = true;
					_buffering.visible = false;
					_cued.visible = false;
					_timer.start();
					break;
				
				case 3:
					// buffering
					_synchro.visible = true;
					_playing.visible = false;
					_cued.visible = false;
					_buffering.visible = true;
					_timer.start();
					break;
					
				case 5:
					// video item cued
					_synchro.visible = false;
					_playing.visible = false;
					_buffering.visible = false;
					_cued.visible = true;
					break;
			}

			_state = _s.state;
			_progress = _s.progress;
			
			timerHandler();
			
		}
		// the mediator detects the duration for this stream and injects it
		// for StreamsMediator the duration is the YouTube clip
		// for VideoMessagesMediator the duration is the recorded message
		public function setDuration( _d:Number ):void
		{
			trace("SynchroBar:: setDuration:", _d );
			_dur = _d;
		}
		public function synchroniseTimer():void
		{
			_timer.reset();
			_timer.start();
		}
		private function timerHandler(e:TimerEvent=null):void
		{
			//trace("SynchroBar:: timerHandler:", _state, _progress, _dur );
			// playing - increase progress bar
			if (_state == 1) {
				var _playHead:int = Math.floor( _width * _progress / _dur );
				_playing.width = _playHead;
				_jewel.x = _playHead;	// jewel can move independently of progress bar
				_progress = (_progress > _dur) ? _dur : _progress+1;	// 1 second has passed
			}
			// paused - flash playing bar
			if (_state == 2) {
				_playing.visible = _playing.visible ? false : true;
			}
			// buffering - slide buffering image
			if (_state == 3) {
				_buffering.x = 0;
				var newX:int = _width / 8;
				TweenLite.to(_buffering, 1, { x:newX, onComplete:tweenComplete, ease:Linear.easeNone } );
			}
		}
		
		private function tweenComplete():void
		{
			trace("SynchroBar:: tweenComplete:" );
			//timerHandler();
		}
		override public function redraw():void
		{
			_base.graphics.clear();
			_base.graphics.beginFill(0x887070, Theme.GLASSALPHA);
			_base.graphics.drawRect(0, 0, _width, _height);
			_base.graphics.endFill();
			
			_playing.graphics.clear();
			_playing.graphics.beginFill(0x00c000, Theme.GLASSALPHA);
			_playing.graphics.drawRect(0, 0, _width, _height);
			_playing.graphics.endFill();
			
			// buffering requires a series of diagonal stripes
			// cued a chequerboard
			_buffering.graphics.clear();
			var _step:int = Math.floor(_width / 8);
			for (var i:int = 0; i < 10; i++ ) {
				_buffering.graphics.lineStyle(0, 0x000, 0);//no line needed
				_buffering.graphics.beginFill(0x00c000, 1);
				_buffering.graphics.moveTo(i * _step, 0);
				_buffering.graphics.lineTo(i * _step + _step /2, 0);
				_buffering.graphics.lineTo(i * _step + _step /4, _height);
				_buffering.graphics.lineTo(i * _step - _step /4, _height);
				_buffering.graphics.lineTo(i * _step, 0);
				_buffering.graphics.endFill();
			}

			_bufferMask.graphics.clear();
			_bufferMask.graphics.beginFill(0x000, 1);	// doesn't matter its a mask
			_bufferMask.graphics.drawRect(0, 0, _width, _height);
			_bufferMask.graphics.endFill();
			
			// redraw jewel again - not realy needed but keeps all rendering in one function
			_jewel.graphics.clear();
			_jewel.graphics.lineStyle(0, 0xFFFF00, 1);
			_jewel.graphics.moveTo(0, 0);
			_jewel.graphics.lineTo(0, _height);
			
		}
	}

		
}