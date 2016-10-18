package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class VideoItemYouTubeVO extends VideoItemVO
	{
		protected static var ATOM:Namespace = new Namespace("http://www.w3.org/2005/Atom");
		protected static var MEDIA:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		protected static var YT:Namespace = new Namespace("http://gdata.youtube.com/schemas/2007");
		protected static var GD:Namespace = new Namespace("http://schemas.google.com/g/2005");

		public function VideoItemYouTubeVO( xml:XML = null ) 
		{
			super(xml);
			provider = "youTube";
			
			if (xml) {
				var _thumbnails:XMLList = xml.MEDIA::group.MEDIA::thumbnail;
				thumbnailURL = getThumbnailURLDefault( _thumbnails );
				thumbnailURLLarge = getThumbnailURLLarge( _thumbnails );
				videoTitle = String(xml.MEDIA::group.MEDIA::title);
				videoDescription = String(xml.MEDIA::group.MEDIA::description);
				category = String(xml.ATOM::category.@label);
				published = xml.ATOM::published.split("T")[0];
				author = xml.ATOM::author[0].ATOM::name;
				views = Number(xml.YT::statistics.@viewCount);
				numlikes = String(xml.YT::rating.@numLikes);
				rating = Number(xml.GD::rating.@average);
				duration = Number(xml.MEDIA::group.YT::duration.@seconds);
				videoID = String(xml.MEDIA::group.YT::videoid);
			}

		}
		
		
		private function getThumbnailURLDefault(_t:XMLList):String
		{
			return _t[0].@url;
		}
		private function getThumbnailURLLarge(_t:XMLList):String
		{
			for (var _x:String in _t) {
				var _att:String = _t[_x].@YT::name;
				if (_att == "hqdefault") {
//					trace("VideoItemYouTubeVO:: getThumbnailURLLarge:", _t[_x].@url );
					return _t[_x].@url;
				}
			}
			return "";
		}
		
	}

}