package com.videoswipe.model.vo 
{
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author 
	 */
	public class ChannelRequestYouTubeVO 
	{
		private var url:String = "http://gdata.youtube.com/";
		private var _projection:String = "api";	// usually one of 'api', 'base' or 'mobile'
		private var _feedtype:String = "";	// usually one of 'videos', 'users' or 'standardfeeds'
		private var _standardFeed:String = "";	// for standard feed, the type of standard feed requested
		private var _category:String = "";	// category filter
		private var _time:String = "";		// time filter
		private var _searchText:String = "";	// search text
		private var maxresults:int = 8;	// used to limit the returned number of results

		private var updateRequired:Boolean = true;	// used to determine if new request needs to be generated
		private var _fullRequest:URLRequest;

		public function FeedRequestYouTubeVO() { }

		public function set projection(p:String):void
		{
			if (p != _projection) {
				_projection = p;
				updateRequired = true;
			}
		}
		public function set feedtype(f:String):void
		{
			if (f != _feedtype) {
				_feedtype = f;
				updateRequired = true;
			}
		}
		public function set searchText(s:String):void
		{
			if (s != _searchText) {
				_searchText = s;
				updateRequired = true;
			}
		}
		public function get fullURL():String
		{
			var _u:String = url + "/" + _projection + "/" + _feedtype;
			if (_feedtype == "standardfeeds") _u += "/" + _standardFeed;
			_u += "?v=2&format=5&max-results=" + maxresults;
			if (_searchText != "") _u += "&q=" + _searchText;
			if (_category != "") _u += "&category=" + _category;
			if (_time != "") _u += "&time=" + _time;
			trace("FeedRequestYouTubeVO:: fullURL:", _u);
			return _u;
		}
		public function get fullRequest():URLRequest
		{
			if (updateRequired) _fullRequest = new URLRequest( fullURL );
			return _fullRequest;
		}
	}

}