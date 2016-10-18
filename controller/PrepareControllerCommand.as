/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class PrepareControllerCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			facade.registerCommand( AppConstants.ADD_STREAM, AddStreamCommand );
			facade.registerCommand( AppConstants.REMOVE_STREAM, RemoveStreamCommand );
			facade.registerCommand( AppConstants.STREAM_CAMERA, StreamCameraCommand );
			facade.registerCommand( AppConstants.INVITEFRIEND, InviteFriendCommand );
			facade.registerCommand( AppConstants.INVITEFROMFRIEND, InviteFromFriendCommand );
			facade.registerCommand( AppConstants.REQUESTFROMFRIEND, RequestFromFriendCommand );
			facade.registerCommand( AppConstants.REQUESTFRIEND, RequestFriendCommand );
			facade.registerCommand( AppConstants.FRIENDOFFLINE, FriendOfflineCommand );
			facade.registerCommand( AppConstants.COPYTOCLIPBOARD, CopyToClipboardCommand );
			facade.registerCommand( AppConstants.KEYBOARDEVENT, KeyboardCommand );
			facade.registerCommand( AppConstants.RESPONDTOREQUEST, RespondToRequestCommand );
			facade.registerCommand( AppConstants.USERREQUESTHELP, UserRequestHelpCommand );
			facade.registerCommand( AppConstants.PROMPTINVITEFRIENDS, PromptInviteFriendsCommand );
			facade.registerCommand( AppConstants.ADDVIDEOMESSAGE, AddVideoMessageCommand );
			facade.registerCommand( AppConstants.SERVERPLAYVIDEOITEM, ServerPlayVideoItemCommand );
			//facade.registerCommand( AppConstants.USERIDENTIFIED, UserIdentifiedCommand );
			//facade.registerCommand( NetConnectionProxy.CONNECTSUCCESS, ConnectSuccessCommand );
			//facade.registerCommand( AppConstants.STAGERESIZE, StageResizeCommand );
			//facade.registerCommand( AppConstants.FEEDRESULT, FeedResultCommand );
			//registerCommand( AppConstasnts.NEWSEARCH, NewSearchCommand );
		}
		
	}
}