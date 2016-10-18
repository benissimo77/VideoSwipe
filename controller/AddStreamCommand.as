/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.view.component.StreamView;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class AddStreamCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {

			trace("AddStreamCommand:: execute: " + note.getBody().streamName);

			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			var sv:StreamView = new StreamView(ncp.netConnection);
			sv.uid = ncp.uid;
			sv.streamname = note.getBody().streamName;
			sv.netStream.play(note.getBody().streamName);

			sendNotification(AppConstants.ADDSTREAMVIEW, sv);
		}
	}
}
