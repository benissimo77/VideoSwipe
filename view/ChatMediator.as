/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.view.component.ChatView;
	import fl.managers.FocusManager;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class ChatMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "ChatMediator";
		
		public function ChatMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		override public function onRegister():void {
			trace("ChatMediator:: onRegister:" );
			chat.chatButton.addEventListener(MouseEvent.CLICK, newMessage);
			chat.chatInput.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
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
			return ChatMediator.NAME;
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
				AppConstants.SERVERNEWCHATMESSAGE
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
				
				case AppConstants.SERVERNEWCHATMESSAGE:
					chat.addMessage(note.getBody());
					break;
					
				default:
					break;		
			}
		}

		private function keyHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == 13) {
				newMessage();
			}
		}
		private function newMessage(e:Event=null):void
		{
			trace("ChatMediator:: newMessage:", chat.chatInput.text );
			if (chat.chatInput.text) {
				var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
				ncp.clientNewChatMessage(chat.chatInput.text);
				chat.chatInput.text = "";
			}
		}

		private function get chat():ChatView
		{
			return viewComponent as ChatView
		}
	}
}