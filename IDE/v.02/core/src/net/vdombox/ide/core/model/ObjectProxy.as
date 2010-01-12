package net.vdombox.ide.core.model
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ObjectProxy extends Proxy implements IObjectProxy
	{
		public static const NAME : String = "ObjectProxy";

		public function ObjectProxy( applicationVO : ApplicationVO, pageVO : PageVO, objectVO : ObjectVO )
		{
			super( NAME + "/" + applicationVO.id + "/" + pageVO.id + "/" + objectVO.id, objectVO );
		}

		public function get id() : String
		{
			return null;
		}

		public function get attributes() : XMLList
		{
			return null;
		}
	}
}