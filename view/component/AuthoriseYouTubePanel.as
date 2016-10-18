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
	public class AuthoriseYouTubePanel extends XSprite
	{
		private var _connect:FacebookButton;
		private var _infoText:TextField;
		
		public function AuthoriseYouTubePanel() 
		{
			initView();
		}
		
		private function initView():void
		{
			// FB CONNECT BUTTON
			_connect = new FacebookButton("youtube", "Login with YouTube", 240, 32);
			_connect.name = "authorise";
			_connect.x = 2;
			_connect.y = 40;
			addChild(_connect);

			// EXTRA INFO
			_infoText = new TFTextField();
			var css:StyleSheet = new StyleSheet(  ); 
			css.parseCSS("p { font-family: Verdana, Courier New, _serif;  font-size: 11; margin-left:2; leading:4; kerning:true; }  .name {	 color: #3B5998; font-weight: bold;} .system { color:#424040; font-weight: bold; } a { text-decoration:underline; } ");
			_infoText.styleSheet = css;
			_infoText.x = 8;
			_infoText.y = 120;
			_infoText.multiline = true;
			_infoText.wordWrap = true;
			_infoText.textColor = Theme.TEXTSTANDARD;
			_infoText.htmlText = "<p><b>Authorise VideoSwipe to access YouTube</b></p>";
			_infoText.htmlText += "<p></p><p><ul>";
			_infoText.htmlText += "<li>Allow VideoSwipe to retrieve your personal subscriptions</li>";
			_infoText.htmlText += "<li>Browse and watch new videos from your favourite channels</li>";
			_infoText.htmlText += "<li>Build playlists directly from any channel you choose</li>";
			_infoText.htmlText += "<li>Build a master playlist from ALL your channels together!</li>";
			_infoText.htmlText += "</ul></p><p></p><p><b>NOTE:</b> you can <a href='https://security.google.com/settings/security/permissions' target='_blank'>revoke this permission</a> anytime you want</p>";
			addChild(_infoText);
		}
		
		override public function redraw():void
		{
			//trace("ConnectPanel:: redraw:", _width, _height );
			_connect.x = (_width - _connect.width) / 2;
			_infoText.width = _width - 180;
			_infoText.x = 90;
			_infoText.height = _height - _infoText.y - 8;
		}
	}

}