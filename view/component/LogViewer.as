package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.LogItemVO;
	import com.videoswipe.model.vo.LogViewerEvent;
	import com.videoswipe.model.vo.LogVO;
	import fl.controls.TextArea;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import myLib.controls.ScrollBar;
	/**
	 * ...
	 * @author 
	 */
	public class LogViewer extends Sprite
	{
		private var _logList:Sprite;
		private var _sessionLog:LogVO;
		private var _logItems:Sprite;
		private var _logViewScroll:ScrollBar;
		private var _logViewcursor:LogItemView;
		private var _logViewCursorIndex:int;	// cursor keeps track of currently selected item
		private var _logViewBody:TextArea;
		
		public function LogViewer( _l:LogVO = null)
		{
			trace("LogViewer:: LogViewer: hello" );
			initView();
			if (_l) sessionLog = _l;	// calls drawView
		}
		
		public function nextItem():void
		{
			if (_logViewCursorIndex > 0) {
				setCurrentItem( false );
				_logViewCursorIndex--;
				setCurrentItem( true );
				_logViewScroll.scrollToChild( _logViewcursor );
			}
		}
		public function previousItem():void
		{
			if (_logViewCursorIndex < _logItems.numChildren - 1) {
				setCurrentItem( false );
				_logViewCursorIndex++;
				setCurrentItem( true );
				_logViewScroll.scrollToChild( _logViewcursor );
			}
		}

		private function initView():void
		{
			trace("LogViewer:: initView:" );
			
			_logItems = new Sprite();
			addChild(_logItems);
			_logViewScroll = new ScrollBar();
			_logViewScroll.scrollTarget = _logItems;
			_logViewScroll.setSize(16, 360);
			_logViewScroll.x = 402;
			addChild(_logViewScroll);
			_logViewBody = new TextArea();
			_logViewBody.x = 424;
			_logViewBody.width = 480;
			_logViewBody.height = 360;
			addChild(_logViewBody);
		}
		
		private function drawView():void
		{
			var _l:LogItemView;
			trace("LogViewer:: drawView:", _sessionLog.logItems.length );
			while (_logItems.numChildren > 0) {
				_logItems.removeChildAt(0);
			}
			var _length:int = _sessionLog.logItems.length;
			for (var i:int = 0; i < _length; i++ ) {
				_l = new LogItemView( _sessionLog.logItems[i] );
				_logItems.addChild( _l );
			}
			arrangeLogItems();
			_logViewScroll.update();
			_logViewCursorIndex = 0;
			setCurrentItem( true );	// first item in list is selected
			_logViewScroll.scrollToChild( _logViewcursor );
			trace("LogViewer:: drawView:", _logItems.width, _logViewScroll.getScrollPosition() );
		}
		
		private function arrangeLogItems():void
		{
			for (var i:int = _logItems.numChildren; i--; ) {
				_logItems.getChildAt(i).y = i * 20;
			}
		}
		private function setCurrentItem( _s:Boolean ):void
		{
			_logViewcursor = _logItems.getChildAt(_logViewCursorIndex) as LogItemView;
			_logViewcursor.selected = _s;
			
			if (_s) {
				_logViewBody.text = _logViewcursor.body;
				dispatchEvent( new LogViewerEvent( LogViewerEvent.DOLOGITEM, _logViewCursorIndex ) );
			}
		}

		public function set sessionLog(value:LogVO):void 
		{
			_sessionLog = value;
			drawView();
		}
	}

}