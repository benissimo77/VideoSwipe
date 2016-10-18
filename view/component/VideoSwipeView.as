package com.videoswipe.view.component 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class VideoSwipeView extends Sprite
	{
		private var _mouse:Shape;
		private var _mouseX:int;
		private var _mouseY:int;
		
		public function VideoSwipeView() 
		{
			_mouse = new Shape();
			_mouse.graphics.clear();
			_mouse.graphics.lineStyle(5, 0xffffff, 1);
			_mouse.graphics.moveTo( 0, -11);
			_mouse.graphics.lineTo( 0, 11);
			_mouse.graphics.moveTo( -11, 0);
			_mouse.graphics.lineTo( 11, 0);
			_mouse.graphics.lineStyle(3, 0x0000c0, 1);
			_mouse.graphics.moveTo(0, -7);
			_mouse.graphics.lineTo(0, 7);
			_mouse.graphics.moveTo( -7, 0);
			_mouse.graphics.lineTo(7, 0);
			
		}
		
		public function mouseMove( _x:int, _y:int):void
		{
			trace("VideoSwipeView:: mouseMove:", _x, _y );
			_mouse.x = _x;
			_mouse.y = _y;
			addChild(_mouse);
		}
	}

}