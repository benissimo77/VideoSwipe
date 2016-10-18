package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class ConnectionLight extends Sprite
	{
		[Embed(source = 'assets/led-green.png')]
		private var LedGreen:Class;
		[Embed(source = 'assets/led-grey.png')]
		private var LedGrey:Class;
		[Embed(source = 'assets/led-orange.png')]
		private var LedOrange:Class;

		private var _offline:Bitmap;
		private var _connecting:Bitmap;
		private var _online:Bitmap;
		private var _timer:Timer;

		public function ConnectionLight() 
		{
			initView();
		}
		
		private function initView():void
		{
			_offline = new LedGrey;
			_connecting = new LedOrange;
			_online = new LedGreen;
			addChild(_offline);
			addChild(_connecting);
			addChild(_online);
			_timer = new Timer(500);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			setStatus(AppConstants.OFFLINE);
		}
		
		public function setStatus(s:int):void
		{
			_offline.visible = false;
			_online.visible = false;
			_connecting.visible = false;
			_timer.stop();
			if (s == AppConstants.OFFLINE) {
				_offline.visible = true;
			}
			if (s == AppConstants.CONNECTING) {
				_offline.visible = true;
				_connecting.visible = true;
				_timer.start();
			}
			if (s == AppConstants.ONLINE) {
				_online.visible = true;
			}
		}
		
		private function timerHandler(e:TimerEvent):void
		{
			if (_connecting.visible) {
				_connecting.visible = false;
			} else {
				_connecting.visible = true;
			}
		}
	}

}