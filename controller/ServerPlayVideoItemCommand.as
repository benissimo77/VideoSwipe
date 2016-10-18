/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.VideoMessageProxy;
	import com.videoswipe.model.vo.VideoItemVO;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class ServerPlayVideoItemCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			trace("ServerPlayVideoItemCommand:: execute:", note.getBody() as String );

			var _plp:PlaylistProxy = facade.retrieveProxy( PlaylistProxy.NAME ) as PlaylistProxy;
			var i:int = _plp.getPlaylistItemIndex( note.getBody() as String ) ;
			_plp.currentlyPlaying = i;

			// firstly, new item so remove any old messages from previous item
			// then check if this item has any video messages, and take action
			var _vmp:VideoMessageProxy = facade.retrieveProxy( VideoMessageProxy.NAME ) as VideoMessageProxy;
			_vmp.deRegisterAllClients();
			sendNotification(AppConstants.REMOVEALLVIDEOMESSAGES);

			var _v:VideoItemVO = _plp.getPlaylistItemAt( _plp.currentlyPlaying );
			if (_vmp.recording) {
				// testing - don't display video messages if recording
				// maybe affects ability of camera to stream (causes failure to store stream)
			} else {
				for (var _m:int = _v.videoMessages.length; _m--; ) {
					_vmp.registerClient( _v.videoMessages[ _m].streamname );
					sendNotification( AppConstants.ADDVIDEOMESSAGE, { sessionID:_v.videoMessages[_m].sessionID, streamName:_v.videoMessages[_m].streamname } );
				}
			}

			// request to play a (valid) video item
			// check if we are recording, and send message to server to begin recording NOW!
			if (_vmp.recording) {
				var _ncp:NetConnectionProxy = facade.retrieveProxy( NetConnectionProxy.NAME ) as NetConnectionProxy;
				_ncp.clientRecordCamera();
			}

		}
		
	}
}