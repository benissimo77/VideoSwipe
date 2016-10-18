package com.videoswipe.view.component 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;

	/**
	 * VideoMessageView
	 * extends streamView to add extra functionality for displaying of users' video messages
	 * namely:
	 *  - ability to delete message
	 * 
	 * @author Ben Silburn
	 */
	public class VideoMessageView extends StreamView
	{
		[Embed (source = "assets/deleteIconGrey.png")]
		private var deleteIcon:Class;
		private var deleteIconBMP:Bitmap;
		
		public function VideoMessageView(_nc:NetConnection) 
		{
			// initialise the deleteIcon bitmap here since it will get referenced during the parent initView call...
			deleteIconBMP = new deleteIcon();
			super(_nc);
			initView();
			this.buttonMode = true;
		}
			
		override protected function netStatusHandler(e:NetStatusEvent):void
		{
			//trace("VideoMessageView:: netStatusHandler:", e.info.code);
			super.netStatusHandler(e);
			
			switch (e.info.code) {
				
				default:
					break;
			}
		}

		private function initView():void
		{
			//trace("VideoMessageView:: initView:" );
			// DELETE ICON
			var deleteIconSprite:Sprite = new Sprite();
			deleteIconSprite.name = "delete";
			deleteIconBMP.width = 24;
			deleteIconBMP.height = 24;
			deleteIconBMP.visible = false;
			deleteIconSprite.addChild(deleteIconBMP);
			addChild(deleteIconSprite);

		}
		
		
		// OVERRIDE FUNCTIONS TO REPLACE STREAMVIEW VERSIONS
		override public function redraw():void
		{
			super.redraw();
			deleteIconBMP.x = _width - 28;
			deleteIconBMP.y = 4;
		}
		override public function mouseOver(e:MouseEvent = null):void
		{
			super.mouseOver(e);
			deleteIconBMP.visible = true;
		}
		override public function mouseOut(e:MouseEvent = null):void
		{
			super.mouseOut(e);
			deleteIconBMP.visible = false;
		}

	}

}