package com.videoswipe.view
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.view.component.StreamView;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;


	public class StreamMediator extends Mediator implements IMediator
	{
		public static const NAME:String	= 'StreamMediator';

		private var _width:int;							// cached ref to total width/height of the streams canvas
		private var _height:int;

		public function StreamMediator(viewComponent:Object)
		{
			trace("StreamMediator:: hello.");
			super( NAME, viewComponent as Sprite);
		}

		override public function onRegister():void
		{
			trace("StreamMediator:: onRegister: hello. this.height:" + stage.height);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppConstants.ADDSTREAMVIEW,
				AppConstants.REMOVESTREAMVIEW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var name:String = notification.getName();
			var body:Object = notification.getBody();
			var _s:StreamView;

			switch ( name )
			{
				
				case AppConstants.ADDSTREAMVIEW:
					trace("StreamMediator:: handleNotification: ApplicationFacade.ADD_STREAMVIEW");
					_s = body as StreamView;
					_s.addEventListener(MouseEvent.CLICK, videoClick);
					stage.addChildAt(_s, 0);
					update();
					break;

				case AppConstants.REMOVESTREAMVIEW:
					trace("StreamMediator:: handleNotification: ApplicationFacade.REMOVE_STREAMVIEW");
					var _streamName:String = body as String;
					for (var i:uint = stage.numChildren; i--; ) {
						_s = stage.getChildAt(i) as StreamView;
						if (_s.streamname == _streamName) {
							stage.getChildAt(i).removeEventListener(MouseEvent.CLICK, videoClick);
							_s.killMe();
							stage.removeChildAt(i);
							break;
						}
					}
					break;
					
			}
		}

		private function update():void
		{
			var sv:StreamView;
			var _offset:int = -120 * stage.numChildren / 2;
			for (var i:int = stage.numChildren; i--; ) {
				sv = stage.getChildAt(i) as StreamView;
				sv.x = _offset + 122*i;
				sv.y = 0;
			}
		}
		// onResize
		// called via the stageMediator whenever the stage area is resized
		// might need to rescale streams to fit new stage area
		public function onResize(w:int, h:int):void {
			trace("StreamMediator:: onResize:", w, h);
		}

		// videoClick
		// called when one of the streamviewers is clicked (place clicked stream into large position)
		private function videoClick(e:MouseEvent):void {
			trace("StreamMediator:: videoClick: hello  " + e.currentTarget);
			var i:uint = stage.getChildIndex(e.currentTarget as StreamView);
			stage.swapChildrenAt(i, 0);
		}

		private function get stage():Sprite {
			return viewComponent as Sprite;
		}
	}
}