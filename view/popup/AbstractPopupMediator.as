/*
 Mediator - PureMVC
 */
package com.videoswipe.view.popup 
{
	import com.videoswipe.view.component.GlassSprite;
	import com.videoswipe.view.popup.event.PopupActionEvent;
	import flash.display.Stage;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.popup.*;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * A Mediator
	 */
	public class AbstractPopupMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "AbstractPopupMediator";
		
		// The request is stored temporarily while the popup is alive
		// so that the mediator can notify the caller.
		protected var request:PopupRequest;

		public function AbstractPopupMediator( NAME:String, viewComponent:Object ) {
			super(NAME, viewComponent);
		}

		/**
		* Override in subclass.
		* Just create and the concrete popup.
		*/
		protected function popupFactory():ConfirmationPopup
		{
			return null;
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
			return AbstractPopupMediator.NAME;
		}
        
		/**
		* Called from the handleNotification method when a request notification
		* is received. Creates the popup with popupFactory(), gives it the data
		* from the request, calls setEventInterests to add the listeners, then
		* pops up the popup and optionally centers it.
		*/
		protected function openPopup( ) : void
		{
			var popup:ConfirmationPopup = popupFactory();
			if (popup) {
				popup.setData( request.data );
				setEventInterests( popup );
				// add popup to display list here!!
				stage.addChild(popup);
				if ( request.center ) {
					// centre it here!
				}
			}
		}

		/**
		* Called from openPopup when the request is set, before
		* popping up the popup. Interrogates the popup for the
		* events it will dispatch and sets listeners for each.
		*/
		protected function setEventInterests( popup:IPopup ):void
		{
			for each ( var interest:String in popup.getEvents() ) {
				popup.addEventListener( interest, handlePopupAction, false, 0, true );
			}
		}

		/**
		  * Subclasses will register a single notification interest,
		  * which will be handled here in the same way for all subclasses.
		  */
		override public function listNotificationInterests():Array {
			return [];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * @param INotification a notification 
		 */
		override public function handleNotification( note:INotification ):void
		{
			request = note.getBody() as PopupRequest;
			openPopup( );
		}

		/**
		 * Subclasses will set a single notification interest,
		 * which will be handled here in the same way for all subclasses.
		 * The popup will be closed if specified by the event, and then the
		 * caller will be notified with the PopupEvent and the
		 */
		protected function handlePopupAction( event:PopupActionEvent ):void
		{
			var popup:ConfirmationPopup = event.target as ConfirmationPopup;
			if ( event.closePopup ) removePopup( popup );
			var note:Notification = new Notification( event.type, event );
			if (request.hasCallback) request.notifyObserver( note );
			request = null;
		}

		/**
		 * Called if the PopupActionEvent's closePopup property is true
		 */
		protected function removePopup( popup:ConfirmationPopup ):void
		{
			stage.removeChild(popup);
		//Remove popup from display here!!!
		//PopUpManager.removePopUp( popup );
		}
		
		private function get stage():Stage
		{
			return viewComponent as Stage;
		}
	}
}