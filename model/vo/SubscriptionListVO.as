package com.videoswipe.model.vo 
{
	import com.adobe.serialization.json.JSONParseError;
	/**
	 * ...
	 * @author  Ben Silburn
	 * 
	 * SubscriptionListVO
	 * a generic class for holding all data for a subscription
	 * constructor is passed a JSON object as returned from the YouTube data API
	 * class provides getters to retrieve the relevant fields
	 */
	public class SubscriptionListVO
	{
		private var _data:Object;
		private var _subscriptions:Vector.<SubscriptionVO>
		
		public function SubscriptionListVO( _d:String = null )
		{
			_subscriptions = new Vector.<SubscriptionVO>;
			try {
				
				_data = JSON.parse( _d );
				for (var i:int = _data.items.length; i--; ) {
					var _sub:SubscriptionVO = new SubscriptionVO( _data.items[i] );
					_subscriptions.push(_sub);
				}

			} catch (e:JSONParseError) {
				trace("SubscriptionListVO:: SubscriptionListVO: JSON error" );
			}
		}

		public function getSubscriptionFromChannelID( _channelID:String ):SubscriptionVO
		{
			for (var i:int = list.length; i--; ) {
				if (list[i].channelID == _channelID) {
					return list[i];
				}
			}
			return null;
		}
		public function get nextPageToken():String
		{
			return _data ? _data.nextPageToken : null;
		}
		public function get totalResults():int
		{
			return _data ? _data.pageInfo.totalResults : 0;
		}
		public function get list():Vector.<SubscriptionVO>
		{
			return _subscriptions;
		}
	}
	

}