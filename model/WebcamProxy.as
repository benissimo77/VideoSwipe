/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.model.vo.WebcamVO;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class WebcamProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "WebcamProxy";

		public function WebcamProxy() {
			super(NAME, new WebcamVO() );
		}

		public function get vo():WebcamVO {
			return data as WebcamVO;
		}
	}
}