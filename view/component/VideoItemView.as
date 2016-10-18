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
	public class VideoItemView extends XSprite
	{
		public static const HEIGHT:int = 98;	// height of this video view object
		private static const WIDTH:int = 440;	// width of this object
		private static const DEFAULTBG:uint = 0x686868;

		private var _videoItemVO:VideoItemVO;	// cache a local copy of this videoItemVO
		private var _queued:Boolean = false;	// records if this item has been queued for playing

		public function VideoItemView( v:VideoItemVO ) 
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
			thumbLoader.x = 4;
			thumbLoader.y = 4;
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
			durationText.x = 4;
			durationText.y = 4;
			addChild(durationText);

			// TITLE
			var titleText:TFTextField = new TFTextField( "subscriptionitem" );
			titleText.selectable = false;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.wordWrap = true;
			titleText.colour = Theme.TEXTHIGHLIGHT;
			titleText.bold = true;
			titleText.x = 128;
			titleText.y = 4;
			titleText.width = WIDTH - 128 - 4;
			titleText.text = _videoItemVO.videoTitle;
			addChild(titleText);
			//titleText.addEventListener(MouseEvent.CLICK, addToPlaylist);

			// CATEGORY (display right justified at bottom)
			var categoryText:TFTextField = new TFTextField();
			categoryText.selectable = false;
			categoryText.text = _videoItemVO.category;
			categoryText.x = 128;
			categoryText.width = WIDTH - 128 - 4;
			categoryText.autoSize = TextFieldAutoSize.RIGHT;
			categoryText.height = 18;
			categoryText.y = HEIGHT - categoryText.height;
			//addChild(categoryText);

			// AUTHOR
			var authorText:TFTextField = new TFTextField();
			authorText.small = true;
			authorText.selectable = false;
			//authorText.anchor = true;
			authorText.text = _videoItemVO.author;
			authorText.width = authorText.textWidth;
			authorText.height = 16;
			authorText.x = 128;
			authorText.y = HEIGHT - authorText.height;
			addChild(authorText);

			// DATE UPLOADED
			var uploadDate:TFTextField = new TFTextField();
			uploadDate.small = true;
			uploadDate.selectable = false;
			uploadDate.colour = 0xaaaadd;
			uploadDate.text = "Uploaded: " + _videoItemVO.published;
			uploadDate.height = 14;
			uploadDate.x = 128;
			uploadDate.y = authorText.y - uploadDate.height;
			addChild(uploadDate);

			// NUMBER OF VIEWS
			var viewsText:TFTextField = new TFTextField();
			viewsText.small = true;
			viewsText.selectable = false;
			viewsText.text = numberToViews(_videoItemVO.views);
			viewsText.height = 14;
			viewsText.x = 128;
			viewsText.y = uploadDate.y - viewsText.height;
			addChild(viewsText);
			
			// DESCRIPTION (fit into remaining available space, if any...)
			var descriptionText:TFTextField = new TFTextField();
			descriptionText.text = _videoItemVO.videoDescription;
			descriptionText.small = true;
			descriptionText.wordWrap = true;
			descriptionText.x = 128;
			descriptionText.y = titleText.y + titleText.height;
			descriptionText.width = WIDTH - 128 - 4;
			descriptionText.height = viewsText.y - descriptionText.y;
			//addChild(descriptionText);

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
			t.width = 120;
			t.height = 90;
			this.cacheAsBitmap = true;
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("VideoItemView:: IOErrorHandler:" );
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