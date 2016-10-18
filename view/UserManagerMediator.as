/*
 Mediator - PureMVC
 */
package com.videoswipe.view
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.UserManagerProxy;
	import flash.display.Sprite;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.component.*;
	
	/**
	 * UserManagerMediator
	 * (c) 2013 Ben Silburn
	 */
	public class UserManagerMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "UserManagerMediator";
		
		private var _ump:UserManagerProxy;	// cache the proxy for ease

		public function UserManagerMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		override public function onRegister():void {
			_ump = facade.retrieveProxy( UserManagerProxy.NAME ) as UserManagerProxy;
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
			return UserManagerMediator.NAME;
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
				AppConstants.FACEBOOKUSERINFO,
				AppConstants.FACEBOOKREQUESTSENT
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
				
				case AppConstants.FACEBOOKUSERINFO:
					trace("UserManagerMediator:: handleNotification: FACEBOOKUSERINFO" );
					_ump.userIdentified( note.getBody() );
					break;

				case AppConstants.FACEBOOKREQUESTSENT:
					trace("UserManagerMediator:: handleNotification: FACEBOOKREQUESTSENT" );
					_ump.storeUserInvitation( note.getBody() );
					
					
				default:
					break;		
			}
		}

		private function get stage():Sprite
		{
			return viewComponent as Sprite
		}
	}
}