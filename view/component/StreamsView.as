package com.videoswipe.view.component 
{
	import com.facebook.graph.net.FacebookBatchRequest;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author 
	 */
	public class StreamsView extends Sprite
	{
		private var _streams:Sprite;
		private var _leaveButton:FacebookButton;
		
		public function StreamsView() 
		{
			_streams = new Sprite();
			addChild(_streams);
			_leaveButton = new FacebookButton("facebook", "EXIT ROOM", 90, 24, false);
			_leaveButton.name = "leave";
			_leaveButton.visible = false;	// defaults to not showing button
			addChild(_leaveButton);
		}

		// makeInvisibleIfUserAlone
		// if user on their own then make their cam view invisible after some inactivity
		public function makeInvisibleIfUserAlone():void
		{
			if (_streams.numChildren == 1) {
				// we have a single person, if streaming then keep this component visible, else invisible
				var _sv:StreamView = _streams.getChildAt(0) as StreamView;
				this.visible = _sv.streaming;
			}
		}
		public function makeVisibleIfUserAlone():void
		{
			if (_streams.numChildren == 1) {
				var _sv:StreamView = _streams.getChildAt(0) as StreamView;
				this.visible = true;
			}
		}
		public function addStreamView(_s:StreamView):void
		{
			_streams.addChildAt(_s, 0);
//			_s.addEventListener(MouseEvent.CLICK, videoClick);
			update();
		}
		public function removeStreamView(_streamName:String):void
		{
			var _s:StreamView;
			for (var i:uint = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				if (_s.streamname == _streamName && _s.destroyMeOnStreamStop()) {
					_s.removeEventListener(MouseEvent.CLICK, videoClick);
					_s.destroy();
					_streams.removeChild(_s);
					break;
				}
			}
			update();
		}
		
		// userConnected
		// inLounge flag holds if user is in lounge or a private room
		// EXIT ROOM button is shown/hidden based on this flag
		public function userConnected(_inLounge:Boolean):void
		{
			_leaveButton.visible = !_inLounge;
		}
		
		// playerStateChange
		// fn called when either local player or any remote player changes state
		// slightly more logic to determine if local player or remote player
		// for local player we update duration of the current video
		// for remote player we update state of this players' synchro
		public function playerStateChange( _newState:Object ):void
		{
			var _s:StreamView;
			for (var i:uint = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				if (_newState.token) {
					if (_s.streamname == _newState.token) {
						_s.state.playerStateChange( _newState );
					}
				} else {
					// if token is null then state object comes from this player - still useful for duration of clip
					if (_newState.dur) {
						_s.state.setDuration( _newState.dur );
					}
				}
				// final extra trick to reset timers when any stream paused
				// ensures flashing paused bars are all synchronised
				if (_newState.state == 2) {
					_s.state.synchroniseTimer();
				}
			}
		}
		public function removeAllStreams():void
		{
			var _s:StreamView;
			for (var i:uint = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				_s.destroy();
				_streams.removeChild(_s);
			}
			update();
		}
		private function update():void
		{
			trace("StreamsView:: update:" );
			for (var i:uint = _streams.numChildren; i--; ) {
				_streams.getChildAt(i).x = 162 * i;
			}
			_streams.x = _streams.width / -2;

			_leaveButton.x = _streams.x + _streams.width + 8;
			_leaveButton.y = (_streams.height - _leaveButton.height) / 2;
			// extra hack to ensure button disappears instantly when user leaves room
			if (_streams.numChildren == 0) {
				_leaveButton.visible = false;
			}
		}

		// videoClick
		// called when one of the streamviewers is clicked (place clicked stream into large position)
		private function videoClick(e:MouseEvent):void {
			trace("StreamsMediator:: videoClick: hello  " + e.currentTarget);
			var i:uint = _streams.getChildIndex(e.currentTarget as StreamView);
			_streams.swapChildrenAt(i, 0);
		}
	}
}