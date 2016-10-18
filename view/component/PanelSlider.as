package com.videoswipe.view.component
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Ben Silburn
	 */
	public class PanelSlider extends Sprite
	{

		private var _panels:Sprite;	// sprite holds all the panels that need to be controlled by this slider
		private var _tabs:Sprite;	// sprite holds the tabs which will allow each panel to be selected
		private var _width:int = 0;	// holds the current width of the slider (will adjust based on the size of the panels added)
		
		public function PanelSlider():void
		{
			trace("panelSlider: hello.");
			_panels = new Sprite();
			_tabs = new Sprite();

			addChild(_panels);
			addChild(_tabs);
			
			// add slider listeners
			this.addEventListener(MouseEvent.MOUSE_OVER, slideIn);
		}
		
		public function add(_p:DisplayObject, _title:String = ""):void
		{
			var panelY:Number = _panels.numChildren * 100;

			var thisTab:Sprite = createTab(_title);
			//thisTab.addEventListener(MouseEvent.CLICK, tabClicked);
			thisTab.y = panelY;
			_tabs.addChild(thisTab);
			_panels.addChild(_p);
			_width = Math.max(_width, _p.width + 8);
			update();
		}
		
		public function update():void
		{
			for (var i:int = _panels.numChildren; i--; ) {
				var _p:DisplayObject = _panels.getChildAt(i);
				_p.x = (_width - _p.width) / 2;
			}
			drawBackground(_width);
			_tabs.x = _width;
			this.x = -_tabs.x;
		}
		
		private function drawBackground(_w:int):void
		{
			var panelBG:Sprite = this;

			panelBG.graphics.clear();
			panelBG.graphics.beginFill(0x555555, 0.7);
			panelBG.graphics.drawRect(0, 0, _w, this.stage.stageHeight);
			panelBG.graphics.endFill();

			// and draw thick line down side (tabs will cover it where necessary)
			panelBG.graphics.lineStyle(3, 0x777777, 1);
			panelBG.graphics.moveTo(_w, 0);
			panelBG.graphics.lineTo(_w, this.stage.stageHeight);
		}
		
		private function createTab(_t:String):Sprite
		{
			var panelBG:Sprite = new Sprite();
			
			// add the tab which will control the slide
			panelBG.graphics.lineStyle(3, 0x777777, 1);
			panelBG.graphics.beginFill(0x555555, 0.7);
			panelBG.graphics.moveTo(0, 0);
			panelBG.graphics.lineTo(20, 0);
			panelBG.graphics.curveTo(28, 8, 28, 8);
			panelBG.graphics.lineTo(28, 96);
			panelBG.graphics.curveTo(28, 104, 20, 104);
			panelBG.graphics.lineTo(0, 104);
			panelBG.graphics.lineTo(0, 0);
			panelBG.graphics.endFill();

			return panelBG;
		}
		
		private function extra():void
		{
			var panelBG:Sprite = this;
			var panelY:int = 0;
			
			// add a thicker outline to the tab to make it pop
			panelBG.graphics.lineStyle(3, 0x777777, 1);
			panelBG.graphics.moveTo( 0, 0);
			panelBG.graphics.lineTo(240, 0);
			panelBG.graphics.lineTo(240, panelY);
			panelBG.graphics.lineTo(260, panelY);
			panelBG.graphics.curveTo(268, panelY, 268, panelY + 8);
			panelBG.graphics.lineTo(268, panelY + 96);
			panelBG.graphics.curveTo(268, panelY + 104, 260, panelY + 104);
			panelBG.graphics.lineTo(240, panelY + 104);
			panelBG.graphics.lineTo(240, 800);
			panelBG.graphics.lineTo( 0, 800);

			// draw contents into slider right here...
		}


		private function slideOut(e:MouseEvent):void {
			trace("slideOut");
			this.removeEventListener(MouseEvent.MOUSE_OUT, slideOut);
			this.addEventListener(MouseEvent.MOUSE_OVER, slideIn);
			TweenLite.to(this, 0.4, { x: -_width } );
				
		}
		private function slideIn(e:MouseEvent):void {
			trace("slideIn");
			this.removeEventListener(MouseEvent.MOUSE_OVER, slideIn);
			this.addEventListener(MouseEvent.MOUSE_OUT, slideOut);
			TweenLite.to(this, 0.4, { x:0 } );
		}
	}
	
}