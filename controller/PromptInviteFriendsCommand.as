/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class PromptInviteFriendsCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void
		{
			trace("PromptInviteFriendsCommand:: execute:" );
			var _itemTitle:String = "Connect with your ONLINE Friends?";
			var _itemBody:String = "Click to connect, then select friends to invite.\n\n";
//			_itemBody = _itemBody + "If you don't connect you can always invite friends later, just click any friend in the Facebook panel (left) to send them an invite.";
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("request", _itemTitle, _itemBody, null, ["Sure, connect!", "No, not now"], 0);
			var request:SystemMessageRequest = new SystemMessageRequest( _itemVO, handleClick, this );
			sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
		}
		
		private function handleClick(e:Notification):void
		{
			trace("PromptInviteFriendsCommand:: handleClick:", e.getName(), e.getBody() );
			
			switch (e.getName()) {
				
				case "Sure, connect!":
					trace("PromptInviteFriendsCommand:: handleClick: SURE WHY NOT!" );
					var _fgp:FacebookGraphProxy = facade.retrieveProxy( FacebookGraphProxy.NAME ) as FacebookGraphProxy;
					_fgp.requestToUsers();
					break;
					
				default:
					// if user says no then we do nothing...
					break;
					
			}
		}

	}
}