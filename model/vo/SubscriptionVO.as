package com.videoswipe.model.vo 
{
	import com.adobe.serialization.json.JSONParseError;
	/**
	 * ...
	 * @author  Ben Silburn
	 * 
	 * SubscriptionVO
	 * a generic class for holding all data for a subscription
	 * constructor is passed a JSON object as returned from the YouTube data API
	 * class provides getters to retrieve the relevant fields
	 */
	public class SubscriptionVO
	{
		private var _data:Object;
		private var _videoItems:Vector.<VideoItemVO>
		
		public function SubscriptionVO( _d:Object = null ) 
		{
			_data = _d;
			_videoItems = new Vector.<VideoItemVO>;
		}

		// used to fill out a channel list from a YouTube (V3) subscription list call
		// we found that some items in a channel subscription can contain dead items
		// ie the videoID of the item was null
		// so we check this and don't add if no videoID found
		public function addVideoItems( _j:Object ):void
		{
			for (var i:int = _j.items.length; i--; ) {
				var _itemVO:VideoItemVO = new VideoItemVO();
				_itemVO.youTubeV3Item = _j.items[i];
				if (_itemVO.videoID) {
					_videoItems.push( _itemVO );
				} else {
					trace("SubscriptionVO:: addVideoItems: VIDEOID NULL");
				}
			}
		}
		
		public function get title():String
		{
			return _data ? _data.snippet.title : null;
		}
		public function get description():String
		{
			return _data ? _data.snippet.description : null;
		}
		public function get channelID():String
		{
			return _data ? _data.snippet.resourceId.channelId : null;
		}
		public function get thumbnailURL():String
		{
			return _data ? _data.snippet.thumbnails.default.url : null;
		}
		public function get videoItems():Vector.<VideoItemVO>
		{
			return _videoItems;
		}

		public function get data():Object
		{
			return _data;
		}
	}

}