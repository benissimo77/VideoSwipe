package com.videoswipe.view.component 
{
	import com.facebook.graph.controls.Distractor;
	import com.greensock.BlitMask;
	import com.greensock.TweenLite;
	import com.videoswipe.model.vo.FeedVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import com.videoswipe.model.vo.VideoItemYouTubeVO;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author Ben Silburn
	 * 
	 * Displays results of a video feed - note feedView is provider-agnostic, it receives data in the form of a FeedVO
	 * which can come from any provider. It is up to the underlying VO model to organise the concrete XML feed data
	 */
	public class FeedView extends XSprite
	{
		public const WIDTH:int = 440;
		public const HEIGHT:int = 480;
		private const ITEMPADDING:int = 16;

		private var _feedVO:FeedVO;	// cache local copy of the search object
		private var _videos:ScrollableSprite;	// holder for the video list
		private	var _scroll:Scroller;	// for the feed videos
		private var _distractor:Distractor;	// displayed while waiting for the results to come back
		private var _results:TFTextField;	// display the number of results
		private var _nextPage:TFTextField;
		private var _previousPage:TFTextField;
		
		
		public function FeedView() 
		{
			super();
			initView();  
		}

		private function initView():void
		{
			_videos = new ScrollableSprite();
			_scroll = new Scroller();
			_scroll.x = 2;
			_scroll.y = 24;
			_scroll.scrollTarget = _videos;	// this adds the videos sprite to the scroll sprite
			addChild(_scroll);
			_distractor = new Distractor();
			_distractor.x = WIDTH / 2 - _distractor.width / 2;
			_distractor.y = 24;
			_distractor.visible = false;
			addChild(_distractor);
			_results = new TFTextField();
			_results.multiline = false;
			_results.height = 24;
			_results.width = WIDTH - 120;
			_results.x = 2;
			_results.y = 0;
			addChild(_results);
			_nextPage = new TFTextField();
			_nextPage.autoSize = TextFieldAutoSize.RIGHT;
			_nextPage.width = 80;
			_nextPage.name = "nextPage";
			_nextPage.multiline = false;
			_nextPage.height = 24;
			_nextPage.autoSize = TextFieldAutoSize.RIGHT;
			_nextPage.anchor = true;
			_nextPage.visible = false;
			addChild(_nextPage);
			_nextPage.addEventListener(MouseEvent.CLICK, nextPage);
			_previousPage = new TFTextField();
			_previousPage.autoSize = TextFieldAutoSize.RIGHT;
			_previousPage.width = 80;
			_previousPage.name = "previousPage";
			_previousPage.multiline = false;
			_previousPage.height = 24;
			//_previousPage.y = -32;	// bit of a hack, relies on space above this sprite;
			_previousPage.autoSize = TextFieldAutoSize.RIGHT;
			_previousPage.anchor = true;
			_previousPage.visible = false;
			addChild(_previousPage);
		}
		private function drawView():void
		{
			var _totalResults:String = _feedVO.totalResults >= 1000000 ? "a million" : String(_feedVO.totalResults);
			var _lastResult:int = _feedVO.startIndex + _feedVO.itemsPerPage - 1;
			if (_lastResult > _feedVO.totalResults) _lastResult = _feedVO.totalResults;
			_results.text = "Displaying " + _feedVO.startIndex + " - " + String(_lastResult) + " of " + _totalResults + " videos";
			while (_videos.numChildren > 0) {
				_videos.removeChildAt(0);
			}
			_videos.y = 0;
			for each (var video:VideoItemVO in _feedVO.videos)
			{
				var v:VideoItemView = new VideoItemView(video);
				v.setSize(_width, VideoItemView.HEIGHT);
				v.y = _videos.numChildren * VideoItemView.HEIGHT;
				_videos.addChild(v);
				trace("FeedView:: drawView:", v.y, video.videoTitle );
			}
			//addChild(_scroll);
			_scroll.update();
			// set visibilities
			_videos.visible = true;
			_scroll.visible = true;
			//_scroll.update(null, true);
			_distractor.visible = false;
			_results.visible = true;
			_nextPage.text = "Next " + _feedVO.itemsPerPage;
			_nextPage.visible = false;
			trace("FeedView:: drawView: _nextPage:", _feedVO.nextPage );
			if (feedVO.nextPage) _nextPage.visible = true;
			_previousPage.text = "Previous " + _feedVO.itemsPerPage;
			_previousPage.visible = false;
			if (feedVO.previousPage) _previousPage.visible = true;
			
			_nextPage.x = WIDTH - _nextPage.width;
			_previousPage.x = _nextPage.x - _previousPage.width - ITEMPADDING;
			trace("FeedView:: drawView:", _nextPage.x, _nextPage.width, _previousPage.x, _previousPage.width );

			// draw a blank graphic over entire display to prevent rogue mouse out events
			_videos.graphics.clear();
			_videos.graphics.beginFill(0x000, 0);
			_videos.graphics.drawRect(0, 0, _width, _feedVO.videos.length * VideoItemView.HEIGHT);
			_videos.graphics.endFill();
			
			//_scroll.scrollY = 0;
			//TweenLite.to(_scroll, 4, {scrollY:1, onComplete:_scroll.disableBitmapMode});
			//TweenLite.to(_videos, 4, { y: -_videos.height + _height, onUpdate:_scroll.update } );
		}
		private function nextPage(e:MouseEvent):void
		{
			trace("FeedView:: nextPage:" );
			//_scroll.bitmapMode = false;
			//_scroll.update(null, true);
			// the below code works to implement a scroll - use instead of mask in Scroller
			//var _newY:int = _scroll.y - _videos.height + _scroll.height;
			//TweenLite.to(_videos, 4, { y:_newY, onStart:_scroll.enableBitmapMode, onUpdate:_scroll.update, onComplete:_scroll.disableBitmapMode } );
		}

		override public function redraw():void
		{
			//trace("FeedView:: redraw:", _width, _height );
			//_scroll.setSize(_width - 4, _height - _scroll.y - 2);
			for (var i:int = _videos.numChildren; i--; ) {
				var v:XSprite = _videos.getChildAt(i) as XSprite;
				//v.setSize(_width - 4, VideoItemView.HEIGHT);
			}
			_scroll.setSize(_width - 4, _height - _scroll.y);
			_distractor.x = _width / 2 - _distractor.width / 2;

		}

		public function beginSearch():void
		{
			trace("FeedView:: beginSearch: hello" );
			_distractor.visible = true;
			_videos.visible = false;
			_scroll.visible = false;
			_results.visible = false;
			_nextPage.visible = false;
			_previousPage.visible = false;
		}
		public function set feedVO(_f:FeedVO):void
		{
			_feedVO = _f;
			drawView();
		}
		public function get feedVO():FeedVO
		{
			return _feedVO;
		}
	}

}