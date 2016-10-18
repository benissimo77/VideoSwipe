/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.model.vo.LayoutElementVO;
	import com.videoswipe.model.vo.LayoutVO;
	import flash.geom.Rectangle;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class LayoutProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "LayoutProxy";

		public function LayoutProxy() {
			var l:LayoutVO = new LayoutVO("default");
			super( NAME, l );

			l.addElement( new LayoutElementVO("ncConnect", "", new Rectangle(8, 8, 0, 0)));
			l.addElement( new LayoutElementVO("ytView", "stretch", new Rectangle(0, 0, 1280,1024)));
			l.addElement( new LayoutElementVO("searchView", "left", new Rectangle(0, 24, 0, 0)));
			l.addElement( new LayoutElementVO("feedView", "left", new Rectangle(0, 96, 0, 0)));
			l.addElement( new LayoutElementVO("playlistView", "", new Rectangle(0, 480, 0, 0)));
			l.addElement( new LayoutElementVO("chatView", "", new Rectangle(540, 400, 0,0)));
		}
		
		public function get layout():LayoutVO
		{
			return data as LayoutVO;
		}
	}
}