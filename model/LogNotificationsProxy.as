/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.controller.AppConstants;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class LogNotificationsProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "LogNotificationsProxy";

		private var _notificationCache:Array;
		private var _ignoreNotifications:Array;
		private var _includeBody:Array;
		private var _startTimer:int;
		
		public function LogNotificationsProxy(data:Object = null) {
			super(NAME, data);
			
		}

		override public function onRegister():void
		{
			_notificationCache = [];
			_ignoreNotifications = [
									AppConstants.PLAYLISTLOADED,
									AppConstants.PLAYLISTSLOADED,
									AppConstants.PLAYLISTUPDATED,
									AppConstants.FEEDRESULT,
									AppConstants.FACEBOOKFRIENDS,
									AppConstants.FACEBOOKFRIENDLISTS,
									AppConstants.TOPTENSLOADED,
									AppConstants.FACEBOOKWRITEINFOTODB,
									AppConstants.FACEBOOKUSERINFO
									];
			_includeBody = [
							AppConstants.MOUSEMOVE,
							AppConstants.SERVERPLAYVIDEOITEM,
							AppConstants.SERVERLOADPLAYLIST,
							AppConstants.LOGSEARCH
							];
			_startTimer = getTimer();
			
			trace("LogNotificationsProxy:: onRegister:" );
		}
		
		public function logNotification( name:String, type:String, body:Object ):void
		{
			//trace("LogNotificationsProxy:: logNotification:", name );
			var timer:int = getTimer() - _startTimer;
			
			// to conserve bandwidth some of the notifications are truncated so we don't send loads of data to the server
			if (_ignoreNotifications.indexOf( name ) > -1) {
				body = null;
			}
			if (body is DisplayObject || body is Event) {
				body = null;
			}

			// to conserve even more bandwidth (and make logging simpler) we don't even send the body except for a few notes
			var _o:Object = { timer:timer, name:name };
			if (_includeBody.indexOf( name ) > -1) {
				_o.body = body;
			}
			
			_notificationCache[ _notificationCache.length ] =  JSON.stringify( _o );

			// we don't send Mouse Move notes, batch them up and send on next 'real' note
			if (name == AppConstants.MOUSEMOVE) {
				// don't send
			} else {
				if (vo.connected) {
					vo.netConnection.call("clientLogNotification", null, vo.uid, _notificationCache );
					_notificationCache = [];
				}
			}
		}

		
		// PUBLIC GETTER/SETTERS
		public function get vo():NetConnectionProxy
		{
			return data as NetConnectionProxy;
		}


	}
}