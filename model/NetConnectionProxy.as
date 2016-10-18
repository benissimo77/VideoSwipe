/*
 * NetConectionProxy
 * model to store all info related to a NetConnection
 * URI of server
 * handles conection callbacks to server, stores a NetConnectionClient which handles calls from server
*/
package com.videoswipe.model
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.model.vo.FriendVO;
	import com.videoswipe.model.vo.NetConnectionVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.VideoItemVO;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.utils.Timer;
    import org.puremvc.as3.interfaces.IProxy;
    import org.puremvc.as3.patterns.proxy.Proxy;

    public class NetConnectionProxy extends Proxy implements IProxy
    {
        public static const NAME:String = 'NetConnectionProxy';
		public static const CONNECTSUCCESS:String = NAME + "connectsuccess";
		public static const CONNECTIONCLOSED:String = NAME + "connectionclosed";

		private var _netConnection:NetConnection;
		private var _netConnectionClient:NetConnectionClient;
		private var _userRequestedDisconnect:Boolean;	// flag determines if we re-connect following a disconnection
		private var _reconnectTimer:Timer;				// can't reconnect from NetStatus handler so short pause before reconnect attempt

        public function NetConnectionProxy( )
        {
            super( NAME, new NetConnectionVO() );
		}
		
		override public function onRegister():void
		{
			_netConnection = new NetConnection();
			_netConnectionClient = new NetConnectionClient(this);
			_netConnection.client = _netConnectionClient;

			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

			_reconnectTimer = new Timer(4000, 3);
			_reconnectTimer.addEventListener( TimerEvent.TIMER, reconnectTimerHandler);
			// tesing Cirrus - set _netConnectionURL to be Cirrus service
			//_netConnectionURL = "rtmfp://p2p.rtmfp.net/f450aba60e2264dd1cf26441-25fd89abf926";
			//_netConnection.connect(_netConnectionURL);

        }
		
		// connect
		// the vo should already be set with the application and instance to connect to
		public function connect():void {
			var _connectString:String = vo.netConnectionURL + "/" + vo.application + "/" + vo.applicationInstance;
			trace("NetConnectionProxy:: connect:", _connectString, vo.uid);

			// for videoswipe viewer we don't carry out the connect
			CONFIG::standalone {
				_netConnection.connect(_connectString, vo.uid, vo.username, vo.friendlist.friends);
			}
		}

		public function disconnect():void
		{
			_userRequestedDisconnect = true;
			_netConnection.close();
			//messageSo.close();
			//userSo.close();
		}

		// connectAnonymous
		// no connection made with Facebook, only VS server to create an anonymous room
		public function connectAnonymousX(_uid:String):void
		{
			var _f:FacebookVO = new FacebookVO();
			_f.uid = _uid;
			_f.name = "Guest";
			vo.facebookVO = _f;
			vo.application = "devsession";	// for now
			vo.applicationInstance = vo.uid;
			connect();
		}
		public function setUserInfo(result:FacebookVO):void
		{
			trace("NetConnectionProxy:: setUserInfo:", result.uid, result.name );
			vo.facebookVO = result;
		}

		private function netStatusHandler(event:NetStatusEvent):void {
			trace("NetConnectionProxy:: netStatusHandler:", event.info.code );
			switch (event.info.code) {
				
				case "NetConnection.Connect.Success":
					onConnectSuccess();
					break;
				
				case "NetConnection.Connect.Closed":
					onConnectionClosed();
					break;
					
				default:
					break;
			}
		}
		private function securityErrorHandler(e:NetStatusEvent):void {
			trace("NetErrorHandler: hello.");
		}

		private function onConnectSuccess():void
		{
			vo.connected = true;
			sendNotification(CONNECTSUCCESS, vo);
		}
		

		private function onConnectionClosed():void
		{
			vo.connected = false;
			sendNotification(CONNECTIONCLOSED);
			_reconnectTimer.reset();
			_reconnectTimer.start();
		}

		private function reconnectTimerHandler(e:TimerEvent = null):void
		{
			// we might well have reconnected already (eg if user simply switching rooms)
			// so only attempt reconnect if we are still not connected
			if (_netConnection.connected) {
				_reconnectTimer.stop();
			} else {
				connect();
			}
		}
		/* PUBLIC FUNCTIONS
		 * 
		 */

		// SERVER FUNCTIONS
		public function serverMoveToRoom(room:String):void
		{
			vo.room = room;	// sets application and app instance vars
			_userRequestedDisconnect = true;	// user is requesting a change, don't attempt to reconnect when connection is lost
			connect();
		}

		
		// CLIENT FUNCTIONS
		
		// clientReturnToLounge
		public function clientReturnToLounge():void
		{
			vo.lounge = true;	// sets application and app instance vars
			_userRequestedDisconnect = true;	// user is requesting a change, don't attempt to reconnect when connection is lost
			connect();
		}

		// clientPlayerStateChange
		// youtube player has changed state, send to server so other users can be informed
		public function clientPlayerStateChange(_state:int, _progress:Number):void
		{
			if (connected) {
				if (inLounge) {
					sendNotification( AppConstants.SERVERPLAYERSTATECHANGE, { token:vo.uid, state:_state, progress:_progress } );
				} else {
					_netConnection.call("clientPlayerStateChange", null, _state, _progress);
				}
			}
			// extra logic here to handle the SYNCRHO functionality provided by the server
			if (_state == 5 && inLounge) {
				sendNotification( AppConstants.SERVERPLAYCLICKED );
			}
		}
		// clientLoadPlaylist
		// client is requesting to load a previously-saved playlist, all participants load the playlist
		public function clientLoadPlaylist(_p:Object):void
		{
			if (connected && !inLounge) {
				_netConnection.call("clientLoadPlaylist", null, _p);
			} else {
				sendNotification(AppConstants.SERVERLOADPLAYLIST, _p);
			}
		}
		// clientAddToPlaylist
		// client is asking for a video item to be added to the shared playlist - pass request to server if connected
		public function clientAddToPlaylist( _v:VideoItemVO ):void
		{
			trace("NetConnectionProxy:: clientAddToPlaylist:" );
			if (connected && !inLounge) {
				_netConnection.call("clientAddPlaylistItem", null, _v);
			} else {
				sendNotification( AppConstants.SERVERADDTOPLAYLIST, _v );
			}
		}
		// clientPlayPlaylistItem
		// client is asking for a specific playlist item to be played immediately - pass request to server if connected
		public function clientPlayVideoItem( _videoID:String ):void
		{
			if (connected && !inLounge) {
				_netConnection.call("clientPlayVideoItem", null, _videoID);
			} else {
				sendNotification( AppConstants.SERVERPLAYVIDEOITEM, _videoID);
			}
		}
		public function clientPlayClicked():void
		{
			if (connected && !inLounge) {
				_netConnection.call("clientPlayClicked", null);
			} else {
				sendNotification( AppConstants.SERVERPLAYCLICKED );
			}
		}
		public function clientPauseClicked():void
		{
			if (connected && !inLounge) {
				_netConnection.call( "clientPauseClicked", null);
			} else {
				sendNotification( AppConstants.SERVERPAUSECLICKED );
			}
		}
		public function clientSeekTo( _s:Number ):void
		{
			if (connected && !inLounge) {
				_netConnection.call( "clientSeekTo", null, _s);
			} else {
				sendNotification( AppConstants.SERVERSEEKTO, _s);
			}
		}
		public function clientDeletePlaylistItem( _v:VideoItemVO ):void
		{
			if (connected && !inLounge) {
				_netConnection.call( "clientDeletePlaylistItem", null, _v );
			} else {
				sendNotification( AppConstants.SERVERDELETEPLAYLISTITEM, _v );
			}
		}
		public function clientMovePlaylistItem( _videoID:String, _position:int):void
		{
			if (connected && !inLounge) {
				_netConnection.call( "clientMovePlaylistItem", null, _videoID, _position );
			} else {
				_netConnectionClient.serverMovePlaylistItem( _videoID, _position );
			}
		}
		public function clientSendPlaylistToServer( vo:PlaylistVO ):void
		{
			trace("NetConnectionProxy:: clientSendPlaylistToServer:", vo.title, vo.playlistItems.length );
			// FMS can't handle a Vector object, so turn into a regular Array
			var _items:Array = new Array();
			for (var i:int = vo.playlistLength; i--; ) {
				_items.unshift( vo.playlistItems[i] );
			}
			_netConnection.call( "clientSendPlaylist", null, { playlistItems:_items, currentlyPlaying:vo.currentlyPlaying } );
		}
		public function clientNewChatMessage( _s:String ):void
		{
			if (connected && !inLounge) {
				_netConnection.call("chat.clientNewChatMessage", null, vo.username, _s);
			} else {
				sendNotification( AppConstants.SERVERNEWCHATMESSAGE, { type:"server", msg:"You must be connected in order to use the chat window" } );
			}
		}

		// following functions apply whether user is in lounge or in a 'room'
		// so function call passes the user token (uid) in case it needs to be passed from room to lounge
		public function clientInviteFriend( _f:FriendVO ):void
		{
			trace("NetConnectionProxy:: clientInviteFriend:", _f.name );
			_netConnection.call("clientInviteFriend", null, vo.uid, _f.uid );
		}
		public function clientCancelInvite( _f:FriendVO ):void
		{
			trace("NetConnectionProxy:: clientCancelInvite:", _f.name );
			_netConnection.call("clientCancelInvite", null, vo.uid, _f.uid );
		}
		public function clientAcceptInvite( _f:FriendVO ):void
		{
			trace("NetConnectionProxy:: clientAcceptInvite:", _f.name, _f.uid );
			_netConnection.call("clientAcceptInvite", null, vo.uid, _f.uid);
		}
		public function clientRequestJoinFriend( _f:FriendVO ):void
		{
			trace("NetConnectionProxy:: clientRequestJoinFriend:", _f.name );
			_netConnection.call("clientRequestJoinFriend", null, vo.uid, _f.uid );
		}
		public function clientAcceptRequest( _f:FriendVO ):void
		{
			trace("NetConnectionProxy:: clientAcceptRequest:", _f.name );
			_netConnection.call("clientAcceptRequest", null, vo.uid, _f.uid );
		}
		public function clientCancelRequest( _f:FriendVO ):void
		{
			trace("NetConnectionProxy:: clientCancelRequest:", _f.name );
			_netConnection.call("clientCancelRequest", null, vo.uid, _f.uid );
		}
		public function clientRecordCamera():void
		{
			trace("NetConnectionProxy:: clientRecordCamera:" );
			_netConnection.call("recordStream", null, vo.uid);
		}

		// PUBLIC GETTER/SETTERS
		public function get vo():NetConnectionVO
		{
			return data as NetConnectionVO;
		}

		public function get netConnection():NetConnection {
			return _netConnection;
		}

		public function get netConnectionURL():String {
			return vo.netConnectionURL;
		}

		public function get connected():Boolean {
			return vo.connected;
		}
		private function get inLounge():Boolean
		{
			return vo.lounge;
		}
		public function get username():String 
		{
			return vo.username;
		}
		public function get uid():String
		{
			return vo.uid;
		}
		public function get applicationInstance():String 
		{
			return vo.applicationInstance;
		}
	}
}