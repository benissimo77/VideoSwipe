/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
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
	public class RequestFromFriendCommand extends SimpleCommand {
		
		private var _ncp:NetConnectionProxy;
		private var _friendVO:FriendVO;

		override public function execute(note:INotification):void
		{
			_ncp = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			_friendVO = new FriendVO(note.getBody());
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("request", "Request from " + _friendVO.name, _friendVO.name + " wants to join you! Watch video together, collaborate on shared playlists and webcam chat while you do it!", null, ["Accept", "Decline"], 3000, note.getBody() );
			var request:SystemMessageRequest = new SystemMessageRequest( _itemVO, handleClick, this );
			sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
		}

		private function handleClick(e:Notification):void
		{
			trace("RequestFromFriendCommand:: handleClick:", e.getName(), e.getBody() );
			
			switch (e.getName()) {
				
				case "Accept":
					_ncp.clientAcceptRequest(_friendVO);
					break;
				case "Decline":
					_ncp.clientCancelRequest(_friendVO);
					break;
					
				default:
					// timer expired or user clicks view outside of buttons
					// default accept request
					_ncp.clientAcceptRequest(_friendVO);
					break;
					
			}
		}
	}
}