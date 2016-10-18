package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class ChannelListVO extends AbstractAtomVO
	{
		protected static var OPENSEARCH:Namespace = new Namespace("http://a9.com/-/spec/opensearch/1.1/");
		//protected static var MEDIA:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		//protected static var YT:Namespace = new Namespace("http://gdata.youtube.com/schemas/2007");
		//protected static var GD:Namespace = new Namespace("http://schemas.google.com/g/2005");

		public function ChannelListVO( _x:XML = null ) 
		{
			super(_x);
			//trace(_x);
		}

		// Implicit getter/setter functions to set/retrieve elements from the feed object...
		public function get startIndex():Number
		{
			return Number(xml.OPENSEARCH::startIndex);
		}
		public function get itemsPerPage():Number
		{
			return Number(xml.OPENSEARCH::itemsPerPage);
		}
		public function get totalResults():Number
		{
			return Number(xml.OPENSEARCH::totalResults);
		}
		public function get previousPage():String
		{
			var xl:XMLList = xml.ATOM::link;
			for each (var link:XML in xl) {
				trace(link);
				if (link.@rel == "previous") {
					trace("FOUND!");
					return link.@href;
				}
			}
			return null;
		}
		public function get nextPage():String
		{
			var xl:XMLList = xml.ATOM::link;
			for each (var link:XML in xl) {
				trace(link);
				if (link.@rel == "next") {
					trace("FOUND!", link.@href);
					return link.@href;
				}
			}
			return null;
		}
		public function get channels():Vector.<ChannelYouTubeVO> {
			var v:Vector.<ChannelYouTubeVO> = new Vector.<ChannelYouTubeVO>();
			var xl:XMLList = xml.ATOM::entry;
			for each ( var sx:XML in xl ) {
				var channel:ChannelYouTubeVO = new ChannelYouTubeVO( sx );
				v.push(channel);
			}
			return v;
		}
		public function set channel( v:Vector.<ChannelYouTubeVO> ):void
		{} // read-only but bindable

	}

}