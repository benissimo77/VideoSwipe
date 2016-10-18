/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.FeedProxy;
	import com.videoswipe.model.NetConnectionClient;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.VideoMessageProxy;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import com.videoswipe.model.vo.VideoMessageVO;
	import com.videoswipe.view.component.PlaylistEvent;
	import com.videoswipe.view.component.PlaylistItemView;
	import com.videoswipe.view.component.PlaylistView;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * A Mediator
	 */
	public class PlaylistMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "PlaylistMediator";
		
		private var _plp:PlaylistProxy;
		
		public function PlaylistMediator(viewComponent:Object) {
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
			return PlaylistMediator.NAME;
		}
        
		override public function onRegister():void {
			trace("PlaylistMediator:: onRegister: hello.");
			_plp = facade.retrieveProxy( PlaylistProxy.NAME ) as PlaylistProxy;
			playlist.playlistVO = _plp.vo;
			playlist.addEventListener( MouseEvent.CLICK, playlistClickHandler );
			playlist.addEventListener( PlaylistEvent.PLAYLISTTITLECHANGED, playlistTitleChanged );
			playlist.addEventListener( PlaylistEvent.PLAYPLAYLISTITEM, playlistEventHandler );
			playlist.addEventListener( PlaylistEvent.MOVEPLAYLISTITEM, movePlaylistItem );
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
				AppConstants.SERVERADDTOPLAYLIST,
				AppConstants.SERVERPLAYVIDEOITEM,
				AppConstants.SERVERMOVEPLAYLISTITEM,
				AppConstants.SERVERDELETEPLAYLISTITEM,
				AppConstants.SERVERLOADPLAYLIST,
				AppConstants.PLAYLISTLOADED,
				AppConstants.PLAYLISTSAVED,
				AppConstants.PLAYLISTSAVEERROR,
				AppConstants.PLAYERITEMENDED,
				AppConstants.PLAYERERROR,
				AppConstants.SERVERREQUESTPLAYLIST,
				AppConstants.SERVERSYNCPLAYLIST,
				AppConstants.YOUTUBEPLAYLISTLOADED,
				AppConstants.SERVERSTREAMRECORDING
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

			var i:int;	// general counter
			var _itemVO:SystemMessageItemVO;
			var _request:SystemMessageRequest;
			var _videoItemVO:VideoItemVO;	// general itemVO for use during switch statement
			
			switch (note.getName()) {
				
				case AppConstants.SERVERADDTOPLAYLIST:
					trace("PlaylistMediator:: handleNotification: AppConstants.SERVERADDTOPLAYLIST");
					_videoItemVO = note.getBody() as VideoItemVO;
					var _playlistLength:int = _plp.playlistLength;
					_plp.addPlaylistItem(_videoItemVO);
					playlist.addPlaylistItemView( _videoItemVO );
					if (_plp.autoplay && _plp.currentlyPlaying == _playlistLength) {
						playPlaylistItem( _videoItemVO );
					}
					break;

				case AppConstants.SERVERPLAYVIDEOITEM:
					trace("PlaylistMediator:: handleNotification: SERVERPLAYVIDEOITEM");
					i = _plp.getPlaylistItemIndex( note.getBody() as String ) ;
					if (i >= 0) {
						playlist.setCurrentPlayingItem( note.getBody() as String );
					}
					break;

				case AppConstants.SERVERMOVEPLAYLISTITEM:
					trace("PlaylistMediator:: handleNotification: SERVERMOVEPLAYLISTITEM", note.getBody().videoID, note.getBody().position );
					_plp.movePlaylistItem(note.getBody().videoID, note.getBody().position );
					playlist.synchronisePlaylistView();
					break;
					
				case AppConstants.SERVERLOADPLAYLIST:
					trace("PlaylistMediator:: handleNotification: SERVERLOADPLAYLIST", note.getBody() );
					if (note.getBody().pid) {
						_plp.loadPlaylist( note.getBody().pid);
					}
					break;
					
				case AppConstants.SERVERDELETEPLAYLISTITEM:
					trace("PlaylistMediator:: handleNotification: SERVERDELETEPLAYLISTITEM" );
					// below fn returns the index of item in playlist array or -1 if not found
					i = _plp.deletePlaylistItem( note.getBody() as VideoItemVO );
					if (i >= 0) {
						playlist.deletePlaylistItem(i);
					}
					break;
					
				case AppConstants.YOUTUBEPLAYLISTLOADED:
					trace("PlaylistMediator:: handleNotification: YOUTUBEPLAYLISTLOADED" );
					_plp.setPlaylist( note.getBody() as PlaylistVO);
					break;
					
				case AppConstants.PLAYLISTLOADED:
					trace("PlaylistMediator:: handleNotification: SERVERPLAYLISTLOADED" );
					playlist.playlistVO = _plp.vo;	// will draw view
					if (_plp.pid > 0) playlist.addLinkButtons( generateLinkText(_plp.pid) );
					if (_plp.playlistLength > 0 && _plp.autoplay) playPlaylistItem( _plp.getPlaylistItemAt(0) );
					sendPlaylistToServer();
					break;
						
				case AppConstants.PLAYLISTSAVED:
					trace("PlaylistMediator:: handleNotification: PLAYLISTSAVED", note.getBody() );
					playlist.addLinkButtons( generateLinkText(note.getBody().pid) );
					if (_plp.autoSave) {
						// don't send system message, autosave is invisible to the user
					} else {
						_itemVO = new SystemMessageItemVO("success", "Playlist saved!", "You can view and load all your saved playlists using the 'My Playlists' tab in the right-hand panel.", null, ["OK"], 6000 );
						_request = new SystemMessageRequest(_itemVO);
						sendNotification( AppConstants.ADDSYSTEMMESSAGE, _request );
					}
					break;
						
				case AppConstants.PLAYLISTSAVEERROR:
					trace("PlaylistMediator:: handleNotification: PLAYLISTSAVEERROR" );
					if (_plp.autoSave) {
						// do nothing here, even errors are ignored during autosave
					} else {
						_itemVO = new SystemMessageItemVO("error", "Problem saving playlist!", "Hmmm... error during save :( Please try again in a few minutes...", null, ["OK"], 8000);
						_request = new SystemMessageRequest(_itemVO);
						sendNotification( AppConstants.ADDSYSTEMMESSAGE, _request);
					}
					break;
						
				case AppConstants.PLAYERITEMENDED:
					trace("PlaylistMediator:: handleNotification: PLAYERITEMENDED");
					if (_plp.autoplay) {
						_videoItemVO = _plp.gotoNextPlaylistItem();
						if (_videoItemVO) {
							cueNextPlaylistItem( _videoItemVO );
						}
					}
					break;
					
				case AppConstants.PLAYERERROR:
					trace("PlaylistMediator:: handleNotification: PLAYERERROR" );
					_videoItemVO = _plp.gotoNextPlaylistItem();
					if (_videoItemVO) {
						playPlaylistItem( _videoItemVO );
					}
					break;

				case AppConstants.SERVERREQUESTPLAYLIST:
					trace("PlaylistMediator:: handleNotification: SERVERREQUESTPLAYLIST" );
					sendPlaylistToServer();
					break;
					
				case AppConstants.SERVERSYNCPLAYLIST:
					trace("PlaylistMediator:: handleNotification: SERVERSYNCPLAYLIST" );
					_plp.synchronisePlaylist( note.getBody() );
					playlist.playlistVO = _plp.vo;
					break;
					
				case AppConstants.SERVERSTREAMRECORDING:
					trace("PlaylistMediator:: handleNotification: SERVERSTREAMRECORDING" );
					var _messageVO:VideoMessageVO = new VideoMessageVO( note.getBody() );
					_messageVO.uid = _plp.uid;
					_plp.addVideoMessageToCurrentlyPlayingVideo( _messageVO );
					break;
					
				default:
					break;
			}
		}

		private function playlistClickHandler(e:MouseEvent):void
		{
			trace("PlaylistMediator:: playlistClickHandler:", e.target.name );
			var _item:PlaylistItemView = e.target.parent as PlaylistItemView;
			switch (e.target.name) {
				case "prevItem":
					playPlaylistItem( _plp.getPrevPlaylistItem() );
					break;
				case "nextItem":
					playPlaylistItem( _plp.getNextPlaylistItem() );
					break;
				case "thumb":
					//playPlaylistItem(_item.videoItemVO);
					break;
				case "delete":
					deletePlaylistItem(_item.videoItemVO);
					break;
				case "post":
					postPlaylist();
					sendNotification( AppConstants.LOGPOSTPLAYLIST, _plp.pid );
					break;
				case "send":
					sendPlaylist();
					sendNotification( AppConstants.LOGSENDPLAYLIST, _plp.pid );
					break;
				case "save":
					savePlaylist();
					break;
				case "load":
					loadPlaylist();
					break;
				case "new":
					newPlaylist();
					break;
				case "copy":
					sendNotification(AppConstants.COPYTOCLIPBOARD, generateLinkText( _plp.pid ));
					playlist.setCopyButtonText("Copied");
					break;
				default:
					trace("PlaylistMediator:: playlistClickHandler: UNKNOWN ITEM" );
					break;
			}
		}
		private function playlistTitleChanged( e:Event ):void
		{
			trace("PlaylistMediator:: playlistTitleChanged:", playlist.playlistVO.title );
			_plp.playlistTitle = playlist.playlistVO.title;
			sendNotification( AppConstants.KEYBOARDINPUTDONE );	// gives focus back to Stage
			// interestingly, because the in this case th view also holds a ref to the playlist VO, maybe we can ust update the VO
			// in the view and it will automatically update the same vo in the proxy...
			// not sure if this is good encapsulation (suspect it isn't) but a side-ffect of storing the VO in the view
		}

		private function playlistEventHandler( e:PlaylistEvent ):void
		{
			playPlaylistItem(e.itemVO);
		}
		private function playPlaylistItem(_v:VideoItemVO):void
		{
			if (_v) {
				var ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
				ncp.clientPlayVideoItem( _v.videoID );
			}
		}
		// this function slightly different to above play function
		// most request to play an item come from the server so they can sync accross all clients
		// EXCEPT when an item ends and we want to cue the next item - we do this 'locally' and send an 'item cued' message when done
		private function cueNextPlaylistItem(_v:VideoItemVO):void
		{
			if (_v) {
				sendNotification( AppConstants.SERVERPLAYVIDEOITEM, _v.videoID);
			}
		}
		private function deletePlaylistItem(_v:VideoItemVO):void
		{
			var ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
			ncp.clientDeletePlaylistItem( _v );
		}
		private function movePlaylistItem(e:PlaylistEvent):void
		{
			var ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME) as NetConnectionProxy;
			ncp.clientMovePlaylistItem(e.itemVO.videoID, e.position);
		}
		private function postPlaylist():void
		{
			// for testing use the title as th ID so we can generat fresh images and check they work
			trace("PlaylistMediator:: sharePlaylist:", _plp.vo.title );
			var _fb:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
			if (_fb.connected) {
				_fb.postPlaylist(_plp.vo);
			} else {
				sendNotification(AppConstants.ADDSYSTEMMESSAGE, new SystemMessageRequest( new SystemMessageItemVO("warning", "You Can't Post Playlists Yet :(", "You must be connected using Facebook if you want to post playlists to your wall.\n\nLogin with Facebook and start sharing playlists with friends!", null, ["OK"], 8000)));
			}
		}
		private function sendPlaylist():void
		{
			trace("PlaylistMediator:: sendPlaylist:", _plp.vo.title );
			var _fb:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
			if (_fb.connected) {
				_fb.sendPlaylist(_plp.vo);
			} else {
				sendNotification(AppConstants.ADDSYSTEMMESSAGE, new SystemMessageRequest( new SystemMessageItemVO("warning", "You Can't Send Playlists Yet :(", "You must be connected using Facebook if you want to send playlists to friends.\n\nLogin with Facebook and start sending playlists to friends!", null, ["OK"], 8000)));
			}
			
		}
		private function sendPlaylistToServer():void
		{
			trace("PlaylistMediator:: sendPlaylistToServer:" );
			var _ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
			_ncp.clientSendPlaylistToServer( _plp.vo );
		}
		private function savePlaylist():void
		{
			trace("PlaylistMediator:: savePlaylist:", _plp.vo.title );
			var _fb:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
			if (_fb.connected) {
				if (_plp.playlistLength == 0) {
					sendNotification(AppConstants.ADDSYSTEMMESSAGE, new SystemMessageRequest( new SystemMessageItemVO("warning", "Hmmm... nothing to save!", "No point in saving an empty playlist.\n\nBrowse YouTube using the right-hand panel and click to add video clips to your playlist.", null, ["OK"], 5000)));
				} else {
					_plp.savePlaylist();	// this will automatically generate the thumb for the playlist
				}
			} else {
				sendNotification(AppConstants.ADDSYSTEMMESSAGE, new SystemMessageRequest( new SystemMessageItemVO("warning", "You can't save playlists yet :(", "You must be connected with Facebook if you want to save playlists.\n\Login with Facebook to start saving your playlists to watch later. Connecting also allows you to send messages, share playlists and invite friends to join you!", null, ["OK"], 8000)));
			}
		}
		private function loadPlaylist():void
		{
			trace("PlaylistMediator:: loadPlaylist:", _plp.pid );
			//if (_plp.pid > 0) _plp.newLoadPlaylist(_plp.pid);
		}
		private function newPlaylist():void
		{
			trace("PlaylistMediator:: newPlaylist:" );
			_plp.vo = new PlaylistVO();
			playlist.playlistVO = _plp.vo;
		}
		private function generateLinkText(_s:int):String
		{
			return "http://videoswipe.net/go/?p=" + _s;
		}

		private function get playlist():PlaylistView
		{
			return viewComponent as PlaylistView
		}
	}
}