package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class VideoItemVimeoVO extends VideoItemVO
	{
		protected static var ATOM:Namespace = new Namespace("http://www.w3.org/2005/Atom");
		protected static var MEDIA:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		protected static var YT:Namespace = new Namespace("http://gdata.youtube.com/schemas/2007");
		protected static var GD:Namespace = new Namespace("http://schemas.google.com/g/2005");

		public function VideoItemVimeoVO( xml:XML = null ) 
		{
			provider = "vimeo";
			if (xml) {
				thumbnailURL = String(xml.MEDIA::group.MEDIA::thumbnail[0].@url);
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
		
	}

}