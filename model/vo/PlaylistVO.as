package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class PlaylistVO 
	{
		private var _playlistID:int;
		private var _playlistUID:String;// uid of the owner of this playlist
		private var _playlistTitle:String;
		private var _playlistDuration:int;
		private var _playlistFather:int;	// ancestor of this playlist (allows tracking of playlist shares)
		private var _playlistLocked:Boolean;
		private var _playlistHidden:Boolean;
		private var _playlistItems:Vector.<VideoItemVO>;
		private var _currentlyPlaying:int;
		private var _timestamp:String;
		private var _source:String;	// source of this playlist YT or VS
		private var _thumbURL:String;	// for YT playlists we need to store the thumb URL (for VS we derive from the pid)
		private var _youTubeID:String;	// for YT playlists the ID is a String
		
		public function PlaylistVO( _o:Object = null) 
		{
			_playlistTitle = "My First Playlist";
			_playlistDuration = 0;
			_playlistUID = "";
			_playlistItems = new Vector.<VideoItemVO>;
			_playlistLocked = false;
			_playlistHidden = false;
			_currentlyPlaying = 0;
			_timestamp = "";
			_source = "VS";
			_thumbURL = "";
			_youTubeID = "";
			
			
			if (_o) fillFromObject(_o);
		}
		
		public function fillFromObject(_o:Object):void
		{
				for (var i:String in _o) {
					try {
						//trace("PlaylistVO:: fillFromObject:", i, _o[i] );
						this[i] = _o[i];
					} catch (e:Error) {
					}
				}
		}
		public function clearPlaylistItems():void
		{
			_playlistItems = new Vector.<VideoItemVO>;
		}
		public function get playlistItems():Vector.<VideoItemVO>
		{
			return _playlistItems;
		}
		public function get playlistLength():int
		{
			return _playlistItems.length;
		}
		public function get currentlyPlaying():int
		{
			return _currentlyPlaying;
		}
		
		public function set currentlyPlaying(value:int):void 
		{
			_currentlyPlaying = value;
		}
		
		public function get title():String 
		{
			return _playlistTitle;
		}
		
		public function set title(value:String):void 
		{
			_playlistTitle = value;
		}
		
		
		public function get pid():int 
		{
			return _playlistID;
		}
		
		public function set pid(value:int):void 
		{
			_playlistID = value;
		}
		
		public function get uid():String 
		{
			return _playlistUID;
		}
		
		public function set uid(value:String):void 
		{
			_playlistUID = value;
		}
		
		public function get father():int 
		{
			return _playlistFather;
		}
		
		public function set father(value:int):void 
		{
			_playlistFather = value;
		}
		
		public function get locked():Boolean 
		{
			return _playlistLocked;
		}
		
		public function set locked(value:Boolean):void 
		{
			_playlistLocked = value;
		}
		
		public function get hidden():Boolean 
		{
			return _playlistHidden;
		}
		
		public function set hidden(value:Boolean):void 
		{
			_playlistHidden = value;
		}
		
		public function get duration():int 
		{
			return _playlistDuration;
		}
		
		public function set duration(value:int):void 
		{
			_playlistDuration = value;
		}
		
		public function get timestamp():String 
		{
			return _timestamp;
		}
		
		public function set timestamp(value:String):void 
		{
			_timestamp = value;
		}
		// sets the properties of this VO according to the YouTube playlist JSON object
		// NOTE: this is a V3 version ready for when V2 is deprecated
		public function set youTubeV3Playlist( _o:Object ):void
		{
			_source = "YT";	// specify this is a YouTube playlist
			if (_o.id && _o.id.playlistId) {
				_youTubeID = _o.id.playlistId;
			}
			if (_o.snippet) {
				if (_o.snippet.title) {
					title = _o.snippet.title;
				}
				if (_o.snippet.thumbnails) {
					if (_o.snippet.thumbnails.default) {
						_thumbURL = _o.snippet.thumbnails.default.url;
					}
					if (_o.snippet.thumbnails.high) {
						_thumbURL = _o.snippet.thumbnails.high.url;
					}
				}
			}
		}
		public function addPlaylistItem(_v:VideoItemVO):void
		{
			_playlistItems.unshift(_v);
			_playlistDuration += _v.duration;
		}
		
		public function get thumbURL():String
		{
			if (_source == "VS") {
				return "http://videoswipe.net/img/playlist/" + pid + ".jpg";
			} else {
				return _playlistItems[0].thumbnailURLLarge;
			}
		}
		
		public function get source():String 
		{
			return _source;
		}
		public function set source(value:String):void 
		{
			_source = value;
		}
		
		public function get youTubeID():String 
		{
			return _youTubeID;
		}
		
		public function set playlistItems(value:Vector.<VideoItemVO>):void 
		{
			_playlistItems = value;
		}
		

	}

}