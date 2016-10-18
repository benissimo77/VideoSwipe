package com.videoswipe.view.component 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author 
	 */
	
	public class FacebookButton extends Sprite
	{
		[Embed(source = "assets/fblogo32.png")]
		private static var FacebookLogo:Class;
		[Embed(source = "assets/videoswipe/videoswipe-logo-square-22pxwhite.png")]
		private static var VideoSwipeLogo:Class;
		[Embed(source = "assets/ytlogo32.png")]
		private static var YouTubeLogo:Class;

		private var _width:int;
		private var _height:int;
		private var _label:TFTextField;
		private var _logo:Boolean;
		private var _style:String;
		
		public function FacebookButton(_s:String="default", _l:String="", _w:int=60, _h:int=16, _showlogo:Boolean = true)
		{
			_style = _s;
			_width = _w;
			_height = _h;
			_logo = _showlogo;
			
			// initView
			_label = new TFTextField(_s);
			_label.colour = 0x000;
			if (_s == "facebook") {
				_label.colour = 0xffffff;
			}
			_label.autoSize = TextFieldAutoSize.CENTER;
			_label.size = Math.min( _h * 0.5, _w * 0.5);
			_label.text = _l;
			addChild(_label);
			if (_logo) {
				var _logoBMP:Bitmap;
				if (_s == "facebook") _logoBMP = new FacebookLogo();
				else if (_s == "youtube") _logoBMP = new YouTubeLogo();
				else _logoBMP = new VideoSwipeLogo();
				addChild(_logoBMP);
				_logoBMP.x = 2;
				_logoBMP.y = 2;
				_logoBMP.width = _logoBMP.height = _height - 4;
			}
			drawView();
			this.mouseChildren = false;	// only the entire button can send mouse events
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		public function setSize(_w:int, _h:int):void
		{
			_width = _w;
			_height = _h;
			if (_logo) _width += _height;
			drawView();
		}
		private function drawView():void
		{
			mouseOut();	// draws background
			placeLabel();
		}
		private function placeLabel():void
		{
			_label.y = (_height - _label.height) / 2;
			_label.x = 0;
			_label.width = _width;
			if (_logo) {
				_label.x = _height;
				_label.width = _width - _label.x;
			}
		}
		private function mouseOver(e:MouseEvent = null):void
		{
			var _fillColour:uint = 0xE6E8FA;
			var _lineColour:uint = 0x000000;
			if (_style == "facebook") {
				_fillColour = Theme.TEXTFACEBOOKMOUSEOVER;
				_lineColour = Theme.TEXTFACEBOOKEDGE;
			}
			graphics.clear();
			graphics.lineStyle(1, _lineColour, 1);	// NOTE: line thickness of 2 seems to render more cleanly (don't know why)
			graphics.beginFill(_fillColour, 1);
			graphics.drawRoundRect(0,0, _width, _height, 2);
			graphics.endFill();
			// FB buttons have a slightly darker bottom border - duplicate!
			graphics.lineStyle(1, 0x1A356E, 1);
			graphics.moveTo(1, _height);
			graphics.lineTo(_width - 1, _height);
		}
		private function mouseOut(e:MouseEvent = null):void
		{
			var _fillColour:uint = 0xffffff;
			var _lineColour:uint = 0x424040;
			if (_style == "facebook") {
				_fillColour = Theme.TEXTFACEBOOKFILL;
				_lineColour = Theme.TEXTFACEBOOKEDGE;	// as above
			}
			graphics.clear();
			graphics.lineStyle(1, _lineColour, 1);	// NOTE: line thickness of 2 seems to render more cleanly (don't know why)
			graphics.beginFill(_fillColour, 1);
			graphics.drawRoundRect(0,0, _width, _height, 2);
			graphics.endFill();
			// FB buttons have a slightly darker bottom border - duplicate!
			graphics.lineStyle(1, 0x1A356E, 1);
			graphics.moveTo(1, _height);
			graphics.lineTo(_width - 1, _height);
		}
		

		// PUBLIC GETTER/SETTERS
		public function set label(_l:String):void
		{
			_label.text = _l;
			placeLabel();
		}
		public function get label():String
		{
			return _label.text;
		}

	}

}