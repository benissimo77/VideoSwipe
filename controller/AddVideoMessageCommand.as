/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.view.component.StreamView;
	import com.videoswipe.view.component.VideoMessageView;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class AddVideoMessageCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {

			trace("AddVideoMessageCommand:: execute: " + note.getBody().streamName);

			var _sessionID:String = note.getBody().sessionID;
			var _streamname:String = note.getBody().streamName;
			
			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			var sv:VideoMessageView = new VideoMessageView(ncp.netConnection);
			sv.uid = ncp.uid;
			sv.streamname = _streamname;
			sv.netStream.play("mp4:" + _sessionID + "/" + _streamname + ".f4v", 0);

			sendNotification(AppConstants.ADDVIDEOMESSAGEVIEW, sv);
		}
	}
}
