package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.ChannelVO;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class ChannelView extends XSprite
	{
		private static const HEIGHT:int = 72;	// height of this video view object
		private static const WIDTH:int = 420;	// width of this object
		private static const DEFAULTBG:uint = 0xeeeeff;

		private var _channelVO:ChannelVO;	// cache a local copy of this videoItemVO
		private var _queued:Boolean = false;	// records if this item has been queued for playing

		public function ChannelView( c:ChannelVO ) 
		{
			_channelVO = c;
			_width = WIDTH;
			_height = HEIGHT;
			initView();
			this.buttonMode = true;
		}
		
		private function initView():void
		{
			trace("ChannelView:: initView:", _channelVO.channelID, _channelVO.provider);

			// BACKGROUND
			drawBackground();

			// THUMBNAIL
			var thumbLoader:LoaderWithRollover = new LoaderWithRollover();
			thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbLoaded);
			thumbLoader.addEventListener(MouseEvent.CLICK, addToPlaylist);
			thumbLoader.x = 4;
			thumbLoader.y = 4;
			thumbLoader.load( new URLRequest( _channelVO.thumbnailURL ));
			addChild(thumbLoader);

			// TITLE
			var titleText:TFTextField = new TFTextField();
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.wordWrap = true;
			titleText.anchor = true;
			titleText.x = 128;
			titleText.y = 4;
			titleText.width = WIDTH - 128 - 4;
			titleText.text = _channelVO.channelTitle;
			addChild(titleText);
			titleText.addEventListener(MouseEvent.CLICK, addToPlaylist);

			// DATE UPDATED
			var uploadDate:TFTextField = new TFTextField();
			uploadDate.small = true;
			uploadDate.colour = 0xaaaadd;
			uploadDate.text = "Updated: " + _channelVO.updated;
			uploadDate.height = 14;
			uploadDate.x = 128;
			uploadDate.y = HEIGHT - uploadDate.height;
			addChild(uploadDate);

			// NUMBER OF VIEWS
			var viewsText:TFTextField = new TFTextField();
			viewsText.small = true;
			viewsText.text = numberToViews(_channelVO.views) + " views";
			viewsText.height = 14;
			viewsText.x = 128;
			viewsText.y = uploadDate.y - viewsText.height;
			addChild(viewsText);
			
			// DESCRIPTION (fit into remaining available space, if any...)
			var descriptionText:TFTextField = new TFTextField();
			descriptionText.text = _channelVO.channelDescription;
			descriptionText.small = true;
			descriptionText.wordWrap = true;
			descriptionText.x = 128;
			descriptionText.y = titleText.y + titleText.height;
			descriptionText.width = WIDTH - 128 - 4;
			descriptionText.height = viewsText.y - descriptionText.y;
			addChild(descriptionText);

		}
		
		public function get channelVO():ChannelVO
		{
			return _channelVO;
		}
		
		// redraw function is overridden from XSprite defn
		override public function redraw():void
		{
			drawBackground();
		}
		private function drawBackground():void
		{
			graphics.clear();
			graphics.beginFill(DEFAULTBG, _queued? 0.7 : 0);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		private function numberToViews(n:Number):String
		{
			if (n < 1000) return String(n);
			else return numberToViews(Math.floor(n / 1000)) + "," + String(n % 1000);
		}
		private function thumbLoaded(e:Event):void
		{
			// size of thumb is *almost* always 88x88, however occasionally it can be larger so just force a resize
			var t:DisplayObject = e.currentTarget.loader as DisplayObject;
			t.width = 60;
			t.height = 60;
		}

		/*
		 * remove below function temporarily as I've made anchor text unselectable meaning this function won't do anything useful...
		private function titleClicked(e:MouseEvent):void
		{
			var _t:TextField = e.currentTarget as TextField;
			if (_t.selectionBeginIndex < _t.selectionEndIndex) {
				trace("VideoItemView:: titleClicked: text selected, not a click");
			} else {
				addToPlaylist();
			}
		}
		*/
		private function addToPlaylist(e:MouseEvent=null):void
		{
			e.stopPropagation();
			if (_queued) {
				trace("ChannelView:: addToPlaylist: item already queued");
			} else {
				_queued = true;
				drawBackground();
				dispatchEvent(new Event( AppConstants.CLIENTADDTOPLAYLIST, true, true));
			}
		}
	}

}