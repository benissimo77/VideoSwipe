/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.LogViewerProxy;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.AllLogsVO;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.model.vo.LogItemVO;
	import com.videoswipe.model.vo.LogViewerEvent;
	import com.videoswipe.model.vo.LogVO;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.view.component.AllLogsViewer;
	import com.videoswipe.view.component.LogViewer;
	import com.videoswipe.view.component.VideoSwipeView;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.*;
	
	/**
	 * A Mediator
	 */
	public class LogViewMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "LogViewMediator";
		
		public function LogViewMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		override public function onRegister():void
		{
			// simulate a facebook login which will set up the user info
			var _f:FacebookVO = new FacebookVO( { uid:"xxx", username:"LogViewer" } );
			var _fgp:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
			_fgp.vo = _f;
			var _ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
			_ncp.setUserInfo( _f );

			// listen for logItem events which are notifications to send to facade
			logView.addEventListener( LogViewerEvent.EVENT, logItemListener);
			
			// listen for keyboard events for controlling various views
			viewer.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyListener );
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
			return LogViewMediator.NAME;
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
				AppConstants.ALLLOGSLOADED,
				AppConstants.LOGLOADED,
				AppConstants.MOUSEMOVE
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
				
				case AppConstants.ALLLOGSLOADED:
					trace("LogViewMediator:: handleNotification: ALLLOGSLOADED" );
					var _al:AllLogsVO = note.getBody() as AllLogsVO;
					allLogsView.allLogs = _al;
					break;
					
				case AppConstants.LOGLOADED:
					trace("LogViewMediator:: handleNotification: LOGLOADED" );
					var _l:LogVO = note.getBody() as LogVO;
					logView.sessionLog = _l;
					
					// testing - send the notes right away 
					for (var i:int = _l.logItems.length; i--; ) {
						var _logItem:LogItemVO = _l.logItems[i];
						//facade.sendNotification( _logItem.name, _logItem.body, _logItem.type );
					}
					break;
				
				case AppConstants.MOUSEMOVE:
					trace("SwipeViewMediator:: handleNotification: MOUSEMOVE" );
					swipeView.mouseMove( note.getBody().x, note.getBody().y );
					break;
					

				default:
					break;		
			}
		}

		// retrieve current log from log overview panel and send to proxy for loading
		private function loadCurrentLog():void
		{
			var _lvp:LogViewerProxy = facade.retrieveProxy( LogViewerProxy.NAME ) as LogViewerProxy;
			_lvp.loadLog( allLogsView.currentLogID );
		}
		private function logItemListener( e:LogViewerEvent ):void
		{
			trace("LogViewMediator:: logItemListener:", e.data );
			var _lvp:LogViewerProxy = facade.retrieveProxy( LogViewerProxy.NAME ) as LogViewerProxy;
			var _o:LogItemVO = _lvp.getLogItem( int(e.data) );
			dispatchLogItem(_o);
		}
		
		// function to send this logItem to the facade so the videoSwipe View can update
		// some of the notifications need to be fiddled with - this function handles the various fiddles...
		private function dispatchLogItem( _o:LogItemVO ):void
		{
			switch ( _o.name ) {
				
				case AppConstants.FACEBOOKUSERINFO:
					var _f:FacebookVO = new FacebookVO( _o.body );
					var _fgp:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
					_fgp.vo = _f;
					_o.body = _f as Object;
					break;
					
				case AppConstants.PLAYLISTUPDATED:
					_o.body = new PlaylistVO( _o.body );
					break;
					
					
			}
			facade.sendNotification( _o.name, _o.body, _o.type );
		}
		
		private function keyListener( e:KeyboardEvent ):void
		{
			trace("Viewer:: keyListener:", e.keyCode );
			if (e.keyCode == Keyboard.UP) {
				if (e.shiftKey) {
					allLogsView.nextItem();
				} else {
					logView.nextItem();
				}
			}
			if (e.keyCode == Keyboard.DOWN) {
				if (e.shiftKey) {
					allLogsView.previousItem();
				} else {
					 logView.previousItem();
				}
			}
			if (e.keyCode == Keyboard.ENTER) {
				loadCurrentLog();
			}
		}

		private function get viewer():Viewer
		{
			return viewComponent as Viewer;
		}
		private function get logView():LogViewer
		{
			return viewer.lv as LogViewer
		}
		private function get allLogsView():AllLogsViewer
		{
			return viewer.alv;
		}
		private function get swipeView():VideoSwipeView
		{
			return viewer.vs as VideoSwipeView;
		}
	}
}