package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author  Ben Silburn
	 * 
	 * VideoItemVO
	 * a generic class for holding all data for a video item
	 * it is provider-independent meaning it can be used for all video providers, it stores the name of the provider so
	 * anyone using this class will know where to retrieve the actual video
	 * designed to be extended by the concrete classes for each provider (these will also set the provider var)
	 */
	public class VideoItemVO
	{
		private var xml:XML;
		
		// the following fields have getters to control how they are used
		// some fields don't get set by the source object
		private var _category:String;
		private var _author:String;

		public var provider:String;
		public var thumbnailURL:String;
		public var thumbnailURLLarge:String;
		public var videoTitle:String;
		public var videoDescription:String;
		public var published:String;
		public var views:Number;
		public var numlikes:String;
		public var rating:Number;
		public var duration:Number;
		public var videoID:String;
		public var videoMessages:Vector.<VideoMessageVO>;
		
		public function VideoItemVO( _x:XML = null ) 
		{
			if (_x) xml = _x;
			videoMessages = new Vector.<VideoMessageVO>;
		}
		
		public function fillFromObject(_o:Object):void
		{
			trace("VideoItemVO:: fillFromObject:", _o, typeof(_o.videoMessages) );
			// special case for serialising videoMessages object
			if (_o.videoMessages) {
				var _thisObj:Object = _o.videoMessages;
				if (typeof(_o.videoMessages) == "string") {
					_thisObj = JSON.parse(_o.videoMessages);
				}
				for (var _i:int = _thisObj.length; _i--; ) {
					videoMessages.push( new VideoMessageVO( _thisObj[_i] ));
				}
				delete _o.videoMessages;
			}
			for (var _s:String in _o) {
				try {
					this[_s] = _o[_s];
				} catch (e:Error) {
					trace("VideoItemVO:: fillFromObject: ERROR" );
				}
			}
		}
		
		// youTubeV3Item
		// allows us to pass in a JSON object and will set the fields from the object
		// object follows the V3 specification for a searchList response (a list of video items)
		public function set youTubeV3Item( _o:Object ):void
		{
			if (_o.title) {
				videoTitle = _o.title;
			}
			if (_o.snippet && _o.snippet.title) {
				videoTitle = _o.snippet.title;
			}
			if (_o.id) {
				videoID = _o.id.videoId;
			}
			if (_o.resourceId && _o.resourceId.videoId) {
				videoID = _o.resourceId.videoId;
			}
			if (_o.snippet && _o.snippet.description) {
				videoDescription = _o.snippet.description;
			}
			if (_o.thumbnails) {
				if (_o.thumbnails.default) {
					thumbnailURL = _o.thumbnails.default.url;
					thumbnailURLLarge = _o.thumbnails.high.url;
				}
				if (_o.thumbnails.high) {
					thumbnailURL = _o.thumbnails.high.url;
					thumbnailURLLarge = _o.thumbnails.high.url;
				}
			}
			if (_o.snippet && _o.snippet.publishedAt) {
				published = _o.snippet.publishedAt;
			}
			if (_o.snippet && _o.snippet.thumbnails) {
				thumbnailURL = _o.snippet.thumbnails.default.url;
				thumbnailURLLarge = thumbnailURL;
			}
		}
		public function set youTubeItem( _o:Object ):void
		{
			if (_o.title) {
				videoTitle = _o.title;
			}
			if (_o.resourceId && _o.resourceId.videoId) {
				videoID = _o.resourceId.videoId;
			}
			if (_o.thumbnails) {
				if (_o.thumbnails.default) {
					thumbnailURL = _o.thumbnails.default.url;
					thumbnailURLLarge = _o.thumbnails.high.url;
				}
				if (_o.thumbnails.high) {
					thumbnailURLLarge = _o.thumbnails.high.url;
				}
			}
		}
		
		public function get category():String 
		{
			return _category ? _category : "";
		}
		
		public function get author():String 
		{
			return _author ? _author : "";
		}
		
		public function set category(value:String):void 
		{
			_category = value;
		}
		
		public function set author(value:String):void 
		{
			_author = value;
		}
		
	}

}