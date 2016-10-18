package com.videoswipe.view.component 
{
	import com.facebook.graph.controls.Distractor;
	import com.greensock.TweenLite;
	import com.videoswipe.model.vo.PlaylistsVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import com.videoswipe.model.vo.VideoItemYouTubeVO;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author Ben Silburn
	 * 
	 * Displays results of a users playlists
	 * PlaylistsVO is the JSON object holding the list of playlistVO playlists
	 */
	public class PlaylistsView extends XSprite
	{
		public const WIDTH:int = 440;
		public const HEIGHT:int = 480;
		private const ITEMPADDING:int = 8;

		private var _playlistsVO:PlaylistsVO;	// cache local copy of the search object
		private var _videos:ScrollableSprite;	// holder for the video list
		private	var _scroll:Scroller;	// for the playlists videos
		private var _distractor:Distractor;	// displayed while waiting for the results to come back
		private var _results:TFTextField;	// display the number of results
		private var _nextPage:TFTextField;
		private var _previousPage:TFTextField;
		private var _tweensCount:int;		// records number of tweens so we can tween X and Y separately
		
		
		public function PlaylistsView() 
		{
			super();
			_playlistsVO = new PlaylistsVO();
			initView();  
		}

		private function initView():void
		{
			_videos = new ScrollableSprite();
			_scroll = new Scroller();
			_scroll.x = 0;
			_scroll.y = 24;
			addChild(_scroll);
			_scroll.scrollTarget = _videos;
			_distractor = new Distractor();
			_distractor.x = WIDTH / 2 - _distractor.width / 2;
			_distractor.y = 24;
			_distractor.visible = false;
			addChild(_distractor);
			_results = new TFTextField();
			_results.h1 = true;
			_results.multiline = false;
			_results.height = 24;
			_results.width = WIDTH - 120;
			_results.x = 0;
			_results.y = 0;
			addChild(_results);
			_nextPage = new TFTextField();
			_nextPage.name = "nextPage";
			_nextPage.multiline = false;
			_nextPage.text = "More results";
			_nextPage.height = 24;
			_nextPage.width = 120;
			_nextPage.x = WIDTH - 120;
			_nextPage.autoSize = TextFieldAutoSize.RIGHT;
			_nextPage.anchor = true;
			_nextPage.visible = false;
			addChild(_nextPage);
		}
		private function displayResults():void
		{
			var _totalResults:int = _playlistsVO.totalResults;
			var _lastResult:int = _playlistsVO.startIndex + _playlistsVO.itemsPerPage - 1;
			if (_lastResult > _playlistsVO.totalResults) _lastResult = _playlistsVO.totalResults;
			_results.text = "You have " + _totalResults + " playlists";
			if (_totalResults == 1) _results.text = "You have 1 playlist";
		}
		private function drawView():void
		{
			displayResults();
			while (_videos.numChildren > 0) {
				_videos.removeChildAt(0);
			}
			for each (var video:PlaylistVO in _playlistsVO.playlists)
			{
				addPlaylistsItem(video);
			}
			_scroll.update();
			// set visibilities
			_videos.visible = true;
			_scroll.visible = true;
			_distractor.visible = false;
			_results.visible = true;
			_nextPage.visible = false;
			if (playlistsVO.nextPage) _nextPage.visible = true;

			// draw a blank graphic over entire display to prevent rogue mouse out events
			var _itemsPerRow:int = Math.floor( _width / (PlaylistsItemView.WIDTH + ITEMPADDING));
			_videos.graphics.clear();
			_videos.graphics.beginFill(0x000, 0);
			_videos.graphics.drawRect(0, 0, _width, Math.floor(_videos.numChildren * PlaylistsItemView.HEIGHT / _itemsPerRow) );
			_videos.graphics.endFill();
		}
		private function nextPage(e:MouseEvent):void
		{
			trace("PlaylistsView:: nextPage:" );
		}

		private function addPlaylistsItem(video:PlaylistVO):void
		{
			var v:PlaylistsItemView = new PlaylistsItemView(video);
			//v.setSize(_width, v.height);
			v.x = calculateXfromIndex(_videos.numChildren);
			v.y = calculateYfromIndex(_videos.numChildren);
			_videos.addChild(v);
			trace("PlaylistsView:: addPlaylistsItem:", _videos.height );
		}

		override public function redraw():void
		{
			//trace("PlaylistsView:: redraw:" );
			_scroll.setSize(_width, _height - 24);
			_scroll.update();
			for (var i:int = _videos.numChildren; i--; ) {
				var v:XSprite = _videos.getChildAt(i) as XSprite;
				//v.setSize(_width, v.height);
			}
			_distractor.x = _width / 2 - _distractor.width / 2;
			arrangePlaylistItems();

		}

		public function beginSearch():void
		{
			trace("PlaylistsView:: beginSearch: hello" );
			_distractor.visible = true;
			_videos.visible = false;
			_scroll.visible = false;
			_results.visible = false;
			_nextPage.visible = false;
		}
		// updatePlaylist
		// a playlist has been saved or updated so we need to update it in the 'my playlists' view
		// loop through playlists until we find the playlist that's been updated and regenerate
		public function updatePlaylist(_p:PlaylistVO):void {
			var done:Boolean = false;
			for (var i:int = _playlistsVO.playlists.length; i--; ) {
				var video:PlaylistVO = _playlistsVO.playlists[i];
				if (video.pid == _p.pid) {
					_playlistsVO.playlists[i] = _p;
					var playlistsItem:PlaylistsItemView = _videos.getChildAt(i) as PlaylistsItemView;
					playlistsItem.playlistsItemVO = _p;
					done = true;
				}
			}
			if (!done) {
				_playlistsVO.playlists.unshift(_p);
				addPlaylistsItem(_p);
				_videos.addChildAt( _videos.getChildAt(_videos.numChildren - 1), 0); // puts at the top
				arrangePlaylistItems();
				_scroll.update();
			}
		}
		// deletePlaylist
		// as for updatePlaylist but we have just deleted a playlist - find it and remove it
		public function deletePlaylist(pid:String):void
		{
			trace("PlaylistsView:: deletePlaylist:", pid  );
			var done:Boolean = false;
			for (var i:int = _playlistsVO.playlists.length; i--; ) {
				var video:PlaylistVO = _playlistsVO.playlists[i];
				if (video.pid == Number(pid)) {
					_playlistsVO.playlists.splice(i, 1);
					_videos.removeChildAt(i);
					done = true;
				}
			}
			if (done) {
				arrangePlaylistItems();
				displayResults();
				_scroll.update();
			}
		}
		
		private function arrangePlaylistItems():void
		{
			trace("PlaylistsView:: arrangePlaylistItems:" );
			var _item:PlaylistsItemView;
			_tweensCount = 0;
			for (var i:int = _videos.numChildren; i--; ) {
				_item = _videos.getChildAt(i) as PlaylistsItemView;
				var _newY:int = calculateYfromIndex(i);
				var _newX:int = calculateXfromIndex(i);
				if (_item.y != _newY) {
					//TweenLite.to(_item, 0.5, { y:_newY } );
				}
				if (_item.x != _newX) {
					TweenLite.to(_item, 0.2, { x:_newX, onComplete:arrangePlaylistItemsY } );
					_tweensCount++;
				}
			}
		}
		private function arrangePlaylistItemsY():void
		{
			trace("arrangePlaylsitItemsY:: ");
			_tweensCount--;
			if (_tweensCount == 0) {
				var _item:PlaylistsItemView;
				for (var i:int = _videos.numChildren; i--; ) {
					_item = _videos.getChildAt(i) as PlaylistsItemView;
					var _newY:int = calculateYfromIndex(i);
					if (_item.y != _newY) {
					TweenLite.to(_item, 0.2, { y:_newY } );
					}
				}
			}
		}

		private function calculateYfromIndex( _index:int ):int
		{
			var _itemsPerRow:int = Math.floor( _width / (PlaylistsItemView.WIDTH + ITEMPADDING));
			return Math.floor( _index / _itemsPerRow ) * (PlaylistsItemView.HEIGHT + ITEMPADDING);
		}
		private function calculateXfromIndex( _index:int ):int
		{
			var _itemsPerRow:int = Math.floor( _width / (PlaylistsItemView.WIDTH + ITEMPADDING) );
			return (_index % _itemsPerRow) * (PlaylistsItemView.WIDTH + ITEMPADDING);
		}
		
		// PUBLIC GETTER/SETTERS
		public function set playlistsVO(_f:PlaylistsVO):void
		{
			_playlistsVO = _f;
			drawView();
		}
		public function get playlistsVO():PlaylistsVO
		{
			return _playlistsVO;
		}
	}

}