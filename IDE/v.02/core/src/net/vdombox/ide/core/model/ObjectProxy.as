package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.soap.Operation;

	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.patterns.observer.ProxyNotification;

	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ObjectProxy extends Proxy
	{
		public static const NAME : String = "ObjectProxy";

		private static const GET_ATTRIBUTES : String = "getAttributes";
		private static const SET_ATTRIBUTES : String = "setAttributes";

		public function ObjectProxy( objectVO : ObjectVO )
		{
			super( NAME + "/" + objectVO.pageVO.applicationVO.id + "/" + objectVO.pageVO.id + "/" + objectVO.id, objectVO );
		}

		private var soap : SOAP = SOAP.getInstance();
		private var typesProxy : TypesProxy;

		public function get objectVO() : ObjectVO
		{
			return data as ObjectVO;
		}

		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			typesProxy = null;

			removeHandlers();
		}

		public function getAttributes() : AsyncToken
		{
			var token : AsyncToken;

			token = soap.get_one_object( objectVO.pageVO.applicationVO.id, objectVO.id );
			token.recipientName = proxyName;

			return token;
		}

		public function setAttributes( attributes : Array ) : AsyncToken
		{
			var token : AsyncToken;

			if ( attributes.length == 0 )
				return null;

			var attributesXML : XML =
				<Attributes/>
				;
			var attributeVO : AttributeVO;

			for each ( attributeVO in attributes )
			{
				attributesXML.appendChild( attributeVO.toXML() );
			}

			token = soap.set_attributes( objectVO.pageVO.applicationVO.id, objectVO.id, attributesXML );
			token.recipientName = proxyName;
			token.requestFunctionName = SET_ATTRIBUTES;

			return token;
		}

		public function getServerActions() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions( objectVO.pageVO.applicationVO.id, objectVO.id );

			token.recipientName = proxyName;

			return token;
		}

		public function createObject( typeVO : TypeVO, attributes : Array ) : AsyncToken
		{
			var token : AsyncToken;

			var attributesXML : XML;
			var attributeVO : AttributeVO;

			if ( attributes.length > 0 )
			{
				attributesXML =
					<Attributes/>
					;

				for each ( attributeVO in attributes )
				{
					attributesXML.appendChild(
						<Attribute Name={attributeVO.name}>{attributeVO.value}</Attribute>
						);
				}
			}

			token = soap.create_object( objectVO.pageVO.applicationVO.id, objectVO.id, typeVO.id, "", attributesXML );

			token.recipientName = proxyName;

			return token;
		}

		private function addHandlers() : void
		{
			soap.get_one_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function removeHandlers() : void
		{
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function generateObjectAttributes( attributesXML : XML ) : Array
		{
			var attributes : Array = [];
			var attribute : AttributeVO;

			for each ( var attributeXML : XML in attributesXML.* )
			{
				attribute = new AttributeVO( attributeXML.@Name, attributeXML[ 0 ] );
				attributes.push( attribute );
			}

			return attributes;
		}

		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var token : AsyncToken = event.token;

			if ( !token.hasOwnProperty( "recipientName" ) || token.recipientName != proxyName )
				return;

			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;

			if ( !operation || !result )
				return;

			var operationName : String = operation.name;
			var notification : ProxyNotification;

			var objectAttributesVO : ObjectAttributesVO;

			switch ( operationName )
			{
				case "get_one_object":
				{
					objectAttributesVO = new ObjectAttributesVO( objectVO );
					objectAttributesVO.setXMLDescription( result.Objects.Object[ 0 ] );

					notification = new ProxyNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED,
														  { objectVO: objectVO, objectAttributesVO: objectAttributesVO } );

					notification.token = token;

					break;
				}

				case "get_server_actions":
				{
					var serverActions : Array = [];

					var serverActionsXML : XMLList = result.ServerActions.Container.( @ID == objectVO.id ).Action;

					var serverActionVO : ServerActionVO;
					var serverActionXML : XML;

					for each ( serverActionXML in serverActionsXML )
					{
						serverActionVO = new ServerActionVO( serverActionXML.@Name, objectVO );
						serverActionVO.setID( serverActionXML.@ID );

						serverActionVO.script = serverActionXML[ 0 ];

						serverActions.push( serverActionVO );
					}

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_GETTED, serverActions );

					break;
				}

				case "create_object":
				{
					var newObjectVO : ObjectVO = new ObjectVO( objectVO.pageVO, typesProxy.getType( result.Object.@Type ) );
					newObjectVO.setID( result.Object.@ID );
					newObjectVO.parentID = result.ParentId[ 0 ];
					newObjectVO.setXMLDescription( result.Object[ 0 ] );

					sendNotification( ApplicationFacade.OBJECT_OBJECT_CREATED, { objectVO: objectVO, newObjectVO: newObjectVO } );

					break;
				}

				case "set_attributes":
				{
					objectAttributesVO = new ObjectAttributesVO( objectVO );
					objectAttributesVO.setXMLDescription( result.Object[ 0 ] );

					notification = new ProxyNotification( ApplicationFacade.OBJECT_ATTRIBUTES_SETTED,
														  { objectVO: objectVO, objectAttributesVO: objectAttributesVO } );
					notification.token = token;

					break;
				}
			}

			if ( notification )
				facade.notifyObservers( notification );
		}
	}
}