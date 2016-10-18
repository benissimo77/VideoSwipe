/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.LogNotificationsProxy;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.SubscriptionListVO;
	import com.videoswipe.model.vo.SubscriptionVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import com.videoswipe.model.YouTubeOAuthProxy;
	import com.videoswipe.model.YouTubeV3Proxy;
	import com.videoswipe.view.component.SubscriptionItemView;
	import com.videoswipe.view.component.SubscriptionListView;
	import com.videoswipe.view.component.SubscriptionView;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class SubscriptionsMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		private static const NAME:String = "SubscriptionsMediator";
		
		public function SubscriptionsMediator(viewComponent:Object) {
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
			return NAME;
		}
        
		override public function onRegister():void {
			trace("SubscriptionsMediator:: onRegister: hello"  );
			subscriptionListView.addEventListener( MouseEvent.CLICK, clickHandler);
			subscriptionListView.addEventListener( AppConstants.CLIENTADDTOPLAYLIST, addToPlaylist);
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
				AppConstants.USERSUBSCRIPTIONRESULT
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
				
				case AppConstants.USERSUBSCRIPTIONRESULT:
					trace("SubscriptionsMediator:: handleNotification: USERSUBSCRIPTIONRESULT" );
					subscriptionListView.addSubscription(note.getBody() as SubscriptionVO);
					break;
					
				default:
					break;
			}
		}

		private function addToPlaylist(e:Event):void
		{
			var _v:SubscriptionItemView = e.target as SubscriptionItemView;
			trace("FeedMediator:: addToPlaylist:", _v.videoItemVO.videoID);
			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			ncp.clientAddToPlaylist( _v.videoItemVO );
		}
		
		private function clickHandler(e:MouseEvent):void
		{
			trace("SubscriptionsMediator:: clickHandler:", e.target.name );
			var _plp:PlaylistProxy = facade.retrieveProxy( PlaylistProxy.NAME ) as PlaylistProxy;
			var _subView:SubscriptionView;
			var _subVO:SubscriptionVO;
			var _playlistVO:PlaylistVO;
			var _videoItemVO:VideoItemVO;
			
			switch (e.target.name) {
				
				case "delete":
					// add a new playlist from the list here...
					break;
					
				case "channel":
					_subView = e.target.parent as SubscriptionView;
					_subVO = _subView.subscriptionVO;
					_playlistVO = new PlaylistVO();
					_playlistVO.title = _subVO.title + " Playlist";
					_playlistVO.playlistItems = _subVO.videoItems;
					_plp.setPlaylist(_playlistVO);
					break;
					
				case "playall":
					_playlistVO = new PlaylistVO();
					_playlistVO.title = "My Channels Playlist";
					var _ytp:YouTubeV3Proxy = facade.retrieveProxy( YouTubeV3Proxy.NAME ) as YouTubeV3Proxy;
					var _subListVO:SubscriptionListVO = _ytp.subscriptionList;
					var _itemsFromEachChannel:int = Math.ceil(60 / _subListVO.list.length);	// 12 channels = 5 per channel
					var _index:int = 0;	// calculate index into subscription list for selected video
					for (var j:int = _itemsFromEachChannel; j-- > 0; ) {
						for (var i:int = _subListVO.list.length; i-- > 0; ) {
							_subVO = _subListVO.list[i];
							// calculate next item _index based on list length and items from each channel
							_index = Math.floor( j * _subListVO.list.length / _itemsFromEachChannel );
							if (_subListVO.list.length < j) {
								_index = j;
							}
							if (_subVO.videoItems.length > _index) {
								_videoItemVO = _subVO.videoItems[_index];
								if (_videoItemVO.videoID) {
									_playlistVO.addPlaylistItem( _videoItemVO );
								}
							}
						}
					}
					_plp.setPlaylist(_playlistVO);
					break;
					
				case "authorise":
					sendNotification( AppConstants.LOGAUTHORISEYOUTUBE );
					var _oauth:YouTubeOAuthProxy = facade.retrieveProxy( YouTubeOAuthProxy.NAME ) as YouTubeOAuthProxy;
					_oauth.requestToken();
					break;

			}
		}
		
		private function get subscriptionListView():SubscriptionListView
		{
			return viewComponent as SubscriptionListView
		}
	}
}