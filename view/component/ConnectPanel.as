package com.videoswipe.view.component 
{
	import flash.external.ExternalInterface;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author 
	 */
	public class ConnectPanel extends XSprite
	{
		private var _connect:FacebookButton;
		private var _connectAnonymous:FacebookButton;
		private var _linkText:TFTextField;
		private var _infoText:TextField;
		
		public function ConnectPanel() 
		{
			initView();
		}
		
		private function initView():void
		{
			// FB CONNECT BUTTON
			_connect = new FacebookButton("facebook", "Login with Facebook", 200, 26);
			_connect.name = "connect";
			_connect.x = 2;
			_connect.y = 160;
			addChild(_connect);

			// OR
			var _orText:TFTextField = new TFTextField();;
			_orText.bold = true;
			_orText.text = "OR";
			_orText.x = 120;
			_orText.y = 120;
			//addChild(_orText);
			
			// REMAIN ANONYMOUS TEXT
			var _anonymous:TFTextField = new TFTextField("facebook");
			_anonymous.size = 18;
			_anonymous.text = "Connected as Guest";
			_anonymous.x = 36;
			_anonymous.y = 24;
			addChild(_anonymous);
			
			// CONNECT ANONYMOUS
			_connectAnonymous = new FacebookButton("videoswipe", "Connect as Guest", 200, 26, true );
			_connectAnonymous.name = "connectAsGuest";
			_connectAnonymous.x = 2;
			_connectAnonymous.y = 24;
			if (!ExternalInterface.available) {
				addChild(_connectAnonymous);
			}
			
			// LINK BOX
			_linkText = new TFTextField();
			_linkText.autoSize = TextFieldAutoSize.NONE;
			_linkText.backgroundColor = 0xffffff;
			_linkText.x = 24;
			_linkText.y = 162;
			_linkText.multiline = true;
			_linkText.wordWrap = true;
			_linkText.width = 240;
			_linkText.height = 60;
			_linkText.border = true;
			//addChild(_linkText);
			
			// EXTRA INFO
			_infoText = new TFTextField();
			var css:StyleSheet = new StyleSheet(  ); 
			css.parseCSS("p { font-family: Verdana, Courier New, _serif;  font-size: 10; margin-left:2; leading:2; kerning:true; }  .name {	 color: #3B5998; font-weight: bold;} .system { color:#424040; font-weight: bold; } ");
			_infoText.styleSheet = css;
			_infoText.x = 8;
			_infoText.y = 220;
			_infoText.multiline = true;
			_infoText.wordWrap = true;
			_infoText.textColor = Theme.TEXTSTANDARD;
			_infoText.htmlText = "<p><b>Guest User</b></p>";
			_infoText.htmlText += "<p><ul>";
			_infoText.htmlText += "<li>Watch videos together with friends</li>";
			_infoText.htmlText += "<li>Use webcam, chat and synchro-features</li>";
			_infoText.htmlText += "</ul></p>";
			_infoText.htmlText += "<p><b>Login with Facebook</b></p>";
			_infoText.htmlText += "<p><ul>";
			_infoText.htmlText += "<li>Save playlists to watch later</li>";
			_infoText.htmlText += "<li>Post playlists to your wall</li>";
			_infoText.htmlText += "<li>Send playlists to friends through facebook or email</li>";
			_infoText.htmlText += "<li>See who's online NOW and invite them to join you!</li>";
			//_infoText.htmlText += "<li>Send messages to friends and friendlists</li>";
			_infoText.htmlText += "</ul></p>";
			addChild(_infoText);
		}
		
		public function set linktext(_s:String):void
		{
			_linkText.text = _s;
		}
		override public function redraw():void
		{
			//trace("ConnectPanel:: redraw:", _width, _height );
			_connect.x = (_width - _connect.width) / 2;
			_connectAnonymous.x = (_width - _connectAnonymous.width) / 2;
			_linkText.width = _width - 48;
			_infoText.width = _width - 16;
			_infoText.height = _height - _infoText.y - 8;
		}
	}

}