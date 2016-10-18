package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class VideoVO extends ValueObject
	{
		
		public function VideoVO( _x:XML = null) 
		{
			super(_x);
		}

		// getter functions for pulling out the relevant fields from the XML object
		public function get thumbnailURL():String
		{
			// NOTE: the line below returns the first thumb in the XML...
			return String(xml.MEDIA::group.MEDIA::thumbnail[0].@url);
			/*
			 * below code to retrieve a list of URLs for thumbnails - do this later !!!
			var v:Vector.<String> = new Vector.<String>();
			var t1:XML = xml.MEDIA::group.MEDIA::thumbnail.(@YT::name = "start")[0];
			var t2:XML = xml.MEDIA::group.MEDIA::thumbnail[0].(@YT::name = "middle")[0];
			var t3:XML = xml.MEDIA::group.MEDIA::thumbnail[0].(@YT::name = "end")[0];
			var td:String = String(xml.MEDIA::group.MEDIA::thumbnail[0].@url);
			if (t1.@url != "") v.push(t1.@url);
			if (t2.@url != "") v.push(t2.@url);
			if (t3.@url != "") v.push(t3.@url);
			if (v.length == 0) v.push(td);
			return td;
			*/
		}
		public function get videoTitle():String
		{
			return String(xml.MEDIA::group.MEDIA::title);
		}
		public function get videoDescription():String
		{
			return String(xml.MEDIA::group.MEDIA::description);
		}
		public function get published():String
		{
			return xml.ATOM::published.split("T")[0];
		}
		public function get author():String
		{
			return ( xml.ATOM::author[0].ATOM::name );
		}
		public function get views():Number
		{
			return Number(xml.YT::statistics.@viewCount);
		}
		public function get numlikes():String
		{
			return String(xml.YT::rating.@numLikes);
		}
		public function get rating():Number
		{
			return Number(xml.GD::rating.@average);
		}
		public function get duration():Number
		{
			return Number(xml.MEDIA::group.YT::duration.@seconds);
		}
		public function get videoID():String
		{
			return String(xml.MEDIA::group.YT::videoid);
		}
	}

}