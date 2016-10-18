package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class SubscriptionItemView extends XSprite
	{
		public static const WIDTH:int = 192;	// width of this object
		public static const HEIGHT:int = 124;	// height of this video view object
		private static const DEFAULTBG:uint = 0x686868;

		private var _videoItemVO:VideoItemVO;	// cache a local copy of this videoItemVO
		private var _queued:Boolean = false;	// records if this item has been queued for playing

		public function SubscriptionItemView( v:VideoItemVO ) 
		{
			_videoItemVO = v;
			_width = WIDTH;
			_height = HEIGHT;
			initView();
		}
		
		private function initView():void
		{
			//trace("VideoItemView:: initView:", _videoItemVO.videoID, _videoItemVO.provider);
			this.buttonMode = true;
			this.useHandCursor = true;
			this.tabEnabled = false;

			// BACKGROUND
			drawBackground( Theme.GLASSTINT, 0);

			// THUMBNAIL
			var thumbLoader:LoaderWithRollover = new LoaderWithRollover();
			thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbLoaded);
			thumbLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			thumbLoader.x = 6;
			thumbLoader.y = 2;
			thumbLoader.load( new URLRequest( _videoItemVO.thumbnailURL ));
			addChild(thumbLoader);

			// DURATION
			var durationText:TFTextField = new TFTextField();
			durationText.selectable = false;
			durationText.backgroundColor = 0x000;
			durationText.background = true;
			durationText.colour = 0xffffff;
			if (_videoItemVO.duration) {
				durationText.text = numberToDuration(_videoItemVO.duration);
			}
			durationText.autoSize = TextFieldAutoSize.CENTER;
			durationText.x = 8;
			durationText.y = 4;
			//addChild(durationText);

			// TITLE
			var titleText:TFTextField = new TFTextField( "subscriptionitem" );
			titleText.selectable = false;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.wordWrap = true;
			titleText.colour = Theme.TEXTHIGHLIGHT;
			titleText.bold = true;
			titleText.x = 6;
			titleText.y = 92;
			titleText.width = WIDTH - titleText.x - 2;
			titleText.height = HEIGHT - titleText.y - 2;
			titleText.text = _videoItemVO.videoTitle;
			shortenTitle( titleText );
			addChild(titleText);
			//titleText.addEventListener(MouseEvent.CLICK, addToPlaylist);

			// DATE UPLOADED
			var uploadDate:TFTextField = new TFTextField();
			uploadDate.small = true;
			uploadDate.selectable = false;
			uploadDate.colour = 0xaaaadd;
			uploadDate.text = "Uploaded: " + _videoItemVO.published;
			uploadDate.height = 14;
			uploadDate.x = 132;
			uploadDate.y = HEIGHT - uploadDate.height;
			//addChild(uploadDate);

			// NUMBER OF VIEWS
			var viewsText:TFTextField = new TFTextField();
			viewsText.small = true;
			viewsText.selectable = false;
			viewsText.text = numberToViews(_videoItemVO.views);
			viewsText.height = 14;
			viewsText.x = 132;
			viewsText.y = uploadDate.y - viewsText.height;
			//addChild(viewsText);
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			addEventListener(MouseEvent.CLICK, addToPlaylist);
		}
		
		public function get videoItemVO():VideoItemVO
		{
			return _videoItemVO;
		}
		
		// redraw function is overridden from XSprite defn
		override public function redraw():void
		{
			drawBackground( Theme.GLASSTINT, 0);
		}
		private function drawBackground( _colour:int, _alpha:Number):void
		{
			graphics.clear();
			graphics.beginFill( _colour, _alpha );
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		private function numberToDuration(n:Number):String
		{
			if (n < 10) return "0" + String(n);
			else if (n < 60) return String(n);
			else if (n < 3600) return String(Math.floor(n / 60)) + ":" + numberToDuration(n % 60);
			else return String(Math.floor(n/3600)) + ":" + numberToDuration(n % 3600);
		}
		private function numberToViews(n:Number):String
		{
			var _s:String = String(n);
			var _l:int = _s.length;
			if (_l > 3) _s = _s.substr(0, -3) + "," + _s.substr( -3, 3);
			if (_l > 6) {
				_s = _s.substr(0, -7) + " Million";
			}
			if (n < 1000000) _s = _s.concat(" views");
			else if (n < 100000000) _s = _s.concat(" views!");
			else _s = _s.concat(" views! Awesome work good job!");
			return _s;
			// old version - not so good :)
			//if (n < 1000) return String(n);
			//else return numberToViews(Math.floor(n / 1000)) + "," + String(n % 1000);
		}
		private function thumbLoaded(e:Event):void
		{
			// size of thumb is *almost* always 120x90, however occasionally it can be larger so just force a resize
			var t:DisplayObject = e.currentTarget.loader as DisplayObject;
			t.width = 180;
			t.height = 90;
			this.cacheAsBitmap = true;
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("VideoItemView:: IOErrorHandler:" );
		}

		// shortenTitle
		// function to reduce the title to make it fit in under two lines
		private function shortenTitle( _t:TFTextField ):void
		{
			// hard-coded values for the 'correct' height
			// 28 is two lines, 42 is three lines
			if (_t.textHeight < 42) return;
			while (_t.textHeight > 28) {
				_t.text = _t.text.substr(0, _t.text.length - 1);
			}
			_t.text = _t.text.substr(0, _t.text.length - 3) + "...";
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
		private function mouseOver(e:MouseEvent = null):void
		{
			drawBackground( Theme.TEXTFACEBOOKFILL, 0.35);
		}
		private function mouseOut(e:MouseEvent = null):void
		{
			drawBackground( Theme.TEXTFACEBOOKFILL, 0);
		}
		private function addToPlaylist(e:MouseEvent=null):void
		{
			e.stopPropagation();
			if (_queued) {
				trace("VideoItemView:: addToPlaylist: item already queued");
			} else {
				// don't bother with the queuing function - not needed
				//_queued = true;
				drawBackground( Theme.TEXTFACEBOOKMOUSEOVER, 0.35);
				dispatchEvent(new Event( AppConstants.CLIENTADDTOPLAYLIST, true, true));
			}
		}
	}

}