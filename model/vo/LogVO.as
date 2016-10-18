package com.videoswipe.model.vo
{
	/**
	 * ...
	 * @author 
	 */
	public class LogVO 
	{
		private var _logObject:Object;
		private var _logItems:Vector.<LogItemVO>;
		
		public function LogVO(_f:Object=null) 
		{
			if (_f) {
				_logObject = _f;
				_logItems = createLogItems();
			}
		}
		
		public function get logItems():Vector.<LogItemVO> {
			return _logItems;
		}

		private function createLogItems():Vector.<LogItemVO> {
			var _json:Object = JSON.parse(_logObject.log);
			var _s:Vector.<LogItemVO> = new Vector.<LogItemVO>();
			for (var i:int = _json.length; i--; ) {
				_s.push ( new LogItemVO( _json[i] ));
			}
			return _s;
		}
		
		public function get uid():String
		{
			if (_logObject) return _logObject.uid;
			return null;
		}
		public function get timestamp():String
		{
			if (_logObject) return _logObject.timestamp;
			return null;
		}
		
	}

}