package net.vdombox.ide.core.model
{
	import mx.rpc.soap.Operation;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.interfaces.IObjectProxy;
	import net.vdombox.ide.core.interfaces.IPageProxy;
	import net.vdombox.ide.core.model.business.SOAP;

	import org.puremvc.as3.multicore.patterns.proxy.Proxy;


	public class PageProxy extends Proxy implements IPageProxy
	{
		public static const NAME : String = "PageProxy";

		public function PageProxy( pageVO : PageVO )
		{
			super( NAME + "/" + pageVO.applicationID + "/" + pageVO.id, pageVO );
		}

		private var soap : SOAP = SOAP.getInstance();

		public function get pageVO() : PageVO
		{
			return data as PageVO;
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

		public function getObjects() : void
		{
			soap.get_child_objects( pageVO.applicationID, pageVO.id );
			soap.get_child_objects.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
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

		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;

			if ( !operation || !result )
				return;

			var operationName : String = operation.name;

			switch ( operationName )
			{
				case "get_child_objects ":
				{

					break;
				}
			}
		}
	}
}