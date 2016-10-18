package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class FeedVO extends AbstractAtomVO
	{
		protected var OPENSEARCH:Namespace;

		//protected static var OPENSEARCH:Namespace = new Namespace("http://a9.com/-/spec/opensearch/1.1/");
		//protected static var MEDIA:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		//protected static var YT:Namespace = new Namespace("http://gdata.youtube.com/schemas/2007");
		//protected static var GD:Namespace = new Namespace("http://schemas.google.com/g/2005");

		private var _cachedVideos:Vector.<VideoItemYouTubeVO>;	// cache a copy of the generated video object for ongoing reference

		public function FeedVO( _x:XML = null ) 
		{
			super(_x);
			// xml now contains valid XML - thought it might be empty
			// set up the namespace used by this feed (different feeds use different namespaces, why???)
			OPENSEARCH = xml.namespace("openSearch");
			if (!OPENSEARCH) {
				OPENSEARCH = new Namespace("http://a9.com/-/spec/opensearch/1.1/");
			}	// sets NS to something valid otherwise requests will throw an error
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
					return link.@href;
				}
			}
			return null;
		}
		public function get videos():Vector.<VideoItemYouTubeVO> {
			if (_cachedVideos) return _cachedVideos;
			var v:Vector.<VideoItemYouTubeVO> = new Vector.<VideoItemYouTubeVO>();
			var xl:XMLList = xml.ATOM::entry;
			for each ( var sx:XML in xl ) {
				var video:VideoItemYouTubeVO = new VideoItemYouTubeVO( sx );
				v.push(video);
			}
			_cachedVideos = v;
			return v;
		}
		
		public function set videos( v:Vector.<VideoItemYouTubeVO> ):void
		{} // read-only but bindable

		public function sortVideos():void
		{
			_cachedVideos = videos;
			_cachedVideos.sort( compareItems );
		}
		private function compareItems( i1:VideoItemYouTubeVO, i2:VideoItemYouTubeVO):Number
		{
			return i2.views - i1.views;
		}
	}

}