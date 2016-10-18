package com.videoswipe.view.component 
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author 
	 */
	public class AnchorTextField extends TextField
	{
		private var _tf:TextFormat;
		
		public function AnchorTextField() 
		{
			applyTextFormat(TF.defaultTF);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		public function applyTextFormat(_t:TextFormat):void
		{
			_tf = _t;
			this.setTextFormat(_t);
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