package com.videoswipe.view.component 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class XSprite extends Sprite implements IXSprite
	{
		protected var _width:uint;
		protected var _height:uint;
		
		public function XSprite(_w:uint = 800, _h:uint = 600) 
		{
			_width = _w;
			_height = _h;
		}
		
		public function setSize(_w:uint, _h:uint):void
		{
			_width = _w;
			_height = _h;
			redraw();
		}
		
		// redraw must be overwritten in subclasses
		public function redraw():void
		{ }
		
	}

}