package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class Position 
	{
		private var _x:int;
		private var _y:int;
		public function Position( x:int = 0, y:int = 0 )
		{
			_x = x;
			_y = y;
		}
		
		public function get x():int 
		{
			return _x;
		}
		
		public function set x(value:int):void 
		{
			_x = value;
		}
		
		public function get y():int 
		{
			return _y;
		}
		
		public function set y(value:int):void 
		{
			_y = value;
		}
		
	}

}