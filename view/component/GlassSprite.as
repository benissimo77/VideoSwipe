package com.videoswipe.view.component 
{
	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class GlassSprite extends XSprite
	{
		private var _showglass:Boolean;
		private var _tint:int;
		private var _edge:int;
		private var _alpha:Number;
		
		public function GlassSprite(_w:int = 800, _h:int = 600) 
		{
			super();
			_tint = Theme.GLASSTINT;
			_edge = Theme.EDGETINT;
			_alpha = Theme.GLASSALPHA;
			_showglass = false;
		}
		
		public function showGlass():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(1, _edge, 1);
			this.graphics.beginFill(_tint, _alpha);
			this.graphics.drawRect(0,0, _width, _height);
			this.graphics.endFill();
			_showglass = true;
		}
		public function hideGlass():void
		{
			this.graphics.clear();
			_showglass = false;
		}
		public function glassTint(_t:int = -1, _e:int = -1 ):void
		{
			if (_t >= 0) {
				_tint = _t;
			}
			if (_e >= 0) {
				_edge = _e;
			}
			redraw();
		}
		public function glassAlpha(_a:Number = -1 ):void
		{
			if (_a < 0) {
				_a = Theme.GLASSALPHA;
			}
			_alpha = _a;
			redraw();
		}

		// overwrite abstract redraw fn in base class
		override public function redraw():void
		{
			if (_showglass) {
				showGlass();
			} else {
				hideGlass();
			}
		}
		
	}

}