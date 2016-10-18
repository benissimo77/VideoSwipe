/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.view.component.HelpSlideView;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.*;
	
	/**
	 * A Mediator
	 */
	public class HelpSlideMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "HelpSlideMediator";

		private var _helpSlideTimer:Timer;
		
		public function HelpSlideMediator(viewComponent:Object) {
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
			return HelpSlideMediator.NAME;
		}
        
		override public function onRegister():void {
			helpSlideView.addEventListener(MouseEvent.CLICK, helpSlideClicked);
			_helpSlideTimer = new Timer(12000, 1);
			_helpSlideTimer.addEventListener(TimerEvent.TIMER_COMPLETE, helpSlideDone);
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
					AppConstants.HELPSLIDE
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
				
				case AppConstants.HELPSLIDE:
					trace("HelpSlideMediator:: handleNotification: HELPSLIDE" );
					helpSlideView.showSlide( note.getBody() );
					_helpSlideTimer.reset();
					_helpSlideTimer.start();
					break;
					
				default:
					break;		
			}
		}

		private function helpSlideClicked(e:MouseEvent = null):void
		{
			if (e.target.name == "done") {
				helpSlideDone();
			}
		}
		private function helpSlideDone(e:TimerEvent = null):void
		{
			_helpSlideTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, helpSlideDone);
			helpSlideView.visible = false;
			sendNotification( AppConstants.HELPSLIDEDONE );
		}
		private function get helpSlideView():HelpSlideView
		{
			return viewComponent as HelpSlideView
		}
	}
}