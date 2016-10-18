package com.videoswipe.view.component 
{
	import flash.display.DisplayObject;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * TabMenu
	 * Top-level sprite for organising/maintaining a tabbed collection of windows
	 * setSize - set the total width/height for the menu (including the tabs)
	 * add - adds a sprite to the collection (a tab will be created for it)
	 * activateTabByIndex - sets the active tab by index
	 * activateTabByName - sets the active tab based on tab name
	 * 
	 * (c) Ben Silburn
	 */
	public class TabMenu extends Sprite
	{
		private static const TABWIDTH:uint = 120;
		private static const TABHEIGHT:uint = 32;
		private static const TABMARGIN:uint = 4;

		private var _panelList:Vector.<XSprite>;	// array holds all the panels that need to be controlled by this menu
		private var _tabs:Sprite;	// sprite holds the tabs which will allow each panel to be selected
		private var _panels:GlassSprite;	// displays the panel
		
		public function TabMenu() 
		{
			trace("TabMenu:: TabMenu: hello.");
			initView();
		}
		
		private function initView():void
		{
			_panelList = new Vector.<XSprite>;
			_tabs = new Sprite();
			_panels = new GlassSprite();
			_panels.y = TABHEIGHT + 6;
			_panels.showGlass();

			addChild(_tabs);
			addChild(_panels);
			
			// add tab button listeners
			_tabs.addEventListener(MouseEvent.CLICK, tabClicked);
			_tabs.addEventListener(MouseEvent.MOUSE_OVER, tabOver);
			_tabs.addEventListener(MouseEvent.MOUSE_OUT, tabOut);
			
			// testing - see if text renders when rotated... it does, must you must use an embedded font (check TF.as)
			//_tabs.rotation = 90;
		}
		
		public function setSize(_w:int, _h:int):void
		{
			for (var i:int = _panelList.length; i--; ) {
				_panelList[i].setSize(_w, _h - _panels.y);
			}
			_panels.setSize(_w, _h - _panels.y);
			
			// draw an invisible background to the tabs so that it registers mouse events
			_tabs.graphics.clear();
			_tabs.graphics.beginFill(0x000, 0);
			_tabs.graphics.drawRect(0, 0, _w, _panels.y);
			_tabs.graphics.endFill();
		}
		public function add(_p:XSprite, _title:String = ""):void
		{
			var thisTab:Sprite = createTab(_title);
			thisTab.x = _tabs.numChildren * (TABWIDTH + TABMARGIN);
			thisTab.y = 0;
			_tabs.addChild(thisTab);
			_p.name = _title;
			_panelList.push(_p);
		}
		public function activateTabByName(_t:String):void
		{
			var _selectedTab:Sprite = _tabs.getChildByName(_t) as Sprite;
			if (_selectedTab) {
				deselectAllTabs();
				drawTabSelected(_selectedTab);
				_tabs.addChild(_selectedTab);	// bring to top of display stack

				// this line throws an error when loading SWF into an outside holder SWF, try removing...
				//_panels.removeChildren();
				while (_panels.numChildren > 0) _panels.removeChildAt(0);
				for (var i:int = _panelList.length; i--; ) {
					if (_panelList[i].name == _t) {
						_panels.addChild(_panelList[i]);
					}
				}
			}
		}

		/*
		override public function redraw():void
		{
			// use this is a general top-level entry point to redraw the tabMenu and associated panels
			// not used at the moment
			var _p:XSprite;
			for (var i:int = _panels.numChildren; i--; ) {
				_p = _panels.getChildAt(i) as XSprite;
				_p.setSize(_width, _height - _panels.y);
			}
			_tabs.graphics.lineStyle(1, 0xffffff, 1);
			_tabs.graphics.moveTo(0, TABHEIGHT);
			_tabs.graphics.lineTo(_width, TABHEIGHT);
		}
		*/

		private function createTab(_t:String):Sprite
		{
			var panelBG:Sprite = new Sprite();
			panelBG.name = _t;
			panelBG.mouseChildren = false;
			var panelText:TFTextField = new TFTextField();
			panelText.x = 4;
			panelText.y = 6;
			panelText.colour = Theme.TEXTSTANDARD;
			panelText.text = _t.toUpperCase();
			panelText.bold = true;
			panelBG.addChild(panelText);
			drawTabDeselected(panelBG);
			return panelBG;
		}
		
		private function drawTabSelected(panelBG:Sprite):void
		{
			/*
			panelBG.graphics.clear();
			panelBG.graphics.lineStyle(1, 0xffffff, 1);
			panelBG.graphics.beginFill(0xeeeeff, 0.7);
			panelBG.graphics.drawRect(0, 0, TABWIDTH, 20);
			panelBG.graphics.endFill();
			*/
			
			// NOTE: for facebook blue use 3B5998
			// Adobe dark blue 596678
			// Adobe grey shades 282828 535353 e1e1e1
			panelBG.graphics.clear();
			panelBG.graphics.lineStyle(1, Theme.HIGHLIGHTTINT, 1);
			panelBG.graphics.beginFill( Theme.GLASSTINT, Theme.GLASSALPHA);
			panelBG.graphics.moveTo( 0, TABHEIGHT);
			panelBG.graphics.lineTo( 0, 0);
			panelBG.graphics.lineTo( TABWIDTH, 0);
			panelBG.graphics.lineTo( TABWIDTH + TABHEIGHT, TABHEIGHT);
			panelBG.graphics.lineTo( 0, TABHEIGHT);
			panelBG.graphics.endFill();
		}
		private function drawTabDeselected(panelBG:Sprite):void
		{
			/*
			panelBG.graphics.clear();
			panelBG.graphics.lineStyle(1, 0xffffff, 1);
			panelBG.graphics.drawRect(0, 0, TABWIDTH, 20);
			*/
			panelBG.graphics.clear();
			panelBG.graphics.lineStyle(1, Theme.EDGETINT, 1);
			panelBG.graphics.beginFill( Theme.GLASSTINT, 0.2 );
			panelBG.graphics.moveTo( 0, 0);
			panelBG.graphics.lineTo( TABWIDTH, 0);
			//panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABMARGIN);
			//panelBG.graphics.lineStyle(1, Theme.EDGETINT, 0);
			//panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABHEIGHT);
			//panelBG.graphics.lineStyle(1, Theme.EDGETINT, 1);
			//panelBG.graphics.lineTo( 0, TABHEIGHT );
			panelBG.graphics.lineTo( TABWIDTH + TABHEIGHT, TABHEIGHT);
			panelBG.graphics.lineTo( 0, TABHEIGHT);
			panelBG.graphics.lineTo( 0, 0);
			panelBG.graphics.endFill();
		}
		private function drawTabMouseOver(panelBG:Sprite):void
		{
//			panelBG.graphics.clear();
			panelBG.graphics.lineStyle(1, Theme.HIGHLIGHTTINT, 1);
//			panelBG.graphics.beginFill( Theme.GLASSTINT, 0.2 );
			panelBG.graphics.moveTo( 0, 0);
			panelBG.graphics.lineTo( TABWIDTH, 0);
			//panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABMARGIN);
			//panelBG.graphics.lineStyle(1, Theme.EDGETINT, 0);
			//panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABHEIGHT);
			//panelBG.graphics.lineStyle(1, Theme.EDGETINT, 1);
			//panelBG.graphics.lineTo( 0, TABHEIGHT );
			panelBG.graphics.lineTo( TABWIDTH + TABHEIGHT, TABHEIGHT);
			panelBG.graphics.lineTo( 0, TABHEIGHT);
			panelBG.graphics.lineTo( 0, 0);
//			panelBG.graphics.endFill();
		}
		private function drawTabMouseOut(panelBG:Sprite):void
		{
//			panelBG.graphics.clear();
			panelBG.graphics.lineStyle(1, Theme.EDGETINT, 1);
//			panelBG.graphics.beginFill( Theme.GLASSTINT, 0.2 );
			panelBG.graphics.moveTo( 0, 0);
			panelBG.graphics.lineTo( TABWIDTH, 0);
			//panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABMARGIN);
			//panelBG.graphics.lineStyle(1, Theme.EDGETINT, 0);
			//panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABHEIGHT);
			//panelBG.graphics.lineStyle(1, Theme.EDGETINT, 1);
			//panelBG.graphics.lineTo( 0, TABHEIGHT );
			panelBG.graphics.lineTo( TABWIDTH + TABHEIGHT, TABHEIGHT);
			panelBG.graphics.lineTo( 0, TABHEIGHT);
			panelBG.graphics.lineTo( 0, 0);
//			panelBG.graphics.endFill();
		}
		private function drawEndTab(panelBG:Sprite):void
		{
			trace("TabMenu:: drawEndTab:" );
			panelBG.graphics.lineStyle(1, Theme.EDGETINT, 1);
			panelBG.graphics.beginFill( Theme.GLASSTINT, 0);
			panelBG.graphics.moveTo( TABWIDTH + TABMARGIN, TABMARGIN);
			panelBG.graphics.lineTo( TABWIDTH + TABHEIGHT, TABHEIGHT);
			panelBG.graphics.lineTo( TABWIDTH + TABMARGIN, TABHEIGHT);
			panelBG.graphics.lineStyle(1, Theme.EDGETINT, 0);
			panelBG.graphics.endFill();
		}

		private function tabClicked(e:MouseEvent = null):void
		{
			trace("TabMenu:: tabClicked:", e.target.name);
			activateTabByName(e.target.name);
		}
		private function tabOver(e:MouseEvent = null):void
		{
			trace("TabMenu:: tabOver:", e.target.name );
			var _selectedTab:Sprite = _tabs.getChildByName(e.target.name) as Sprite;
			var _activeTab:Sprite = _tabs.getChildAt( _tabs.numChildren - 1) as Sprite;
			if (_selectedTab) {
				drawTabMouseOver(_selectedTab);
				_tabs.addChild( _selectedTab );
				_tabs.addChild( _activeTab );
			}
		}
		private function tabOut(e:MouseEvent = null):void
		{
			trace("TabMenu:: tabOut:", e.target.name );
			var _selectedTab:Sprite = _tabs.getChildByName(e.target.name) as Sprite;
			var _activeTab:Sprite = _tabs.getChildAt( _tabs.numChildren - 1) as Sprite;
			if (_selectedTab) {
				drawTabMouseOut(_selectedTab);
				// rerender the selected tab since mouse out changes its appearance
				drawTabSelected(_activeTab);
			}
		}
		private function deselectAllTabs():void
		{
			for (var i:int = _tabs.numChildren; i--; ) {
				drawTabDeselected(_tabs.getChildAt(i) as Sprite);
			}
			//drawEndTab(_tabs.getChildByName(_panelList[_panelList.length - 1].name) as Sprite);
		}
		
	}

}