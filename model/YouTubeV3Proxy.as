/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.SubscriptionListVO;
	import com.videoswipe.model.vo.SubscriptionVO;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class YouTubeV3Proxy extends Proxy implements IProxy {
		
		public static const NAME:String = "YouTubeV3Proxy";
		private static const APIKEY:String = "AIzaSyDvwIO5aZMNk6tEV35lT5z-RGRPPrcyAwY";	// official VideoSwipe API key

		protected var _requestQueue:Array;
		protected var _requestId:int;

		private var _subscriptions:SubscriptionListVO;
		
		public function YouTubeV3Proxy(data:Object = null) {
			super(NAME, data);
		}
	
		override public function onRegister():void
		{
			trace("YouTubeV3Proxy:: onRegister:" );
			_requestId = 0;
			_requestQueue = [];
		}

		public function getUserSubscriptions(accessToken:String, maxResults:int = 40, pageToken:String = ""):int
		{
			trace("YouTubeV3Proxy:: getUserSubscriptions:", accessToken );
			var url:String = "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&mine=true&key=" + APIKEY + "&access_token=" + accessToken;

			// additional modifiers go here...
			url += "&order=relevance&maxResults=" + maxResults;
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.GET;
			
			return runLoader(request, doSubscriptionsLoaded, { comment:"subscriptions" } );
		}
		protected function doSubscriptionsLoaded(evt:Event):void
		{
			trace("YouTubeV3Proxy:: doSubscriptionsLoaded:" );
			var wrapper:Object = getWrapper(evt.target as URLLoader);
			_subscriptions = new SubscriptionListVO( wrapper.loader.data );
			
			trace("YouTubeV3Proxy:: doSubscriptionsLoaded:", _subscriptions.nextPageToken, _subscriptions.totalResults );
			for (var i:int = _subscriptions.list.length; i--; ) {
				var _subVO:SubscriptionVO = _subscriptions.list[i];
				trace("YouTubeV3Proxy:: doSubscriptionsLoaded:", _subVO.title);
				getVideosForChannel( _subVO.channelID, _subVO.data );
			}
//			sendNotification( "xxx", { id:wrapper.id, feed:JSON.parse(evt.target.data) } );
		}
		
		
		public function getUserPlaylists(accessToken:String, startIndex:int = 1, maxResults:int = 25):int
		{
			var request:URLRequest = new URLRequest("");
			return runLoader(request, doUserPlaylistsLoaded, { comment:"user_playlist" } );
		}
		protected function doUserPlaylistsLoaded(e:Event):void
		{
			trace("doUserPlaylistsLoaded");
			
			var wrapper:Object = getWrapper(e.target as URLLoader);
			sendNotification( "xxx", { id:wrapper.id, feed:JSON.parse(e.target.data) } );
		}
		
		private function getVideosForChannel( channelID:String, channelObj:Object = null, maxResults:int = 15 ):void
		{
			var url:String = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=" + channelID + "&order=date&key=" + APIKEY;
			
			// extra modifiers here...
			url += "&maxResults=" + maxResults;
			
			trace("YouTubeV3Proxy:: getVideosForChannel:", url );
			var request:URLRequest = new URLRequest( url );
			if (!channelObj) {
				channelObj = { comment:"videosforchannel" };
			}
			runLoader( request, onVideosForChannelLoaded, { channelID:channelID } );
		}
		private function onVideosForChannelLoaded(e:Event):void
		{
			trace("YouTubeV3Proxy:: onVideosForChannelLoaded:" );
			var wrapper:Object = getWrapper(e.target as URLLoader);
			var json:Object = JSON.parse(wrapper.loader.data);
			
			var _subVO:SubscriptionVO = _subscriptions.getSubscriptionFromChannelID(wrapper.channelID);
			if (_subVO) {
				_subVO.addVideoItems(json);
				trace("YouTubeV3Proxy:: onVideosForChannelLoaded: DONE!" );
				sendNotification( AppConstants.USERSUBSCRIPTIONRESULT, _subVO );
			}
		}
		// Utility functions to create and manage the URLLoader objects
		protected function getLoaderIndex(loader:URLLoader):int
		{
			for (var i:int = _requestQueue.length; i--; )
			{
				if (_requestQueue[i].loader == loader)
					return i;
			}
			return -1;
		}
		protected function getWrapper(loader:URLLoader):Object
		{
			return _requestQueue[getLoaderIndex(loader)];
		}
		
		protected function runLoader(request:URLRequest, doComplete:Function, wrapper:Object):Number
		{
			trace("YouTubeV3Proxy:: runLoader:", request.data );
			var loader:URLLoader = new URLLoader();			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, progressEventHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR , securityErrorHandler);
			loader.addEventListener(Event.COMPLETE, doComplete);
			loader.load(request);
			
			wrapper.id = _requestId++;
			wrapper.success = false;
			wrapper.loader = loader;
			_requestQueue.push(wrapper);
			
			return _requestId - 1;
		}
		

		// EVENT HANDLERS FOR URLLOADER
		protected function httpStatusHandler(evt:HTTPStatusEvent):void
		{
			if (evt.status == 201)
			{
				evt.stopImmediatePropagation();
				var wrapper:Object = getWrapper(evt.target as URLLoader);
				trace("YouTubeV3Proxy:: httpStatusHandler:", wrapper.videoId );
				wrapper.success = true;
			}
		}
		protected function IOErrorHandler(evt:IOErrorEvent):void
		{
			trace("YouTubeV3Proxy:: IOErrorHandler:", evt.toString() );
			var wrapper:Object = getWrapper(evt.target as URLLoader);
			trace("YouTubeV3Proxy:: IOErrorHandler:", wrapper.success );
		}
		protected function securityErrorHandler(evt:SecurityErrorEvent):void
		{
			trace("YouTubeV3Proxy:: securityErrorHandler:", evt.toString() );
		}
		protected function progressEventHandler(evt:ProgressEvent):void
		{
			var percent:Number = Math.round(evt.bytesLoaded / evt.bytesTotal * 100);
			var idx:Number = getLoaderIndex(evt.target as URLLoader);
			trace("loader:"+idx+" at "+percent+"%; bytesLoaded:"+evt.bytesLoaded+", bytesTotal:"+evt.bytesTotal);
		}
		
		public function get subscriptionList():SubscriptionListVO 
		{
			return _subscriptions;
		}
	}
}