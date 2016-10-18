package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.ChannelListVO;
	import com.videoswipe.model.vo.ChannelVO;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;

	
	/**
	 * ...
	 * @author Ben Silburn
	 * 
	 * Displays results of a channel list feed - note feedView is provider-agnostic, it receives data in the form of a FeedVO
	 * which can come from any provider. It is up to the underlying VO model to organise the concrete XML feed data
	 */
	public class ChannelListView extends XSprite
	{
		public const WIDTH:int = 440;
		public const HEIGHT:int = 480;
		private const ITEMPADDING:int = 2;

		private var _channelListVO:ChannelListVO;	// cache local copy of the search object
		private var _channels:ScrollableSprite;	// holder for the channel list
		private	var s:Scroller;	// for the feed videos
		private var _results:TFTextField;	// display the number of results
		private var _nextPage:TFTextField;
		private var _previousPage:TFTextField;
		
		
		public function ChannelListView() 
		{
			super();
			this.name = "channelListView";
			initView();
		}

		private function initView():void
		{
			_channels = new ScrollableSprite();
			s = new Scroller();
			s.x = WIDTH;
			s.y = 24;
			s.scrollTarget = _channels;
			addChild(s);
			_results = new TFTextField();
			_results.multiline = false;
			_results.height = 24;
			_results.width = WIDTH - 120;
			_results.x = 0;
			_results.y = 0;
			addChild(_results);
			_nextPage = new TFTextField();
			_nextPage.name = "nextPage";
			_nextPage.multiline = false;
			_nextPage.height = 24;
			_nextPage.width = 120;
			_nextPage.x = WIDTH - 120;
			_nextPage.autoSize = TextFieldAutoSize.RIGHT;
			_nextPage.anchor = true;
			addChild(_nextPage);
		}
		private function drawView():void
		{
			var _totalResults:String = _channelListVO.totalResults >= 1000000 ? "a million" : String(_channelListVO.totalResults);
			_results.text = "Displaying " + _channelListVO.startIndex + " - " + String(_channelListVO.startIndex + _channelListVO.itemsPerPage - 1) + " of " + _totalResults + " channels";
			if (channelListVO.nextPage) _nextPage.text = "More results";
			while (_channels.numChildren > 0) {
				_channels.removeChildAt(0);
			}
			for each (var channel:ChannelVO in _channelListVO.channels)
			{
				var c:ChannelView = new ChannelView(channel);
				c.setSize(_width - 18, c.height);
				c.y = _channels.numChildren * (c.height + ITEMPADDING);
				_channels.addChild(c);
			}
			s.update();
		}
		private function nextPage(e:MouseEvent):void
		{
			trace("ChannelListView:: nextPage:" );
		}

		override public function redraw():void
		{
			trace("ChannelListView:: redraw:" );
			s.x = _width - 16;
			s.setSize(_width, _height - 24);
			for (var i:int = _channels.numChildren; i--; ) {
				var c:XSprite = _channels.getChildAt(i) as XSprite;
				c.setSize(_width - 18, c.height);
			}
		}

		public function set channelListVO(_cl:ChannelListVO):void
		{
			_channelListVO = _cl;
			drawView();
		}
		public function get channelListVO():ChannelListVO
		{
			return _channelListVO;
		}
	}

}