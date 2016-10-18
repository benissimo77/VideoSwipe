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
	public class ViewerFacade extends Facade implements IFacade {
		
		// Notification name constants
		public static const STARTUPVIEWER:String = "startupviewer";

		public static function getInstance():ViewerFacade {
			if (instance == null) instance = new ViewerFacade();
			return instance as ViewerFacade;
		}
		
		// Register commands with the controller
		override protected function initializeController():void {
			super.initializeController();
			
			registerCommand( STARTUPVIEWER, StartupViewerCommand );
		}
		
        public function startup( stage:Object ):void
        {
        	sendNotification( STARTUPVIEWER, stage );
        }

        // Nice function override to trace output of all sendNotifications...
		override public function sendNotification(notificationName:String, body:Object=null, type:String=""):void
		{
			trace("Sent " + notificationName);
			notifyObservers( new Notification( notificationName, body, type ) );
		}

	}
	
}