package com.videoswipe.model.vo
{
	/**
	 * ...
	 * @author 
	 */
	public class AllLogsVO 
	{
		private var _logObject:Object;
		private var _allLogs:Array;
		private var _totals:Array;
		
		private var _index:Object;
		
		public function AllLogsVO(_f:Object=null) 
		{
			if (_f) {
				_logObject = _f;
				_allLogs = _logObject.overview as Array;
				_totals = _logObject.totals as Array;
			}
		}

		public function get totalNumberOfLogs():int
		{
			return _allLogs.length;
		}
		public function get logItems():Array
		{
			return _allLogs;
		}
		public function getTotalSessionsForUser( u:String ):int
		{
			if (_index[u]) return _index[u];
			for (var i:int = _totals.length; i--; ) {
				if (_totals[i].uid == u) {
					_index[u] = _totals[i].count;
					return _index[u];
				}
			}
			return 0;
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