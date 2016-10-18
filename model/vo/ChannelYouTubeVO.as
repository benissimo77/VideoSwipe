package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class ChannelYouTubeVO extends ChannelVO
	{
		protected static var ATOM:Namespace = new Namespace("http://www.w3.org/2005/Atom");
		protected static var MEDIA:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		protected static var YT:Namespace = new Namespace("http://gdata.youtube.com/schemas/2007");
		protected static var GD:Namespace = new Namespace("http://schemas.google.com/g/2005");

		public function ChannelYouTubeVO( xml:XML = null ) 
		{
			provider = "youTube";
			if (xml) {
				thumbnailURL = String(xml.MEDIA::thumbnail.@url);
				channelTitle = String(xml.ATOM::title);
				channelDescription = String(xml.ATOM::summary);
				updated = xml.ATOM::updated.split("T")[0];
				views = Number(xml.YT::channelStatistics.@viewCount);
				channelID = String(xml.YT::channelId);
			}
		}
		
	}

}