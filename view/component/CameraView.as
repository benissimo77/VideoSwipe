package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.ControlBarEvent;
	import com.videoswipe.model.vo.WebcamVO;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	import flash.net.NetConnection;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * StreamView
	 * view component for displaying video streams, creates basic video object and adds decoration
	 * eg border round video, name of stream, mouse event handlers etc
	 * @author Ben Silburn
	 */
	public class CameraView extends StreamView
	{
		[Embed (source = "assets/webcam.png")]
		private var webcamIconClass:Class;
		[Embed (source = "assets/webcamOver.png")]
		private var webcamIconOverClass:Class;
		private var webcamIcon:SimpleButton;
		private var webcamMutedIcon:SimpleButton;
		private var webcam:Sprite;
		private var _recording:Boolean;	// is this stream being recorded? If so then show in view
		private var _recordingView:Shape;

		private var _cam:WebcamVO;
		private var _camData:TFTextField;
		private var microphone:Microphone;
		
		public function CameraView(_nc:NetConnection, _c:WebcamVO) 
		{
			_cam = _c;
			this.name = "cameraView";	// used by StageView to determine if mouse over camera view

			// initialise the sprites before we call the super
			webcam = new Sprite();
			super(_nc);

			initView();

			streamname = _cam.streamname;
			uid = _cam.streamname;

			// set initial state to NOT streaming
			_streaming = false;
			stopStreamVideo();
		}
		
		private function initView():void
		{
			trace("CameraView:: initView:" );

			_video.width = 160;
			_video.scaleY = _video.scaleX;
			trace("CameraView:: initView:", _video.scaleX );

			// add the icons
			webcam.x = _video.width - 32 - 4;
			webcam.y = 120 - 32 - 4;
			webcamMutedIcon = new SimpleButton( new webcamIconClass(), new webcamIconOverClass(), new webcamIconClass(), new webcamIconClass() );
			webcamIcon = new SimpleButton( new webcamIconOverClass(), new webcamIconClass(), new webcamIconOverClass(), new webcamIconOverClass() );
			webcam.addChild(webcamIcon);
			webcam.addChild(webcamMutedIcon);
			webcam.addEventListener(MouseEvent.ROLL_OVER, webcamOver);
			webcam.addEventListener(MouseEvent.ROLL_OUT, webcamOut);
			webcam.addEventListener(MouseEvent.CLICK, webcamClick);
			addChild(webcam);
			
			_camData = new TFTextField();
			_camData.x = 4;
			_camData.y = 4;
			_camData.selectable = false;
			_camData.multiline = false;
			_camData.colour = 0xff0000;
			//addChild(_camData);

			// add the recording view
			_recordingView = new Shape();
			drawRecordBorder( _recordingView, 4);
			addChild(_recordingView);
			
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_2);
			netStream.videoStreamSettings = h264Settings;

			// workaround to force tablet to use non-enhanced microphone
			if (CONFIG::tablet) {
				_cam.codec = SoundCodec.SPEEX;
			}
			if (_cam.codec == "") {
				var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
				options.autoGain = true;
				options.echoPath = 128;
				options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
				options.nonLinearProcessing = true;
				microphone = Microphone.getEnhancedMicrophone();
				microphone.codec = SoundCodec.SPEEX;
				microphone.setSilenceLevel(0);
				microphone.enhancedOptions = options;
			} else {
				microphone = Microphone.getMicrophone();
				microphone.codec = _cam.codec;
				microphone.setUseEchoSuppression(true);
			}
			if (microphone) {
				microphone.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
				microphone.addEventListener(StatusEvent.STATUS, statusHandler);
			}
			trace("Camera settings:", _cam.streamname, _cam.camera.bandwidth, _cam.camera.width, _cam.camera.height, _cam.camera.currentFPS);
			
			var _camTimer:Timer = new Timer(1000, 0);
			_camTimer.addEventListener(TimerEvent.TIMER, showCamData);
			//_camTimer.start();
			
			_cam.camera.addEventListener(StatusEvent.STATUS, camStatusHandler);
		}

		
		// STATUS HANDLERS
		// netStream status handler - info on stream activity
		// camera status handler - info on camera acvitivty (mute/unmute)
		// mic status and activity - not used but keep in case needed
		///
		override protected function netStatusHandler(e:NetStatusEvent):void
		{
			trace("CameraView:: netStatusHandler:", e.info.code);
			super.netStatusHandler(e);
			
			switch (e.info.code) {
				
				case "NetStream.Publish.Start":
					dispatchEvent( new CameraEvent( CameraEvent.CAMERASTREAMING, true ));
					break;
				
				
				case "NetStream.Unpublish.Success":
					dispatchEvent( new CameraEvent( CameraEvent.CAMERASTREAMING, false ));
					break;
					
				default:
					break;
			}
		}

		private function camStatusHandler(event:StatusEvent):void
		{
			trace("CameraView:: camStatusHandler:", event.code );
			if (event.code == "Camera.Muted") {
				_streaming = stopStreamVideo();
			}
        }
		private function activityHandler(event:ActivityEvent):void {
            trace("MIC: activityHandler: " + event);
        }

        private function statusHandler(event:StatusEvent):void {
            trace("MIC: statusHandler: " + event);
        }

		
		// COMMANDS TO START/STOP RECORDING VIDEO/AUDIO
		//
		private function streamVideo():Boolean
		{
			_video.visible = true;
			webcamIcon.visible = true;
			webcamMutedIcon.visible = false;
			_video.attachCamera(_cam.camera);
			netStream.attachCamera(_cam.camera);
			streamAudio();
			return true;
		}
		private function streamAudio():void
		{
			netStream.attachAudio(microphone);
			netStream.publish(_cam.streamname);
			_volume.unmuteAudio();
		}
		private function stopStreamVideo():Boolean
		{
			_video.visible = false;
			_recording = false;
			_recordingView.visible = false;
			webcamIcon.visible = false;
			webcamMutedIcon.visible = true;
			_video.attachCamera(null);
			netStream.attachCamera(null);
			stopStreamAudio();
			return false;
		}
		private function stopStreamAudio():void
		{
			netStream.attachAudio(null);
			netStream.close();
			_volume.muteAudio();
		}

		// FUNCTIONS TO CONTROL DISPLAY ON MOUSE OVER/OUT
		private function webcamOver(e:MouseEvent = null):void
		{
			ToolTip.show( _streaming? "Turn Webcam OFF" : "Turn Webcam ON" );
		}
		private function webcamOut(e:MouseEvent = null):void
		{
			ToolTip.hide();
		}
		private function webcamClick(e:MouseEvent = null):void
		{
			trace("CameraView:: webcamClick:", _streaming );
			_streaming = _streaming? stopStreamVideo() : streamVideo();
		}
		private function drawRecordBorder(_b:Shape, _thickness:Number):void
		{
			var _offset:Number = _thickness / 2;
			_b.graphics.lineStyle(_thickness, 0xff0000, 1, false, LineScaleMode.NONE);
			_b.graphics.drawRect(_offset, _offset, _width - _thickness, _height - _thickness);
		}
		private function showCamData(e:TimerEvent = null):void
		{
			_camData.text = String(_cam.camera.activityLevel) + " " + String(_cam.camera.currentFPS);
		}
		
		
		// OVERRIDE FUNCTIONS TO REPLACE STREAMVIEW VERSIONS
		override public function mouseOver(e:MouseEvent = null):void
		{
			super.mouseOver(e);
			webcam.visible = true;
		}
		override public function mouseOut(e:MouseEvent = null):void
		{
			super.mouseOut(e);
			if (_streaming) {
				webcam.visible = false;	// when cam is ON we remove icon on mouse out
			}
		}
		// stream stopped publishing - chance to react
		override public function destroyMeOnStreamStop():Boolean
		{
			return false;
		}
		// this fn can be overridden to use a different icon for the slider
		override protected function addVolumeSlider():void
		{
			_volume = new SmallSlider("mic");
			_volume.value = 70;	// initialise to slightly lower volume
		}
		override protected function onVolumeChange(e:ControlBarEvent):void
		{
			trace("CameraView:: onVolumeChange:", e.data.volume);
			microphone.gain = e.data.volume;
			if (e.data.volume > 0) {
				//streamAudio();
				// above line removed as was causing infinite loop - if important then look again at the flow here
			}
			// NOTE: we don't call stopStreamAudio if vol=0 in case we are streaming video
		}
		
		public function set recording(value:Boolean):void 
		{
			_recording = value;
			_recordingView.visible = value;
		}

		


	}

}