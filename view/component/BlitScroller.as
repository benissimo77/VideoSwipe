package com.videoswipe.view.component 
{
	import com.greensock.BlitMask;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * (c) Ben Silburn
	 * Scroller extends XSprite so it has a width and height property which can be set using setSize
	 * The size determines the viewport size of the target display object
	 * Scroller adds left/right up/down graphics over the target to implement scrolling
	 * Scroller interrogates the target to determine its extent and uses this to base the calculations of how much to scroll
	 * 
	 */
	public class BlitScroller extends XSprite
	{
		[Embed(source = "assets/scrollButton.png")]
		private var buttonClass:Class;
		[Embed(source = "assets/green-arrow-up.png")]
		private var arrowClass:Class;
		
		private static const NOTSCROLLING:int = 0;
		private static const UP:int = 1;
		private static const DOWN:int = 2;
		private static const LEFT:int = 3;
		private static const RIGHT:int = 4;
		private static const ACCELERATION:Number = 1.8;
		private static const DECELERATION:Number = 0.6;
		
		private var _maxScrollSpeed:int = 100;
		private var _up:Sprite;	// holds the graphic for up scrolling
		private var _down:Sprite;	// for down (note these are used if behaviour should be left/right)
		private var _upMask:Sprite;	// mask for up button, so it can slide in
		private var _downMask:Sprite; // mask for down button
		private var _targetMask:Sprite;	// mask the target clip
		private var _upArrow:Bitmap;	//
		private var _downArrow:Bitmap;
		private var _target:DisplayObjectContainer;	// cache the target object
		private var _horizontal:Boolean;	// boolean says if this is a vertical or horizontal scroll (default vertical)
		private var _scrollDirection:int;	// holds code (above) for current scroll status
		private var _scrolling:Boolean;	// are we scrolling?
		private var _scrollSpeed:int;	// stores a value for current speed of scroll (allows acceleration of scroll)
		
		public function BlitScroller(_h:Boolean = false) 
		{
			_horizontal = _h;
			initView();
		}
		
		private function initView():void
		{
			_upMask = new Sprite();
			_downMask = new Sprite();
			addChild(_upMask);
			addChild(_downMask);
			_up = new Sprite();
			_up.name = "up";
			_up.addEventListener(MouseEvent.ROLL_OVER, scrollOver);
			_up.addEventListener(MouseEvent.ROLL_OUT, scrollOut);
			_up.mask = _upMask;
			addChild(_up);
			_down = new Sprite();
			_down.name = "down";
			_down.addEventListener(MouseEvent.ROLL_OVER, scrollOver);
			_down.addEventListener(MouseEvent.ROLL_OUT, scrollOut);
			_down.mask = _downMask;
			addChild(_down);
			addEventListener(MouseEvent.ROLL_OVER, rollOver);
			addEventListener(MouseEvent.ROLL_OUT, rollOut);

			_upArrow = new arrowClass();
			_downArrow = new arrowClass();
			
			_scrolling = false;
			_scrollSpeed = 0;
			rollOut();	// initial state is mouse OUT
		}
		
		public function set scrollTarget(_d:DisplayObjectContainer):void
		{
			_target = _d;
			if (_target) {
				trace("Scroller:: scrollTarget: adding target to scroll..." );
				addChild(_up);
				addChild(_down);
				adjustScrollButtonPositions();
				if (!_horizontal) {
					_target.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
				}
			}
		}
		// update
		// the content of the target clip has changed, so adjust scroll button positions and maxscrollspeed
		public function update():void
		{
			trace("Scroller:: update:" );
			_maxScrollSpeed = _target.height / 20;
			if (_horizontal) _maxScrollSpeed = _target.width / 16;
			adjustScrollButtonPositions();
			//if (_target) _target.mask = _targetMask;
		}
		// redraw
		// follows as setSize call - width/height may have changed
		override public function redraw():void
		{
			trace("Scroller:: redraw:", _width, _height );
			drawScrollButtons();
			adjustScrollButtonPositions();
			trace("Scroller:: redraw: DONE"  );
		}
		
		private function drawScrollButtons():void
		{
			trace("Scroller:: updateScrollButtons:", _width, _height );
			var _w:int = _width;
			var _h:int = Math.floor(_height / 8);
			
			if (_horizontal) {
				_w = _height;
				_h = Math.floor(_width / 8);
			}
			if (_h < 60) _h = 60;

			// create the up/down shaded scroll buttons
			while (_up.numChildren > 0) _up.removeChildAt(0);
			var _upBmp:Bitmap = new buttonClass();
			_upBmp.width = _w;
			_upBmp.height = _h;
			_up.addChild(_upBmp);
			_upMask.graphics.clear();
			_upMask.graphics.beginFill(0x000, 0);
			_upMask.graphics.drawRect(0, 0, _w, _h);
			_upMask.graphics.endFill();

			while (_down.numChildren > 0) _down.removeChildAt(0);
			var _downBmp:Bitmap = new buttonClass();
			_downBmp.width = _w;
			_downBmp.height = _h;
			_down.addChild(_downBmp);
			_downMask.graphics.clear();
			_downMask.graphics.beginFill(0x000, 0);
			_downMask.graphics.drawRect(0, 0, _w, _h);
			_downMask.graphics.endFill();

			// position buttons and masks
			_up.x = 0;
			_up.y = 0;
			_upMask.x = 0;
			_upMask.y = 0;
			_down.rotation = 180;
			_down.x = _width;
			_down.y = _height;
			_downMask.rotation = 180;
			_downMask.x = _width;
			_downMask.y = _height;

			// position arrow graphics (centred in each button)
			_upArrow.x = (_w - _upArrow.width) / 2;
			_upArrow.y = (_h - _upArrow.height) / 2;
			_downArrow.x = (_w - _downArrow.width) / 2;
			_downArrow.y = (_h - _downArrow.height) / 2;
			_up.addChild(_upArrow);
			_down.addChild(_downArrow);

			// general adjustments for horizontal scroller
			if (_horizontal) {
				_up.rotation = -90;
				_up.y = _height;
				_upMask.rotation = -90;
				_upMask.y = _height;
				_down.rotation = 90;
				_down.x = _width;
				_down.y = 0;
				_downMask.rotation = 90;
				_downMask.x = _width;
				_downMask.y = 0;
			}
			
		}
		
		// doScroll
		// does job of carrying out the scroll, and runs the timer to repeat action
		private function doScroll(e:TimerEvent = null):void
		{
			//trace("Scroller:: doScroll:", _scrollDirection, _upMask.x, _upMask.y);
			var _x:int = _target.x , _y:int = _target.y;

			if (_scrolling) {
				_scrollSpeed = Math.abs(_scrollSpeed) < _maxScrollSpeed ? _scrollSpeed * ACCELERATION : _scrollSpeed;
			} else {
				// just let the _scrollSpeed return to 0
				_scrollSpeed = _scrollSpeed * DECELERATION;
				if (Math.abs(_scrollSpeed) < 4) _scrollSpeed = 0;
			}

			if (_horizontal) {
				_x = _target.x + _scrollSpeed;
				if (_x > 0) _x = 0;
				if (_x < _width - _target.width) _x = _width - _target.width;
			} else {
				_y = _target.y + _scrollSpeed;
				if (_y > 0) _y = 0;
				if (_y < _height - _target.height) _y = _height - _target.height;
			}

			if (_target.x != _x || _target.y != _y) {
				TweenLite.to( _target, 0.2, { x:_x, y:_y, ease:Linear.easeNone, onUpdate:adjustScrollButtonPositions, onComplete:doScroll } );
			}
		}
		
		private function mouseWheel(e:MouseEvent):void
		{
			trace("Scroller:: mouseWheel:", e.delta );
			//TweenLite.killTweensOf(_target);
			var _newY:int;
			var _inc:int = _height * 0.75;
			if (e.delta < 0) {
				_newY = _target.y - _inc > -_target.height + _height ? _target.y - _inc : -_target.height + _height;
			} else {
				_newY = _target.y + _inc < 0 ? _target.y + _inc : 0;
			}
			TweenLite.to( _target, 0.3, { y:_newY, ease:Linear.easeNone, onUpdate:adjustScrollButtonPositions } );
		}

		// adjustScrollButtonPositions
		// removes the scrollbuttons if the target is already scrolled to make the button not required
		private function adjustScrollButtonPositions():void
		{
			//trace("Scroller:: adjustScrollButtonPositions:", _target.height, _height );
			if (_horizontal) {
				_up.x = 0;
				_down.x = _width;
				if (_target.x > -_up.width) _up.x = - _up.width - _target.x;
				if (_target.x < _width - _target.width + _down.width) {
					_down.x = _width + _width - _target.width - _target.x + _down.width;
				}
			} else {
				_up.y = 0;
				_down.y = _height;
				if (_target.y > -_up.height) _up.y = - _up.height - _target.y;
				if (_target.y < _height - _target.height + _down.height) {
					_down.y = _height + _height - _target.height - _target.y + _down.height;
				}
			}
		}
		private function rollOver(e:MouseEvent):void
		{
			trace("Scroller:: rollOver:", _up.y, _upMask.y, _down.y, _downMask.y );
			//TweenLite.killTweensOf(_up);
			//TweenLite.killTweensOf(_down);
			_up.alpha = 1;
			_down.alpha = 1;
			_up.visible = true;
			_down.visible = true;
			adjustScrollButtonPositions();
		}
		private function rollOut(e:MouseEvent=null):void
		{
			//trace("Scroller:: rollOut:" );
			TweenLite.to(_up, 0.1, { alpha:0 } );
			TweenLite.to(_down, 0.1, { alpha:0 } );
			//_up.visible = false;
			//_down.visible = false;
		}
		private function scrollOver(e:MouseEvent):void
		{
			//trace("Scroller:: scrollOver:", e.currentTarget.name, _height, _target.height );
			_scrolling = true;
			if (e.currentTarget.name == "up") {
				_scrollSpeed = 20 
			} else {
				_scrollSpeed = -20
			}
			doScroll();
		}
		private function scrollOut(e:MouseEvent):void
		{
			//trace("Scroller:: scrollOut:", e.currentTarget.name );
			_scrolling = false;
		}
	}

}