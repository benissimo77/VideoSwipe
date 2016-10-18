package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.PlaylistVO;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
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
	public class PlaylistsItemView extends XSprite
	{
		[Embed (source = "assets/deleteIconGrey.png")]
		private var deleteIcon:Class;
		private var deleteIconBMP:Bitmap;

		public static const HEIGHT:int = 98;	// height of this video view object
		public static const WIDTH:int = 240;	// width of this object		private static const DEFAULTBG:uint = 0x686868;

		private var _item:Sprite;
		private var _titleText:TFTextField;
		private var _uploadDate:TFTextField;
		private var _durationText:TFTextField;
		private var _thumbLoader:LoaderWithRollover;
		
		private var _playlistsItemVO:PlaylistVO;	// cache a local copy of this videoItemVO
		private var _queued:Boolean = false;	// records if this item has been queued for playing

		public function PlaylistsItemView( v:PlaylistVO ) 
		{
			_width = WIDTH;
			_height = HEIGHT;
			initView();
			if (v) playlistsItemVO = v;	// setter will draw view
		}
		
		private function initView():void
		{
			//trace("PlaylistsItemView:: initView: http://videoswipe.net/img/playlist/" + _playlistsItemVO.pid + ".jpg"  );
			_item = new Sprite();
			_item.buttonMode = true;
			addChild(_item);

			// BACKGROUND (transparent, grab mouse events)
			drawBackground( Theme.GLASSTINT, 0);

			// THUMBNAIL
			_thumbLoader = new LoaderWithRollover();
			_thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbLoaded);
			_thumbLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
//			_thumbLoader.addEventListener(MouseEvent.CLICK, loadPlaylist);
			_thumbLoader.x = 4;
			_thumbLoader.y = 4;
			_item.addChild(_thumbLoader);

			// DURATION
			_durationText = new TFTextField();
			_durationText.selectable = false;
			_durationText.backgroundColor = 0x000;
			_durationText.background = true;
			_durationText.colour = 0xffffff;
			_durationText.size = 11;
			_durationText.autoSize = TextFieldAutoSize.LEFT;
			_durationText.x = 6;
			_durationText.y = 6;
			_item.addChild(_durationText);

			// TITLE
			_titleText = new TFTextField();
			_titleText.selectable = false;
			_titleText.autoSize = TextFieldAutoSize.LEFT;
			_titleText.wordWrap = true;
			_titleText.anchor = true;
			//_titleText.colour = Theme.TEXTHIGHLIGHT;
			//_titleText.bold = true;
			_titleText.x = 128;
			_titleText.y = 4;
			_titleText.width = WIDTH - 128 - 4;
			_item.addChild(_titleText);
			//_titleText.addEventListener(MouseEvent.CLICK, loadPlaylist);

			// CATEGORY (display right justified at bottom)
			var categoryText:TFTextField = new TFTextField();
			categoryText.text = "category";// _videoItemVO.category;
			categoryText.anchor = true;
			categoryText.x = 128;
			categoryText.width = WIDTH - 128 - 4;
			categoryText.autoSize = TextFieldAutoSize.RIGHT;
			categoryText.height = 18;
			categoryText.y = HEIGHT - categoryText.height;
			//addChild(categoryText);

			// AUTHOR
			var authorText:TFTextField = new TFTextField();
			authorText.small = true;
			authorText.anchor = true;
			authorText.text = "author";// _videoItemVO.author;
			authorText.width = authorText.textWidth;
			authorText.height = 16;
			authorText.x = 128;
			authorText.y = HEIGHT - authorText.height;
			//addChild(authorText);

			// DATE UPLOADED
			_uploadDate = new TFTextField();
			_uploadDate.selectable = false;
			_uploadDate.small = true;
			_uploadDate.colour = 0xaaaadd;
			_uploadDate.height = 14;
			_uploadDate.x = 128;
			_uploadDate.y = authorText.y - _uploadDate.height;
			_item.addChild(_uploadDate);

			// NUMBER OF VIEWS
			var viewsText:TFTextField = new TFTextField();
			viewsText.selectable = false;
			viewsText.small = true;
			viewsText.text = "views";// numberToViews(_videoItemVO.views) + " views";
			viewsText.height = 14;
			viewsText.x = 128;
			viewsText.y = _uploadDate.y - viewsText.height;
			//addChild(viewsText);
			
			// DESCRIPTION (fit into remaining available space, if any...)
			var descriptionText:TFTextField = new TFTextField();
			descriptionText.small = true;
			descriptionText.wordWrap = true;
			descriptionText.x = 128;
			descriptionText.y = _titleText.y + _titleText.height;
			descriptionText.width = WIDTH - 128 - 4;
			descriptionText.height = viewsText.y - descriptionText.y;
			//addChild(descriptionText);

			// DELETE ICON
			var deleteIconSprite:Sprite = new Sprite();
			deleteIconSprite.name = "delete";
			deleteIconBMP = new deleteIcon();
			deleteIconBMP.width = 24;
			deleteIconBMP.height = 24;
			deleteIconBMP.x = WIDTH - 28;
			deleteIconBMP.y = 4;
			deleteIconBMP.visible = false;
			deleteIconSprite.addChild(deleteIconBMP);
			deleteIconSprite.buttonMode = true;
			addChild(deleteIconSprite);

			// SET UP HANDLERS
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			_item.addEventListener(MouseEvent.CLICK, mouseClick);

		}

		// fill out the details of this playlistsItemView using new VO data
		public function drawView():void
		{
			_titleText.text = _playlistsItemVO.title;
			_durationText.text = numberToDuration(_playlistsItemVO.duration);
			_durationText.visible = true;
			if (_playlistsItemVO.duration == 0) {
				_durationText.visible = false;
			}
			if (playlistsItemVO.timestamp) {
				_uploadDate.text = "Last changed: " + _playlistsItemVO.timestamp;
			}
			mouseOut();	// initialise to deselected

			// LOAD THUMB - DO THIS LAST IN CASE ERRORS STOP EXECUTION
			_thumbLoader.load( new URLRequest( _playlistsItemVO.thumbURL ));
		}

		public function get playlistsItemVO():PlaylistVO
		{
			return _playlistsItemVO;
		}
		public function set playlistsItemVO(_p:PlaylistVO):void
		{
			_playlistsItemVO = _p;
			drawView();
		}
		public function get pid():int
		{
			return _playlistsItemVO.pid;
		}
		
		// redraw function is overridden from XSprite defn
		override public function redraw():void
		{
			drawBackground( Theme.GLASSTINT, 0 );
		}
		private function drawBackground( _colour:int, _alpha:Number ):void
		{
			_item.graphics.clear();
			_item.graphics.beginFill( _colour, _alpha);
			_item.graphics.drawRect(0, 0, _width, _height);
			_item.graphics.endFill();
		}
		private function numberToDuration(n:Number):String
		{
			if (n < 10) return "0" + String(n);
			else if (n < 60) return String(n);
			else if (n < 3600) return numberToDuration(Math.floor(n / 60)) + ":" + numberToDuration(n % 60);
			else return String(Math.floor(n/3600)) + ":" + numberToDuration(n % 3600);
		}
		private function numberToViews(n:Number):String
		{
			if (n < 1000) return String(n);
			else return numberToViews(Math.floor(n / 1000)) + "," + String(n % 1000);
		}
		private function thumbLoaded(e:Event):void
		{
			// size of thumb is *almost* always 120x90, however occasionally it can be larger so just force a resize
			var t:DisplayObject = e.currentTarget.loader as DisplayObject;
			t.width = 120;
			t.height = 90;
			// since this playlist item view can be re-loaded we don't remove the event listeners
			//removeEventListeners();
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("PlaylistsItemView:: IOErrorHandler:" );
			//removeEventListeners();
		}

		private function removeEventListeners():void
		{
			_thumbLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, thumbLoaded);
			_thumbLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
		}
		private function mouseOver(e:MouseEvent):void
		{
			drawBackground( Theme.TEXTFACEBOOKFILL, 0.35 );
			deleteIconBMP.visible = true;
		}
		private function mouseOut(e:MouseEvent=null):void
		{
			drawBackground( Theme.GLASSTINT, 0 );
			deleteIconBMP.visible = false;
		}
		private function mouseClick(e:MouseEvent):void
		{
			drawBackground( Theme.TEXTFACEBOOKMOUSEOVER, 0.35 );
			e.stopPropagation();
			dispatchEvent(new Event( AppConstants.CLIENTLOADPLAYLIST, true, true));
		}
		/*
		 * remove below function temporarily as I've made anchor text unselectable meaning this function won't do anything useful...
		private function titleClicked(e:MouseEvent):void
		{
			var _t:TextField = e.currentTarget as TextField;
			if (_t.selectionBeginIndex < _t.selectionEndIndex) {
				trace("PlaylistsItemView:: titleClicked: text selected, not a click");
			} else {
				addToPlaylist();
			}
		}
		*/
	}

}