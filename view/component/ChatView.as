package com.videoswipe.view.component 
{
	import fl.controls.TextInput;
	import fl.events.ComponentEvent;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author 
	 */
	public class ChatView extends GlassSprite
	{
		private var chatBox:TextField;
		public var chatInput:TFTextField;
		public var chatButton:FacebookButton;

		public function ChatView() 
		{
			this.name = "chatView";
			initView();
		}
		
		private function initView():void
		{
			chatBox = new TextField();
			chatBox.multiline = true;
			chatBox.wordWrap = true;
			addChild(chatBox);

			var css:StyleSheet = new StyleSheet(  ); 
			css.parseCSS("p { font-family: Verdana, Courier New, _serif;  font-size: 12; margin-left:2; leading:2; kerning:true; color:#C2C0C0;  }  .name {	 color: #3B5998; font-weight: bold;} .system { color:#626060; font-weight: bold; } ");
			chatBox.styleSheet = css; 

			chatInput = new TFTextField();
			chatInput.autoSize = TextFieldAutoSize.NONE;
			chatInput.type = TextFieldType.INPUT;
			chatInput.size = 22;
			chatInput.height = 24;
			chatInput.border = true;
			addChild(chatInput);
			
			chatButton = new FacebookButton("facebook", "SEND", 60, 24, false);
			addChild(chatButton);
			
			showGlass();
			
			// default just to ensure a basic layout
			setSize(320, 160);
		}

		override public function redraw():void
		{
			chatBox.width = _width;
			chatBox.height = _height - 28;
			chatInput.width = _width - 92;
			chatInput.x = 4;
			chatInput.y = _height - 26;
			chatButton.x = _width - 84;
			chatButton.y = _height - 26;
			chatButton.setSize(80, 24);
			showGlass();
		}

		public function addMessage(msgObj:Object):void
		{

			trace("ChatView:: addMessage:", msgObj.type, msgObj.msg );
			var _message:String = processMessage(msgObj.msg);
			if (msgObj.type == "client") {
				chatBox.htmlText += "<p><span class='name'>" + msgObj.user + ": </span>" + _message + "</p>";
			}
			if (msgObj.type == "server") {
				chatBox.htmlText += "<p><span class='system'>" + _message + "</span></p>";
			}
			
			chatBox.scrollV = chatBox.maxScrollV;
		}
		
		// keyHandler stops event from triggering keyboard shortcuts on stage (eg video play/pause)
		private function keyHandler(e:KeyboardEvent):void
		{
			e.stopPropagation();
		}
		// parses message and turns links into clickable links
		private function processMessage(_s:String):String
		{
			var protocol:String = "((?:http|ftp)://)"; 
			var urlPart:String = "([a-z0-9_-]+\.[a-z0-9_-]+)"; 
			var optionalUrlPart:String = "(\.[a-z0-9_-]*)"; 
			var urlPattern:RegExp = new RegExp(protocol + urlPart + optionalUrlPart, "ig"); 
			var result:String = _s.replace(urlPattern, "<a href='$1$2$3$4$5' target='_new'><u>$1 : $2 : $3 : $4 : $5</u></a>");
			//trace("ChatView:: processMessage:", result );

			var url1:String = "\([a-zA-Z]*://[^ ]*\)\(.*\)";
			var pattern2:RegExp = new RegExp(url1, "ig");
			var result2:String = _s.replace(pattern2, '<a href="$1">$1</a>\$2');
			
			var url3:String = "(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?";
			var pattern3:RegExp = new RegExp(url3, "ig");
			var result3:String = _s.replace(pattern3, '<a href="$1">$1</a>\$2');
			//return result + "<br/>" + result2 + "<br/>" + result3;
			return _s;
		}
	}

}