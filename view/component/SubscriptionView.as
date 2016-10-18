package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.SubscriptionVO;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class SubscriptionView extends XSprite
	{
		public static const HEIGHT:int = 160;	// height of this video view object
		private static const WIDTH:int = 640;	// width of this object
		private static const DEFAULTBG:uint = 0xeeeeff;

		private var _videos:ScrollableSprite;	// scrolling sprite to hold latest videos in this subscription
		private var _scroll:Scroller;
		private var _subscriptionVO:SubscriptionVO;	// cache a local copy of this videoItemVO

		public function SubscriptionView( c:SubscriptionVO ) 
		{
			_subscriptionVO = c;
			_width = WIDTH;
			_height = HEIGHT;
			initView();
//			this.buttonMode = true;
		}
		
		private function initView():void
		{
			trace("SubscriptionView:: initView:", _subscriptionVO.channelID);

			// BACKGROUND
			drawBackground();

			// THUMBNAIL
			var thumbLoader:Loader = new Loader();
			thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbLoaded);
			//thumbLoader.addEventListener(MouseEvent.CLICK, addToPlaylist);
			thumbLoader.x = 2;
			thumbLoader.y = 2;
			thumbLoader.load( new URLRequest( _subscriptionVO.thumbnailURL ));
			addChild(thumbLoader);

			// TITLE
			var titleText:TFTextField = new TFTextField();
			titleText.name = "channel";
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.wordWrap = true;
			titleText.anchor = true;
			titleText.x = 40;
			titleText.y = 2;
			titleText.width = WIDTH - titleText.x - 4;
			titleText.text = _subscriptionVO.title;
			addChild(titleText);

			// DATE UPDATED
			var uploadDate:TFTextField = new TFTextField();
			uploadDate.small = true;
			uploadDate.colour = 0xaaaadd;
			//uploadDate.text = "Updated: " + _subscriptionVO.updated;
			uploadDate.height = 14;
			uploadDate.x = 128;
			uploadDate.y = HEIGHT - uploadDate.height;
			//addChild(uploadDate);

			// NUMBER OF VIEWS
			var viewsText:TFTextField = new TFTextField();
			viewsText.small = true;
			//viewsText.text = numberToViews(_subscriptionVO.views) + " views";
			viewsText.height = 14;
			viewsText.x = 128;
			viewsText.y = uploadDate.y - viewsText.height;
			//addChild(viewsText);
			
			// DESCRIPTION (fit into remaining available space, if any...)
			var descriptionText:TFTextField = new TFTextField();
			descriptionText.text = _subscriptionVO.description;
			descriptionText.small = true;
			descriptionText.wordWrap = true;
			descriptionText.x = 128;
			descriptionText.y = titleText.y + titleText.height;
			descriptionText.width = WIDTH - 128 - 4;
			descriptionText.height = viewsText.y - descriptionText.y;
			//addChild(descriptionText);

			_videos = new ScrollableSprite();
			
			_scroll = new Scroller( true );
			_scroll.x = 0;
			_scroll.y = 28;
			_scroll.scrollTarget = _videos;
			addChild(_scroll);
			
			// add the video items from the subscription VO - maybe this should go into its own fn
			for (var i:int = _subscriptionVO.videoItems.length; i--; ) {
				var _item:SubscriptionItemView = new SubscriptionItemView( _subscriptionVO.videoItems[i] );
				_item.x = i * (SubscriptionItemView.WIDTH + 4);
				_videos.addChild(_item);
			}
		}
		
		public function get subscriptionVO():SubscriptionVO
		{
			return _subscriptionVO;
		}
		
		// redraw function is overridden from XSprite defn
		override public function redraw():void
		{
			drawBackground();
			_scroll.setSize(_width, _height - _scroll.y);
			_scroll.update();
		}
		private function drawBackground():void
		{
			graphics.clear();
			graphics.beginFill(DEFAULTBG, 0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		private function thumbLoaded(e:Event):void
		{
			// size of thumb is *almost* always 88x88, however occasionally it can be larger so just force a resize
			var t:DisplayObject = e.currentTarget.loader as DisplayObject;
			t.width = 24;
			t.height = 24;
		}

	}

}