/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.ChannelListVO;
	import com.videoswipe.model.vo.FeedRequestVimeoVO;
	import com.videoswipe.model.vo.FeedVO;
	import com.videoswipe.model.vo.PlaylistsVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.SearchVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import com.videoswipe.model.vo.VideoItemYouTubeVO;
	import com.videoswipe.model.vo.VideoVO;
	import com.videoswipe.model.vo.FeedRequestYouTubeVO;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class FeedProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "FeedProxy";
		private static const APIKEY:String = "AIzaSyDvwIO5aZMNk6tEV35lT5z-RGRPPrcyAwY";	// official VideoSwipe API key
		private static const MAXPLAYLISTITEMS:int = 50;	// maximum number of playlist items returned

		private var youTubeLoader:URLLoader;
		private var youTubeJSONLoader:URLLoader;	// a new API call for retrieving JSON objects
		private var vimeoLoader:URLLoader = new URLLoader();
		private var _feedRequestYouTubeVO:FeedRequestYouTubeVO;
		private var _playlistRequestYouTubeVO:FeedRequestYouTubeVO;
		private var _feedRequestVimeoVO:FeedRequestVimeoVO;
		private var _searchText:String;	// cache a copy of the search string

		public function FeedProxy() {
			super(NAME, Number(0) );
		}
		
		override public function onRegister():void
		{
			youTubeLoader = new URLLoader();
			youTubeJSONLoader = new URLLoader();
			_feedRequestYouTubeVO = new FeedRequestYouTubeVO();
			_playlistRequestYouTubeVO = new FeedRequestYouTubeVO();
			_playlistRequestYouTubeVO.maxresults = 50;
			_playlistRequestYouTubeVO.format = "atom";
			
			youTubeLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			youTubeLoader.addEventListener(Event.COMPLETE, youTubeFeedResultHandler);
			youTubeJSONLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			youTubeJSONLoader.addEventListener(Event.COMPLETE, youTubeJSONResultHandler);
			// Ignore Vimeo for now...
			//_feedRequestVimeoVO = new FeedRequestVimeoVO();
			//vimeoLoader.addEventListener(Event.COMPLETE, vimeoResultHandler);
			//vimeoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			// for now just populate the YouTube feed with some top-rated videos
			directSearch( "http://gdata.youtube.com/feeds/api/standardfeeds/top_favorites?time=this_month&max-results=20" );
		}

		private function get requestYouTube():FeedRequestYouTubeVO
		{
			//trace("FeedProxy:: requestYouTube:", _feedRequestYouTubeVO.fullURL );
			return _feedRequestYouTubeVO;
		}
		private function set requestYouTube( fr:FeedRequestYouTubeVO ):void
		{
			_feedRequestYouTubeVO = fr;
		}
		public function youTubeSearch( searchVO:SearchVO ):void
		{
			_searchText = searchVO.searchText;
			if (searchVO.standardFeed) {
				requestYouTube.feedtype = "standardfeeds";
				requestYouTube.standardFeed = searchVO.standardFeed;
			} else {
				requestYouTube.feedtype = "videos";
			}
			//request.category = (searchVO.category)? searchVO.category : "";
			//request.time = (searchVO.timeperiod)? searchVO.timeperiod : "";
			requestYouTube.searchText = searchVO.searchText;
			//youTubeLoader.removeEventListener(Event.COMPLETE, youTubeChannelResultHandler);
			//youTubeLoader.addEventListener(Event.COMPLETE, youTubeFeedResultHandler);
			youTubeLoader.load( requestYouTube.fullRequest );
			
			// extra job search for playlists (use new v3 API)
			// just hack the URL for now - extend if useful
			// sample URI: https://www.googleapis.com/youtube/v3/search?part=snippet&type=playlist&maxResults=25&q=skateboarding
			//var _r:URLRequest = new URLRequest( "https://www.googleapis.com/youtube/v3/search?part=snippet&type=playlist&maxResults=25&key=" + APIKEY + "&q=" + searchVO.searchText);
			_playlistRequestYouTubeVO.feedtype = "videos";
			_playlistRequestYouTubeVO.searchText = searchVO.searchText;
			youTubeJSONLoader.load( _playlistRequestYouTubeVO.fullRequest );
		}
		public function getRelatedVideos( _videoID:String ):void
		{
			//youTubeLoader.removeEventListener(Event.COMPLETE, youTubeChannelResultHandler);
			youTubeLoader.removeEventListener(Event.COMPLETE, youTubeFeedResultHandler);
			youTubeLoader.addEventListener(Event.COMPLETE, youTubeRelatedVideosHandler);
			youTubeLoader.load( new URLRequest("http://gdata.youtube.com/feeds/api/videos/" + _videoID + "/related?max-results=15"));
		}
		public function channelRequest( searchVO:SearchVO ):void
		{
			requestYouTube.feedtype = "channels";
			requestYouTube.searchText = searchVO.searchText;
			youTubeLoader.removeEventListener(Event.COMPLETE, youTubeFeedResultHandler);
			youTubeLoader.addEventListener(Event.COMPLETE, youTubeChannelResultHandler);
			youTubeLoader.load( requestYouTube.fullRequest );
		}
		public function directSearch( s:String ):void
		{
			youTubeLoader.load( new URLRequest(s));
		}
		// retrieves a playlist from YouTube (V3 data API)
		public function playlistRequest( pid:String ):void
		{
			trace("FeedProxy:: playlistRequest:", pid );
			var _r:URLRequest = new URLRequest( "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=" + MAXPLAYLISTITEMS + "&playlistId=" + pid + "&key=" + APIKEY);
			youTubeJSONLoader.load( _r );
			
		}
		public function youTubeChannelResultHandler(e:Event):void
		{
			trace("FeedProxy:: youTubeChannelRequestHandler:");
			var c:ChannelListVO = new ChannelListVO( XML(e.currentTarget.data) );
			sendNotification( AppConstants.CHANNELSEARCHRESULT, c );
		}
		private function youTubeFeedResultHandler(e:Event):void
		{
			trace("FeedProxy: youTubeResultHandler: DATA");
			//trace("FeedProxy:: youTubeFeedResultHandler:", e.currentTarget.data );
			var f:FeedVO = new FeedVO( XML(e.currentTarget.data) );
			sendNotification( AppConstants.FEEDRESULT, f );
		}
		public function youTubeRelatedVideosHandler(e:Event):void
		{
			trace("FeedProxy:: youTubeRelatedVideosHandler:" );
		}
		
		private function upperCaseFirstWords(str:String):String {
			var words:Array = str.split(" ");
			for(var i:String in words) {
				words[i] = String(words[i]).charAt(0).toUpperCase() + String(words[i]).substr(1, String(words[i]).length);
			}
			return words.join(" ");
		}
		// youTubeJSONResultHandler
		// this function takes the returned FeedVO and creates a set of playlist objects
		// this should be factored out into a command the logic is getting very playlist-specific
		private function youTubeJSONResultHandler(e:Event):void
		{
			// At the moment this is used to retrieve YouTube playlists
			trace("FeedProxy:: youTubeV3ResultHandler:" );
			var _f:FeedVO = new FeedVO( XML(e.currentTarget.data) );
			_f.sortVideos();
			
				var _l:Array = new Array();
				if (_f.videos.length < 10) return;	// if less than 10 items we don't even have 1 Top 10 list

				// now break this array into a series of 10-item playlists
				var _numberOfPlaylists:int = Math.floor( _f.videos.length / 10);
				var _playlists:PlaylistsVO = new PlaylistsVO();
				for (var i:int = _numberOfPlaylists; i--; ) {
					var _playlistVO:PlaylistVO = new PlaylistVO();
					_playlistVO.source = "YT";	// indicate this is a YouTube playlist (NOT VideoSwipe)
					_playlistVO.title = upperCaseFirstWords(_searchText) + " Top 10";
					_playlists.addYouTubePlaylist(_playlistVO);
				}
				var _counter:int = _numberOfPlaylists;
				for (i = _numberOfPlaylists * 10; i--; ) {
					var _itemVO:VideoItemVO = _f.videos[i];
					_playlists.playlists[--_counter].addPlaylistItem( _itemVO );
					if (_counter == 0) _counter = _numberOfPlaylists;
				}
				trace("FeedProxy:: youTubeJSONResultHandler:" );
				sendNotification( AppConstants.YOUTUBEPLAYLISTSLOADED, _playlists );
			
		}
		public function vimeoResultHandler(e:Event):void
		{
			trace("FeedProxy: vimeoResultHandler: hello.");
			var f:FeedVO = new FeedVO( XML(e.currentTarget.data) );
			sendNotification( AppConstants.FEEDRESULT, f );
		}
		public function errorHandler(e:IOErrorEvent):void
		{
			trace("FeedProxy:: errorHandler:", e.text);
		}
	}
}