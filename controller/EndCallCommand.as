/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import nl.brevidius.model.CallRequestModel;
	import nl.brevidius.model.JWPlayerProxy;
	import nl.brevidius.model.SessionDataProxy;
	import nl.brevidius.model.WebcamProxy;
	import nl.brevidius.view.CallRequestMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class EndCallCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			trace("EndCallCommand:: hello.");
			//ExternalInterface.call("endSession");

			// carry out all cleaning up duties to end the call:
			// - remove all streamviews (this is done by streamMediator which catches this notification)
			// - reset model to clear out call details (below)
			// - send msg to server that client is leaving (happens automatically once webcam object is deleted)
			// - remove callRequestModel since we don't need this anymore...
			// - if we are running within JWPlayer then resume playback
			var sdp:SessionDataProxy = facade.retrieveProxy(SessionDataProxy.NAME) as SessionDataProxy;
			sdp.removeAllStreams();
			if (facade.hasProxy(WebcamProxy.NAME)) {
				facade.removeProxy(WebcamProxy.NAME);
			}
			if (facade.hasProxy(CallRequestModel.NAME)) {
				facade.removeProxy(CallRequestModel.NAME);
			}
			if (facade.hasMediator(CallRequestMediator.NAME)) {
				var crm:CallRequestMediator = facade.retrieveMediator(CallRequestMediator.NAME) as CallRequestMediator;
				crm.killMe();
				facade.removeMediator(CallRequestMediator.NAME);
			}

			if (sdp.project == "ABCTV" && facade.hasProxy(JWPlayerProxy.NAME)) {
				var jwp:JWPlayerProxy = facade.retrieveProxy(JWPlayerProxy.NAME) as JWPlayerProxy;
				jwp.resumePlayer();	// will set to the state it was in before the call
			}
				
		}
		
	}
}