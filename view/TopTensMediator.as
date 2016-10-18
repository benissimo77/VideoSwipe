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
	import com.videoswipe.view.component.TopTensView;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class TopTensMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		private static const NAME:String = "TopTensMediator";
		
		public function TopTensMediator(viewComponent:Object) {
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
			trace("TopTensMediator:: onRegister: hello"  );
			toptensView.addEventListener( AppConstants.CLIENTLOADPLAYLIST, loadPlaylist );
			toptensView.addEventListener( MouseEvent.CLICK, clickHandler);
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
				AppConstants.TOPTENSLOADED,
				AppConstants.YOUTUBEPLAYLISTSLOADED
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
				
				case AppConstants.TOPTENSLOADED:
					trace("TopTensMediator:: handleNotification: TOPTENSLOADED", note.getBody() );
					toptensView.toptensVO = new PlaylistsVO( note.getBody() );
					break;
					
				// note: this is no longer used, playlist deleted immediately (see below)
				case AppConstants.PLAYLISTDELETED:
					trace("PlaylistsMediator:: handleNotification: PLAYLISTDELETED", note.getBody() );
					//toptensView.deletePlaylist( note.getBody() as String );
					break;
					
				case AppConstants.YOUTUBEPLAYLISTSLOADED:
					trace("TopTensMediator:: handleNotification: YOUTUBEPLAYLISTSLOADED" );
					toptensView.toptensVO = note.getBody() as PlaylistsVO;
					break;
					
				default:
					break;		
			}
		}

		private function loadPlaylist(e:Event):void
		{
			var _v:PlaylistsItemView = e.target as PlaylistsItemView;
			trace("TopTensMediator:: clientLoadPlaylist:", _v.playlistsItemVO.youTubeID);
			if (_v.playlistsItemVO.source == "VS") {
				var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
				ncp.clientLoadPlaylist( _v.playlistsItemVO );
			} else {
				var plp:PlaylistProxy = facade.retrieveProxy( PlaylistProxy.NAME ) as PlaylistProxy;
				plp.setPlaylist( _v.playlistsItemVO );
			}
		}
		private function clickHandler(e:MouseEvent):void
		{
			trace("TopTensMediator:: clickHandler:", e.target.name );
			
			switch (e.target.name) {
				
				case "delete":
					var _item:PlaylistsItemView = e.target.parent as PlaylistsItemView;
					deletePlaylist(_item.playlistsItemVO);
					// add a new playlist from the list here...
					break;
					
			}
		}
		
		// this function also immediately deletes the playlist from the view
		// we don't wait for a return note from the proxy to delete this playlist since
		// we might as well delete it (that's what the user wants) and don't need to wait
		// for confirmation of a successsful delete
		private function deletePlaylist(_p:PlaylistVO):void
		{
//			var plp:PlaylistProxy = facade.retrieveProxy(PlaylistProxy.NAME) as PlaylistProxy;
//			plp.deletePlaylist( _p );
			toptensView.deletePlaylist( String(_p.pid) );
		}

		private function get toptensView():TopTensView
		{
			return viewComponent as TopTensView
		}
	}
}