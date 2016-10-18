package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.SubscriptionListVO;
	import com.videoswipe.model.vo.SubscriptionVO;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Ben Silburn
	 * 
	 */
	public class SubscriptionListView extends XSprite
	{
		public const WIDTH:int = 440;
		public const HEIGHT:int = 480;
		private const ITEMPADDING:int = 2;

		private var _subscriptionListVO:SubscriptionListVO;	// cache local copy of the search object
		private var _subscriptions:ScrollableSprite;	// holder for the subscription list
		private	var _scroll:Scroller;	// for the feed videos
		private var _results:TFTextField;	// display the number of results
		private var _playAll:TFTextField;	// clickable link to play all channels
		private var _nextPage:TFTextField;
		private var _previousPage:TFTextField;
		private var _authorisePanel:AuthoriseYouTubePanel;
		
		
		public function SubscriptionListView() 
		{
			super();
			this.name = "subscriptionListView";
			initView();
			authorised = false;	// will set visibility of view elements
		}

		private function initView():void
		{
			_subscriptions = new ScrollableSprite();
			_scroll = new Scroller();
			_scroll.x = 0;
			_scroll.y = 24;
			_scroll.scrollTarget = _subscriptions;
			addChild(_scroll);
			_results = new TFTextField();
			_results.multiline = false;
			_results.height = 24;
			_results.width = WIDTH - 120;
			_results.x = 0;
			_results.y = 0;
			addChild(_results);
			_playAll = new TFTextField();
			_playAll.name = "playall";
			_playAll.multiline = false;
			_playAll.height = 24;
			_playAll.width = 120;
			_playAll.x = WIDTH - 120 - ITEMPADDING;
			_playAll.y = 2;
			_playAll.autoSize = TextFieldAutoSize.RIGHT;
			_playAll.anchor = true;
			_playAll.text = "Play All Channels";
			addChild(_playAll);
			_nextPage = new TFTextField();
			_nextPage.name = "nextPage";
			_nextPage.multiline = false;
			_nextPage.height = 24;
			_nextPage.width = 120;
			_nextPage.x = WIDTH - 120;
			_nextPage.autoSize = TextFieldAutoSize.RIGHT;
			_nextPage.anchor = true;
			addChild(_nextPage);
			_authorisePanel = new AuthoriseYouTubePanel();
			addChild(_authorisePanel);
		}
		private function drawView():void
		{
			var _totalResults:String = _subscriptionListVO.totalResults >= 1000000 ? "a million" : String(_subscriptionListVO.totalResults);
			_results.text = "Displaying " + "1" + " - " + String( _totalResults) + " subscriptions";
			//if (subscriptionListVO.nextPage) _nextPage.text = "More results";
			while (_subscriptions.numChildren > 0) {
				_subscriptions.removeChildAt(0);
			}
			for each (var subscription:SubscriptionVO in _subscriptionListVO.list)
			{
				var c:SubscriptionView = new SubscriptionView(subscription);
				c.setSize(_width - 18, c.height);
				c.y = _subscriptions.numChildren * (c.height + ITEMPADDING);
				_subscriptions.addChild(c);
			}
			_scroll.update();
		}
		private function drawBackground():void
		{
			_subscriptions.graphics.clear();
			_subscriptions.graphics.beginFill(0x000, 0);
			_subscriptions.graphics.drawRect(0, 0, _width, _subscriptions.height);
			_subscriptions.graphics.endFill();
		}
		private function nextPage(e:MouseEvent):void
		{
			trace("SubscriptionListView:: nextPage:" );
		}

		override public function redraw():void
		{
			//trace("SubscriptionListView:: redraw:" );
			_scroll.setSize(_width, _height - 24);
			_scroll.update();
			for (var i:int = _subscriptions.numChildren; i--; ) {
				var c:XSprite = _subscriptions.getChildAt(i) as XSprite;
				c.setSize(_width, c.height);
			}
			_playAll.x = _width - 120 - ITEMPADDING;
			_authorisePanel.setSize(_width, _height);
		}

		public function addSubscription( _s:SubscriptionVO ):void
		{
			var c:SubscriptionView = new SubscriptionView(_s);
			c.setSize(_width - 18, c.height);
			c.y = _subscriptions.numChildren * (c.height + ITEMPADDING);
			_subscriptions.addChild(c);
			_scroll.update();
			drawBackground();
			authorised = true;	// set visibilities of elements
		}
		
		private function set authorised( _b:Boolean ):void
		{
			if (_b) {
				_subscriptions.visible = true;
				_scroll.visible = true;
				_playAll.visible = true;
				_nextPage.visible = true;
				_results.visible = true;
				_authorisePanel.visible = false;
			} else {
				_subscriptions.visible = false;
				_scroll.visible = false;
				_playAll.visible = false;
				_nextPage.visible = false;
				_results.visible = false;
				_authorisePanel.visible = true;
			}
		}
		private function get subscriptionListVO():SubscriptionListVO 
		{
			return _subscriptionListVO;
		}
	}

}