package net.vdombox.ide.modules.wysiwyg.model
{
	import com.zavoo.svg.nodes.SVGImageNode;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ResourcesProxy  extends Proxy implements IProxy
	{
		public static const NAME : String = "ResourcesProxy";
		
		/**
		 * Array of  SVGImageNode. Thats waiting self image resoures from IDECore. 
		 */		
		private var waitingsArray : Array = [];

		public function ResourcesProxy()
		{
			super( NAME );
		}
		
		
		public function addWaitingSVGImageNode( svgImageNode : SVGImageNode ) : void
		{
			waitingsArray.push(svgImageNode);
		}
		
		
		public function resourceGeted( resourceVO : ResourceVO ) : void
		{
			if ( !resourceVO)
				return;
			
			for ( var i : String in waitingsArray)
			{
				var  svgImageNode : SVGImageNode = waitingsArray[ i ] as SVGImageNode;
				
				if ( svgImageNode.resourceID == resourceVO.id )
				{
					svgImageNode.resourceVO = resourceVO;
					
					delete waitingsArray[ i ];
					
					continue;
					
					trace("\n +++++++++++++++ ResourcesProxy WORKAET !  +++++++++++++++++");
				}
			}
		}
	}
}