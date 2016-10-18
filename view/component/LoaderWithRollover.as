package com.videoswipe.view.component 
{
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class LoaderWithRollover extends Loader
	{
		private var _thumbTint:Shape;		// varies tint of thumb when mouse rolls over
		
		public function LoaderWithRollover() 
		{
			this.addEventListener(MouseEvent.MOUSE_OVER, thumbOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, thumbOut);
			thumbOut();	// set default state to mouse not over
		}

		private function thumbOver(e:MouseEvent = null):void
		{
			this.alpha = 100;
		}
		private function thumbOut(e:MouseEvent = null):void
		{
			this.alpha = 0.75;
		}
		
	}

}