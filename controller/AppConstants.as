package com.videoswipe.controller 
{
	/**
	 * ...
	 * @author 
	 */
	public class AppConstants 
	{
		// Misc constants
		public static const ADDSYSTEMMESSAGE:String = "addsystemmessage";
		public static const COPYTOCLIPBOARD:String = "copytoclipboard";
		public static const KEYBOARDEVENT:String = "keyboardevent";
		public static const KEYBOARDINPUTDONE:String = "keyboardinputdone";
		public static const HELPSLIDE:String = "helpslide";
		public static const HELPSLIDEDONE:String = "helpslidedone";
		public static const FEEDBACKSLIDE:String = "feedbackslide";
		public static const TOPTENSLOADED:String = "toptensloaded";
		public static const USERREQUESTHELP:String = "userrequesthelp";
		public static const PROMPTINVITEFRIENDS:String = "promptinvitefriends";
		public static const SESSION_DATA:String = "SessionData";
		public static const ADD_STREAM:String	= "AddStream";
		public static const REMOVE_STREAM:String = "RemoveStream";
		public static const STREAM_CAMERA:String = "StreamCamera";
		public static const ADDVIDEOMESSAGE:String = "addvideomessage";
		
		// Constants which do nothing but register that an event took place
		public static const LOGFRIENDINVITED:String = "logfriendinvited";
		public static const LOGFRIENDSINVITED:String = "logfriendsinvited";
		public static const LOGCONNECTCLICKED:String = "logconnectclicked";
		public static const LOGPOSTPLAYLIST:String = "logpostplaylist";
		public static const LOGSENDPLAYLIST:String = "logsendplaylist";
		public static const LOGPLAYLISTPOSTOK:String = "logplaylistpostok";
		public static const LOGPLAYLISTPOSTCANCEL:String = "logplaylistpostcancel";
		public static const LOGPLAYLISTSENDOK:String = "logplaylistsendok";
		public static const LOGPLAYLISTSENDCANCEL:String = "logplaylistsendcancel";
		public static const LOGSEARCH:String = "logsearch";
		public static const LOGCAMERASTREAMING:String = "logcamerastreaming";
		public static const LOGAUTHORISEYOUTUBE:String = "logauthoriseyoutube";
		
		// Server constants
		public static const ATTEMPTCONNECT:String = "attemptconnect";
		public static const INVITEFRIEND:String = "invitefriend";
		public static const INVITEFROMFRIEND:String = "invitefromfriend";
		public static const INVITERESPONDED:String = "inviteresponded";
		public static const REQUESTFROMFRIEND:String = "requestfromfriend";
		public static const REQUESTFRIEND:String = "requestfriend";
		public static const RESPONDTOREQUEST:String = "respondtorequest";
		public static const REQUESTRESPONDED:String = "requestresponded";
		public static const FRIENDOFFLINE:String = "friendoffline";
		public static const SERVERPLAYERSTATECHANGE:String = "serverplayerstatechange";
		public static const SERVERSTREAMRECORDING:String = "serverstreamrecording";
		
		// Playlist constants
		public static const CLIENTADDTOPLAYLIST:String = "clientaddtoplaylist";
		public static const SERVERADDTOPLAYLIST:String = "serveraddtoplaylist";
		public static const CLIENTPLAYVIDEOITEM:String = "clientplayvideoitem";
		public static const SERVERPLAYVIDEOITEM:String = "serverplayvideoitem";
		public static const SERVERDELETEPLAYLISTITEM:String = "serverdeleteplaylistitem";
		public static const SERVERMOVEPLAYLISTITEM:String = "servermoveplaylistitem";
		public static const CLIENTLOADPLAYLIST:String = "clientloadplaylist";
		public static const SERVERLOADPLAYLIST:String = "serverloadplaylist";
		public static const PLAYLISTUPDATED:String = "playlistupdated";
		public static const PLAYLISTLOADED:String = "playlistloaded";
		public static const PLAYLISTDELETED:String = "playlistdeleted";
		public static const PLAYLISTSLOADED:String = "playlistsloaded";
		public static const PLAYLISTSAVED:String = "playlistsaved";
		public static const PLAYLISTSAVEERROR:String = "playlistsaveerror";
		public static const YOUTUBEPLAYLISTSLOADED:String = "youtubeplaylistsloaded";
		public static const YOUTUBEPLAYLISTLOADED:String = "youtubeplaylistloaded";
		public static const SERVERREQUESTPLAYLIST:String = "serverrequestplaylist";
		public static const SERVERSYNCPLAYLIST:String = "serversyncplaylist";
		
		// Search constants
		public static const NEWSEARCH:String = "newsearch";
		public static const FEEDRESULT:String = "feedresult";
		public static const CHANNELSEARCHRESULT:String = "channelsearchresult";
		public static const USERSUBSCRIPTIONRESULT:String = "usersubscriptionresult";

		// Chat constants
		public static const CLIENTNEWCHATMESSAGE:String = "clientnewchatmessage";
		public static const SERVERNEWCHATMESSAGE:String = "servernewchatmessage";
		public static const ADDCHATVIEW:String = "addchatview";
		public static const REMOVECHATVIEW:String = "removechatview";

		// Player constants
		public static const PLAYERREADY:String = "playerready";
		public static const PLAYERSTATECHANGE:String = "playerstatechange";
		public static const PLAYERITEMENDED:String = "playeritemended";
		public static const PLAYERERROR:String = "playererror";
		public static const PLAYERITEMPLAYING:String = "playeritemplaying";
		public static const PLAYERFULLSCREEN:String = "playerfullscreen";
		public static const PLAYERVOLUME:String = "playervolume";
		public static const CLIENTPLAYCLICKED:String = "clientplayclicked";
		public static const SERVERPLAYCLICKED:String = "serverplayclicked";
		public static const CLIENTPAUSECLICKED:String = "clientpauseclicked";
		public static const SERVERPAUSECLICKED:String = "serverpauseclicked";
		public static const CLIENTPLAYPAUSE:String = "clientplaypause";
		public static const CLIENTSEEKTO:String = "clientseekto";
		public static const SERVERSEEKTO:String = "serverseekto";

		public static const ADDSTREAMVIEW:String = "addstreamview";
		public static const REMOVESTREAMVIEW:String = "removestreamview";
		public static const ADDVIDEOMESSAGEVIEW:String = "addvideomessageview";
		public static const REMOVEVIDEOMESSAGEVIEW:String = "removevideomessageview";
		public static const REMOVEALLVIDEOMESSAGES:String = "removeallvideomessages";
		
		// Connection Statuses
		public static const OFFLINE:int = 0;
		public static const CONNECTING:int = 1;
		public static const ONLINE:int = 2;
		
		// Display
		public static const STAGERESIZE:String = "stageresize";
		public static const MOUSEMOVE:String = "mm";
		public static const STAGECLEAR:String = "stageclear";
		
		// Logging
		public static const ALLLOGSLOADED:String = "alllogsloaded";
		public static const LOGLOADED:String = "logloaded";
		
		// Facebook
		public static const FACEBOOKONLINESTATUS:String = "facebookonlinestatus";
		public static const FACEBOOKFRIENDLISTS:String = "facebookfriendlists";
		public static const FACEBOOKFRIENDLIST:String = "facebookfriendlist";
		public static const FACEBOOKFRIENDS:String = "facebookfriends";
		public static const FACEBOOKONLINEFRIENDS:String = "facebookonlinefriends";
		public static const FACEBOOKSHARE:String = "facebookshare";
		public static const FACEBOOKUSERINFO:String = "facebookuserinfo";
		public static const FACEBOOKCOVERINFO:String = "facebookcoverinfo";
		public static const FACEBOOKFRIENDSONLINESTATUS:String = "facebookfriendsonlinestatus";
		public static const FACEBOOKWRITEINFOTODB:String = "facebookwriteinfotodb";
		public static const FACEBOOKLOGINOK:String = "facebookloginok";
		public static const FACEBOOKLOGINCANCEL:String = "facebooklogincancel";
		public static const FACEBOOKREQUESTSENT:String = "facebookrequestsent";
	}

}