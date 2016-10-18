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
	 * RespondToRequest
	 * If this user has arrived at VideoSwipe via an invitation (request) from a friend
	 * then we ask them if they would like to 'respond' to this invitation.
	 * A response will either be a request to join the friend - if they're online
	 * OR a FB request back.
	 * Logic is that the first is done, and if the friend turns out to be offline then the server
	 * returns a FriendOffline message and the second automatically happens.
	 */
	public class RespondToRequestCommand extends SimpleCommand {
		
		private var _ncp:NetConnectionProxy;
		private var _friendVO:FriendVO;

		override public function execute(note:INotification):void
		{
			_ncp = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			_friendVO = new FriendVO( { name:note.getBody().inviteFromName, uid:note.getBody().inviteFrom } );
			
			var _itemTitle:String = "You received an invitation!";
			var _itemBody:String = "Would you like to connect with your friend?";
			if ( _friendVO.name ) {
				_itemTitle = _friendVO.name + " sent you an invitation!";
				_itemBody = "Would you like to connect with " + _friendVO.name + "?";
			}
			_itemBody = _itemBody + "\n\nIf you connect you will watch tv together, using all the SYNCHRO features of VideoSwipe plus webcam and chat.\n\n";
			_itemBody = _itemBody + "If you don't connect you will use VideoSwipe on your own. You can connect with friends later by clicking their name in the Facebook panel on the left.";
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("request", _itemTitle, _itemBody, null, ["Sure, connect!", "No, not now"], 0, _friendVO );
			var request:SystemMessageRequest = new SystemMessageRequest( _itemVO, handleClick, this );
			sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
		}

		private function handleClick(e:Notification):void
		{
			trace("InviteFriendCommand:: handleClick:", e.getName(), e.getBody() );
			
			switch (e.getName()) {
				
				case "Sure, connect!":
					_ncp.clientRequestJoinFriend( _friendVO );
					break;
					
				default:
					// if user says no then we do nothing...
					break;
					
			}
		}
	}
}