/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.adobe.webapis.URLLoaderBase;
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.AllLogsVO;
	import com.videoswipe.model.vo.LogItemVO;
	import com.videoswipe.model.vo.LogVO;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class LogViewerProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "LogViewerProxy";

		private var logLoader:URLLoader;
		
		public function LogViewerProxy() {
			data = new LogVO();;
			super(NAME, data);
			
		}

		override public function onRegister():void {
			trace("LogViewerProxy:: onRegister: hello" );
			
			logLoader = new URLLoader();
			logLoader.addEventListener(Event.COMPLETE, logLoaded);
		}
		
		public function loadAllLogs():void
		{
			var _allLogsLoader:URLLoader = new URLLoader();
			var _v:URLVariables = new URLVariables();
			var _r:URLRequest = new URLRequest( "http://videoswipe.net/go/db/loadAllLogs.php" );
			_r.method = "POST";
			_allLogsLoader.addEventListener( Event.COMPLETE, allLogsLoaded );
			_allLogsLoader.load( _r );
			
		}
		public function loadLog( id:int ):void
		{
			trace("LogViewerProxy:: loadLog:", id );
			var _v:URLVariables = new URLVariables();
			_v.logid = id;
			var _r:URLRequest = new URLRequest( "http://videoswipe.net/go/db/loadLog.php" );
			_r.method = "POST";
			_r.data = _v;
			logLoader.load( _r );
		}
		
		private function allLogsLoaded( e:Event ):void
		{
			trace("LogViewerProxy:: allLogsLoaded:", e.currentTarget.data );
			if (e.currentTarget.data == "BAD") {
				// do nothing
			} else {
				sendNotification( AppConstants.ALLLOGSLOADED, new AllLogsVO( JSON.parse( e.currentTarget.data ) ) );
			}
		}
		private function logLoaded( e:Event ):void
		{
			trace("LogViewerProxy:: logLoaded:", e.currentTarget.data );
			if (e.currentTarget.data == "BAD") {
				// error do nothing
			} else {
				vo = new LogVO( JSON.parse(e.currentTarget.data) );
				sendNotification( AppConstants.LOGLOADED, vo );
			}
		}
		
		public function getLogItem( i:int ):LogItemVO
		{
			if (i >= 0 && i < vo.logItems.length) {
				return vo.logItems[i];
			}
			return null;
		}
		public function set vo(_f:LogVO):void
		{
			data = _f;
		}
		public function get vo():LogVO {
			return data as LogVO;
		}

	}
}