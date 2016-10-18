/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.ControlBarEvent;
	import com.videoswipe.view.component.YouTubeViewer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class YouTubeMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "YouTubeMediator";

		private var _ncp:NetConnectionProxy;
		private var _videoCache:String = null;	// cache the requested video if player not yet ready
		private var _playTimer:Timer;			// once a video has been playing for 10 seconds we trigger a 'definitely playing' action
		private var _cueWhenReady:Boolean;		// allows 'cue' functionality - pause player and indicate item cued - server then synchro starts when everyone cued
		
		public function YouTubeMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return YouTubeMediator.NAME;
		}

		override public function onRegister():void {
			trace("YouTubeMediator:: onRegister: hello.");
			_ncp = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			viewer.addEventListener(Event.INIT, viewerReady);
			_cueWhenReady = false;	// initialise
		}
		
		private function viewerReady(e:Event):void
		{
			trace("YouTubeMediator:: viewerReady:" );
			viewer.removeEventListener(Event.INIT, viewerReady);
			player.addEventListener("onStateChange", onPlayerStateChange);	// youTube player event
			player.addEventListener("onError", onPlayerError);	// youTube player error
			if (_videoCache) {
				_cueWhenReady = true;
				player.loadVideoById(_videoCache);
				_videoCache = null;
			}
			// player.loadVideoById( "6USyWoGJ8OQ" );
			sendNotification( AppConstants.PLAYERREADY, player );
		}

		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [
				AppConstants.SERVERPLAYVIDEOITEM,
				AppConstants.SERVERPLAYCLICKED,
				AppConstants.SERVERPAUSECLICKED,
				AppConstants.SERVERSEEKTO,
				AppConstants.CLIENTPLAYPAUSE,
				AppConstants.PLAYERVOLUME,
				AppConstants.KEYBOARDEVENT
				];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification 
		 */
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {  
				
				// the problem with this note is that if a playlist is loaded on startup the youtube
				// player might not yet be ready...
				// in which case cache the videoID and load it as soon as the player is ready
				case AppConstants.SERVERPLAYVIDEOITEM:
					trace("YouTubeMediator:: handleNotification: SERVERPLAYVIDEOITEM:", note.getBody());
					if (player) {
						_cueWhenReady = true;	// will force a cue event
						player.loadVideoById( note.getBody() as String );
					} else {
						_videoCache = note.getBody() as String;
					}
					if (_playTimer) {
						_playTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, playTimerHandler);
						_playTimer = null;
					}
					_playTimer = new Timer(5000, 1);
					_playTimer.addEventListener(TimerEvent.TIMER_COMPLETE, playTimerHandler);
					break;

				// this command is also sent when player was cued - so cancel the flag
				case AppConstants.SERVERPLAYCLICKED:
					trace("YouTubeMediator:: handleNotification: SERVERPLAYCLICKED" );
					_cueWhenReady = false;
					player.playVideo();
					break;
				case AppConstants.SERVERPAUSECLICKED:
					trace("YouTubeMediator:: handleNotification: SERVERPAUSECLICKED" );
					player.pauseVideo();
					break;
				case AppConstants.SERVERSEEKTO:
					trace("YouTubeMediator:: handleNotification: SERVERSEEKTO:", note.getBody() );
					_cueWhenReady = true;
					player.seekTo( note.getBody() );
					break;

				// this is sent by from an external controller to play/pause the video
				// player state is interrogated and a play/pause request sent to server
				case AppConstants.CLIENTPLAYPAUSE:
					trace("YouTubeMediator:: handleNotification: CLIENTPLAYPAUSE" );
					togglePlayPause();
					break;
					
				case AppConstants.PLAYERVOLUME:
					trace("YouTubeMediator:: handleNotification: PLAYERVOLUME", note.getBody() );
					player.setVolume( note.getBody() as int);
					break;
					
				case AppConstants.KEYBOARDEVENT:
					if (CONFIG::screengrab) {
						viewer.keyHandler( note.getBody() as KeyboardEvent );
					}
					default:
					break;
			}
		}


		// setSize
		// just pass the new size straight through to the loader to size the player and controlbar if there is one
		public function setSize(w:int, h:int):void
		{
			trace("YouTubeMediator:: setSize:", w, h );
			viewer.setSize(w, h);
		}

		private function togglePlayPause():void
		{
				if (player.getPlayerState() == 1) {
					_ncp.clientPauseClicked();
				} else if (player.getPlayerState() == 2) {
					_ncp.clientPlayClicked();
				}
		}
		protected function onPlayerStateChange(event:Event):void {
			// Event.data contains the event parameter, which is the new player state
			var _state:int = Object(event).data;
			trace("YouTubeMediator:: onPlayerStateChange:", _state, player.getCurrentTime() );

			var _sendState:Boolean = true;	// logic decides if we should broadcast this state or not
			
			if (_state == -1) {
				// unstarted
			}
			if (_state == 0) {
				// video item ended (load next item in playlist)
				sendNotification( AppConstants.PLAYERITEMENDED );
			}
			if (_state == 1) {
				
				// video item playing
				// we might now need to pause item, and send an item cued event
				if (_cueWhenReady) {
					player.pauseVideo();
					_state = 5;
				}
				if (_playTimer) {
					trace("YouTubeMediator:: onPlayerStateChange: TIMER starts" );
					_playTimer.reset();
					_playTimer.start();
				}
			}
			if (_state == 2) {
				if (_cueWhenReady) {
					_sendState = false;	// we are not paused, we are cued - waiting for server GO command
				}
				// video item paused
				if (_playTimer) {
					_playTimer.stop();
				}
			}
			if (_state == 3) {
				// buffering
			}
			if (_state == 5) {
				// video item cued
				//sendNotification( AppConstants.PLAYERITEMPLAYING );
			}

			// this first note is 'local' and broadcasts state, duration and progress of this player
			// used by the control bar so we get quick feedback on the state
			// also used by streamsView so all synchro bars get duration of item as soon as it starts playing
			// the line after invokes a SERVERPLAYERSTATECHANGE - which is broadcast to all connected players
			if (_sendState) {
				sendNotification( AppConstants.PLAYERSTATECHANGE, { state:_state, dur:player.getDuration(), progress:player.getCurrentTime() } );
				_ncp.clientPlayerStateChange( _state, player.getCurrentTime() );
			}
			
		}
		protected function onPlayerError(event:Event):void {
			// Event.data contains the event parameter, which is the error code
			trace("YouTubeMediator:: onPlayerError:", Object(event).data);
			sendNotification(AppConstants.PLAYERERROR);
		}

		private function playTimerHandler(e:TimerEvent):void
		{
			trace("YouTubeMediator:: playTimerHandler: DONE!" );
			_playTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, playTimerHandler);
			_playTimer = null;
		}
		// Three levels of getter functions allow us to drill down to the youTube player itself
		private function get viewer():YouTubeViewer
		{
			return viewComponent as YouTubeViewer;
		}
		private function get player():Object
		{
			return viewer.loader.content;
		}
	}
}