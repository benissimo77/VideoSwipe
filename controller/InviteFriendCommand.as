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
	 * InviteFriendCommand
	 * Informs the user that they are waiting for their friend to respond on their invite
	 * NOTE: the only callback defined here is to cancel the invite, this is automatically called when the timer expires
	 * Thus it is important that the timer delay is set to longer than the timer delay for the friend, otherwise this cancel event will trigger before the friend has had time to respond
	 */ 
	public class InviteFriendCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			var _friendVO:FriendVO = new FriendVO(note.getBody());
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("invite", "You are inviting " + _friendVO.name, "If they accept your invitation you can watch videos together, build shared playlists and webcam chat!", null, ["Cancel"], 6000, _friendVO );
			var request:SystemMessageRequest = new SystemMessageRequest( _itemVO, cancelInvite, this );
			sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
		}

		private function cancelInvite(e:Notification):void
		{
			trace("InviteFriendCommand:: cancelInvite:", e.getName(), e.getBody() );
			var _itemVO:SystemMessageItemVO = e.getBody() as SystemMessageItemVO;
			var _ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			_ncp.clientCancelInvite( new FriendVO(_itemVO.data) );
			//_ncp = null;
			//_itemVO = null;
			//e = null;
		}
	}
}