package com.videoswipe.view.component 
{
	import com.greensock.TweenLite;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * ...
	 * @author 
	 */
	public class SystemMessageItemView extends GlassSprite
	{
		[Embed (source = "assets/warning.png")]
		private static var warningIcon:Class;
		[Embed (source = "assets/round-error.png")]
		private static var errorIcon:Class;
		[Embed (source = "assets/round-ok.png")]
		private static var successIcon:Class;
		[Embed (source = "assets/fb_inviteIcon.png")]
		private static var inviteIcon:Class;
		[Embed (source = "assets/questionmark.png")]
		private static var requestIcon:Class;

		private static const _icons:Object = { warning:warningIcon, error:errorIcon, success:successIcon, invite:inviteIcon, request:requestIcon };
		public static const WIDTH:int = 640;
		public static const HEIGHT:int = 120;
		
		private var _messageRequest:SystemMessageRequest;
		private var _itemVO:SystemMessageItemVO;
		private var _icon:Bitmap;
		private var _titleText:TFTextField;
		private var _infoText:TFTextField;
		private var _buttons:Sprite;
		private var _timer:Shape;	// timmer works as a Tweened shape
		
		public function SystemMessageItemView( _m:SystemMessageRequest = null) 
		{
			trace("SystemMessageItemView:: SystemMessageItemView:", _m );
			this.name = "";	// sprite names are used as responses, the base sprite is a 'null' response (user clicked the view not a button)
			initView();
			if (_m) messageRequest = _m;	// this also sets the _itemVO and draws the view
		}
		
		private function initView():void
		{
			_titleText = new TFTextField("facebook");
			_titleText.x = 80;
			_titleText.y = 16;
			_titleText.width = WIDTH - _titleText.x - 4;
			_titleText.colour = Theme.TEXTHIGHLIGHT;
			_titleText.size = 18;
			_titleText.bold = true;
			addChild(_titleText);
			_infoText = new TFTextField();
			_infoText.x = 80;
			_infoText.y = 48;
			_infoText.size = 16;
			_infoText.multiline = true;
			_infoText.wordWrap = true;
			_infoText.width = WIDTH - _infoText.x - 4;	// 4 pixel border on right
			_infoText.height = HEIGHT - _infoText.y;
			addChild(_infoText);
			_buttons = new Sprite();		// holds  buttons if they are required
			addChild(_buttons);
			_width = WIDTH;
			_height = HEIGHT;
			_timer = new Shape();
			addChild(_timer);
		}
		private function drawView():void
		{
			trace("SystemMessageItemView:: drawView:", _itemVO.type );
			if (_icons.hasOwnProperty(_itemVO.type)) {
				var typeClass:Class = _icons[_itemVO.type];
				_icon = new typeClass;
				_icon.width = 32;
				_icon.scaleY = _icon.scaleX;
				_icon.x = 40 - _icon.width / 2;
				_icon.y = _icon.x;
				addChild(_icon);
			}
			if (_itemVO.title) {
				// workaround - for success items use normal colour not highlight (clashes with success icon!)
				if (_itemVO.type == "success") {
					_titleText.colour = Theme.TEXTFACEBOOKFILL;
				}
				_titleText.text = _itemVO.title;
			}
			if (_itemVO.text) {
				_infoText.text = _itemVO.text;
			}
			if (_itemVO.htmlText) {
				_infoText.htmlText = _itemVO.htmlText;
			}
			if (_infoText.textHeight > HEIGHT) {
				trace("SystemMessageItemView:: drawView: changing HEIGHT of textItemView", _infoText.height, _infoText.textHeight );
				_infoText.height = _infoText.textHeight;
			}
			if (_itemVO.buttons) {
				var b:FacebookButton;
				var _vertical:Boolean = false;
				if (_itemVO.buttons.length >= 5) _vertical = true;	// dirty hack, but for 5 buttons or more display as a vertical column (centred)
				var _maxWidth:int = 0;
				for (var i:int = _itemVO.buttons.length; i--; ) {
					if (_itemVO.buttons[i].length > _maxWidth) {
						_maxWidth = _itemVO.buttons[i].length;
					}
				}
				trace("SystemMessageItemView:: drawView:", _maxWidth );
				for (i = _itemVO.buttons.length; i--; ) {
					b = new FacebookButton("facebook", _itemVO.buttons[i], _maxWidth*12 + 24, 32, false);
					if (_vertical) {
						b.y = i * (b.height + 4);
					} else {
						b.x = i * (b.width + 4);
					}
					b.name = _itemVO.buttons[i];
					_buttons.addChild(b);
				}
				if (_vertical) {
					_buttons.x = (WIDTH - _buttons.width) / 2;	// centred
				} else {
					_buttons.x = WIDTH - _buttons.width - 4;	// right-aligned
				}
			}
			_buttons.y = _infoText.y + _infoText.height + 16;	// buttons always appear below other content
			
			// set up the shape which will tween its width to zero (then trigger an event)
			if (_itemVO.timerDelay > 0) {
				_timer.graphics.clear();
				_timer.graphics.beginFill(0x00c000, 0.2);
				_timer.graphics.drawRect(0, 0, WIDTH-8, 4);
				_timer.graphics.endFill();
				_timer.x = 4;
				_timer.y = _buttons.y + _buttons.height + 4;
			}

			// set _height and show backround
			_height = _buttons.y + _buttons.height + 12;
			showGlass();
		}
		
		public function startTimer():void
		{
			trace("SystemMessageItemView:: startTimer:", _itemVO.timerDelay );
			if (_itemVO.timerDelay > 0) {
				TweenLite.to(_timer, _itemVO.timerDelay / 1000, { width:0, onComplete:timerDone } );
			}
		}
		private function timerDone():void
		{
			trace("SystemMessageItemView:: timerDone:" );
			if (_itemVO.buttons && _itemVO.buttons.length > 0) {
				this.name = _itemVO.buttons[0];
			}
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		// PUBLIC GETTER/SETTERS
		
		public function get messageItemVO():SystemMessageItemVO 
		{
			return _itemVO;
		}
		
		public function set messageItemVO(value:SystemMessageItemVO):void 
		{
			_itemVO = value;
			drawView();
		}
		
		public function get messageRequest():SystemMessageRequest 
		{
			return _messageRequest;
		}
		
		public function set messageRequest(value:SystemMessageRequest):void 
		{
			trace("SystemMessageItemView:: messageRequest:", value );
			_messageRequest = value;
			_itemVO = _messageRequest.itemVO;
			drawView();
			
		}
		
	}

}