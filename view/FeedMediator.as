/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.FeedVO;
	import com.videoswipe.model.FeedProxy;
	import com.videoswipe.view.component.VideoItemView;
	import com.videoswipe.view.component.FeedView;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class FeedMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		private static const NAME:String = "FeedMediator";
		private var _name:String;
		
		public function FeedMediator(viewComponent:Object, name:String) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			_name = name;
			super(name, viewComponent);
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
			return _name;
		}
        
		override public function onRegister():void {
			trace("FeedMediator:: onRegister: hello.");
			feedView.addEventListener( AppConstants.CLIENTADDTOPLAYLIST, addToPlaylist );
			feedView.addEventListener( MouseEvent.CLICK, clickHandler);
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
				AppConstants.FEEDRESULT
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
				
				case AppConstants.FEEDRESULT:
					trace("FeedMediator::", _name, ": handleNotification: ApplicationFacade.FEEDRESULT");
					feedView.feedVO = note.getBody() as FeedVO;
					break;
					
				default:
					break;		
			}
		}

		private function addToPlaylist(e:Event):void
		{
			var _v:VideoItemView = e.target as VideoItemView;
			trace("FeedMediator:: addToPlaylist:", _v.videoItemVO.videoID);
			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			ncp.clientAddToPlaylist( _v.videoItemVO );
		}
		private function clickHandler(e:MouseEvent):void
		{
			trace("FeedMediator:: clickHandler:", e.target.name );
			var fp:FeedProxy;
			if (e.target.name == "nextPage") {
				fp = facade.retrieveProxy(FeedProxy.NAME) as FeedProxy;
				fp.directSearch( feedView.feedVO.nextPage );
			} else if (e.target.name == "previousPage") {
				fp = facade.retrieveProxy(FeedProxy.NAME) as FeedProxy;
				fp.directSearch( feedView.feedVO.previousPage);
			}
		}
		private function get feedView():FeedView
		{
			return viewComponent as FeedView
		}
	}
}