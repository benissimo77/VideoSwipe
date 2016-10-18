/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import flash.display.Stage;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class StageResizeCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var s:Stage = note.getBody() as Stage;
			
			trace("StageResizeCommand:: execute:", s.displayState, s.stageWidth, s.stageHeight);
		}
		
	}
}