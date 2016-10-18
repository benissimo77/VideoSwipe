package com.videoswipe.view.component 
{
	import com.facebook.graph.net.FacebookBatchRequest;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * (c) 2013 Ben Silburn
	 * HelpSlide
	 * Displays help information on a transparent acetate slide
	 * Help slides are based around 1280x800, stageView sets a scaleX and Y to fit actual screen size
	 * 
	 * showSlide: accepts a string form of a JSON-encoded array object holding the slide data
	 * 
	 */
	public class HelpSlideView extends GlassSprite
	{
		[Embed (source = "assets/deleteIconGrey.png")]
		private var closeIcon:Class;
		private var closeIconBMP:Bitmap;
		[Embed (source = "assets/white-arrow-curved.png")]
		private var arrowCurvedIcon:Class;
		[Embed (source = "assets/white-arrow-straight.png")]
		private var arrowStraightIcon:Class;
		[Embed (source = "assets/unbroken-box.png")]
		private var boxDottedIcon:Class;
		
		
		private var _doneButton:GlassSprite;
		private var _slideData:Object;	// a JSON object holding all data for current slide
		
		public function HelpSlideView() 
		{
				_slideData = {};	// initialise to empty array
				initView();

				// testing call the create slide with sample object
				var _slideStr:String = '[' +
				'{"x":282, "y":252, "w":360, "h":80, "t":"Invite your Facebook friends, and watch video together :)" },' +
				'{"x":40, "y":440, "w":200, "h":80, "t":"* We will never do anything on Facebook unless you tell us to!", "small":true },' +
				'{"x":220,"y":270,"w":240,"h":120,"arrow":15,"curved":true},' +
				'{"x": -400, "y":240, "w":400, "h":180, "t":"YouTube over here..." },' +
				'{"x":160, "y": -120, "w":40, "h":120, "arrow":-90 },' +
				'{"x":-160, "y": -120, "w":40, "h":120, "arrow": 90 },' +
				'{"x":440, "y": -130, "w":480, "h":120, "t":"Videos you watch go into a playlist" },' +
				'{"x":600, "y": 4, "w":80, "h":60, "box":1 },' +
				'{"x":520, "y": 4, "w":80, "h":60, "box":1 },' +
				'{"x":680, "y": 4, "w":80, "h":60, "box":1 },' +
				'{"x":480, "y": 72, "w":400, "h":120, "t":"Friends webcams appear here" }' +
				']';
				//_slideStr = '[{"x":282, "y":252, "w":360, "h":80, "t":"Invite your Facebook friends, and watch video together :)" },{"x":40, "y":440, "w":200, "h":80, "t":"* We will never do anything on Facebook unless you tell us to!", "small":true },{"x":220,"y":270,"w":240,"h":120,"arrow":15,"curved":true},{"x": -400, "y":240, "w":400, "h":180, "t":"YouTube over here..." },{"x":600, "y": 4, "w":80, "h":60, "box":1 },{"x":520, "y": 4, "w":80, "h":60, "box":1 },{"x":680, "y": 4, "w":80, "h":60, "box":1 },{"x":480, "y": 72, "w":400, "h":120, "t":"Friends webcams appear here" }]';
				/*
				 * Original help slide before removing some of the lines...
				 * [{"x":282, "y":252, "w":360, "h":80, "t":"Invite your Facebook friends, and watch video together :)" },{"x":40, "y":440, "w":200, "h":80, "t":"* We will never do anything on Facebook unless you tell us to!", "small":true },{"x":220,"y":270,"w":240,"h":120,"arrow":15,"curved":true},{"x": -400, "y":240, "w":400, "h":180, "t":"YouTube over here..." },{"x":160, "y": -120, "w":40, "h":120, "arrow":-90 },{"x":-160, "y": -120, "w":40, "h":120, "arrow": 90 },{"x":440, "y": -130, "w":480, "h":120, "t":"Videos you watch go into a playlist" },{"x":600, "y": 4, "w":80, "h":60, "box":1 },{"x":520, "y": 4, "w":80, "h":60, "box":1 },{"x":680, "y": 4, "w":80, "h":60, "box":1 },{"x":480, "y": 72, "w":400, "h":120, "t":"Friends webcams appear here" }]
				 */

				// TESTING - second help slide
				_slideStr = '[{"x": -480, "y":320, "w":320, "h":180, "t":"Click button here to connect to YouTube!\\nYour channels will be shown here..."}, {"x": -450, "y":220, "w":120,"h":180,"arrow":60,"curved":true} ]';

				//showSlide( JSON.parse(_slideStr) );
				//trace("HelpSlideView:: HelpSlideView:", _slideStr );
		}
		
		private function initView():void
		{
			
			// create the DONE button (text field plus close icon)
			var _tf:TFTextField = new TFTextField("help");
			_tf.text = "OK, got it!";
			_tf.size = 36;
			_tf.selectable = false;
			closeIconBMP = new closeIcon();
			closeIconBMP.width = 48;
			closeIconBMP.height = 48;
			closeIconBMP.x = 140;
			closeIconBMP.y = 0;
			
			_doneButton = new GlassSprite(200, 48);
			_doneButton.name = "done";
			_doneButton.glassAlpha(0);
			_doneButton.addChild(_tf);
			_doneButton.addChild(closeIconBMP);
			_doneButton.buttonMode = true;
			_doneButton.useHandCursor = true;

			glassTint(0x000000, 0x333333);
			glassAlpha(0.7);
		}
		
		// showSlide
		// accepts a string representation of a help slide (JSON format) and builds the assets
		public function showSlide( _s:Object ):void
		{
			trace("HelpSlideView:: showSlide:", _s.length );
			// first remove all children to clear old slide data
			while (numChildren > 0) {
				removeChildAt(0);
			}

			_slideData = _s;
			for (var i:int = _slideData.length; i--; ) {
				var _slide:Object = _slideData[i];
				if (_slide.t) {
					addChildAt( createText(_slide), 0 );
				}
				if (_slide.arrow) {
					addChildAt( createArrow(_slide), 0 );
				}
				if (_slide.box) {
					addChildAt( createBox(_slide), 0 );
				}
			}
			addChild(_doneButton);
			showGlass();
			setSize(1280, 800);	// theoretical screen size, stageView scales to fit viewport
			this.visible = true;
		}
		private function createText(_t:Object):TextField
		{
			var _tf:TFTextField = new TFTextField("help");
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.selectable = false;
			_tf.width = _t.w;
			_tf.height = _t.h;
			_tf.text = _t.t;
			_tf.size = 32;
			if (_t.small) {
				_tf.size = 20;
			}
			if (_t.large) {
				_tf.size = 44;
			}
			return _tf;
		}
		private function createArrow( _a:Object ):Sprite
		{
			var _arrow:Sprite = new Sprite();
			var _arrowBMP:Bitmap = new arrowStraightIcon();
			if (_a.curved) {
				_arrowBMP = new arrowCurvedIcon();
			}
			_arrowBMP.x = _arrowBMP.width / -2; // centre registration point
			_arrow.rotation = _a.arrow;
			_arrow.addChild(_arrowBMP);
			return _arrow;
		}
		private function createBox( _b:Object ):Sprite
		{
			var _box:Sprite = new Sprite();
			var _boxBMP:Bitmap = new boxDottedIcon();
			_box.addChild(_boxBMP);
			return _box;
		}
		

		override public function redraw():void
		{
			super.redraw();
			
			// loop through slide data setting position and adjusting size based on stage size
			for (var i:int = _slideData.length; i--; )
			{
				var _d:DisplayObject = getChildAt(i);
				_d.width = _slideData[i].w;
				_d.height = _slideData[i].h;
				if (_slideData[i].x < 0) {
					_d.x = _width + _slideData[i].x;
				} else {
					_d.x = _slideData[i].x;
				}
				if (_slideData[i].y < 0) {
					_d.y = _height + _slideData[i].y;
				} else {
					_d.y = _slideData[i].y;
				}
			}

			// reset position of done button (always top right)
			_doneButton.x = _width - _doneButton.width - 8;
			_doneButton.y = 8;
		}
		
	}

}