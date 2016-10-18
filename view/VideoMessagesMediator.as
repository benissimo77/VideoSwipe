/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.view.component.StreamEvent;
	import com.videoswipe.view.component.StreamView;
	import com.videoswipe.view.component.VideoMessagesView;
	import com.videoswipe.view.component.VideoMessageView;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class VideoMessagesMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "VideoMessagesMediator";
		
		public function VideoMessagesMediator(viewComponent:Object) {
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
			return NAME;
		}
        
		override public function onRegister():void {
			trace("VideoMessageMediator:: onRegister: hello.");
			streamsView.addEventListener( StreamEvent.STREAMEVENT, streamEventHandler);
			streamsView.addEventListener( MouseEvent.CLICK, clickHandler );
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
				AppConstants.SERVERPLAYCLICKED,
				AppConstants.SERVERPAUSECLICKED,
				AppConstants.ADDVIDEOMESSAGEVIEW,
				AppConstants.REMOVEALLVIDEOMESSAGES,
				AppConstants.SERVERSEEKTO,
				AppConstants.PLAYERSTATECHANGE
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
			var body:Object = note.getBody();
			switch (note.getName()) {
				
				case AppConstants.ADDVIDEOMESSAGEVIEW:
					trace("VideoMessagesMediator:: handleNotification: ADDVIDEOMESSAGEVIEW" );
					var _s:StreamView = note.getBody() as StreamView;
					streamsView.addStreamView(_s);
					break;
				
				case AppConstants.REMOVEALLVIDEOMESSAGES:
					streamsView.removeAllMessages();
					break;
					
				case AppConstants.SERVERPLAYCLICKED:
					trace("VideoMessageMediator:: handleNotification: SERVERPLAYCLICKED");
					streamsView.playStreams();
					break;
				case AppConstants.SERVERPAUSECLICKED:
					trace("VideoMessagesMediator:: handleNotification: SERVERPAUSECLICKED" );
					streamsView.pauseStreams();
					break;
				case AppConstants.SERVERSEEKTO:
					trace("VideoMessagesMediator:: handleNotification: SERVERSEEKTO:", note.getBody() );
					streamsView.seekTo( note.getBody() as Number);
					break;


				// PLAYERSTATECHANGE
				// important one for synchronising the messages with the main controlbar
				// eg if youTube video paused then all messages must pause
				case AppConstants.PLAYERSTATECHANGE:
					trace("VideoMessagesMediator:: handleNotification: AppConstants.PLAYERSTATECHANGE" );
					streamsView.playerStateChange(body);
					break;
					
				case AppConstants.SERVERPLAYERSTATECHANGE:
					// we DON'T do anything for a SERVERPLAYERSTATECHANGE - that is for remote clients
					// we are only concerned with local changes, synchro with those
					break;

				default:
					break;		
			}
		}
		
		
		// streamEventHandler
		// important function for tranlating the NetStream status codes into 'state' to match the YouTube player
		// this makes the Synchro work similarly if the same system is used for YouTube player and stream players
		private function streamEventHandler( e:StreamEvent):void
		{
			trace("VideoMessagesView:: streamEventHandler:", e.eventName );
			var _sv:StreamView = e.currentTarget as StreamView;
			
			switch (e.eventName) {
				
				// NetStream.Play.Reset
				// new item playing - we need to 'pause' ready for a SYNCHRO event
				case "NetStream.Play.Reset":
					_sv.netStream.pause();
					break;
					
				default:
					break;
					
			}

		}


		private function clickHandler(e:Event):void
		{
			trace("VideoMessageMediator:: clickHandler:", e.target.name);
			
			if (e.target.name == "delete") {
				var _vmv:VideoMessageView = e.target.parent as VideoMessageView;
				streamsView.removeStreamView( _vmv.streamname );
				var _plp:PlaylistProxy = facade.retrieveProxy( PlaylistProxy.NAME ) as PlaylistProxy;
				_plp.removeVideoMessageFromCurrentlyPlayingVideo( _vmv.streamname );
			}
		}
		
		private function get streamsView():VideoMessagesView
		{
			return viewComponent as VideoMessagesView;
		}
	}
}