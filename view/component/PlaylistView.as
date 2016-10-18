package com.videoswipe.view.component 
{
	import com.greensock.TweenLite;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author 
	 */
	public class PlaylistView extends GlassSprite
	{
		public const PLAYLISTTITLE:String = "playlistTitle";
		
		public const HEIGHT:int = 138;		// height of this display object
		private const ITEMHEIGHT:int = 98;	// height of the playlist items

		private static const ITEMPADDING:int = 4;	// space around items in this view
		private static const ITEMWIDTH:int = 128;	// width of a single playlist item

		private var _playlistVO:PlaylistVO;	// the view holds the model
		private var _nextButton:FacebookButton;		// button for the next page of playlist items
		private var _previousButton:FacebookButton;		// previous page
		private var _tweening:Boolean;		// true if we are currently tweening the playlist
		private var _videos:Sprite;	// holder for the video items list
		private var _buttons:Sprite;	// holder for the control buttons
		private var _itemMask:Sprite;	// used to mask the playlist items
		private var _title:EditableTextField;	// used to enter the title of this playlist
		private var _dragDelay:Timer;		// 120ms pause between mouse down and mouse up, decides if user wants to drag an item
		private var _dragTimer:Timer;		// timer runs while dragging to update drag cursor
		private var _dragCursor:Sprite;	// cursor shows where the item will move to after dragging completed
		private var _dragItem:PlaylistItemView;	// cache the currently dragging item
		
		
		public function PlaylistView()
		{
			trace("PlaylistView:: PlaylistView: hello."  );
			this.name = "playlistView";
			initView();
			_tweening = false;
		}

		private function initView():void
		{
			initActionButtons();
			layoutActionButtons();

			// ITEMS
			_videos = new Sprite();
			_videos.x = 0;
			_videos.y = HEIGHT - ITEMHEIGHT - ITEMPADDING;
			addChild(_videos);
			
			// MASK
			_itemMask = new Sprite();
			_itemMask.graphics.beginFill(0x000, 1);
			_itemMask.graphics.drawRect(0, 0, _width, ITEMHEIGHT);
			_itemMask.graphics.endFill();
			_itemMask.x = _videos.x;
			_itemMask.y = _videos.y;
			addChild(_itemMask);
			_videos.mask = _itemMask;
			
			// buttons for paging through the playlist
			_previousButton = new FacebookButton("facebook", "<", 24, ITEMHEIGHT - 2 * ITEMPADDING, false);
			_previousButton.name = "previous";
			_previousButton.x = ITEMPADDING;
			_previousButton.y = _videos.y + ITEMPADDING;
			_previousButton.addEventListener(MouseEvent.CLICK, previousPage);
			_nextButton = new FacebookButton("facebook", ">", 24, ITEMHEIGHT - 2 * ITEMPADDING, false);
			_nextButton.name = "next";
			_nextButton.x = _width - 24 - ITEMPADDING;
			_nextButton.y = _videos.y + ITEMPADDING;
			_nextButton.addEventListener(MouseEvent.CLICK, nextPage);

			// drag cursor
			_dragCursor = new Sprite();
			_dragCursor.graphics.clear();
			_dragCursor.graphics.lineStyle(1, 0xffff00);
			_dragCursor.graphics.beginFill( Theme.TEXTHIGHLIGHT, 0.8);
			_dragCursor.graphics.drawRect( -2, 0, 5, ITEMHEIGHT);
			_dragCursor.graphics.endFill();
			_dragCursor.mouseEnabled = false;
			_dragCursor.y = _videos.y;
			addChild(_dragCursor);
			_dragCursor.visible = false;
			
			// drag timer
			_dragDelay = new Timer(150, 1);
			_dragDelay.addEventListener(TimerEvent.TIMER, dragDelayComplete);
			
			_dragTimer = new Timer(100, 0);
			_dragTimer.addEventListener(TimerEvent.TIMER, dragTimerHandler);
			_videos.addEventListener(MouseEvent.MOUSE_DOWN, playlistItemMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}

		// initActionButtons
		// sets up all the buttons running along the top of the playlist view
		private function initActionButtons():void
		{
			_buttons = new Sprite();
			_buttons.x = 0;
			_buttons.y = 6;
			addChild(_buttons);

			/*
			var _p:Button = new Button();
			_p.name = "prevItem";
			_p.text = "<";
			_p.width = 16;
			_buttons.addChild(_p);
			var _c:Button = new Button();
			_c.text = "CURRENT";
			_c.width = 64;
			_c.addEventListener(MouseEvent.CLICK, showCurrentItem);
			_buttons.addChild(_c);
			var _n:Button = new Button();
			_n.name = "nextItem";
			_n.text = ">";
			_n.width = 16;
			_n.textField.borderColor = 0x0000ff;
			_buttons.addChild(_n);
			*/
			_title = new EditableTextField();
			_title.width = 180;
			_title.height = 24;
			_title.addEventListener(Event.COMPLETE, playlistTitleChanged);
			_buttons.addChild(_title);
			
			var _save:FacebookButton = new FacebookButton("facebook", "Save", 64, 24, false);	// false for no logo
			_save.name = "save";
			_buttons.addChild(_save);
			
			var _load:FacebookButton = new FacebookButton("facebook", "Load", 64, 24, false);
			_load.name = "load";
			//_buttons.addChild(_load);
			
			var _new:FacebookButton = new FacebookButton("facebook", "New", 64, 24, false);
			_new.name = "new";
			_buttons.addChild(_new);
			
			var _shareText:TFTextField = new TFTextField();
			_shareText.text = "  Share:";
			_shareText.size = 14;
			_shareText.y = 2;	// slight adjust to vertically centre
			_shareText.bold = true;
			_shareText.colour = 0xFFB100;	// complementary colour to FB blue (kuler)
			_buttons.addChild(_shareText);
			
			var _s:FacebookButton = new FacebookButton("facebook", "Post to Wall", 116, 24);
			_s.name = "post";
			_buttons.addChild(_s);
			
			var _send:FacebookButton = new FacebookButton("facebook", "Send to Friend", 132, 24);
			_send.name = "send";
			_buttons.addChild(_send);
		}

		public function addLinkButtons(_s:String):void
		{
			if (_buttons.getChildByName("linkBox")) {
				// we already added the box, just update the text
				var _l:TFTextField = _buttons.getChildByName("linkBox") as TFTextField;
				_l.text = _s;
				setCopyButtonText("Copy");
			} else {
				var _linkText:TFTextField = new TFTextField();
				_linkText.text = "  Link:";
				_linkText.size = 14;
				_linkText.y = 2;
				_linkText.bold = true;
				_linkText.colour = Theme.TEXTHIGHLIGHT;
				_buttons.addChild(_linkText);
				
				var _linkBox:TFTextField = new TFTextField();
				_linkBox.name = "linkBox";
				_linkBox.autoSize = TextFieldAutoSize.NONE;	// needed otherwise width can't be set
				_linkBox.size = 14;
				_linkBox.height = 24;	// defines size of border
				_linkBox.colour = Theme.TEXTSTANDARD;
				_linkBox.border = true;
				_linkBox.width = 148;
				_linkBox.text = _s;
				_buttons.addChild(_linkBox);
				
				var _copyButton:FacebookButton = new FacebookButton("facebook", "Copy", 64, 24, false);
				_copyButton.name = "copy";	// used to identify this button clicked in mediator
				_buttons.addChild(_copyButton);
				layoutActionButtons();
			}
		}
		public function setCopyButtonText( _s:String ):void
		{
			var _c:FacebookButton = _buttons.getChildByName("copy") as FacebookButton;
			if (_c) {
				_c.label = _s;
			}
		}
		// layoutActionButtons
		// organises all the action buttons in the _buttons sprite (sets their x pos to place them along the buttons row)
		private function layoutActionButtons():void
		{
			_buttons.getChildAt(0).x = 2;
			for (var i:int = 0; i < _buttons.numChildren; i++) {
				if (i > 0) {
					_buttons.getChildAt(i).x = _buttons.getChildAt(i - 1).x + _buttons.getChildAt(i - 1).width + 4;
				}
			}
		}
		private function drawView():void
		{
			trace("PlaylistView:: drawView:", playlistVO.playlistItems.length );
			if (_dragTimer.running) {
				_dragCursor.visible = false;
				_dragItem.stopDrag();
				removeChild(_dragItem);
			}
			while (_videos.numChildren > 0) {
				_videos.removeChildAt(0);
			}
			removeSlideButtons();	// force remove to reset state before adding new items
			_videos.x = 0;
			var _itemView:PlaylistItemView;
			for each (var _playlistItem:VideoItemVO in _playlistVO.playlistItems)
			{
				_itemView = new PlaylistItemView(_playlistItem);
				_itemView.x = _videos.numChildren * ITEMWIDTH;
				_videos.addChild(_itemView);
			}
			_title.text = playlistVO.title;
			checkButtons();
			showGlass();
		}

		private function previousPage(e:MouseEvent=null):void
		{
			if (e) e.stopPropagation();
			if (!_tweening) {
				var _newX:int = _videos.x + _itemMask.width;
				if (_newX > _itemMask.x) _newX = _itemMask.x;
				TweenLite.to(_videos, 0.5, { x:_newX, onComplete:tweenComplete } );
				_tweening = true;
			}
		}
		private function nextPage(e:MouseEvent=null):void
		{
			if (e) e.stopPropagation();
			if (!_tweening) {
				if (_videos.x + _playlistVO.playlistLength * ITEMWIDTH > _itemMask.width) {
					TweenLite.to(_videos, 0.5, { x:_videos.x - _itemMask.width, onComplete:tweenComplete } );
					_tweening = true;
				}
			}
		}
		private function tweenComplete():void
		{
			_tweening = false;
		}
		private function playlistTitleChanged(e:Event):void
		{
			trace("PlaylistView:: playlistTitleEntered:", _title.text );
			e.stopPropagation();
			playlistVO.title = _title.text;
			dispatchEvent( new PlaylistEvent( PlaylistEvent.PLAYLISTTITLECHANGED ));
		}
		
		public function addPlaylistItemView(_v:VideoItemVO):void
		{
				var _itemView:PlaylistItemView;
				var _found:Boolean = false;
				for (var j:int = _videos.numChildren; j--; ) {
					_itemView = _videos.getChildAt(j) as PlaylistItemView;
					if (_itemView.videoID == _v.videoID) {
						_found = true;
						break;
					}
				}
				if (!_found) {
					_itemView = new PlaylistItemView(_v);
					_itemView.x = _videos.numChildren * ITEMWIDTH;
					_videos.addChild(_itemView);
				}
				makeItemVisible(_itemView);
				_itemView.flash();
				checkButtons();
		}
		public function deletePlaylistItem(i:int):void
		{
			if (i >= 0 && i < _videos.numChildren) {
				_videos.removeChildAt(i);
				arrangePlaylistItems();
				checkButtons();
			}
		}
		// synchronise playlist
		// called when the playlist (vo) has been changed, need to re-sync view
		public function synchronisePlaylistView():void
		{
			var i:int, j:int;
			var found:Boolean;
			var _itemVO:VideoItemVO;
			var _itemView:PlaylistItemView;
			for (i = 0; i < playlistVO.playlistLength; i++ ) {
				_itemVO = playlistVO.playlistItems[i];
				found = false;
				for (j = 0; j < _videos.numChildren; j++ ) {
					_itemView = _videos.getChildAt(j) as PlaylistItemView;
					if (_itemView.videoID == _itemVO.videoID) {
						trace("PlaylistView:: synchronisePlaylist:", i, j );
						found = true;
						_videos.addChildAt( _itemView, i );
						break;
					}
				}
				// if item not found then add new item view
				if (!found) {
					_itemView = new PlaylistItemView(_itemVO);
					_itemView.x = i * ITEMWIDTH;
					_videos.addChildAt(_itemView, i);
					_itemView.flash();
				}
			}
			arrangePlaylistItems();
			checkButtons();
		}
		private function arrangePlaylistItems():void
		{
			trace("PlaylistView:: arrangePlaylistItems:" );
			var _item:Sprite;
			for (var i:int = _videos.numChildren; i--; ) {
				_item = _videos.getChildAt(i) as Sprite;
				var _newX:int = i * ITEMWIDTH;
				if (_item.x != _newX) {
					TweenLite.to(_item, 0.5, { x:_newX } );
				}
			}
		}
		
		// checkButtons
		// looks at length of playlist and size of display and decides whether we need to display the scroll buttons
		private function checkButtons():void
		{
			var playlistWidth:int = _videos.numChildren * ITEMWIDTH;
			if (playlistWidth > _itemMask.width) {
				addSlideButtons();
			} else {
				removeSlideButtons();
			}
		}
		private function addSlideButtons():void
		{
			if (!this.getChildByName("next")) {
				this.addChild(_previousButton);
				this.addChild(_nextButton);
				_itemMask.x = 24 + 2 * ITEMPADDING;
				_itemMask.width = _width - 48 - 4 * ITEMPADDING;
				_videos.x += _itemMask.x;
			}
		}
		private function removeSlideButtons():void
		{
			if (this.getChildByName("next")) {
				this.removeChild(_previousButton);
				this.removeChild(_nextButton);
				_videos.x -= _itemMask.x;
				_videos.x = 0;	// try just setting to 0, since we have no buttons to navigate it should just set the position
				_itemMask.x = 0;
				_itemMask.width = _width;
			}
		}
		public function setCurrentPlayingItem( _videoID:String ):void
		{
			trace("PlaylistView:: setCurrentPlayingItem:", i );
			clearPlaylistItems();
			var _item:PlaylistItemView;
			if (_dragItem && (_videoID == _dragItem.videoID )) {
				_item = _dragItem;
				_item.playing = true;
			} else {
				for (var i:int = _videos.numChildren; i--; ) {
					_item = _videos.getChildAt(i) as PlaylistItemView;
					if (_item.videoID == _videoID) {
						_item.playing = true;
						break;
					}
				}
			}
			makeItemVisible(_item);
		}
		private function makeItemVisible( _item:PlaylistItemView):void
		{
			// if user dragging then don't change the playlist dispay
			if (!_dragTimer.running) {
				TweenLite.killTweensOf(_videos);
				if (_videos.x + _item.x < _itemMask.x) {	// bring onto left edge of playlist
					TweenLite.to(_videos, 0.4, { x: _itemMask.x - _item.x, onComplete:tweenComplete } );
					_tweening = true;
				}
				if (_videos.x + _item.x >= _itemMask.x + _itemMask.width) {	// bring onto right edge of playlist
					TweenLite.to(_videos, 0.4, { x: _itemMask.x + _itemMask.width - _item.x - _item.width, onComplete:tweenComplete } );
					_tweening = true;
				}
			}
		}

		private function clearPlaylistItems():void
		{
			for (var i:int = _videos.numChildren; i--; ) {
				var _item:PlaylistItemView = _videos.getChildAt(i) as PlaylistItemView;
				_item.playing = false;
			}
			if (_dragItem) _dragItem.playing = false;
		}

		override public function redraw():void
		{
			super.redraw();	// redraw the glass if needed
			_nextButton.x = _width - _nextButton.width - ITEMPADDING;
			_itemMask.width = _width;
			if (this.getChildByName("next")) {
				_itemMask.width = _width - 48 - 4 * ITEMPADDING;
			}
			
			// draw the backgrounds
			drawItemBackgrounds();

			// this panel is unusual in that it is designed to have an opaque background
			//this.graphics.clear();
			//this.graphics.beginFill(0xebebeb, 1);
			//this.graphics.drawRect(0, 0, _width, HEIGHT);
			//this.graphics.endFill();
			
		}
		private function drawItemBackgrounds():void
		{
			var _nItems:int = _videos.numChildren + Math.ceil(_width / ITEMWIDTH);
			trace("PlaylistView:: drawItemBackgrounds:", _nItems );
			_videos.graphics.clear();
			for (var i:uint = _nItems; i--; ) {
				drawItemBackgroundAt(i);
			}
		}
		private function drawItemBackgroundAt(i:int):void
		{
			_videos.graphics.lineStyle(4, 0x1A356E, 1);
			_videos.graphics.drawRect( i * ITEMWIDTH + 8, 8, ITEMWIDTH -16, ITEMHEIGHT - 16);
		}

		private function playlistItemMouseDown(e:MouseEvent):void
		{
			trace("PlaylistView:: playlistItemMouseDown:", e.target.name);
			
			// if user has clicked the thumb image (ie not the delete icon) then we might want to drag
			if (e.target.name == "thumb") {
				_dragItem = e.target.parent as PlaylistItemView;
				_dragItem.addEventListener(MouseEvent.MOUSE_UP, playlistItemMouseUp);
				_dragDelay.reset();
				_dragDelay.start();
			}
		}
		// dragDelayComplete
		// once the 120ms delay is done then we start dragging
		private function dragDelayComplete(e:TimerEvent):void
		{
			trace("PlaylistView:: dragDelayComplete:", _videos.y, _dragItem.name, _dragItem.y );
			_videos.removeChild(_dragItem);
			_dragItem.y += _videos.y;
			_dragItem.x += _videos.x;
			_dragItem.alpha = 0.7;
			dragTimerHandler();	// call the handler right away to set cursor
			this.addChild(_dragItem);
			this.addChild(_dragCursor);
			_dragItem.startDrag(false, new Rectangle(ITEMWIDTH/-2, _videos.y, _width, 0));
			_dragTimer.reset();
			_dragTimer.start();
			_dragCursor.visible = true;
		}
		private function dragTimerHandler(e:TimerEvent=null):void
		{
			// this checks for mouse leaving the playlistview and stops the dragging if so
			if (this.mouseY < 0) {
				playlistItemMouseUp();
			}

			// if tweening the playlist then do nothing, too much going on already
			if (!_tweening) {

				_dragCursor.x = _videos.x + dragCursorSlot() * ITEMWIDTH;
			
				if (_dragItem.x >= _itemMask.x + _itemMask.width - ITEMWIDTH) {
					if (_videos.x + _playlistVO.playlistLength * ITEMWIDTH > _itemMask.width) {
						TweenLite.to(_videos, 0.5, { x:_videos.x - ITEMWIDTH, onComplete:tweenComplete } );
						_tweening = true;
					}
				}
				if (_dragItem.x < _itemMask.x) {
					var _newX:int = _videos.x + ITEMWIDTH;
					if (_newX > _itemMask.x) _newX = _itemMask.x;
					TweenLite.to(_videos, 0.5, { x:_newX, onComplete:tweenComplete } );
					_tweening = true;
				}
			}
		}

		private function playlistItemMouseUp(e:MouseEvent=null):void
		{
			trace("PlaylistView:: playlistItemMouseUp:" );
			_dragItem.removeEventListener(MouseEvent.MOUSE_UP, playlistItemMouseUp);
			_dragTimer.stop();

			if (_dragDelay.running) {
				// this counts as a click, cancel dragTimer
				_dragDelay.stop();
				dispatchEvent( new PlaylistEvent( PlaylistEvent.PLAYPLAYLISTITEM, _dragItem.videoItemVO));
			} else {
				// user has been dragging, clear up
				trace("PlaylistView:: playlistItemMouseUp: STOP DRAG" );
				_dragCursor.visible = false;
				_dragItem.stopDrag();
				removeChild(_dragItem);
				_dragItem.alpha = 1;
				_videos.addChildAt( _dragItem, dragItemSlot() );	// reset at correct place in display stack (determines position)
				dispatchEvent( new PlaylistEvent( PlaylistEvent.MOVEPLAYLISTITEM, _dragItem.videoItemVO, dragItemSlot() ));
				_dragItem.x -= _videos.x;
				_dragItem.y -= _videos.y;
			}
		}

		// dragCursorSlot
		// returns the 'slot' position of the cursor (where the drag item will be positioned after dragging)
		private function dragCursorSlot():int
		{
			var i:int = Math.floor( (_dragItem.x - _videos.x + ITEMWIDTH / 2) / ITEMWIDTH );
			if (i > _videos.numChildren+1) i = _videos.numChildren+1;
			if (i < 0) i = 0;
			return i;
		}
		// dragItemSlot
		// similar to above, but adjusted for the final slot
		private function dragItemSlot():int
		{
			var i:int = dragCursorSlot();
			if (i > _videos.numChildren) i = _videos.numChildren;
			return i;
		}
		
		// mouseUpHandler
		// we need this to catch all mouse up events in case user stops dragging
		private function mouseUpHandler(e:MouseEvent):void
		{
			trace("PlaylistView:: mouseUpHandler:" );
			if (_dragTimer.running) {
				playlistItemMouseUp();
			}
		}
		
		// PUBLIC GETTER/SETTERS
		public function set playlistVO(_p:PlaylistVO):void
		{
			_playlistVO = _p;
			drawView();
		}
		public function get playlistVO():PlaylistVO
		{
			return _playlistVO;
		}
		
	}

}