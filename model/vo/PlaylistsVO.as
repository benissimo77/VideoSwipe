package com.videoswipe.model.vo 
{
	/**
	 * 
	 * (c) 2013 Ben Silburn
	 * PlaylistsVO
	 * Stores a playlists object (in Object form) and makes a series of values available to return
	 * the underlying data in a useful format
	 */
	public class PlaylistsVO
	{
		private var _json:Object;
		private var _playlists:Vector.<PlaylistVO>
		private var _index:int;

		public function PlaylistsVO( _p:Object= null ) 
		{
			//trace(_p);
			_playlists = new Vector.<PlaylistVO>;
			if (_p) vo = _p;
		}

		// Implicit getter/setter functions to set/retrieve elements from the feed object...
		public function get startIndex():Number
		{
			return 0;
		}
		public function get itemsPerPage():Number
		{
			return 15;
		}
		public function get totalResults():int
		{
			return _playlists.length;
		}
		public function get previousPage():String
		{
			return null;
		}
		public function get nextPage():String
		{
			return null;
		}
		public function get playlists():Vector.<PlaylistVO> {
			return _playlists;
		}

		// NOTE: this function ready for when V2 is deprecated (not used currently)
		public function set youTubeV3Playlists( _o:Object ):void
		{
			if (_o.items) {
				playlists.length = 0;
				var _items:Object = _o.items;
				for (var i:int = _items.length; i--;) {
					var _item:Object = _items[i];
					var _p:PlaylistVO = new PlaylistVO();
					_p.youTubeV3Playlist = _items[i];
					_playlists.unshift(_p);
				}
			}
		}
		public function addYouTubePlaylist( _p:PlaylistVO ):void
		{
			_playlists.unshift(_p);
		}
		private function set vo( _j:Object ):void
		{
			//trace("PlaylistsVO:: vo:", _j.length );
			playlists.length = 0;
			for (var i:int = _j.length; i--; ) {
				var v:PlaylistVO = new PlaylistVO(_j[i]);
				_playlists.unshift(v);
			}
		}
	}

}