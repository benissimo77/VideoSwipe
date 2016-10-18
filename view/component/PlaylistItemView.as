package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author 
	 */
	public class PlaylistItemView extends Sprite
	{
		[Embed (source = "assets/deleteIconGrey.png")]
		private var deleteIcon:Class;
		private var deleteIconBMP:Bitmap;
		
		private static const WIDTH:int = 128;	// width of this object
		private static const HEIGHT:int = 98;	// height of this video view object
		private static const DEFAULTBG:uint = 0xeeeeff;
		private static const QUEUEDBG:uint = 0x908433;	// colour chosen from http://colorschemedesigner.com/#1y31Qrro8w0w0
		private static const PLAYING:uint = 0x4444ff;

		private var _videoItemVO:VideoItemVO;	// cache a local copy of this VO
		private var _thumbLoader:Loader;			// loader for the thumb image
		private var _thumbTint:Shape;				// used to darken/brighten image on mouse over
		private var _videoMessageIcon:Loader;	// icon to show that this item has a video message attached
		private var _flash:Shape;					// can flash this item to make it stand out

		public function PlaylistItemView( p:VideoItemVO = null) 
		{
			initView();
			this.buttonMode = true;
			if (p) videoItemVO = p;	// calls setter function
		}
		
		private function initView():void
		{
			// THUMBNAIL
			_thumbLoader = new Loader();
			_thumbLoader.name = "thumb";
			_thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, thumbLoaded);
			_thumbLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_thumbLoader.x = 4;
			_thumbLoader.y = 4;
			addChild(_thumbLoader);

			// THUMBTINT
			_thumbTint = new Shape();
			_thumbTint.graphics.clear();
			_thumbTint.graphics.beginFill(0x000, 1);
			_thumbTint.graphics.drawRect(0, 0, 120, 90);
			_thumbTint.graphics.endFill();
			_thumbTint.x = _thumbLoader.x;
			_thumbTint.y = _thumbLoader.y;
			addChild(_thumbTint);
			
			// VIDEO MESSAGE ICON
			_videoMessageIcon = new Loader();
			_videoMessageIcon.name = "messageicon";
			_videoMessageIcon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoaded);
			_videoMessageIcon.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_videoMessageIcon.mouseEnabled = false;
			_videoMessageIcon.x = 12;
			_videoMessageIcon.y = 12;
			addChild(_videoMessageIcon);
			
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
			addChild(deleteIconSprite);

			// FLASH
			_flash = new Shape();
			_flash.graphics.clear();
			_flash.graphics.lineStyle(3, 0xE0CD50, 1);
			_flash.graphics.drawRect(2, 2, WIDTH - 4, HEIGHT - 4);
			graphics.endFill();
			_flash.graphics.beginFill(0x000, 0);
			_flash.graphics.drawRect( WIDTH-4, HEIGHT-4, -WIDTH+8, -HEIGHT+8);
			graphics.endFill();
			_flash.visible = false;
			addChild(_flash);

			// BACKGROUND
			drawBackground(DEFAULTBG);

			// MOUSE EVENTS
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);

		}
		
		public function flash():void
		{
			_flash.visible = true;
			var _timer:Timer = new Timer(180, 5);
			_timer.addEventListener(TimerEvent.TIMER, flashHandler);
			_timer.start();
		}
		private function flashHandler(e:flash.events.TimerEvent):void
		{
			_flash.visible = (_flash.visible) ? false : true;
		}
		private function drawView():void
		{
			trace("PlaylistItemView:: drawView:", videoID );
			_thumbLoader.load( new URLRequest( _videoItemVO.thumbnailURL ));
			
			if (_videoItemVO.videoMessages.length > 0) {
				_videoMessageIcon.load( new URLRequest( "https://graph.facebook.com/" + _videoItemVO.videoMessages[0].uid + "/picture" ));
			}
		}
		private function mouseOver(e:MouseEvent):void
		{
			_thumbTint.alpha = 0;
			deleteIconBMP.visible = true;
			if (e.target.name == "thumb") {
				//trace("PlaylistItemView:: mouseOver: showing TOOLTIP", _videoItemVO.videoTitle );
				ToolTip.show( _videoItemVO.videoTitle );
			}
		}
		private function mouseOut(e:MouseEvent=null):void
		{
			//trace("PlaylistItemView:: mouseOut: hiding TOOLTIP", _videoItemVO.videoTitle );
			ToolTip.hide();
			deleteIconBMP.visible = false;
			_thumbTint.alpha = 0.25;
		}
		private function drawBackground(colour:uint):void
		{
			graphics.clear();
			if (colour != DEFAULTBG) {
				graphics.beginFill(colour);
				graphics.drawRect(0, 0, WIDTH, HEIGHT);
				graphics.endFill();
			}
		}
		private function thumbLoaded(e:Event):void
		{
			var t:DisplayObject = e.currentTarget.loader as DisplayObject;
			t.width = 120;
			t.height = 90;
			mouseOut();	// initialise to deselected
		}
		private function iconLoaded(e:Event):void
		{
			var t:DisplayObject = e.currentTarget.loader as DisplayObject;
			t.width = 32;
			t.height = 32;
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("PlaylistItemView:: IOErrorHandler:", videoID );
		}
		
		// GETTER SETTERS
		public function get videoItemVO():VideoItemVO
		{
			return _videoItemVO;
		}
		public function set videoItemVO(value:VideoItemVO):void 
		{
			_videoItemVO = value;
			drawView();
		}
		public function get videoID():String
		{
			return _videoItemVO.videoID;
		}
		public function set playing(b:Boolean):void
		{
			if (b) drawBackground(PLAYING);
			else drawBackground(DEFAULTBG);
		}
		
	}

}
