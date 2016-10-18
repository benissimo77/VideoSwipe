/*    
 * NetConnectionClient
 * handles all communication out of the Media Server
 * (c) Ben Silburn 2011
 */

package com.videoswipe.model {
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import org.puremvc.as3.interfaces.INotifier;
	import org.puremvc.as3.patterns.observer.Notifier;

	public class NetConnectionClient extends Notifier implements INotifier {

        public static const NAME:String = 'NetConnectionClient';

		private var _ncp:NetConnectionProxy;	// cache a copy of the proxy so we can call it directly
		private var messageSo:SharedObject;
		private var userSo:SharedObject;
		private var playlistSO:SharedObject;
		
		public function NetConnectionClient(_n:NetConnectionProxy):void
		{
			// we store a local copy of the netConnection proxy (shared objects need it, plus direct calls from this client to proxy)
			_ncp = _n;
		}
		public function onBWCheck(...rest):void {
		}

		public function onBWDone(...rest):void {
		}


		// connectSharedObjects
		// called by the server if this client should receive shared messages and playlists (server can decide)
		public function connectSharedObjects():void
		{
			trace("NetConnectionClient:: connectSharedObjects:" );

			messageSo = SharedObject.getRemote("message", netConnection.uri, false);
			messageSo.client = this;
			messageSo.connect(netConnection);
		
			userSo = SharedObject.getRemote("users", netConnection.uri, false);
			userSo.addEventListener(SyncEvent.SYNC, usersSoOnSync);
			userSo.client = this;
			userSo.connect(netConnection);  
			sendNotification( AppConstants.ADDCHATVIEW );

			playlistSO = SharedObject.getRemote("playlist", netConnection.uri, false);
			playlistSO.client = this;
			playlistSO.addEventListener(NetStatusEvent.NET_STATUS, playlistStatusHandler);
			playlistSO.addEventListener(SyncEvent.SYNC, playlistSyncHandler);
			//playlistSO.addEventListener(Event.ACTIVATE, playlistEventHandler);
			//playlistSO.addEventListener(Event.DEACTIVATE, playlistEventHandler);
			playlistSO.connect(netConnection);
			
			netConnection.call("chat.getHistory", new Responder(onGetHistory));
		}
		private function playlistStatusHandler(e:NetStatusEvent):void
		{
			trace("NetConnectionClient:: playlistStatusHandler:", e.info );
		}
		private function playlistSyncHandler(e:SyncEvent):void
		{
			trace("NetConnectionClient:: playlistSyncHandler:", e.changeList.length );
			for (var i:int = 0; i < e.changeList.length; i++ ) {
				trace(i, e.changeList[i].code, e.changeList[i].name);
				if (e.changeList[i].name == "playlistItems") {
					trace( playlistSO.data );
				}
			}
		}
		private function playlistEventHandler(e:Event):void
		{
			trace("NetConnectionClient:: playlistEventHandler:", e.type );
		}
		// serverStreamCamera
		// called by the server if this client is authorized to begin streaming
		public function serverStreamCamera():void
		{
			trace("NetConnectionClient:: serverStreamCamera:" );
			sendNotification(AppConstants.STREAM_CAMERA);
		}
		private function onGetHistory(result:Array):void
		{
			var messagesTf:String = "";
			var lastMessage:String = "";
			for ( var i:int = 0; i < result.length; i++ )
			{
				var msgObj:Object = result[i];
				if (msgObj.msg != lastMessage) {
					sendNotification( AppConstants.SERVERNEWCHATMESSAGE, msgObj );
					messagesTf += msgObj.user + ": " + msgObj.msg + "\n";
					lastMessage = msgObj.msg;
				}
			}
			trace("onGetHistory:");
			trace(messagesTf);
		}

		// serverRequestPlaylist
		// called by server to request user's playlist, server then syncs and sends to all users
		public function serverRequestPlaylist():void
		{
			trace("NetConnectionClient:: serverRequestPlaylist:" );
			sendNotification( AppConstants.SERVERREQUESTPLAYLIST );
		}
		// serverSyncPlaylist
		// called by server whenever new user joins room, newly synced playlist
		public function serverSyncPlaylist( vo:Object ):void
		{
			trace("NetConnectionClient:: serverSyncPlaylist:", vo.title );
			sendNotification( AppConstants.SERVERSYNCPLAYLIST, vo );
		}

		// onUpdatePlaylist - called by server if we have a new playlist
		private function onUpdatePlaylist(result:Object):void
		{
			trace("NetConnectionClient:: onUpdatePlaylist:");
			for (var i:String in result) {
				trace(i, ":", result[i]);
			}
		}

		// onSync event - updates the users list
		private function usersSoOnSync(event:SyncEvent):void
		{
			var usersTf:String;
			var usersArray:Array;
			
			if (userSo.data && userSo.data.users) {

				usersArray = userSo.data.users;
				for ( var i:int = 0; i < usersArray.length; i++ )
				{
					var user:Object    = usersArray[i];
					usersTf += user.username + "\n";
				}

			}
			trace("usersSoOnSync:");
			trace(usersTf);
			//usersTf.verticalScrollPosition    = usersTf.maxVerticalScrollPosition;
		}

		// addStream
		// another client is streaming to this client, display their stream (c: the name of the stream)
		public function addStream(c:String):void {
			trace("NetConnectionClient:: addStream: " + c);
			sendNotification(AppConstants.ADD_STREAM, { streamName: c } );
		}

		// removeStream
		// client has left room, remove their stream from view
		public function removeStream(c:String):void {
			trace("NetConnectionClient:: removeStream: " + c);
			sendNotification(AppConstants.REMOVE_STREAM, { streamName: c } );
		}

		/*
		 * SERVER VERSIONS OF USER FUNCTIONS
		 * A lot of functionality comes from the client, gets sent to the server, then returns
		 * these functions have two versions, clientXXX and serverXXX to denote whether they are from the client or server
		 * All functions below are the server versions of client functions
		 * NOTE: these functions all take a token parameter which is unused,
		 * this is to match the signature of the Server-Side Client functions which also receive these calls and require a token
		 */
		public function serverMoveToRoom( _token:String, room:String ):void
		{
			trace("NetConnectionClient:: serverMoveToRoom:", room );
			_ncp.serverMoveToRoom(room);
		}
		public function serverPlayerStateChange( _token:String, _state:int, _progress:Number ):void
		{
			trace("NetConnectionClient:: serverPlayerStateChange:", _token, _state, _progress );
			sendNotification( AppConstants.SERVERPLAYERSTATECHANGE, { token:_token, state:_state, progress:_progress } );
		}
		public function serverLoadPlaylist( _p:Object ):void
		{
			trace("NetConnectionClient:: serverLoadPlaylist:" );
			sendNotification( AppConstants.SERVERLOADPLAYLIST, _p );
		}
		public function serverInviteFriend( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverInviteFriend:", _token, _o.name );
			sendNotification( AppConstants.INVITEFRIEND, _o);
		}
		public function serverInviteFromFriend( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverInviteFromFriend:", _token, _o.name );
			sendNotification( AppConstants.INVITEFROMFRIEND, _o);
		}
		public function serverInviteResponded( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverInviteResponded:", _o.name );
			sendNotification( AppConstants.INVITERESPONDED, _o );
		}
		public function serverRequestFromFriend( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverRequestFromFriend:", _token, _o.name );
			sendNotification( AppConstants.REQUESTFROMFRIEND, _o );
		}
		public function serverRequestFriend( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverRequestFriend:", _token, _o.name );
			sendNotification( AppConstants.REQUESTFRIEND, _o );
		}
		public function serverRequestResponded( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverRequestResponded:", _o.name );
			sendNotification( AppConstants.REQUESTRESPONDED, _o );
		}
		public function serverFriendsOnlineStatus( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverFriendsOnlineStatus:", _token, _o );
			if (_o) {
				// translate the received object into a format similar to the Facebook online_presence object
				// _o.friendlist is an array of uids, _o.connected boolean true/false
				// _f is an array of objects, _f.uid the token _f.online_presence a string active,idle,offline,error _f.live true/false if on VideoSwipe
				var _f:Array = new Array();
				for (var i:int = _o.friendlist.length; i--; ) {
					_f.unshift( { uid:_o.friendlist[i], live:_o.connected } );
				}
				// send this directly to the Facebook Graph Proxy
				var _fgp:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
				_fgp.onUsersOnlineFriends(_f, null);
			}
		}
		// serverFriendOffline
		// called by the server when a user request to invite friend fails due to the friend being offline
		// route user to the standard Facebook invitiation dialogue
		// NOTE: this is UNLIKELY to happen now since we perform an online/offline check before inviting friend in the first place
		public function serverFriendOffline( _token:String, _o:Object ):void
		{
			trace("NetConnectionClient:: serverFriendOffline:", _token, _o.uid );
			sendNotification(AppConstants.FRIENDOFFLINE, _o );
		}

		
		public function serverAddPlaylistItem( _o:Object ):void
		{
			trace("NetConnectionClient:: serverAddPlaylistItem:" );
			var _v:VideoItemVO = new VideoItemVO();
			_v.fillFromObject(_o);
			sendNotification( AppConstants.SERVERADDTOPLAYLIST, _v );
		}
		public function serverPlayVideoItem( _o:Object ):void
		{
			trace("NetConnectionClient:: serverPlayVideoItem:", _o );
			sendNotification( AppConstants.SERVERPLAYVIDEOITEM, _o as String );
		}
		public function serverPlayClicked( ):void
		{
			trace("NetConnectionClient:: serverPlayClicked:" );
			sendNotification( AppConstants.SERVERPLAYCLICKED );
		}
		public function serverPauseClicked( ):void
		{
			trace("NetConnectionClient:: serverPauseClicked:" );
			sendNotification( AppConstants.SERVERPAUSECLICKED );
		}
		public function serverSeekTo(_s:Number):void {
			trace("NetConnectionClient:: serverSeekTo:", _s );
			sendNotification( AppConstants.SERVERSEEKTO, _s);
		}
		public function serverDeletePlaylistItem( _o:Object ):void
		{
			trace("NetConnectionClient:: serverDeletePlaylistItem:" );
			var _v:VideoItemVO = new VideoItemVO();
			_v.fillFromObject(_o);
			sendNotification( AppConstants.SERVERDELETEPLAYLISTITEM, _v );
		}
		public function serverMovePlaylistItem( _videoID:String, _position:int ):void
		{
			sendNotification( AppConstants.SERVERMOVEPLAYLISTITEM, { videoID:_videoID, position:_position } );
		}
		public function serverNewChatMessage(type:String, user:String, msg:String):void
		{
			sendNotification( AppConstants.SERVERNEWCHATMESSAGE, { type:type, user:user, msg:msg } );
		}
		public function serverStreamRecording( sessionID:String, streamName:String ):void
		{
			trace("NetConnectionClient:: serverStreamRecording:", sessionID, streamName );
			sendNotification( AppConstants.SERVERSTREAMRECORDING, { sessionID:sessionID, streamname:streamName } );
		}
		
		/*
		 * LOCAL GETTER FUNCTIONS
		 */
		private function get netConnection():NetConnection
		{
			return _ncp.netConnection;
		}
    }
}
