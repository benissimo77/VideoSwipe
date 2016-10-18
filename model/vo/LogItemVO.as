package com.videoswipe.model.vo
{
	/**
	 * ...
	 * @author 
	 */
	public class LogItemVO 
	{
		
		public var name:String;
		public var type:String;
		public var body:Object;
		
		public function LogItemVO(_f:Object=null) 
		{
			if (_f) fillFromObject(_f);
		}
		
		private function fillFromObject(_o:Object):void
		{
			name = _o.name;
			if (_o.type) type = _o.type;
			if (_o.body) body = _o.body;
		}
		
		
	}

}