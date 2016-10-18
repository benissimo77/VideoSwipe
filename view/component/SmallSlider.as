package com.videoswipe.view.component
{
	import com.greensock.motionPaths.RectanglePath2D;
	import com.videoswipe.model.vo.ControlBarEvent;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * (c) 2013 Ben Silburn
	 */
	public class SmallSlider extends XSprite
	{
		[Embed(source = "assets/microphonesmall-grey.png")]
		private static var microphoneClass:Class;
		[Embed(source = "assets/microphonesmall-greyMuted.png")]
		private static var microphoneMutedClass:Class;
		
		[Embed(source="assets/speakerIcon.png")]
		private static var speakerClass:Class;
		[Embed(source="assets/speakerIconOver.png")]
		private static var speakerClassOver:Class;
		[Embed(source="assets/mutedIcon.png")]
		private static var speakerMutedClass:Class;
		[Embed(source="assets/mutedIconOver.png")]
		private static var speakerMutedClassOver:Class;
		[Embed(source = "assets/slideThumbIcon.png")]
		/*[Embed(source = "assets/microphone-grey.png")]
		private const microphonenClass:Class;
		[Embed (source = "assets/microphone-grey.png")]
		private static var microphoneClassOver:Class;
		[Embed (source = "assets/microphone-grey.png")]
		private static var microphoneMutedClass:Class;
		[Embed (source = "assets/microphone-grey.png")]
		private static var microphoneMutedClassOver:Class;
*/
		private static var slideThumbClass:Class;
		
		private const sliderTypes:Object = {
			speaker:[ new speakerClass(), new speakerClassOver(), new speakerMutedClass(), new speakerMutedClassOver() ],
			mic:[ new microphoneClass(), new microphoneClass(), new microphoneMutedClass(), new microphoneMutedClass() ]
			};
		
		
		private var _timer:Timer;	// timer allows slider to send events while dragging
		private var _slideThumb:Sprite; // sprite holds the actual slider control
		private var _slideRail:Sprite;	// holds the 'rail' that slider slides along (must accept mouse clicks)
		private var _icon:SimpleButton; // holds the icon for this slider
		private var _iconMuted:SimpleButton; // holds the 'muted' icon (icon is a toggle button)
		private var _value:int; // the current value of this slider
		private var _mutedValue:int; // cache the current value to provide mute/unmute functionality
		private var _dragging:Boolean = false;	// are we dragging the thumb
		private var _muted:Boolean = false;	// is mic/volume muted
		
		public function SmallSlider( _type:String )
		{
			initView( _type );
			value = 100;	// will trigger control bar event
		}
		
		override public function redraw():void
		{
			_slideRail.graphics.clear();
			_slideRail.graphics.beginFill( Theme.EDGETINT, Theme.GLASSALPHA);
			_slideRail.graphics.drawRect( -3, 0, 6, _height - 48);
			_slideRail.graphics.endFill();
			_slideRail.y = _height * -1 + 12;

			_slideThumb.y = valueAsThumbPosition(_value);	// we need to recallibrate thumb based on the height
		}

		private function initView( _type:String ):void
		{
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);

			_slideRail = new Sprite();
			_slideRail.x = 0;
			addChild(_slideRail);
			
			var _bitmap:Bitmap = new slideThumbClass();
			_bitmap.x = _bitmap.width / -2;
			_bitmap.y = _bitmap.height / -2;
			_slideThumb = new Sprite();
			_slideThumb.addChild(_bitmap);
			_slideThumb.x = 0;
			addChild(_slideThumb);

			// use type to determine which icon to use
			var _element:Array = sliderTypes[ _type ];
			_icon = new SimpleButton( _element[0], _element[1], _element[0], _element[0] );
			_icon.x = _icon.width / -2;
			_icon.y = _icon.height * -1;
			addChild(_icon);
			_iconMuted = new SimpleButton( _element[2], _element[3], _element[2], _element[2] );
			_iconMuted.x = _iconMuted.width / -2;
			_iconMuted.y = _iconMuted.height * -1;
			addChild(_iconMuted);
			
			
			this.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
			_slideRail.addEventListener(MouseEvent.MOUSE_DOWN, onSlideRailClick);
			_slideThumb.addEventListener(MouseEvent.MOUSE_DOWN, onSlideThumbClick);
			_icon.addEventListener(MouseEvent.CLICK, onIconClick);
			_iconMuted.addEventListener(MouseEvent.CLICK, onIconClick);
			
			// start undrawn
			onMouseOut();
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			trace("SmallSlider:: onMouseOver:" );
			this.graphics.clear();
			this.graphics.lineStyle(1, Theme.EDGETINT);
			this.graphics.beginFill(Theme.GLASSTINT, Theme.GLASSALPHA);
			this.graphics.drawRoundRect(_width / -2, -_height, _width, _height, 3);
			this.graphics.endFill();

			_slideRail.visible = true;
			_slideThumb.visible = true;
		}
		
		private function onMouseOut(e:MouseEvent = null):void
		{
			trace("SmallSlider:: onMouseOut:" );
			this.graphics.clear();
			_slideRail.visible = false;
			_slideThumb.visible = false;
			if (_dragging) stopThumbDrag();
		}
		
		private function onIconClick(e:MouseEvent):void
		{
			if (_muted) {
				unmuteAudio();
			} else {
				muteAudio();
			}
		}
		private function onSlideThumbClick(e:MouseEvent=null):void
		{
			trace("SmallSlider:: onSlideThumbClick:", -_height + 8, _height - 48 );
			_dragging = true;
			_slideThumb.startDrag(false, new Rectangle(0, -_height + 12, 0, _height - 48));
			_slideThumb.stage.addEventListener(MouseEvent.MOUSE_UP, stopThumbDrag);
			_timer.start();
		}
		
		private function stopThumbDrag(e:MouseEvent=null):void
		{
			_timer.stop();
			_dragging = false;
			_slideThumb.stopDrag();
			_slideThumb.removeEventListener(MouseEvent.MOUSE_UP, stopThumbDrag);
			trace("SmallSlider:: stopThumbDrag:", _value, _slideThumb.y );
			value = thumbPositionAsValue( _slideThumb.y );
			trace("SmallSlider:: stopThumbDrag:", _value, _slideThumb.y );
		}
		
		private function onSlideRailClick(e:MouseEvent):void
		{
			var _v:int = thumbPositionAsValue(this.mouseY);
			trace("SmallSlider:: onSlideRailClick:", _v );
			if (_v > 0 && _v < 100) {
				_slideThumb.y = valueAsThumbPosition(_v);
				onSlideThumbClick();
			}
		}

		private function timerHandler(e:TimerEvent):void
		{
			value = thumbPositionAsValue(_slideThumb.y);
		}

		private function thumbPositionAsValue(_p:int):int
		{
			// thumb Y position can be between value -height+4 : -36
			//recallibrate and normalise to 0-100
			var _base:int = (_p + 36) * -1;
			return Math.floor(_base * 100 / (_height-48));
		}
		
		private function valueAsThumbPosition(_v:int):int
		{
			var _base:int = Math.ceil(_v * (_height - 48) / 100);
			return (_base + 36) * -1;
		}
		
		public function muteAudio():void
		{
			_muted = true;
			_mutedValue = _value;
			value = 0;
		}
		public function unmuteAudio():void
		{
			_muted = false;
			value = _mutedValue;
		}
		
		public function set value(_v:int):void 
		{
			trace("SmallSlider:: value:", _v );
			_value = _v;
			_slideThumb.y = valueAsThumbPosition(_value);
			dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, { volume:_value } ));
			_icon.visible = true;
			_iconMuted.visible = false;
			if (_value == 0) {
				_icon.visible = false;
				_iconMuted.visible = true;
			}
		}
	}

}