package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class Size 
	{
		private var _w:int;
		private var _h:int;
		
		public function Size( w:int = 0, h:int = 0 ) 
		{
			_w = w;
			_h = h;
		}
		
		public function get w():int 
		{
			return _w;
		}
		
		public function set w(value:int):void 
		{
			_w = value;
		}
		
		public function get h():int 
		{
			return _h;
		}
		
		public function set h(value:int):void 
		{
			_h = value;
		}
		
	}

}