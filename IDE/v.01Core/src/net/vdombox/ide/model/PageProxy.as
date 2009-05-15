package net.vdombox.ide.model
{
	import net.vdombox.ide.interfaces.IObjectProxy;
	import net.vdombox.ide.interfaces.IPageProxy;
	import net.vdombox.ide.model.vo.ObjectVO;

	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class PageProxy extends Proxy implements IPageProxy
	{
		public static const NAME : String = "PageProxy";

		public function PageProxy( proxyName : String = null, data : Object = null )
		{
			super( proxyName, data );
		}

		public function get id() : String
		{
			return null;
		}

		public function get structure() : XML
		{
			return null;
		}

		public function get selectedObject() : ObjectVO
		{
			return null;
		}

		public function get selectedObjectID() : String
		{
			return null;
		}

		public function createObject( objectID : String ) : ObjectVO
		{
			return null;
		}

		public function deleteObject( objectVO : ObjectVO ) : void
		{
		}

		public function deleteObjectAt( objectID : String ) : void
		{
		}

		public function getObjectAt( objectID : String ) : ObjectVO
		{
			return null;
		}

		public function getObjectProxie( objectVO : ObjectVO ) : IObjectProxy
		{
			return null;
		}

		public function getObjectProxieAt( objectID : String ) : IObjectProxy
		{
			return null;
		}
	}
}