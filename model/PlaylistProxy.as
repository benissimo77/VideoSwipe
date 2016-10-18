/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.adobe.webapis.URLLoaderBase;
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.VideoItemVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.VideoItemYouTubeVO;
	import com.videoswipe.model.vo.VideoMessageVO;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class PlaylistProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "PlaylistProxy";

		private var _loadLoader:URLLoader;
		private var _saveLoader:URLLoader;
		private var _thumbLoader:URLLoader;
		private var _deleteLoader:URLLoader;
		private var _autoSave:Boolean = false;
		private var _uid:String;	// cache the uid for when saving playlists
		private var _autoplay:Boolean;	// keep here instead of in the VO since its independent of the playlist object
		private var _fileStub:String = ""; // used to resolve site-relative links to absolute links (when running from standalone Flash player)

		public function PlaylistProxy() {
			super(NAME, new PlaylistVO());
			_autoplay = true;
		}
		
		override public function onRegister():void 
		{
			if (!ExternalInterface.available) {
				_fileStub = "http://videoswipe.net";
			}
			_loadLoader = new URLLoader();
			_loadLoader.addEventListener(Event.COMPLETE, playlistLoaded);
			_loadLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_saveLoader = new URLLoader();
			_saveLoader.addEventListener(Event.COMPLETE, playlistSaved);
			_saveLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_thumbLoader = new URLLoader();
			_thumbLoader.addEventListener(Event.COMPLETE, thumbGenerated);
			_thumbLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_deleteLoader = new URLLoader();
			_deleteLoader.addEventListener(Event.COMPLETE, playlistDeleted);
			_deleteLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
		}

		// loadPlaylist
		// pass a playlist id (usually supplied via the flashvars obj) and it will asynchronously request the playlist from the DB
		// playlist can be a YouTube playlist so object also includes a source
		public function loadPlaylist( _p:int ):void
		{
			trace("PlaylistProxy:: loadPlaylist:", _p );
			var _vars:URLVariables = new URLVariables();
			_vars.p = _p;
			_vars.uid = uid;
			_vars.rec = 1;	// flag signifies that we want to record this load in the DB
			var _r:URLRequest = new URLRequest( _fileStub + "/go/db/loadPlaylist.php" );
			_r.data = _vars;
			_r.method = "POST";
			_loadLoader.load(_r);
		}
		// savePlaylist
		// collects up the key playlist data and bundles it into a JSON object and passes to server to be saved
		// important that we send the user id of this person so it can be stored with the playlist
		// function returns the id of the playlist which is stored so that next save will update the playlist not create a new one
		public function savePlaylist():void
		{
			trace("PlaylistProxy:: savePlaylist:", playlistTitle, vo.duration );
			var _v:VideoItemVO;
			var _videoList:Array = new Array();
			var duration:int = 0;
			
			for (var _i:int = 0; _i < playlistLength; _i++) {
				_v = vo.playlistItems[_i];
				var _o:Object = { provider:_v.provider, videoID:_v.videoID, videoTitle:_v.videoTitle, duration:_v.duration, author:_v.author, category:_v.category, thumbnailURL:_v.thumbnailURL, thumbnailURLLarge:_v.thumbnailURLLarge };
				if (_v.videoMessages) {
					_o.videoMessages = JSON.stringify(_v.videoMessages);
				}
				_videoList.push( _o );
				//_videoList.push( _v );
				duration += _v.duration;
			}
			vo.duration = duration;

			var _vars:URLVariables = new URLVariables();
			_vars.p = vo.pid;	// NOTE: this can be null (meaning its a new playlist not yet saved)
			_vars.uid = _uid;
			_vars.title = vo.title;
			_vars.duration = vo.duration;
			_vars.father = vo.father;
			_vars.locked = vo.locked;
			_vars.hidden = vo.hidden;
			_vars.videolist = JSON.stringify(_videoList);
			//_vars.videolist = JSON.stringify(vo.playlistItems);
			trace("PlaylistProxy:: savePlaylist: videolist.length:", _vars.videolist.length );
			var _r:URLRequest = new URLRequest( _fileStub + "/go/db/savePlaylist.php" );
			_r.data = _vars;
			_r.method = "POST";
			_saveLoader.load(_r);
		}
		// autoSavePlaylist
		// saves playlist but sets flag so user won't be send confirmation once saved
		// added: don't autosave if no items in playlist
		public function autoSavePlaylist():void
		{
			if (_uid && vo.playlistLength > 0) {
				_autoSave = true;
				savePlaylist();
			}
		}

		// deletePlaylist
		// send to PHP script to remove playlist from database
		public function deletePlaylist(_p:PlaylistVO):void
		{
			trace("PlaylistProxy:: deletePlaylist:", _p.title, _p.pid );
			var _vars:URLVariables = new URLVariables();
			_vars.p = _p.pid;
			_vars.uid = _uid;
			var _r:URLRequest = new URLRequest( _fileStub + "/go/db/deletePlaylist.php" );
			_r.data = _vars;
			_r.method = "POST";
			_deleteLoader.load(_r);
		}
			
		// addPlaylistItem returns true if successfully added
		public function addPlaylistItem( _v:VideoItemVO ):Boolean
		{
			if (getPlaylistItemIndex(_v.videoID) < 0) {
				vo.playlistItems.push(_v);
				vo.duration += _v.duration;
				autoSavePlaylist();
				return true;
			}
			return false;
		}
		// synchronisePlaylist - we have a new playlist
		// we keep the existing VO properties except for the playlist items and the currently playing
		public function synchronisePlaylist( _newPlaylist:Object ):void
		{
			trace("PlaylistProxy:: synchronisePlaylist:" );
			vo.clearPlaylistItems();
			for (var i:int = _newPlaylist.playlistItems.length; i--; ) {
				var _videoItemVO:VideoItemVO = new VideoItemVO();
				_videoItemVO.fillFromObject( _newPlaylist.playlistItems[i] );
				vo.playlistItems.unshift( _videoItemVO );
			}
			vo.currentlyPlaying = _newPlaylist.currentlyPlaying;
			// NOTE: more logic here to ensure new arrivals sync playing item accurately
		}
		public function getPrevPlaylistItem():VideoItemVO
		{
			if (vo.currentlyPlaying > 0) {
				return vo.playlistItems[ vo.currentlyPlaying - 1 ];
			}
			return null;
		}
		public function getNextPlaylistItem():VideoItemVO
		{
			if (vo.currentlyPlaying + 1 < vo.playlistItems.length) {
				return vo.playlistItems[ vo.currentlyPlaying + 1 ];
			}
			return null;
		}
		public function getPlaylistItemAt(i:int):VideoItemVO
		{
			if (i >= 0 && i < vo.playlistItems.length) {
				return vo.playlistItems[i];
			}
			return null;
		}
		public function getPlaylistItemIndex( _videoID:String ):int
		{
			for (var i:int = vo.playlistItems.length; i--; ) {
				if (vo.playlistItems[i].videoID == _videoID) {
					return i;
				}
			}
			return -1;
		}

		// gotoNextPlaylistItem
		// we have a gotoNext as well as a getNext because of the way currentlyPlaying is implemented
		// we *want* currentlyPlaying to advance, so that it goes beyond the length of the playlist
		// that way we know we are ready to play the next item as soon as it is added to the playlist
		public function gotoNextPlaylistItem():VideoItemVO
		{
			vo.currentlyPlaying++;
			if (vo.currentlyPlaying < vo.playlistItems.length) {
				var _v:VideoItemVO = vo.playlistItems[vo.currentlyPlaying];
				return _v;
			}
			return null;
		}

		public function deletePlaylistItem(_v:VideoItemVO):int
		{
			var i:int = getPlaylistItemIndex(_v.videoID);
			if (i >= 0) {
				vo.playlistItems.splice(i, 1);
				if (vo.currentlyPlaying >= i) {
					vo.currentlyPlaying--;
				}
				vo.duration -= _v.duration;
				autoSavePlaylist();	// keep stored version synchronised
			}
			return i;
		}
		
		public function movePlaylistItem( _videoID:String, _position:int):void
		{
			var _item:VideoItemVO;
			for (var i:int = vo.playlistLength; i--; ) {
				_item = vo.playlistItems[i];
				if (_item.videoID == _videoID) {
					trace("PlaylistProxy:: movePlaylistItem:", i, currentlyPlaying, _position );
					vo.playlistItems.splice(i, 1);
					if (_position > i) _position--;	// above splice shifted items above by 1, so allow for this
					vo.playlistItems.splice(_position, 0, _item);
					if (currentlyPlaying == i) currentlyPlaying = _position;
					else {
						if (currentlyPlaying > i) currentlyPlaying--;
						if (currentlyPlaying >= _position) currentlyPlaying++;
					}
					break;
				}
			}
			// since an item has moved then we better auto-save to be safe
			autoSavePlaylist();
		}

		public function generateThumb():void
		{
			trace("PlaylistProxy:: generateThumb:", vo.pid, getImageURLsForThumb() );
			
			// if ID is zero we haven't yet saved this playlist - so autosave it, the thumb will get generated upon save complete
			if (vo.pid == 0) {
				autoSavePlaylist();
			} else {
				var _vars:URLVariables = new URLVariables();
				_vars.img = getImageURLsForThumb();
				_vars.n = vo.playlistItems.length;
				_vars.p = vo.pid;
				var _r:URLRequest = new URLRequest( _fileStub + "/go/db/generatePlaylistThumb.php" );
				_r.data = _vars;
				_r.method = "POST";
				_thumbLoader.load(_r);
				trace("PlaylistProxy:: generateThumb:  ", _fileStub + "/go/db/generatePlaylistThumb.php?p=" + _vars.p + "&n=" + _vars.n + "&img=" + _vars.img );
			}
		}
		// getImageURLsForThumb
		// builds a comma-delimited list of the first (up to) 4 items in the playlist
		// these can then be passed to a PHP script to generate a dynamic thumb image representing this playlist
		private function getImageURLsForThumb():String
		{
			var _urls:String = "";
			var _items:Vector.<VideoItemVO> = vo.playlistItems;
			
			for (var i:int = 0; i < 4; i++) {
				if (i < _items.length) {
					_urls = _urls.concat( getBestThumb(_items[i]), ",");
				}
			}
			return _urls.substr(0, _urls.length - 1);
		}
		private function getBestThumb( _i:VideoItemVO ):String
		{
			if (_i.thumbnailURLLarge) {
				return _i.thumbnailURLLarge;
			} else {
				return _i.thumbnailURL;
			}
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("PlaylistProxy:: IOErrorHandler:" );
		}
		// playlistLoaded
		// callback function called once playlist loaded from DB, returns JSON object
		// Must populate a playlistVO with the JSON data
		// if creator is different to this user then DON'T set the playlistiD - this will mean when it gets saved it will be given a new ID
		// only the original creator can update this playlist using the original ID, everyone else will save a new copy for themselves
		private function playlistLoaded(e:Event):void
		{
			trace("PlaylistProxy:: playlistLoaded:", e.currentTarget.data.length );

			var _str:String = e.currentTarget.data as String;
			if (_str.slice(0, 3) == "BAD") {
				// we have a problem, do nothing...
			} else {
				var _o:Object = JSON.parse( _str );
				vo = new PlaylistVO();

				// If this user is the creator of this playlist then the UIDs will match
				// If they don't match then when the playlist is next saved it will generate a new playlist and return the new pid
				vo.uid = _uid;
				vo.pid = _o.pid;
				vo.father = _o.father;
				if (_o.uid != _uid) {
					vo.father = _o.pid;	// if not owner then new playlist will become a child of current playlist
				}
				vo.title = _o.title;
				vo.duration = _o.duration;
				vo.hidden = (_o.hidden == "1");
				vo.locked = (_o.locked == "1");
				var videoList:Object = JSON.parse( _o.videolist );
				for (var i:int =  videoList.length; i--; ) {
					var _item:VideoItemYouTubeVO = new VideoItemYouTubeVO();
					_item.fillFromObject( videoList[i] );
					vo.playlistItems.unshift(_item);
				}
				sendNotification( AppConstants.PLAYLISTLOADED, vo );
			}
		}
		// setPlaylist
		// inject a YouTube playlist directly into the vo
		// playlist was created prior by the top 10 system
		// see the above playlistLoaded fn for full logic of processing a new playlist
		public function setPlaylist( _p:PlaylistVO ):void
		{
			trace("PlaylistProxy:: youTubePlaylistLoaded:" );
			vo = _p;
			vo.uid = _uid;
			vo.pid = 0;		// this is NOT a VS playlist so no pid as yet
			vo.father = 0;
			vo.hidden = false;
			vo.locked = false;
			sendNotification( AppConstants.PLAYLISTLOADED, vo );
		}
		
		public function addVideoMessageToCurrentlyPlayingVideo( _messageVO:VideoMessageVO ):void
		{
			trace("PlaylistProxy:: addVideoMessageToCurrentlyPlayingVideo:", _messageVO.sessionID, _messageVO.streamname );
			var _v:VideoItemVO = vo.playlistItems[vo.currentlyPlaying];
			_v.videoMessages.push( _messageVO );
			autoSavePlaylist();
		}
		public function removeVideoMessageFromCurrentlyPlayingVideo( _s:String ):void
		{
			trace("PlaylistProxy:: removeVideoMessageFromCurrentlyPlayingVideo:", _s );
			var _v:VideoItemVO = vo.playlistItems[vo.currentlyPlaying];
			for (var i:int = _v.videoMessages.length; i--; ) {
				if (_v.videoMessages[i].streamname == _s) {
					trace("PlaylistProxy:: removeVideoMessageFromCurrentlyPlayingVideo: FOUND" );
					_v.videoMessages.splice(i, 1);
				}
			}
			autoSavePlaylist();
		}
		
		// playlistSaved
		// callback function called once playlist saved to DB
		// returns ID of the newly saved playlist (in case it was saved for first time and ID just generated)
		private function playlistSaved(e:Event):void
		{
			trace("PlaylistProxy:: playlistSaved:", e.currentTarget.data );

			if (e.currentTarget.data == "BAD") {
				// some error during DB save
				sendNotification( AppConstants.PLAYLISTSAVEERROR );
			} else {
				vo.pid = int(JSON.parse(e.currentTarget.data));
				sendNotification( AppConstants.PLAYLISTSAVED, vo );
				generateThumb();	// in the event of a successful save we can generate the thumb for this playlist
			}
			_autoSave = false; // reset ready for next time
			vo.source = "VS";	// since playlist saved it has become a VS playlist
		}

		// thumbGenerated
		// callback function once thumb generated from PHP script
		// sends notification PLAYLISTSAVED
		// this is the point that we have successfully saved the playlist
		// so update the VO and send note that the view needs to be updated
		private function thumbGenerated(e:Event):void
		{
			trace("PlaylistProxy:: thumbGenerated:", e.currentTarget.data );
			sendNotification( AppConstants.PLAYLISTUPDATED, vo );
		}

		// playlistDeleted
		// callback function once playlist successfully deleted
		// PHP script returns the PID of the deleted playlist so vo and view can be updated
		private function playlistDeleted(e:Event):void
		{
			trace("PlaylistProxy:: playlistDeleted:", e.currentTarget.data );
			if (e.currentTarget.data == "BAD") {
				// do nothing, error during DB update
			} else {
				sendNotification( AppConstants.PLAYLISTDELETED, e.currentTarget.data);
			}
		}
		// PUBLIC GETTER/SETTERS
		//
		public function get playlistLength():int
		{
			return vo.playlistItems.length;
		}
		public function get playlistTitle():String 
		{
			return vo.title;
		}
		public function set playlistTitle(value:String):void 
		{
			vo.title = value;
			autoSavePlaylist();
		}
		public function get currentlyPlaying():int 
		{
			return vo.currentlyPlaying;
		}
		public function set currentlyPlaying(value:int):void 
		{
			vo.currentlyPlaying = value;
		}
		
		public function get autoplay():Boolean 
		{
			return _autoplay;
		}
		public function set autoplay(value:Boolean):void 
		{
			_autoplay = value;
		}
		public function get vo():PlaylistVO
		{
			return data as PlaylistVO;
		}
		public function set vo( _v:PlaylistVO ):void
		{
			data = _v;
		}
		public function get pid():int
		{
			return vo.pid;
		}
		
		// uid is NOT the one stored in the playlist as part of the playlistVO 
		// uid is this user's ID, the playlistVO.uid is (possibly) the uid of the playlist creator
		public function set uid(value:String):void 
		{
			_uid = value;
		}
		public function get uid():String
		{
			return _uid;
		}
		
		public function get autoSave():Boolean 
		{
			return _autoSave;
		}
		
		
	}
}
