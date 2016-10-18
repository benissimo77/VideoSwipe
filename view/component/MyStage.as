package com.videoswipe.view.component 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	/**
	 * MyStage
	 * Provides a 'stage' class to allow setting of stage-specific properties even
	 * when class is not added directly to Stage
	 * @author 
	 */
	public class MyStage extends DisplayObjectContainer
	{
		private var _standalone:Boolean = false;
		
		public function MyStage() 
		{
			if (root.parent && root.parent == stage) {
				_standalone = true;
			}
		}
		
		public function set displayState( s:String ):void
		{
			trace("MyStage:: displayState:", s );
		}
		public function get displayState():String
		{
			return StageDisplayState.NORMAL;
		}
		public function get stageWidth():int
		{
			return _standalone ? this.stage.stageWidth : this.parent.width;
		}
		public function get stageHeight():int
		{
			return _standalone ? this.stage.stageHeight : this.parent.height;
		}
		
	}

}