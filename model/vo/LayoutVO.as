package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class LayoutVO 
	{
		private var _name:String;
		private var _elements:Vector.<LayoutElementVO>;

		public function LayoutVO( name:String = null) 
		{
			if (name) _name = name;
			_elements = new Vector.<LayoutElementVO>;
		}
		
		public function get elements():Vector.<LayoutElementVO> 
		{
			return _elements;
		}
		public function get name():String 
		{
			return _name;
		}
		public function set name(value:String):void 
		{
			_name = value;
		}

		public function addElement( e:LayoutElementVO ):void
		{
			_elements.push(e);
		}
	}

}