/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class CopyToClipboardCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			var _s:String = note.getBody() as String;
			trace("CopyToClipboardCommand:: execute:", _s );
			Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _s);
		}
		
	}
}