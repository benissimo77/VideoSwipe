package com.videoswipe.view.component 
{
	import com.greensock.TweenLite;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * (c) Ben Silburn
	 * 
	 * SystemMessageView
	 * general purpose sprite to display system messages in a consistent style/format
	 * class handles rapid addition of several status messages, will gracefully display them for a period before removing them
	 * fades out and becomes invisible after DISPLAYTIME has passed
	 * 
	 * Accepts a message TYPE: WARNING, ERROR, TIP
	 * displays a relevant icon to highlight the message type
	 */
	public class SystemMessageView extends Sprite
	{
		private const DISPLAYTIME:int = 3000;
		
		private var _nextY:int;

		public function SystemMessageView() 
		{
			trace("SystemMessageView:: SystemMessageView:" );
			_nextY = 0;
		}
		
		public function addMessage(_item:SystemMessageItemView):void
		{
			addChild(_item);
			_item.y = _nextY;
			_nextY = _item.y + _item.height;
			if (numChildren == 1) _item.startTimer();
		}

		public function removeMessage(_item:SystemMessageItemView):void
		{
			var _n:int = getChildIndex(_item);
			var _height:int = _item.height;
			TweenLite.killTweensOf(_item);
			removeChild(_item);
			_nextY -= _height;
			for (var i:int = _n; i<numChildren; i++ ) {
				var _starty:int = getChildAt(i).y;
				TweenLite.killTweensOf(getChildAt(i));
				TweenLite.to(getChildAt(i), 0.5, { y: _starty-_height } );
			}
			if (_n==0 && numChildren > 0) startTimer();
			
		}
		private function startTimer():void
		{
			var _item:SystemMessageItemView = getChildAt(0) as SystemMessageItemView;
			//_timer.delay = _item.messageItemVO.timerDelay;
			//trace("SystemMessageView:: startTimer:", _timer.delay );
			//if (_timer.delay > 0) _timer.start();
			_item.startTimer();
		}
	}

}