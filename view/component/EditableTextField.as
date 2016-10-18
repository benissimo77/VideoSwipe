package com.videoswipe.view.component 
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * (c) Ben Silburn
	 */
	public class EditableTextField extends TFTextField
	{
		private var _originalText:String;	// cache text when inputting in case user decides to escape and revert to old text
		private var _defaultText:String;	// can display a default string if needed...
		private var _useBorder:Boolean;		// user can set if text always has a border

		public function EditableTextField() 
		{
			super("default");	// can use Facebook font, but currently only alphanumerics are embedded so less useful for user typing
			_defaultText = null;	// don't use default text as standard, only if wanted
			_useBorder = false;		// default to NOT using a border (until entering text)
			this.addEventListener(MouseEvent.CLICK, clickHandler);
			this.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			this.addEventListener(FocusEvent.FOCUS_OUT, textEntered);
			this.multiline = false;
			this.wordWrap = false;
			this.text = "";
			this.height = 22;	// need to explicitly set the height for when we display a border
			this.size = 14;
			this.bold = true;
			//this.h1 = true;
			this.autoSize = TextFieldAutoSize.NONE;	// can't use autosize with editable since width changes with autosize
			setTextToDisplayFormat();
		}

		private function clickHandler(e:MouseEvent=null):void
		{
			//trace("EditableTextField:: clickHandler:" );
			_originalText = this.text;	// cache current text so user can revert by hitting escape
			if (_defaultText && this.text == _defaultText) {
				this.text = "";
			}
			this.type = TextFieldType.INPUT;
			this.border = true;
			this.maxChars = 32;
			this.colour = 0xFFB160;			
		}
		private function keyHandler(e:KeyboardEvent = null):void
		{
			trace("EditableTextField:: keyHandler:", e.keyCode );
			if (e.keyCode == 13) textEntered();
			if (e.keyCode == 27) {
				this.text = _originalText;
				setTextToDisplayFormat();
			}
			e.stopPropagation();	// stop other key handlers from catching these events
		}
		// textDisplay - reverts format of this textfield to standard dynamic format
		private function setTextToDisplayFormat():void
		{
			this.type = TextFieldType.DYNAMIC;
			this.colour = 0xFFB100;			
			this.border = _useBorder;
			this.scrollH = 0;
		}
		private function textEntered(e:Event=null):void
		{
			trace("EditableTextField:: textEntered:" );
			setTextToDisplayFormat();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function set defaultText(value:String):void 
		{
			_defaultText = value;
			this.text = value;
			this.colour = 0x555555;	// display default text faint
		}
		
		public function set useBorder(value:Boolean):void 
		{
			_useBorder = value;
			this.border = value;
		}
	}

}