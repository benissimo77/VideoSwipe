/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.UserManagerProxy;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class UserIdentifiedCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var _ump:UserManagerProxy = facade.retrieveProxy( UserManagerProxy.NAME ) as UserManagerProxy;
			_ump.userIdentified( note.getBody() );
		}
		
	}
}