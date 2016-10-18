/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * SimpleCommand
	 */
	public class RemoveStreamCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {

			trace("RemoveStreamCommand:: execute: " + note.getBody().streamName);

			// send note to remove this stream view from the streams display
			sendNotification(AppConstants.REMOVESTREAMVIEW, note.getBody().streamName);

		}
		
	}
}