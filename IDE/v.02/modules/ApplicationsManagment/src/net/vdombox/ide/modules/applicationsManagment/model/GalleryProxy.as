package net.vdombox.ide.modules.applicationsManagment.model
{
	import mx.core.BitmapAsset;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class GalleryProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "GalleryProxy";
		
		public function GalleryProxy()
		{
			super( NAME );
			
			var d : * = imgCls();
		}
		
		[Embed(source="gallery/book.png")] 
		public var imgCls:Class;
	}
}