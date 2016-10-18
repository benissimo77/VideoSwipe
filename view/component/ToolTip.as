package com.videoswipe.view.component 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Tool tip class for displaying tool tips in an app. It is a singleton class.  
	 * Use it by simply calling ToolTip.show( 'Tool tip goes here' ) and providing the tip
	 * You need to explicitly call the ToolTip.hide() method when you want it to dissapear.
	 * 
	 * NOTE: You must call ToolTip.init( stage ) and pass a reference to the stage before you call ToolTip.show();
	 * This only needs to happen once per project
	 * 
	 * ...
	 * @author Phillip Chertok
	 */
	public class ToolTip extends GlassSprite
	{
		//private var _tip: 					TextField;
		private var _stage:					DisplayObjectContainer;	
		
		private static var _instance:		ToolTip;
		private static var _allowInstance:	Boolean;
		
		/**
		 * Returns an instance of the tool tip
		 */
		private static function get instance():ToolTip 
		{
			if (ToolTip._instance)
			{
				return ToolTip._instance;				
			}
			
			ToolTip._allowInstance = true;
			ToolTip._instance = new ToolTip();
			ToolTip._allowInstance = false;
			
			return ToolTip._instance;	
		}	
		
		
		/**
		 * Consrtuctor does not get explicitly called
		 * 
		 */
		public function ToolTip() 
		{			
			if (!ToolTip._allowInstance)
			{
				throw new Error("Error: Use ToolTip.instance instead of the new keyword.");
			}
			else
			{				
				this.mouseEnabled = false;
				//initTextField();					
			}
		}	
		
		/**
		 * We need to pass at least one reference to the stage
		 */ 
		public static function init(_s:DisplayObjectContainer):void
		{
			ToolTip.instance._stage = _s;
		}
		
		/**
		 * Creates a text field that will be used to display the tooltip
		 */
		private function initTextField(_s:String):void
		{
			var _tip:TFTextField = new TFTextField();			
			
			_tip.selectable = false;
			_tip.mouseEnabled = false;
			_tip.wordWrap = true;
			_tip.multiline = true;
			_tip.bold = true;
			_tip.width = 240;
			_tip.autoSize = TextFieldAutoSize.CENTER;
			_tip.text = _s;
			_tip.x = 20;
			_tip.y = 8;
			
			addChild(_tip);
			
			_height = _tip.y + _tip.textHeight + 16;
			_width = _tip.textWidth + 40;
			showGlass();
		}
		
		/**
		 * Gets our instance and calls the internal method to display the tooltip
		 * 
		 * @param	$tip
		 */
		public static function show(_t:String):void
		{			
			ToolTip.instance.showTip(_t);
		}
		
		/**
		 * 
		 * 
		 * @param	$tip
		 */
		private function showTip(_t:String):void
		{
			initTextField(_t);
			// updating text from previous tooltip text - bit of chicanery to make sure border fits neatly around text
			// first set the width wide to ensure the text stays on one line, then adjust width to fit around textWidth
			// the height sorts itself out since autosize and wordwrap are set
			//_tip.width = 600;
			//_tip.height = 2;
			//_tip.multiline = false;
			//_tip.text = _t;
			//_tip.width = _tip.textWidth + 4;	// need to add 4 for margins on either side
			//if (_tip.width > 240) {
				//_tip.multiline = true;
				//_tip.width = 240;
			//}
			
			//Add an event listener to follow our mouse movement
			//this.addEventListener(Event.ENTER_FRAME, followMouse, false, 0, true);		
			
			//Explicitly call our mouse tracking method to make sure the tool tip appears in the correct place
			followMouse(null);
			
			//Add the tip to the stage
			_stage.addChild(this);
			
			this.alpha = 0;
			TweenLite.to(this, 0.4, { alpha:1, delay:0.5 } );
		}
		
		/**
		 * Public function that calls our instance's internal hide method
		 */
		public static function hide():void
		{
			ToolTip.instance.hideTip();
		}
		
		/**
		 * Removes the tup from the stage
		 */
		private function hideTip():void
		{
			//removeEventListener(Event.ENTER_FRAME, followMouse, false);

			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			if (_stage.contains(this)) _stage.removeChild(this);		
		}	
		
		/**
		 * Tracks the mouse position and follows accordingly
		 * 
		 * @param	$e
		 */
		private function followMouse(e:Event):void 
		{				
			var newX:Number = _stage.mouseX + 4;
			var newY:Number = _stage.mouseY - _height - 4;
			
			if (newX + 260 > _stage.stage.stageWidth) {
				newX = _stage.stage.stageWidth - 260;
			}
			this.x = newX;
			this.y = newY;			
		}
	}
}