/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.greensock.loading.core.DisplayObjectLoader;
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.view.component.VideoSwipeView;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.*;
	
	/**
	 * A Mediator
	 */
	public class SwipeViewMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "SwipeViewMediator";
		
		public function SwipeViewMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		override public function onRegister():void
		{
			// simulate a facebook login which will set up the user info
			var _f:FacebookVO = new FacebookVO( { uid:"xxx", username:"LogViewer" } );
			var _fgp:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
			_fgp.vo = _f;
			var _ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
			_ncp.setUserInfo( _f );
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
			return SwipeViewMediator.NAME;
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
				AppConstants.MOUSEMOVE
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

				case AppConstants.MOUSEMOVE:
					trace("SwipeViewMediator:: handleNotification: MOUSEMOVE" );
					swipeView.mouseMove( note.getBody().x, note.getBody().y );
					break;
					
				default:
					break;		
			}
		}

		private function get swipeView():VideoSwipeView
		{
			return viewComponent as VideoSwipeView
		}
	}
}