package com.videoswipe 
{
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import com.videoswipe.model.*;
	import com.videoswipe.view.*;
	import com.videoswipe.controller.*;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	* ...
	* @author Dave Keen
	*/
	public class ApplicationFacade extends Facade implements IFacade {
		
		// Notification name constants
		public static const STARTUP:String = "startup";

		public static function getInstance():ApplicationFacade {
			if (instance == null) instance = new ApplicationFacade();
			return instance as ApplicationFacade;
		}
		
		// Register commands with the controller
		override protected function initializeController():void {
			super.initializeController();
			
			registerCommand( STARTUP, StartupCommand );
		}
		
        public function startup( stage:Object ):void
        {
        	sendNotification( STARTUP, stage );
        }

        // Nice function override to trace output of all sendNotifications...
		override public function sendNotification(notificationName:String, body:Object=null, type:String=""):void
		{
			// log this notification - send to server
			// NOTE: only log if this SWF is running 'standalone' not inside a Viewer SWF (otherwise we generate logs for the Viewer)
			// NOTE: we do this BEFORE executing in case further notes are generated during execution
			// ALSO has the benefit of NOT including the initial startup note which is not required in the archive
			CONFIG::standalone {
				var _lnp:LogNotificationsProxy = retrieveProxy( LogNotificationsProxy.NAME ) as LogNotificationsProxy;
				if (_lnp) {
					_lnp.logNotification( notificationName, type, body );
				}
			}

			if (notificationName != "mm") {
				trace("Sent " + notificationName);
			}
			notifyObservers( new Notification( notificationName, body, type ) );
			
		}

	}
	
}