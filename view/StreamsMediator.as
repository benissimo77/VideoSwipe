package com.videoswipe.view
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.VideoMessageProxy;
	import com.videoswipe.model.vo.NetConnectionVO;
	import com.videoswipe.model.WebcamProxy;
	import com.videoswipe.view.component.CameraEvent;
	import com.videoswipe.view.component.CameraView;
	import com.videoswipe.view.component.StreamsView;
	import com.videoswipe.view.component.StreamView;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;


	public class StreamsMediator extends Mediator implements IMediator
	{
		public static const NAME:String	= 'StreamsMediator';

		private var _cameraView:CameraView;	// cache the stream that holds the camera
		private var _width:int;				// cached ref to total width/height of the streams canvas
		private var _height:int;

		private var publishCount:int = 0;	// testing number of recordings this session
		
		public function StreamsMediator(viewComponent:Object)
		{
			trace("StreamsMediator:: hello.");
			super( NAME, viewComponent as Sprite);
		}

		override public function onRegister():void
		{
			trace("StreamsMediator:: onRegister: hello. this.height:" + streamsView.height);
			streamsView.addEventListener(MouseEvent.CLICK, streamsClick);
			streamsView.addEventListener(CameraEvent.CAMERASTREAMING, cameraStreaming);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppConstants.ADDSTREAMVIEW,
				AppConstants.REMOVESTREAMVIEW,
				AppConstants.PLAYERSTATECHANGE,
				AppConstants.SERVERPLAYERSTATECHANGE,
				NetConnectionProxy.CONNECTSUCCESS,
				NetConnectionProxy.CONNECTIONCLOSED,
				AppConstants.SERVERSTREAMRECORDING
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var name:String = notification.getName();
			var body:Object = notification.getBody();
			var _s:StreamView;
			var i:uint;

			switch ( name )
			{
				
				case AppConstants.ADDSTREAMVIEW:
					trace("StreamsMediator:: handleNotification: ApplicationFacade.ADD_STREAMVIEW");
					_s = body as StreamView;
					//_s.addEventListener(MouseEvent.CLICK, videoClick);
					streamsView.addStreamView(_s);
					break;

				case AppConstants.REMOVESTREAMVIEW:
					trace("StreamsMediator:: handleNotification: ApplicationFacade.REMOVE_STREAMVIEW");
					var _streamName:String = body as String;
					streamsView.removeStreamView(_streamName);
					break;
					
				case AppConstants.PLAYERSTATECHANGE:
					trace("StreamsMediator:: handleNotification: AppConstants.PLAYERSTATECHANGE" );
					streamsView.playerStateChange(body);
					break;
					
				case AppConstants.SERVERPLAYERSTATECHANGE:
					trace("StreamsMediator:: handleNotification: AppConstants.SERVERPLAYERSTATECHANGE", body.token, body.state, body.dur, body.progress );
					streamsView.playerStateChange(body);
					break;
					
				case NetConnectionProxy.CONNECTSUCCESS:
					trace("StreamsMediator:: handleNotification: CONNECTSUCCESS" );
					var _ncvo:NetConnectionVO = notification.getBody() as NetConnectionVO;
					streamsView.userConnected( _ncvo.lounge );
					break;
					
				case NetConnectionProxy.CONNECTIONCLOSED:
					trace("StreamsMediator:: handleNotification: NetConnectionProxy.CONNECTIONCLOSED" );
					streamsView.removeAllStreams();
					// remove webcamProxy object since this tells us if we are streaming or not (good?)
					facade.removeProxy(WebcamProxy.NAME);
					break;
					
				case AppConstants.SERVERSTREAMRECORDING:
					trace("StreamsMediator:: handleNotification: SERVERSTREAMRECORDING" );
					_cameraView.recording = true;
					break;

			}
		}

		private function streamsClick(e:MouseEvent):void
		{
			if (e.target.name == "leave") {
				var _ncp:NetConnectionProxy = facade.retrieveProxy(NetConnectionProxy.NAME) as NetConnectionProxy;
				_ncp.clientReturnToLounge();
			}
		}

		private function cameraStreaming( e:CameraEvent ):void
		{
			trace("StreamsMediator:: cameraStreaming:", e.streaming );
			
			// this event sent by the cameraView so we can grab the target and cache this view
			_cameraView = e.target as CameraView;

			// at the moment just pass directly into the VideoMessageProxy
			// maybe later this can be factored into a command
			var _vmp:VideoMessageProxy = facade.retrieveProxy( VideoMessageProxy.NAME ) as VideoMessageProxy;
			_vmp.streaming = e.streaming;
			
			// for now - automatically record
			//_vmp.recording = e.streaming;
			
			sendNotification( AppConstants.LOGCAMERASTREAMING, { streaming:e.streaming } );
			
			trace("StreamsMediator:: Proxy now holds:", _vmp.streaming );
		}

		// onResize
		// called via the stageMediator whenever the stage area is resized
		// might need to rescale streams to fit new stage area
		public function onResize(w:int, h:int):void {
			trace("StreamsMediator:: onResize:", w, h);
		}

		private function get streamsView():StreamsView {
			return viewComponent as StreamsView;
		}
	}
}