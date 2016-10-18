/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.NetConnectionClient;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.FriendVO;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */ 
	public class RequestFriendCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var _friendVO:FriendVO = new FriendVO(note.getBody());
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("request", "You are asking to join " + _friendVO.name, "If they accept your request you can watch videos together, build shared playlists and webcam chat!", null, ["Cancel"], 6000, _friendVO );
			var request:SystemMessageRequest = new SystemMessageRequest( _itemVO, cancelRequest, this );
			sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
		}

		private function cancelRequest(e:Notification):void
		{
			trace("RequestFriendCommand:: cancelRequest:", e.getName(), e.getBody() );
			var _itemVO:SystemMessageItemVO = e.getBody() as SystemMessageItemVO;
			var _ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			_ncp.clientCancelRequest( new FriendVO(_itemVO.data) );
			_ncp = null;
			_itemVO = null;
			e = null;
		}
	}
}