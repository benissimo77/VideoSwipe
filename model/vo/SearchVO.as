package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class SearchVO 
	{
		private var _searchtext:String = "";
		private var _standardfeed:String = "";
		private var _category:String = "";
		private var _timeperiod:String = "";
		
		public function SearchVO()
		{}

		public function get searchText():String
		{
			return _searchtext;
		}
		public function get standardFeed():String
		{
			return _standardfeed;
		}
		public function get category():String
		{
			return _category;
		}
		public function get timeperiod():String
		{
			return _timeperiod;
		}
		
		
		public function set searchText(value:String):void 
		{
			_searchtext = value;
		}
		public function set standardFeed(value:String):void 
		{
			_standardfeed = value;
		}
		public function set category(value:String):void 
		{
			_category = value;
		}
		public function set timeperiod(value:String):void 
		{
			_timeperiod = value;
		}
		
	}

}