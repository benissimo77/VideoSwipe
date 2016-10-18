package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.LogItemVO;
	import fl.controls.TextArea;
	import flash.display.Sprite;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author 
	 */
	public class AllLogsItemView extends GlassSprite
	{
		private var _item:Object;
		private var _name:TFTextField;
		private var _type:TFTextField;
		private var _body:TFTextField;
		
		public function AllLogsItemView( _i:Object = null) 
		{
			//trace("LogItemView:: LogItemView:" );
			initView();
			_width = 400;
			_height = 20;
			if (_i) item = _i;
		}
		
		private function initView():void
		{
			//trace("LogItemView:: initView:" );
			_name = new TFTextField("facebook");
			_name.autoSize = TextFieldAutoSize.NONE;
			_name.multiline = false;
			_name.width = 120;
			addChild(_name);
			_type = new TFTextField("facebook");
			_type.multiline = false;
			_type.width = 28;
			addChild(_type);
			_body = new TFTextField("facebook");
			_body.autoSize = TextFieldAutoSize.NONE;
			_body.width = 256;
			_body.multiline = false;
			addChild(_body);
		}
		private function drawView():void
		{
			//trace("LogItemView:: drawView:" );
			_name.text = _item.timestamp;
			if (_item.duration) _type.text = _item.duration;
			_type.x = 122;
			if (_item.uid) _body.text = _item.uid;
			_body.x = 142;
			
			if (_item.name == "facebookuserinfo") {
				trace("LogItemView:: drawView:", _body.text, _item.body.toString() );
			}
			
		}
		private function set item( _i:Object ):void
		{
			_item = _i;
			drawView();
		}
		
		public function set selected( s:Boolean):void
		{
			if (s) {
				showGlass();
			} else {
				hideGlass();
			}
		}
		
		public function get body():String 
		{
			return _body.text;
		}
	}

}