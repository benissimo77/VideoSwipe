/*
 * DO CALL COMMAND
 * Executes the set of tasks to make a real call happen:
 * creates a StreamViewer object attached to a camera for streaming the client webcam
 * 
 */
package com.videoswipe.controller
{
	import nl.brevidius.model.JWPlayerProxy;
	import nl.brevidius.model.vo.WebcamVO;
	import nl.brevidius.view.CallRequestMediator;
	import nl.brevidius.view.component.CameraView;

    import org.puremvc.as3.interfaces.ICommand;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.command.SimpleCommand;

	import nl.brevidius.ApplicationFacade;
	import nl.brevidius.model.CallRequestModel;
	import nl.brevidius.model.CameraListModel;
	import nl.brevidius.model.NetConnectionProxy;
	import nl.brevidius.model.SessionDataProxy;
	import nl.brevidius.model.WebcamProxy;

    public class DoCallCommand extends SimpleCommand implements ICommand
    {
        /**
         * Register the Proxies and Mediators.
         * 
         * Get the View Components for the Mediators from the app,
         * which passed a reference to itself on the notification.
         */
        override public function execute( note:INotification ) : void    
        {
			trace("DoCallCommand:: execute: hello.");
			

			// Many things to do when a call is created... firstly remove the CallRequest model/view since they have done their job
			if (facade.hasProxy(CallRequestModel.NAME)) facade.removeProxy(CallRequestModel.NAME);
			if (facade.hasMediator(CallRequestMediator.NAME)) {
				var crm:CallRequestMediator = facade.retrieveMediator(CallRequestMediator.NAME) as CallRequestMediator;
				crm.killMe();
				facade.removeMediator(CallRequestMediator.NAME);
			}

			// NOTE: we are using a dedicated WebcamProxy instead of a generic StreamProxy since we only want one webcam so it makes sense to use a singleton
			// for the other streams we can use the same proxy each time, so we will use a different system
			//
			// NOTE ALSO: this command might be executing when we are ALREADY in a call.
			// This can happen if user was in a call then made/received a call request to a third person
			// In this case we just need to add the new stream.
			// We use the existence of the WebcamProxy to determine if we already in a call or not (when call ends webcamproxy is destroyed)
			if (facade.hasProxy(WebcamProxy.NAME)) {

			} else {

				var wp:WebcamProxy = new WebcamProxy();
				facade.registerProxy(wp);

				// if we have a pluginProxy then this means we are running beeldbellen as a plugin - pause the player (and show the plugin)
				if (facade.hasProxy(JWPlayerProxy.NAME)) {
					var jwp:JWPlayerProxy = facade.retrieveProxy(JWPlayerProxy.NAME) as JWPlayerProxy;
					jwp.pausePlayer();
				}

				var sdp:SessionDataProxy = facade.retrieveProxy(SessionDataProxy.NAME) as SessionDataProxy;
				sdp.addStream(sdp.user.token);

				var clp:CameraListModel = facade.retrieveProxy(CameraListModel.NAME) as CameraListModel;
				var cam:WebcamVO = wp.vo;
				cam.camera = clp.getActiveCamera();	// the implicit setter will automatically set cam settings
				cam.streamName = sdp.user.token;	// use the user token, the room will be added at the server...

				var codec:String = "";
				if (sdp.codec) codec = sdp.codec;
				cam.codec = codec;

				var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
				var sv:CameraView = new CameraView(ncp.netConnection, cam);

				sendNotification(ApplicationFacade.ADD_STREAMVIEW, sv);
			}
			
        }
    }
}
