/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.CameraListModel;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.vo.WebcamVO;
	import com.videoswipe.model.WebcamProxy;
	import com.videoswipe.view.component.CameraView;
	import com.videoswipe.view.component.StreamView;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
    
	/**
	 * SimpleCommand
	 */
	public class StreamCameraCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			// if we already have a webcamproxy object then we are already streaming the webcam, no need to continue
			if (facade.hasProxy(WebcamProxy.NAME)) {

			} else {

				var wp:WebcamProxy = new WebcamProxy();
				facade.registerProxy(wp);

				var ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
				var clp:CameraListModel = facade.retrieveProxy(CameraListModel.NAME) as CameraListModel;

				trace("StreamCameraCommand:: execute:", clp.getActiveCamera().width, clp.getActiveCamera().height );

				var cam:WebcamVO = wp.vo;
				cam.camera = clp.getActiveCamera();	// the implicit setter will automatically set cam settings
				cam.streamname = ncp.uid;
				if (!cam.streamname) {
					trace("GOT IT");
					cam.streamname = "anonymous" + Math.random();
				}

				var sv:CameraView = new CameraView(ncp.netConnection, cam);

				trace("StreamCameraCommand:: execute:", sv.width, sv.height );
				
				sendNotification(AppConstants.ADDSTREAMVIEW, sv);				
			}
		}
		
	}
}