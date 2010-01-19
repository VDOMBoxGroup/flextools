package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.soap.Operation;

	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.interfaces.IObjectProxy;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.patterns.observer.ProxyNotification;

	import org.puremvc.as3.multicore.patterns.proxy.Proxy;


	public class PageProxy extends Proxy
	{
		public static const NAME : String = "PageProxy";

		public function PageProxy( pageVO : PageVO )
		{
			super( NAME + "/" + pageVO.applicationID + "/" + pageVO.id, pageVO );
		}

		private var soap : SOAP = SOAP.getInstance();

		private var _objects : Array;

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

		override public function onRegister() : void
		{
			addEventListeners();
		}

		public function getStructure() : AsyncToken
		{
			var token : AsyncToken;

			token = soap.get_child_objects_tree( pageVO.applicationID, pageVO.id );
			soap.get_child_objects.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			token.recepientName = proxyName;

			return token;
		}

		public function getObjects() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_child_objects( pageVO.applicationID, pageVO.id );

			token.recepientName = proxyName;

			return token;
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

		public function getObjectAt( objectID : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_one_object( pageVO.applicationID, objectID );

			token.recepientName = proxyName;

			return token;
		}

		public function getObjectProxy( objectVO : ObjectVO ) : ObjectProxy
		{
			var objectProxy : ObjectProxy = facade.retrieveProxy( ObjectProxy.NAME + "/" + objectVO.applicationID + "/" + objectVO.pageID + "/" + objectVO.id ) as ObjectProxy;

			if ( !objectProxy )
			{
				objectProxy = new ObjectProxy( objectVO ) as ObjectProxy;
				facade.registerProxy( objectProxy );
			}

			return objectProxy;
		}

//		public function getObjectProxyAt( objectID : String ) : ObjectProxy
//		{
//			var objectProxy : ObjectProxy = facade.retrieveProxy( ObjectProxy.NAME + "/" + pageVO.applicationID + "/" + pageVO.id + "/" + objectID ) as ObjectProxy;
//			
//			if ( !objectProxy )
//			{
//				objectProxy = new ObjectProxy( objectVO ) as ObjectProxy;
//				facade.registerProxy( objectProxy );
//			}
//			
//			return objectProxy;
//		}

		private function addEventListeners() : void
		{
			soap.get_child_objects_tree.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function removeEventListeners() : void
		{
			soap.get_child_objects_tree.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function createObjectsList( objects : XML ) : void
		{
			_objects = [];

			var objectID : String;
			var typeID : String;

			for each ( var object : XML in objects.* )
			{
				objectID = object.@ID[ 0 ];

				typeID = object.@Type[ 0 ];

				if ( !objectID || !typeID )
					continue;

				var objectVO : ObjectVO = new ObjectVO( objectID, pageVO.applicationID, pageVO.id, typeID );

				objectVO.setXMLDescription( object );

				_objects.push( objectVO );
			}
		}

		private function generatePageStructure( rawPage : XML ) : XML
		{
			var structure : XML =
				<page/>

			var rawObjects : XMLList = rawPage.Objects.Object;

			var object : XML;

			structure.@id = rawPage.@ID;
			structure.@name = rawPage.@Name;
			structure.@typeID = rawPage.@Type;

			if ( rawObjects.length() == 0 )
				return structure;

			for each ( var rawObject : XML in rawObjects )
			{
				object = createStructureObject( rawObject );

				structure.appendChild( object );
			}

			return structure;
		}

		private function createStructureObject( rawXML : XML ) : XML
		{
			var structureObject : XML =
				<object/>
				;
			var rawChildren : XMLList = rawXML.Objects.Object;

			var child : XML;

			structureObject.@id = rawXML.@ID;
			structureObject.@name = rawXML.@Name;
			structureObject.@typeID = rawXML.@Type;

			if ( rawChildren.length() == 0 )
				return structureObject;

			for each ( var rawChild : XML in rawChildren )
			{
				child = createStructureObject( rawChild );

				structureObject.appendChild( child );
			}

			return structureObject;
		}

		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var token : AsyncToken = event.token;

			if ( !token.hasOwnProperty( "recepientName" ) || token.recepientName != proxyName )
				return;

			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;

			if ( !operation || !result )
				return;

			var operationName : String = operation.name;
			var notification : ProxyNotification;

			switch ( operationName )
			{
				case "get_child_objects_tree":
				{
					var structure : XML = generatePageStructure( result.Object[ 0 ] );
					notification = new ProxyNotification( ApplicationFacade.PAGE_STRUCTURE_GETTED, structure )
					notification.token = token;

					break;
				}

				case "get_child_objects":
				{
					createObjectsList( result.Objects[ 0 ] );
					notification = new ProxyNotification( ApplicationFacade.OBJECTS_GETTED, _objects );
					notification.token = token;

					break;
				}

				case "get_one_object":
				{
//					createObjectesList( result.Objects[ 0 ] );
					var objectXML : XML = result.Objects.Object[ 0 ];
					var objectVO : ObjectVO = new ObjectVO( objectXML.@ID, pageVO.applicationID, pageVO.id,
															objectXML.@Type );
					objectVO.setXMLDescription( objectXML );

					notification = new ProxyNotification( ApplicationFacade.OBJECT_GETTED, objectVO );
					notification.token = token;

					break;
				}
			}

			if ( notification )
				facade.notifyObservers( notification );
		}
	}
}