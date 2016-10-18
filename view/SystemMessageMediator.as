package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import com.videoswipe.view.component.SystemMessageItemView;
	import com.videoswipe.view.component.SystemMessageView;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.*;
	import org.puremvc.as3.patterns.observer.Notification;
	
	/**
	 * A Mediator
	 */
	public class SystemMessageMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "SystemMessageMediator";
		
		public function SystemMessageMediator(viewComponent:Object) {
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
			return SystemMessageMediator.NAME;
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
				AppConstants.ADDSYSTEMMESSAGE,
				AppConstants.INVITERESPONDED
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

			var _s:SystemMessageRequest = note.getBody() as SystemMessageRequest;
			var _item:SystemMessageItemView;

			switch (note.getName()) {
				
				case AppConstants.ADDSYSTEMMESSAGE:
					trace("SystemMessageMediator:: handleNotification:", note.getName() );
					_item = new SystemMessageItemView(_s);
					_item.addEventListener(MouseEvent.CLICK, onMouseClick);
					systemMessageView.addMessage(_item);
					break;
					
				case AppConstants.INVITERESPONDED:
					trace("SystemMessageMediator:: handleNotification: INVITERESPONDED", note.getBody().name );
					for (var i:int = systemMessageView.numChildren; i--; ) {
						_item = systemMessageView.getChildAt(i) as SystemMessageItemView;
						if (_item.messageItemVO.data && _item.messageItemVO.data.uid == note.getBody().uid) {
							trace("SystemMessageMediator:: handleNotification: found ITEM:", note.getBody().uid );
							_item.removeEventListener(MouseEvent.CLICK, onMouseClick);
							systemMessageView.removeMessage(_item);
						}
					}
					break;
					
				default:
					break;
			}
		}
	
		private function onMouseClick(e:MouseEvent = null):void
		{
			trace("SystemMessageMediator:: onMouseClick:", e.currentTarget.name, e.target.name );
			var _item:SystemMessageItemView = e.currentTarget as SystemMessageItemView;
			var _request:SystemMessageRequest = _item.messageRequest;
			// check if the click originated from one of the buttons and NOT the outside glass
			var _found:Boolean = true;
			if (_request.itemVO.buttons && _request.itemVO.buttons.length > 0) {
				_found = false;
				for (var i:int = _request.itemVO.buttons.length; i--; ) {
					if (_request.itemVO.buttons[i] == e.target.name) {
						_found = true;
					}
				}
			}
			if (_found) {
				_item.removeEventListener(MouseEvent.CLICK, onMouseClick);
				systemMessageView.removeMessage(_item);
				var note:Notification = new Notification( new String(e.target.name), _item.messageItemVO );
				if (_request.hasCallback) _request.notifyObserver( note );
				_item = null;
				_request = null;
			}
		}
		private function get systemMessageView():SystemMessageView
		{
			return viewComponent as SystemMessageView;
		}
	}
}