package com.videoswipe.view.component 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class VideoMessagesView extends Sprite
	{
		private static const WIDTH:int = 240;
		private static const HEIGHT:int = 180;
		
		private var _streams:Sprite;
		
		public function VideoMessagesView() 
		{
			_streams = new Sprite();
			addChild(_streams);
		}

		public function addStreamView(_s:StreamView):void
		{
			_s.setSize( WIDTH, HEIGHT );	// display larger than the live stream views
			_streams.addChildAt(_s, 0);
			update();
		}
		public function removeStreamView(_streamName:String):void
		{
			var _s:StreamView;
			for (var i:uint = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				if (_s.streamname == _streamName && _s.destroyMeOnStreamStop()) {
					_s.destroy();
					_streams.removeChild(_s);
					break;
				}
			}
			update();
		}
		public function removeAllMessages():void
		{
			var _s:StreamView;
			while (_streams.numChildren > 0) {
				_s = _streams.getChildAt(0) as StreamView;
				_s.destroy();
				_streams.removeChild(_s);
			}
		}
		public function setItemDuration( _dur:Number ):void
		{
			var _s:StreamView;
			for (var i:uint = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				_s.duration = _dur;
			}
		}

		// playerStateChange
		// this is a 'local' state change - ie it is THIS youTube player which has changed (not a remote client)
		// logic here determines what to do with the video message streams
		public function playerStateChange( _newState:Object ):void
		{
			trace("VideoMessagesView:: playerStateChange:", _newState.state, _newState.dur, _newState.progress );
			var _s:StreamView;
			for (var i:uint = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				_s.state.playerStateChange( _newState );
				_s.state.setDuration( _newState.dur );

				// final extra trick to reset timers when any stream paused
				// ensures flashing paused bars are all synchronised
				if (_newState.state == 2) {
					_s.state.synchroniseTimer();
				}
			}
		}
		public function playStreams():void
		{
			trace("VideoMessagesView:: playStreams:" );
			var _s:StreamView;
			for (var i:int = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				_s.netStream.resume();
			}
		}
		public function pauseStreams():void
		{
			trace("VideoMessagesView:: pauseStreams:" );
			var _s:StreamView;
			for (var i:int = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				_s.netStream.pause();
			}
		}
		public function seekTo( _p:Number ):void
		{
			var _s:StreamView;
			for (var i:int = _streams.numChildren; i--; ) {
				_s = _streams.getChildAt(i) as StreamView;
				_s.netStream.seek( _p );
			}
		}
		public function connectionClosed():void
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
			var _nMessages:int = Math.floor(800 / WIDTH );
			for (var i:uint = _streams.numChildren; i--; ) {
				_streams.getChildAt(i).x = (WIDTH + 2) * (i % _nMessages);
				_streams.getChildAt(i).y = Math.floor(i / _nMessages) * (HEIGHT + 8);
			}
		}
	}
}