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
	public class LogItemView extends GlassSprite
	{
		private var _item:LogItemVO;
		private var _name:TFTextField;
		private var _type:TFTextField;
		private var _body:TFTextField;
		
		public function LogItemView( _i:Object = null) 
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
			_name.width = 140;
			addChild(_name);
			_type = new TFTextField("facebook");
			_type.multiline = false;
			//addChild(_type);
			_body = new TFTextField("facebook");
			_body.autoSize = TextFieldAutoSize.NONE;
			_body.width = 256;
			_body.multiline = false;
			addChild(_body);
		}
		private function drawView():void
		{
			//trace("LogItemView:: drawView:" );
			_name.text = _item.name;
			if (_item.type) _type.text = _item.type;
			_type.x = 120;
			if (_item.body) _body.text = JSON.stringify(_item.body).substr(0,48);
			_body.x = 142;			
		}
		private function set item( _i:Object ):void
		{
			_item = new LogItemVO( _i );
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
			return JSON.stringify(_item.body);
		}
	}

}