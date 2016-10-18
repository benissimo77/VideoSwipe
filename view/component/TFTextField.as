package com.videoswipe.view.component 
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author 
	 */
	public class TFTextField extends TextField
	{
		private var _tf:TextFormat;

		public function TFTextField(_style:String = "default") 
		{
			switch (_style) {
				
				case "youtube":
					_tf = TF.defaultTF;
					break;
					
				case "facebook":
					_tf = TF.facebookTF;
					this.embedFonts = true;
					break;
					
				case "help":
					_tf = TF.helpSlideTF;
					this.embedFonts = true;
					break;
					
				case "subscriptionitem":
					_tf = TF.defaultTF;
					break;
					
				default:
					_tf = TF.defaultTF;
			}
			this.antiAliasType = AntiAliasType.ADVANCED;
			this.defaultTextFormat = _tf;
			this.selectable = true;
			this.autoSize = TextFieldAutoSize.LEFT;
			this.addEventListener( KeyboardEvent.KEY_DOWN, keyHandler );
		}

		// setters implement basic text-formatting functionality
		public function set anchor(b:Boolean):void
		{
			if (b) {
				_tf.color = TF.anchorColour;
				_tf.bold = true;
				this.selectable = false;
				this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			} else {
				_tf.color = TF.defaultColour;
				_tf.bold = false;
				this.selectable = true;
				this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			}
			this.setTextFormat(_tf);
		}
		public function set size(i:int):void
		{
			_tf.size = i;
			this.setTextFormat(_tf);
		}
		public function set h1(b:Boolean):void
		{
			if (b) {
				size = TF.headerSize;
			} else {
				size = TF.defaultSize;
			}
		}
		public function set small(b:Boolean):void
		{
			if (b) {
				size = TF.smallSize;
			} else {
				size = TF.defaultSize;
			}
		}
		public function set colour(i:uint):void
		{
			_tf.color = i;
			this.setTextFormat(_tf);
		}
		public function set bold(b:Boolean):void
		{
			if (b) {
				_tf.bold = true;
			} else {
				_tf.bold = false;
			}
			this.setTextFormat(_tf);
		}
		public function set font(f:String):void
		{
			_tf.font = f;
			this.setTextFormat(_tf);
		}
		

		override public function set text(s:String):void
		{
			super.text = s;
			this.setTextFormat( _tf );
		}
		public function set maxwidth(i:int):void
		{
			if (this.width > i) {
				super.width = i;
			}
		}
		// we catch keypresses so they don't bubble up to the stage and trigger commands
		private function keyHandler(e:KeyboardEvent):void
		{
			e.stopPropagation();
		}
		private function mouseOver(e:MouseEvent):void
		{
			_tf.underline = true;
			this.setTextFormat(_tf);
		}
		private function mouseOut(e:MouseEvent):void
		{
			_tf.underline = false;
			this.setTextFormat(_tf);
		}
		
	}

}