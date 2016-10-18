/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.ControlBarEvent;
	import com.videoswipe.view.component.ControlBarView;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.*;
	
	/**
	 * A Mediator
	 */
	public class ControlBarMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ControlBarMediator";
		
		public function ControlBarMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}
		
		override public function onRegister():void {
			trace("ControlBarMediator:: onRegister:" );
			controlBarView.addEventListener( ControlBarEvent.EVENT, handleControlBarEvent );
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
			return ControlBarMediator.NAME;
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
				AppConstants.PLAYERREADY,
				AppConstants.PLAYERSTATECHANGE,
				AppConstants.SERVERSEEKTO
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
				
				case AppConstants.PLAYERREADY:
					trace("ControlBarMediator:: handleNotification: PLAYERREADY" );
					controlBarView.player = note.getBody();
					break;
					
				case AppConstants.PLAYERSTATECHANGE:
					trace("ControlBarMediator:: handleNotification: PLAYERSTATECHANGE" );
					controlBarView.onPlayerStateChange( note.getBody() );
					break;
				
				case AppConstants.SERVERSEEKTO:
					trace("ControlBarMediator:: handleNotification: SERVERSEEKTO" );
					controlBarView.stopScrub();
					break;
					
				default:
					break;		
			}
		}

		private function handleControlBarEvent(e:ControlBarEvent):void
		{
			var _ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
			trace("ControlBarMediator:: handleControlBarEvent:", e.data );
			
			switch (e.event) {
				
				case ControlBarEvent.PLAY:
					_ncp.clientPlayClicked();
					break;
				case ControlBarEvent.PAUSE:
					_ncp.clientPauseClicked();
					break;
				case ControlBarEvent.SEEK:
					_ncp.clientSeekTo( e.data.seekTo );
					break;
				case ControlBarEvent.VOLUME:
					trace("ControlBarMediator:: handleControlBarEvent: VOLUME", e.data.volume);
					sendNotification( AppConstants.PLAYERVOLUME, e.data.volume);
					break;
				case ControlBarEvent.FULLSCREEN:
					sendNotification( AppConstants.PLAYERFULLSCREEN );
					break;
					
			}
		}

		private function get controlBarView():ControlBarView
		{
			return viewComponent as ControlBarView
		}
	}
}