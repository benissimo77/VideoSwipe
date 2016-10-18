/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.adobe.webapis.URLLoaderBase;
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import com.videoswipe.model.vo.UserManagerVO;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.observer.Notification;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/*
	 * A proxy
	 */
	public class UserManagerProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "UserManagerProxy";

		private var _fileStub:String;
		private var _flashVars:Object;	// cache the flashVars object (we will send to DB once user identified)
		private var _userData:Object;	// caches the response from the getUserData call
		private var _invitation:Object	// caches all invitation details (if user was invited to the app)
		private var _onlineFriends:Object	// caches the list of user's online friends
		private var _feedbackDelay:int;	// how long before we display the feedback question
		private var _playlistsLoader:URLLoader;
		private var _topTensLoader:URLLoader;
		private var _initialised:Boolean;	// flag set once everything completed, we don't then re-do everything if user initiates a new facebook login (or adds friendlists)
		private var _feedbackTimer:Timer;


		public function UserManagerProxy( _f:Object = null) {
			super(NAME, new UserManagerVO() );
			
			_fileStub = "/go/db/";
			if (!ExternalInterface.available) {
				_fileStub = "http://videoswipe.net/go/db/";
				// *** TESTING - use co.uk for script access
				// ***
				//_fileStub = "http://videoswipe.co.uk/go/db/";
			}
			_flashVars = _f;
		}

		override public function onRegister():void {
			// nothing much happens here until we have a uid
			_feedbackDelay = 200;
			if (ExternalInterface.available) {
				_feedbackDelay = 360000;
			}
			_feedbackTimer = new Timer( _feedbackDelay, 1);
			_feedbackTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
			
			_playlistsLoader = new URLLoader();
			_playlistsLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_playlistsLoader.addEventListener(Event.COMPLETE, userPlaylistsLoaded);
			_topTensLoader = new URLLoader();
			_topTensLoader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			_topTensLoader.addEventListener(Event.COMPLETE, topTensLoaded);
			// TESTING - call the invitation fn with dummy value
			//var _r:Object = { "to":["100007939239063"], "request":"227511550788860", "e2e":"{\"submit_0\":1396430109001}" };
			//storeUserInvitation( _r );

			_initialised = false;
		}

		// userIdentifed
		// the entire initialisation chain starts here...
		public function userIdentified( _o:Object ):void
		{
			var _f:FacebookVO = _o as FacebookVO;
			trace("UserManagerProxy:: userIdentified:", _f.uid );
			if (_f.uid) vo.uid = _f.uid;
			if (_f.name) vo.name = _f.name;
			if (_f.connected) {
				vo.isFacebookUser = _f.connected;
				saveUserInfo( _f );
			}
			loadUsersPlaylists();
			// remaining stuff we only want to do ONE time per session - might already have done this
			if (!_initialised) {
				loadTopTens();		// Top10 lists
				getUserData();		// retrieves info on this user, calls processFlashVars
				writeFlashvarsToDB();	// do this last because getUserData expects current session NOT to be written
				_initialised = true;
			}
		}
		
		private function getUserData():void
		{
			trace("UserManagerProxy:: getUserData:", vo.uid );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = vo.uid;
			_vars.action = _flashVars.action;
			var _url:String = _fileStub + "getUserData.php";
			var _r:URLRequest = new URLRequest( _url );
			_r.data = _vars;
			_r.method = "POST";
			var _s:URLLoader = new URLLoader( _r );
			_s.addEventListener(Event.COMPLETE, onUserData);
			_s.load(_r);
		}
		private function onUserData(e:Event):void
		{
			trace("UserManagerProxy:: onUserData:", e.currentTarget.data );
			if (e.currentTarget.data && e.currentTarget.data != "BAD") {
				
				_userData = JSON.parse( e.currentTarget.data );

				// we have pulled back some data to display to the user
				// at the moment this could be one or both of:
				// feedbackData - we want to solicit the user for feedback
				// helpData - we want to display a help slide to show the user how it works
				//
			
				// Oriignal feedback slide:
				// {"type":"request","text":null,"data":null,"htmlText":"We would <b>really</b> appreciate your opinion on this before we give up our day jobs!<br/><br/><b>How are we doing with VideoSwipe so far?</b>","timerDelay":0,"title":"Could we ask you ONE question...?","buttons":["It rocks!","I'm curious","Meh...","Hmmm... nope","It sucks :("]}

				// the line below injects feedbackID 1 to the screen
				//_userData.feedbackData = '{ "type":"request", "text":null, "data":null, "htmlText":"Would you mind helping us out with these TWO questions?<br/><br/><b>Whats the WORST thing about VideoSwipe?</b>", "title":"Hello, its us again... :)", "buttons":["YouTube panel", "Playlist panel", "Facebook panel", "The whole interface", "Nothing, its all good!"] , "followupQuestion": [ { "type":"request", "text":null, "data":null, "htmlText":"<b>So which of these would MOST improve the YouTube panel?", "title":"Ok, thanks!", "buttons":[ "More Top 10 Lists", "More/better recommendations", "Better search", "Easier scrolling", "Access my YouTube stuff"] }, { "type":"request", "text":null, "data":null, "htmlText":"<b>And if you could add a NEW feature which if these would you like most?</b>", "title":"Ok, thanks!", "buttons":["More Top 10 Lists", "More/better recommendations", "Better help", "iPad/Android version", "Nothing, Im happy!"] }, { "type":"request", "text":null, "data":null, "htmlText":"<b>And if you could add a NEW feature which if these would you like most?</b>", "title":"Ok, thanks!", "buttons":["More Top 10 Lists", "More/better recommendations", "Better help", "iPad/Android version", "Nothing, Im happy!"] }, { "type":"request", "text":null, "data":null, "htmlText":"<b>So which of these would MOST improve the interface?</b>", "title":"Ok, thanks!", "buttons":["Panels NOT transparent", "Panels dont slide", "Scrolling easier", "YouTube not fullscreen", "Keyboard shortcuts" ] }, { "type":"request", "text":null, "data":null, "htmlText":"<b>So if you could add a NEW feature which if these would you like most?</b>", "title":"Ok, thanks!", "buttons":["More Top 10 Lists", "More/better recommendations", "Better help", "iPad/Android version", "Nothing, Im happy!"] } ] }';
				if (_userData.feedbackData) {
					_feedbackTimer.reset();
					_feedbackTimer.start();
				}

				if (_userData.slideData) {
					sendNotification( AppConstants.HELPSLIDE, JSON.parse(_userData.slideData) );
				}

				// now that we have retrieved userData we process FlashVars
				// we wait until here so that we can decide, based on userData, what to do...
				processFlashVars();	// retrieve invitation info (if relevant)

			}
		}

		// loadUsersPlaylists
		// once we have a UID we can load the users videoswipe playlists
		private function loadUsersPlaylists():void
		{
			trace("PlaylistProxy:: loadAllPlaylists:", vo.uid );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = vo.uid;
			var _r:URLRequest = new URLRequest( _fileStub + "loadAllPlaylists.php" );
			_r.data = _vars;
			_r.method = "POST";
			_playlistsLoader.load(_r);
		}
		private function userPlaylistsLoaded(e:Event):void
		{
			trace("PlaylistProxy:: playlistsLoaded:", e.currentTarget.data.length );
			if (e.currentTarget.data == "BAD") {
				// we have a problem, do nothing...
			} else {
				sendNotification(AppConstants.PLAYLISTSLOADED, JSON.parse(e.currentTarget.data));
			}
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("PlaylistProxy:: IOErrorHandler:" );
		}

		// loadTopTens
		// load public top 10 lists - uses current PID as a guide to relevant lists
		private function loadTopTens():void
		{
			var _vars:URLVariables = new URLVariables();
			_vars.pid = _flashVars.p;
			_vars.uid = vo.uid;	// for testing
			var _r:URLRequest = new URLRequest( _fileStub + "loadTopTens.php" );
			_r.data = _vars;
			_r.method = "POST";
			_topTensLoader.load(_r);
		}
		private function topTensLoaded(e:Event):void
		{
			trace("UserManagerProxy:: topTensLoaded:", e.currentTarget.data.length );
			if (e.currentTarget.data == "BAD") {
				// we have a problem, do nothing...
			} else {
				sendNotification(AppConstants.TOPTENSLOADED, JSON.parse(e.currentTarget.data));
			}
			
		}

		// saveUserInfo
		// NOTE: userData is info for help/feedback slides, userInfo is *all* the FB info (eg devices, locale)
		private function saveUserInfo( result:FacebookVO ):void
		{
			trace("UserManagerProxy:: saveUserInfo:", result.uid );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = result.uid;
			_vars.name = result.name;
			_vars.username = result.username;
			_vars.gender = result.gender;
			_vars.locale = result.locale;
			_vars.timezone = result.timezone;
			_vars.age_range = result.age_range;
			_vars.installed = result.installed;
			_vars.devices = JSON.stringify(result.devices);
			_vars.email = result.email;	// email is an extra field on top of public profile
			var _url:String = _fileStub + "saveUserInfo.php";
			var _r:URLRequest = new URLRequest( _url );
			_r.data = _vars;
			_r.method = "POST";
			var _s:URLLoader = new URLLoader( _r );
			_s.load(_r);
		}

		private function writeFlashvarsToDB():void
		{
			trace("UserManagerProxy:: writeFlashvarsToDB:", _flashVars.s );
			var _url:String = _fileStub + "saveFlashvars.php";
			var _r:URLRequest = new URLRequest( _url );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = "uid";
			if (vo.uid) {
				_vars.uid = vo.uid;
			};
			_vars.flashvars = JSON.stringify( _flashVars );
			_r.method = "POST";
			_r.data = _vars;
			var _s:URLLoader = new URLLoader( _r );
			_s.load(_r);
		}

		// processFlashVars
		// function called one time only, when user has been identified
		// look through the passed-in FlashVars to see if there are any initial things to set up
		private function processFlashVars():void
		{
			// have we requested an initial playlist?
			if (_flashVars.p) {
				sendNotification( AppConstants.SERVERLOADPLAYLIST, { source:"VS", pid:_flashVars.p } );
			}

			// are we asking to join a user? Note: don't request to join if u is this person!
			if (_flashVars.u && _flashVars.u != vo.uid ) {
				sendNotification( AppConstants.RESPONDTOREQUEST, { inviteFrom: _flashVars.u } );
			} else if (_flashVars.request_ids) {
				// OR have we arrived via a Facebook request?
				var _userArray:Array = _flashVars.request_ids.split(",", 1);
				if (_userArray[0]) {
					getInvitationDetails(_userArray[0]);
				}
			} else {
				// if neither then ask if user wants to invite friends now
				//sendNotification( AppConstants.PROMPTINVITEFRIENDS );
			}
		}
		private function getInvitationDetails( _u:String ):void
		{
			trace("UserManagerProxy:: getInvitationDetails:", _u );
			var _url:String = _fileStub + "getInvitation.php";
			var _r:URLRequest = new URLRequest( _url );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = vo.uid;
			_vars.request = _u;
			_r.method = "POST";
			_r.data = _vars;
			var _s:URLLoader = new URLLoader( _r );
			_s.addEventListener(Event.COMPLETE, onInvitationDetails);
			_s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_s.load(_r);
		}
		public function onInvitationDetails(e:Event):void
		{
			trace("UserManagerProxy:: onInvitationDetails:", e.currentTarget.data );
			_invitation = JSON.parse( e.currentTarget.data );
			if (_invitation && _invitation.inviteFrom) {
				// we have retrieved the user who sent this invite!
				// decide what to do here...
				trace("UserManagerProxy:: onInvitationDetails:", _invitation.inviteFrom );
				sendNotification( AppConstants.RESPONDTOREQUEST, _invitation );
			}
		}

		// storeUserInvitation
		// User has invited a friend to join - store details in tbl_invitations ready for retrieval later
		// result contains details of the invite (user might have cancelled)
		public function storeUserInvitation( _request:Object ):void
		{
			var _url:String = _fileStub + "saveInvitation.php";
			var _r:URLRequest = new URLRequest( _url );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = vo.uid;
			_vars.name = vo.name;
			_vars.request = JSON.stringify( _request );
			_r.method = "POST";
			_r.data = _vars;
			var _s:URLLoader = new URLLoader( _r );
			_s.addEventListener(Event.COMPLETE, invitationStored);
			_s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_s.load(_r);
		}
		private function ioErrorHandler( e:IOErrorEvent ):void
		{
			trace("UserManagerProxy:: ioErrorHandler:", e.currentTarget.data );
		}
		private function invitationStored(e:Event):void
		{
			trace("UserManagerProxy:: invitationStored:", e.currentTarget.data );
			// {"to":["100007939239063"],"request":"227511550788860","e2e":"{\"submit_0\":1396430109001}"}
		}
		private function timerHandler(e:TimerEvent=null):void
		{
			var _f:Object = JSON.parse(_userData.feedbackData);
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO(_f.type, _f.title, _f.text, _f.htmlText, _f.buttons, _f.timerDelay, _userData.feedbackID );
			var request:SystemMessageRequest = new SystemMessageRequest( _itemVO, responseHandler, this );
			sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
		}

		// responseHandler
		// handler for the user feedback form (called via the system message mediator)
		public function responseHandler(e:Notification):void
		{
			trace("UserManagerProxy:: responseHandler:", e.getName(), e.getBody() );
			var _vars:URLVariables = new URLVariables();
			_vars.uid = vo.uid;
			_vars.feedbackid = e.getBody().data;
			_vars.response = e.getName();
			_vars.responsecode = 0;
			// translate response to a code by iterating through button strings checking index
			var _b:Array = e.getBody().buttons;
			for (var i:int = _b.length; i-- > 0; ) {
				if (_b[i] == e.getName()) {
					_vars.responsecode = i+1;	// use traditional 1-5 counting, with 0 for 'no result'
				}
			}
			var _url:String = _fileStub + "writeUserFeedback.php";
			var _r:URLRequest = new URLRequest( _url );
			_r.data = _vars;
			_r.method = "POST";
			var _s:URLLoader = new URLLoader( _r );
			_s.load(_r);
			
			// we now have the possibility of a follow-up question based on the response of the first
			// recurse back through the system using the responseData object if available
			var _followupQuestion:Boolean;
			var _f:Object = JSON.parse(_userData.feedbackData);
			if (_f.followupQuestion && _vars.responsecode > 0 && _vars.responsecode <= _f.followupQuestion.length) {
				if (_f.followupQuestion[ _vars.responsecode - 1]) {
					_userData.feedbackData = JSON.stringify( _f.followupQuestion[ _vars.responsecode - 1 ] );
					_followupQuestion = true;
				}
			}
			if (_followupQuestion) {
				_userData.feedbackID++;	// use the next ID for the followup (hack?!)
				timerHandler();	// will invoke the next SystemMessageItem using the followup question
			} else {
				var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("success", "OK got it, THANKS! :)", null, null, [], 1400, null);
				var _request:SystemMessageRequest = new SystemMessageRequest( _itemVO, null, null);
				sendNotification( AppConstants.ADDSYSTEMMESSAGE, _request );
			}
		}
		
		// GETTER/SETTERS
		public function get vo():UserManagerVO {
			return data as UserManagerVO;
		}

	}
}