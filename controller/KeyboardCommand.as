/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import flash.events.KeyboardEvent;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class KeyboardCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			// keyboard event is held inside the note
			var e:KeyboardEvent = note.getBody() as KeyboardEvent;
			
			trace("KeyboardCommand:: execute:", e.keyCode );
			switch (e.keyCode) {
				
				case 32:
					sendNotification( AppConstants.CLIENTPLAYPAUSE );
					break;
					
			}
		}
		
	}
}