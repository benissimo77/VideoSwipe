/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.view.component.NetConnectionView;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class NetConnectionMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "NetConnectionMediator";
		
		// cache a copy of the proxy
		private var _ncp:NetConnectionProxy;
		
		public function NetConnectionMediator(viewComponent:Object) {
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
			return NetConnectionMediator.NAME;
		}
        
		override public function onRegister():void {
			trace("NetConnectionMediator:: onRegister:" );
			netConnectionView.addEventListener(MouseEvent.CLICK, ConnectOrDisconnect);
			
			_ncp = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
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
				NetConnectionProxy.CONNECTSUCCESS,
				NetConnectionProxy.CONNECTIONCLOSED,
				AppConstants.FACEBOOKUSERINFO
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
				
				case NetConnectionProxy.CONNECTSUCCESS:
					trace("NetConnectionMediator:: handleNotification: NetConnectionProxy.CONNECTSUCCESS" );
					netConnectionView.setStatus( AppConstants.ONLINE );
					break;
					
				case NetConnectionProxy.CONNECTIONCLOSED:
					trace("NetConnectionMediator:: handleNotification: NetConnectionProxy.CONNECTIONCLOSED" );
					netConnectionView.setStatus( AppConstants.OFFLINE );
					break;

				case AppConstants.FACEBOOKUSERINFO:
					trace("NetConnectionMediator:: handleNotification: FACEBOOKUSERINFO" );
					_ncp.setUserInfo( note.getBody() as FacebookVO );
					if (ExternalInterface.available) {
						_ncp.connect();
					} else {
						_ncp.serverMoveToRoom("videoswipe/" + _ncp.vo.uid);
						//_ncp.connect();
					}
					
				default:
					break;
			}
		}

		private function ConnectOrDisconnect(e:MouseEvent):void
		{
			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			if (e.target.name == "connect") {
				if (netConnectionView.status == AppConstants.OFFLINE) {
					netConnectionView.setStatus( AppConstants.CONNECTING );
					ncp.connect();
				} else {
					netConnectionView.setStatus( AppConstants.OFFLINE );
					ncp.disconnect();
				}
			}
		}

		private function get netConnectionView():NetConnectionView
		{
			return viewComponent as NetConnectionView;
		}
	}
}