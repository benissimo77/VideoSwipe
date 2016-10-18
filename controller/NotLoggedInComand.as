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
	public class NotLoggedInComand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			sendNotification(AppConstants.ADDSYSTEMMESSAGE, new SystemMessageRequest( new SystemMessageItemVO("warning", "You Can't Save Your Playlists Yet :(", "You must be connected (via Facebook) if you want to save or edit a playlist.\n\nConnect using the Facebook connect button. Connecting will also allow you to send messages to friends, swap playlists and watch videos together.\n\nGo on... CONNECT!", null, ["OK"], 3000)));

		}
		
	}
}