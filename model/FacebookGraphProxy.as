/*
 * FacebookGraphProxy
 * Some quick notes on the Facebook graph API as it makes sense now, but didn't at first
 * Facebook.init is called first, if user is already logged in then result will be a FacebookAuthResponse object, can proceed
 * if user is not logged in result will be false - must provide a means for user to login
 * must do this via a button to prevent pop-up blocker from blocking the login request
 * using the JSEventListener it this point is pointless since it is all covered during the .init call
 * maybe later there will be a reason for using this event listener - it works but its redundant
 * Facebook.login and Facebook.logout carry out the real logging in and out of facebook
 * ie if the user has facebook open in another window, the Facebook.logout call will logout user out of facebook in other window
 * use with caution since users might not be aware they are really logging out of facebook entirely
 * that's about it! It turns out to be very straight-forward but somehow it took a long time to reach this point.
 * Now time to test out the posting of notifications and the inviting of friends to join...
 * Note: login is successful if user allows app even if they DON'T allow extended permissions... so be prepared for api calls to still fail even if user logged in
*/
package com.videoswipe.model 
{
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.Facebook;
	import com.facebook.graph.FacebookMobile;
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	CONFIG::tablet {
		import flash.media.StageWebView;
	}

	/**
	 * (c) 2013 Ben Silburn
	 */
	public class FacebookGraphProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "FacebookGraphProxy";
		private static const APPID:String = "445205765493888";

		private var _ncp:NetConnectionProxy;
		private var _plp:PlaylistProxy;
		private var _guestID:String;	// ID to use if we don't have a Facebook user id
		private var _siteURL:String = ""; // use apps.facebook.com when running inside facebook canvas
		private var _flashVars:Object;	// cache the flashVars ready for when user is identified
		
		public function FacebookGraphProxy( _n:NetConnectionProxy, _p:PlaylistProxy, _f:Object ) {
			_ncp = _n;
			_plp = _p;
			_flashVars = _f;

			_guestID = "guest-" + Math.floor(Math.random() * 10000000);
			if (_f.s) {
				_guestID = _f.s;	// this is the ID to use if the Facebook login fails
			}
			//_siteURL = "http://videoswipe.net/go";
			_siteURL = "https://apps.facebook.com/videoswipe";
			if (_f.d) {
				_siteURL = "http://" + _f.d + "/go";
			}
			if (_f.fb) {
				_siteURL = "https://apps.facebook.com/videoswipe";
			}
			super(NAME, new FacebookVO());
			trace("FacebookGraphProxy:: FacebookGraphProxy:" );
		}
		
		override public function onRegister():void {
			trace("FacebookGraphProxy:: onRegister: hello" );
			
			// begin with the uid set to guest user - if facebook successful overwrite with Facebook UID
			vo.uid = _guestID;
			
			// Facebook.init kicks off connection pipeline
			// onInit processes result
			// onConnect result of a Facebook login attempt
			// onUserInfo collects Facebook user and calls connectUser
			// connectUser either a Facebook user VO or a guest user VO - perform connect
			CONFIG::tablet {
				FacebookMobile.init(APPID, onInit);
			}
			CONFIG::standalone {
				if (ExternalInterface.available) Facebook.init(APPID, onInit, {frictionlessRequests:true, friends_online_presence:true,user_status:true,user_friends:true} );
			}
		}
		
		// onInit - callback function after call to Facebook.init
		// if NOT successful we connect as guest so can immediately share with friends
		private function onInit(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onInit:");
			if (result) {
				onConnect(result, false);
			} else {
				userIdentified( _guestID );
				
				// quick fix - for now send an immediate help slide to screen
				//var _slideStr:String = '[ {"x":272,"y":72,"w":360,"h":80,"t":"Invite your Facebook friends, and watch video together :)"}, {"x":100,"y":200,"w":240,"h":120,"r":-45}, {"x":-420,"y":200,"w":400,"h":120,"t":"Browse YouTube videos, channels, subscriptions and playlists here..."}, {"x":400,"y":-120,"w":480,"h":120,"t":"Everything you watch gets automatically added to your personal playlist, here..."} ]';
				//sendNotification( AppConstants.HELPSLIDE, JSON.parse(_slideStr) );
			}
			if (fail) {
				trace("FacebookGraphProxy:: onInit: FAIL!" );
				// this can happen on mobile devices... when this happens we need to log the user in
				// the trouble is, to do this we need to pass an instance of the Stage and we might not have this yet
				// so do nothing now, and once the stage has been initialise it will take responsibility for logging in the user
			}
		}

		// connect - attempts connect to Facebook
		// can request a login scope for extra permissions (scope:"user_online_presence,friends_online_presence,read_friendlists,publish_stream")
		// not using this right now
		public function connect( _s:Stage = null ):void
		{
			trace("FacebookGraphProxy:: connect:" );
			if (CONFIG::tablet) {
				var myWebView:StageWebView = new StageWebView();
				myWebView.stage = _s;
				myWebView.viewPort = new Rectangle(_s.stageWidth / 4, _s.stageHeight / 4, _s.stageWidth / 2, _s.stageHeight / 2);
				FacebookMobile.login(onLoginAttempt, _s, [], myWebView );
			} else {
				if (ExternalInterface.available) {
					//Facebook.login(onLoginAttempt, { scope:"email,friends_online_presence" } );
					Facebook.login(onLoginAttempt );
				} else {
					dummyInit();
				}
			}
		}
		// onLoginAttempt
		// new callback function to see if we can catch whether user connects or not
		// either way we log the result as its useful to see if people are clicking this and then cancelling
		public function onLoginAttempt(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onLoginAttempt:", result, fail );
			if (result) {
				sendNotification( AppConstants.FACEBOOKLOGINOK, result );
			} else {
				sendNotification( AppConstants.FACEBOOKLOGINCANCEL );
			}
			// fall through to the onConnect function which handles the real connect attempt
			onConnect(result, fail);
		}
		// onConnect - callback function for above connect
		// we have a facebook UID so we can connect to FMS using this
		private function onConnect(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onConnect:" );
			
			// if successful then we have a valid Facebook user
			// if not successful then user has refused access... do nothing
			if (result) {
				// the below two lines work for the standard Web version, but not for the Mobile version
				// since they're not really needed anyway just comment out...
				//var FS:FacebookAuthResponse = result as FacebookAuthResponse;
				//trace("FacebookGraphProxy:: onConnect:", FS.accessToken);
				vo.connected = true;	// connected to FB (not guest)
				getUserInfo();		// retrieves full user info including friends
				getFriendlists();	// retrieves friendlists if allowed
				// not needed as we set the online status when we send the entire VO
				//sendNotification(AppConstants.FACEBOOKONLINESTATUS, true );	// prepares facebookView for online user
			}
		}

		// userIdentified
		// we either have a Facebook userid or a guest user ID, spread to other proxies and connect
		// TODO factor this out into a command
		public function userIdentified( _u:String ):void
		{
			vo.uid = _u;
			_plp.uid = _u;			
			sendNotification( AppConstants.FACEBOOKUSERINFO, vo );

			// if we've been passed any request ids then delete them (good FB practice)
			// they will already have been processed by UserManagerProxy so can delete...
			if (_flashVars.request_ids) {
				var _userArray:Array = _flashVars.request_ids.split(",", 1);
				if (_userArray[0]) {
					trace("FacebookGraphProxy:: userIdentified:", "/" + _userArray[0] + "_" + vo.uid );
					// NOTE: below line does NOT work - 'delete' method doesn't work for api calls
					//Facebook.api( "/" + _userArray[0] + "_" + vo.uid, onDeleteRequests, null, "DELETE");
				}
			}
		}
		
		public function onDeleteRequests( result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onDeleteRequests:", result);
		}

		// retrieve info on logged-in user
		// me?fields=id,name,username,cover,gender,locale,age_range,installed,devices,picture.type(small),friends
		private function getUserInfo():void
		{
			trace("FacebookGraphProxy:: getMe:" );
			if (CONFIG::tablet) {
				FacebookMobile.api("/me?fields=id,name,username,cover,gender,locale,age_range,installed,devices,picture.type(square),friends&", onUserInfo);
			} else {
//				Facebook.api("/me?fields=id,name,username,cover,gender,locale,timezone,age_range,installed,devices,picture.type(square),friends,email&", onUserInfo);
				Facebook.api("/me?fields=id,name,cover,gender,locale,timezone,age_range,installed,devices,picture.type(square),friends,email&", onUserInfo);
			}
		}
		// onUserInfo - callback function for retrieving users facebook details
		// sends a notification FACEBOOKUSERINFO which is used by facebookView to build the user page
		private function onUserInfo(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onUserInfo:", result );
			if (result) {

				// initiate the next Facebook request straight away, will take a while...
				// only retrieve online friends for now, later will have to modify if we re-fetch data every few (10?) minutes
				Facebook.fqlQuery( " SELECT uid, name, online_presence, devices FROM user WHERE online_presence in ('active','idle') and uid IN ( SELECT uid2 FROM friend WHERE uid1 = me() )", onUsersOnlineFriends);
				
				// easier to dump entire result into a new VO
				vo = new FacebookVO(result);
				vo.connected = true;	// true because we are FB connected (not guest user)
				userIdentified( vo.uid );
			}
			if (fail) {
				trace("FacebookGraphProxy:: onMe: FAIL!" );
			}
		}

		public function onUsersOnlineFriends(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: addFriendlists:" );
			if (result) {
				
				// perform a very (ie crude) sort on list to try to preserve order
				var _sorted:Array = result as Array;
				_sorted.sortOn( "name" );
				trace("FacebookGraphProxy:: onUsersOnlineFriends:" );
				vo.updateOnlineStatus( _sorted );
				sendNotification( AppConstants.FACEBOOKFRIENDSONLINESTATUS );
			}
		}
		
		// addFriendlists
		// makes a second request to Facebook to ask permission to read friendlists - comes from user clicking the 'add friendlists' button in the friendPanel
		public function addFriendlists( _s:Stage = null):void
		{
			// - scope:"read_friendlists" useful for getting users friendlists, but not really needed if I use the SEND dialog, can select the friend group from the popup
			if (CONFIG::tablet) {
				FacebookMobile.login(onConnect, _s, ["read_friendlists"]);
			} else {
				Facebook.login(onConnect, { scope:"read_friendlists" } );
			}
		}

		// getFriendlists
		// retrieves the friendlists for this user.
		// Use the Facebook API Explorer for a fuller understanding of all the possible queries available via the Graph API
		// the following request is the most efficient way to retrieve all friendlists with members of each list
		// me?fields=id,name,friendlists.fields(name,members)
		private function getFriendlists():void
		{
			trace("FacebookGraphProxy:: getFriendlists:" );
			if (CONFIG::tablet) {
				FacebookMobile.api("/me/friendlists?fields=id,name,members&", onFriendlists);
			} else {
				Facebook.api("/me/friendlists?fields=id,name,members&", onFriendlists);
			}
		}
		// onFriendlists
		// callback fn for Facebook request for friendlists
		// in case working offline this is a sample result array
		// [ { id:"10150534116916922", list_type: "education", name:"University of Bristol"}, { id:"10150341719426922", list_type:"acquaintances", name:"Acquaintances" } ];
		private function onFriendlists(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onFriendlists:" );
			if (result) {
				sendNotification( AppConstants.FACEBOOKFRIENDLISTS, result );
			}
			if (fail) {
				trace("FacebookGraphProxy:: onFriendlists: FAIL!" );
			}
		}
		
		public function getCover(id:String):void
		{
			if (CONFIG::tablet) {
				FacebookMobile.api("/" + id, onCover);
			} else {
				if (ExternalInterface.available) {
					Facebook.api("/" + id, onCover);
				} else {
					var cover:Object = { "id": "10151181722121922", "source": "http://sphotos-d.ak.fbcdn.net/hphotos-ak-snc7/s720x720/427685_10151181722121922_758888704_n.jpg", "offset_y": 58 };
					onCover(cover, true);
				}
			}
		}
		private function onCover(result:Object, fail:Object):void
		{
			trace("FacebookGraphProxy:: onCover:" );
			if (result) {
				sendNotification( AppConstants.FACEBOOKCOVERINFO, result);
			}
		}
		public function requestToUsers(_s:String = ""):void
		{
			trace("FacebookGraphProxy:: requestToUsers:", _s );
			var args:Object = {
				message:"Hey! I'm online at VideoSwipe right now. Click to join me and we can watch TV together :)",
				title:"VideoSwipe: the revolution will be live-streamed",
				redirect_uri:"http://videoswipe.net/go/?u=" + vo.uid,
				to:_s
			}

			if (CONFIG::tablet) {
				FacebookMobile.postData("apprequests", onRequest, args);
			} else {
				Facebook.ui("apprequests", args, onRequest);
			}
		}

		private function onRequest(result:Object):void
		{
			trace("FacebookGraphProxy:: onRequest:", result );
			// sample result:
			//result.request: 1402813029969727
			// result.to[0]: 1364264810
			if (result && result.request) {
				var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("success", "Invitation sent!", "Thanks for spreading the word :)", null, [], 1500 );
				var _request:SystemMessageRequest = new SystemMessageRequest(_itemVO);
				sendNotification( AppConstants.ADDSYSTEMMESSAGE, _request );
				sendNotification( AppConstants.FACEBOOKREQUESTSENT, result);
			}
		}
		public function sendToUsers(_s:String = ""):void
		{
			trace("FacebookGraphProxy:: sendToUsers:", _s );
			var _args:Object = {
				link:_siteURL + "?fb_source=sendToUser",
				to:_s
			}
			if (_plp.pid > 0) {
				_args.link = _siteURL + "?fb_source=sendToUser&p=" + _plp.pid;
			}

			if (CONFIG::tablet) {
				FacebookMobile.postData("send", onSend, _args);
			} else {
				Facebook.ui("send", _args, onSend);
			}
		}
		private function onSend(result:Object):void
		{
			trace("FacebookGraphProxy:: onSend:" );
			if (result) {
				sendNotification( AppConstants.LOGPLAYLISTSENDOK );
				var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("success", "Message Sent!", "Thanks for spreading the word :)", null, [], 1500 );
				var _request:SystemMessageRequest = new SystemMessageRequest(_itemVO);
				sendNotification( AppConstants.ADDSYSTEMMESSAGE, _request );
			} else {
				sendNotification( AppConstants.LOGPLAYLISTSENDCANCEL );
			}
		}

		public function postPlaylist( _p:PlaylistVO ):void
		{
			trace("FacebookGraphProxy:: postPlaylist:", _p.pid );
			var _args:Object = {
				link:_siteURL + "?fb_source=userPost&p=" + _p.pid,
				href:_siteURL + "?fb_source=userPost&p=" + _p.pid,
				picture: "http://videoswipe.net/img/playlist/" + _p.pid + ".jpg?" + Math.random(),
				description:"Connect with friends and watch videos together, share playlists and keep in touch while watching. VideoSwipe: the revolution will be live-streamed",
				title: _p.title
			} 
			// add new Open Graph meta tag format
			_args.url = _args.link;
			_args.image = _args.picture;
			_args.title = _args.description;
			_args.type = "video.movie";
			if (CONFIG::tablet) {
				var messageTitle:String = "title for the message";
				var messageUrl:String = "Link to the application";
				var messageDescription:String = "Whatever you'd like to say";
				var appThumb:String = _args.picture;
				var redirectUrl:String = "http://videoswipe.net/getapp.php";
				var URLString:String = "https://www.facebook.com/dialog/feed?app_id=" + APPID +"&link="+messageUrl+"&picture="+appThumb+"&name="+messageTitle+"&description="+messageDescription+"&redirect_uri="+redirectUrl;
				var req:URLRequest = new URLRequest(URLString);
				try{ navigateToURL(req,"_blank"); }
				catch (e:Error){ trace(">> ERROR <<", e.message); } 
			} else {
				Facebook.ui("feed", _args, onPostPlaylist);
			}
		}
		private function onPostPlaylist(result:Object):void
		{
			trace("FacebookGraphProxy:: onPostToUserWall:" );
			for (var i:String in result) {
				trace(i, ":", result[i]);
			}
			if (result) {
				sendNotification( AppConstants.LOGPLAYLISTPOSTOK );
				var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("success", "Playlist Posted!", "Thanks for spreading the word :)", null, [], 1500 );
				var _request:SystemMessageRequest = new SystemMessageRequest(_itemVO);
				sendNotification( AppConstants.ADDSYSTEMMESSAGE, _request );
			} else {
				sendNotification( AppConstants.LOGPLAYLISTPOSTCANCEL );
			}
		}

		public function sendPlaylist( _p:PlaylistVO ):void
		{
			trace("FacebookGraphProxy:: sendPlaylist:", _p.pid );
			var _args:Object = {
				link:_siteURL + "?fb_source=sendToUser&p=" + _p.pid
				};
				// add new Open Graph meta tag format
				_args.url = _args.link;
			Facebook.ui("send", _args, onSend);				
		}

		
		// connectAsGuest
		// similar to connect but for connecting as a guest user
		// ONLY CALLED BY ME
		// set up the proxies with relevant user info data and connect
		public function connectAsGuest():void
		{
			trace("FacebookGraphProxy:: connectAsGuest:", vo.uid );
			userIdentified( vo.uid );
		}
		// onAuthResponseChange - UNUSED
		// will return in the result object a status of "offline", "connected", "idle", "error"
		// can use this to decide what to do next
		private function onAuthResponseChangeX(result:Object):void
		{
			trace("FacebookGraphProxy:: onAuthResponseChange:", result.status );
			switch (result.status) {
				case "offline":
					vo.connected = false;
					break;
				case "connected":
					vo.connected = true;
					break;
			}
			//sendNotification(AppConstants.FACEBOOKONLINESTATUS, vo.connected );
		}


		// GETTER/SETTERS
		public function get connected():Boolean
		{
			return vo.connected;
		}
		public function set vo(_f:FacebookVO):void
		{
			data = _f;
		}
		public function get vo():FacebookVO {
			return data as FacebookVO;
		}

	}
}