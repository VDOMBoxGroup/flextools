package net.vdombox.ide.modules.wysiwyg.model
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class RenderProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "RenderProxy";
		
		public function RenderProxy()
		{
			super( NAME );
		}
		
		private var _renderData : ItemVO;
		
		public function setRawRenderData( renderData : XML ) : void
		{
			_renderData = new ItemVO();
			_renderData.setXMLDescription( renderData );
			
			sendNotification( ApplicationFacade.RENDER_DATA_CHANGED, _renderData );
		}
		
		public function get renderData() : ItemVO
		{
			return _renderData;
		}
		
	}
}