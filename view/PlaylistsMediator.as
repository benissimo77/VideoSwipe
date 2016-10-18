/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.vo.PlaylistsVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.view.component.PlaylistsItemView;
	import com.videoswipe.view.component.VideoItemView;
	import com.videoswipe.view.component.PlaylistsView;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class PlaylistsMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		private static const NAME:String = "PlaylistsMediator";
		
		public function PlaylistsMediator(viewComponent:Object) {
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
			trace("PlaylistsMediator:: onRegister: hello.");
			playlistsView.addEventListener( AppConstants.CLIENTLOADPLAYLIST, loadPlaylist );
			playlistsView.addEventListener( MouseEvent.CLICK, clickHandler);
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
				AppConstants.PLAYLISTSLOADED,
				AppConstants.PLAYLISTUPDATED
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
				
				case AppConstants.PLAYLISTSLOADED:
					trace("PlaylistsMediator:: handleNotification: PLAYLISTSLOADED", note.getBody() );
					playlistsView.playlistsVO = new PlaylistsVO( note.getBody() );
					break;
					
				case AppConstants.PLAYLISTUPDATED:
					trace("PlaylistsMediator:: handleNotification: PLAYLISTUPDATED" );
					playlistsView.updatePlaylist( note.getBody() as PlaylistVO );
					break;
					
				// note: this is no longer used, playlist deleted immediately (see below)
				case AppConstants.PLAYLISTDELETED:
					trace("PlaylistsMediator:: handleNotification: PLAYLISTDELETED", note.getBody() );
					playlistsView.deletePlaylist( note.getBody() as String );
					break;
					
				default:
					break;		
			}
		}

		private function loadPlaylist(e:Event):void
		{
			var _v:PlaylistsItemView = e.target as PlaylistsItemView;
			trace("PlaylistsMediator:: clientLoadPlaylist:", _v.playlistsItemVO.pid);
			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			ncp.clientLoadPlaylist(_v.playlistsItemVO);
		}
		private function clickHandler(e:MouseEvent):void
		{
			trace("PlaylistsMediator:: clickHandler:", e.target.name );
			
			switch (e.target.name) {
				
				case "delete":
					var _item:PlaylistsItemView = e.target.parent as PlaylistsItemView;
					deletePlaylist(_item.playlistsItemVO);
					break;
					
			}
		}
		
		// this function also immediately deletes the playlist from the view
		// we don't wait for a return note from the proxy to delete this playlist since
		// we might as well delete it (that's what the user wants) and don't need to wait
		// for confirmation of a successsful delete
		private function deletePlaylist(_p:PlaylistVO):void
		{
			var plp:PlaylistProxy = facade.retrieveProxy(PlaylistProxy.NAME) as PlaylistProxy;
			plp.deletePlaylist( _p );
			playlistsView.deletePlaylist( String(_p.pid) );
		}

		private function get playlistsView():PlaylistsView
		{
			return viewComponent as PlaylistsView
		}
	}
}