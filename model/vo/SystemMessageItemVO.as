package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * (c) Ben Silburn
	 */
	public class SystemMessageItemVO 
	{
		public static const INVITE:String = "Invite";
		public static const SUCCESS:String = "Success";
		public static const ERROR:String = "Error";
		public static const WARNING:String = "Warning";
		
		
		private var _type:String;	// the message type, INVITE, SUCCESS, ERROR or WARNING
		private var _title:String;	// title for this message (displayed large size)
		private var _text:String;
		private var _htmlText:String;
		private var _buttons:Array;
		private var _timerDelay:int;	// length of time before auto-remove (0 = no timer)
		private var _data:Object;		// generic holder for extra info if needed
		
		public function SystemMessageItemVO( _msgtype:String = null, _title:String=null, _t:String = null, _h:String = null, _b:Array = null, _delay:int = 0, _d:Object = null )
		{
			if (_msgtype) type = _msgtype;
			if (_title) title = _title;
			if (_t) text = _t;
			if (_h) htmlText = _h;
			if (_b) buttons = _b;
			if (_d) data = _d;
			timerDelay = _delay;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function set type(value:String):void 
		{
			_type = value;
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			_text = value;
		}
		public function get htmlText():String 
		{
			return _htmlText;
		}
		
		public function set htmlText(value:String):void 
		{
			_htmlText = value;
		}
		
		public function get buttons():Array 
		{
			return _buttons;
		}
		
		public function set buttons(value:Array):void 
		{
			_buttons = value;
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
		public function set data(value:Object):void 
		{
			_data = value;
		}
		
		public function get timerDelay():int 
		{
			return _timerDelay;
		}
		
		public function set timerDelay(value:int):void 
		{
			_timerDelay = value;
		}
		
		public function get title():String 
		{
			return _title;
		}
		
		public function set title(value:String):void 
		{
			_title = value;
		}
		
		
	}

}