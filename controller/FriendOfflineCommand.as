/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.FriendVO;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * FriendOfflineCommand
	 * Called when a user invites a friend to join, but friend is offline
	 * Alternative call is made to the Facebook notification dialogue
	 */
	public class FriendOfflineCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {

			/*
			 * slightly changed functionality here
			 * automatically display the Facebook dialog, but also display a system message since this will appear must faster
			 * will help to cover the pause while the Facebook dialog is rendered
			 * UPDATE: dialog appears to render pretty quickly! Just bring up the dialog and be done...
			var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("warning", "This person is not connected!", "Send them a Facebook invitation and as soon as they see it they can join you online.", null, ["OK"], 5000, _friendVO);
			_itemVO.htmlText = "<img src='https://graph.facebook.com/" + _friendVO.uid + "/picture'><font size='14'>Send them a Facebook invitation, and as soon as they see it they can join you online.\n\n</font>";
			_itemVO.buttons = ["OK"];

			var _request:SystemMessageRequest = new SystemMessageRequest(_itemVO);
			sendNotification(AppConstants.ADDSYSTEMMESSAGE, _request);
			 */
			var _friendVO:FriendVO = new FriendVO(note.getBody());
			var _fgp:FacebookGraphProxy = facade.retrieveProxy(FacebookGraphProxy.NAME) as FacebookGraphProxy;
			_fgp.requestToUsers(_friendVO.uid);
		}
		
	}
}