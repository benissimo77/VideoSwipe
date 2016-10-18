package com.videoswipe.view.popup 
{
	import com.videoswipe.view.component.FacebookButton;
	import com.videoswipe.view.component.GlassSprite;
	import com.videoswipe.view.component.TFTextField;
	import com.videoswipe.view.popup.event.PopupActionEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * ...
	 * @author 
	 */
	public class ConfirmationPopup extends GlassSprite implements IPopup
	{
		private var windowTitle:String = "Confirmation";
		private var promptText:String = "Are you sure?";
		
		private var textTF:TFTextField;
		private var okButton:FacebookButton;
		private var cancelButton:FacebookButton;
		
		public function ConfirmationPopup() 
		{
			_width = 240;
			_height = 200;
			initView();
		}

		private function initView():void
		{
				textTF = new TFTextField();
				textTF.x = 0;
				textTF.y = 20;
				textTF.width = _width;
				addChild(textTF);
				okButton = new FacebookButton("facebook", "OK", 60, 16, false);
				okButton.x = 30;
				okButton.y = 64;
				okButton.addEventListener(MouseEvent.CLICK, onOk);
				addChild(okButton);
				cancelButton = new FacebookButton("facebook", "Cancel", 60, 16, false);
				cancelButton.x = 140;
				cancelButton.y = 64;
				cancelButton.addEventListener(MouseEvent.CLICK, onCancel);
				addChild(cancelButton);
		}
		
		override public function redraw():void
		{
			trace("ConfirmationPopup:: redraw:", _width, _height );
			showGlass();
		}
		// Required by IPopup interface
		public function setData( data:Object ):void
		{
			if ( data.windowTitle ) windowTitle = data.windowTitle;
			if ( data.promptText ) promptText = data.promptText;
			if ( data.width ) _width = data.width;
			if ( data.height ) _height = data.height;
			setSize(_width, _height);
		}
		
		// Required by IPopup interface
		public function getEvents( ):Array
		{
			return [ PopupActionEvent.OK, PopupActionEvent.CANCEL ]
		}

		private function onOk(e:MouseEvent=null):void
		{
			dispatchEvent( new PopupActionEvent( PopupActionEvent.OK ) )
		}
		private function onCancel(e:MouseEvent=null):void
		{
			dispatchEvent( new PopupActionEvent( PopupActionEvent.CANCEL ) )
		}
		
	}

}