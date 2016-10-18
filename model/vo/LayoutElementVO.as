package com.videoswipe.model.vo 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * (c) Ben Silburn
	 */
	public class LayoutElementVO 
	{
		private var _elementName:String;
		private var _anchor:String;
		private var _elementPosition:Position;
		private var _elementSize:Size;
		
		public function LayoutElementVO( name:String = "Unknown", anchor:String = "", pos:Rectangle = null ) 
		{
			_elementName = name;
			_anchor = anchor;
			_elementPosition = new Position();
			_elementSize = new Size();
			if (pos) layout = pos;
		}
		
		public function set layout(pos:Rectangle):void
		{
			_elementPosition.x = pos.x
			_elementPosition.y = pos.y;
			_elementSize.w = pos.width;
			_elementSize.h = pos.height;
		}
		public function get layout():Rectangle
		{
			return new Rectangle(_elementPosition.x, _elementPosition.y, _elementSize.w, _elementSize.h);
		}
		public function get name():String 
		{
			return _elementName;
		}
		
		public function set name(value:String):void 
		{
			_elementName = value;
		}
		
		public function get position():Position 
		{
			return _elementPosition;
		}
		
		public function set position(value:Position):void 
		{
			_elementPosition = value;
		}
		
		public function get size():Size 
		{
			return _elementSize;
		}
		
		public function set size(value:Size):void 
		{
			_elementSize = value;
		}
		
		public function get anchor():String 
		{
			return _anchor;
		}
		
		public function set anchor(value:String):void 
		{
			_anchor = value;
		}
		
		
	}

}