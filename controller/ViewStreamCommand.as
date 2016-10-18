/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import nl.brevidius.ApplicationFacade;
	import nl.brevidius.model.NetConnectionProxy;
	import nl.brevidius.model.SessionDataProxy;
	import nl.brevidius.view.component.StreamView;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

    
	/**
	 * SimpleCommand
	 */
	public class ViewStreamCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {

			trace("ViewStreamCommand:: execute: " + note.getBody().streamName);

			// firstly, add this stream to the SessionData model and adjust the LayoutsModel
			var sdp:SessionDataProxy = facade.retrieveProxy(SessionDataProxy.NAME) as SessionDataProxy;
			sdp.addStream(note.getBody().streamName);
			
			var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
			var sv:StreamView = new StreamView(ncp.netConnection);
			sv.uid = ncp.uid;
			sv.streamname = note.getBody().streamName;
			sv.netStream.play(note.getBody().streamName);

			sendNotification(ApplicationFacade.ADD_STREAMVIEW, sv);
		}

	}
}

