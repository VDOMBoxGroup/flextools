package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.soap.Operation;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.patterns.observer.ProxyNotification;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ObjectProxy extends Proxy
	{
		public static const NAME : String = "ObjectProxy";

		public function ObjectProxy( objectVO : ObjectVO )
		{
			super( NAME + "/" + objectVO.pageVO.applicationVO.id + "/" + objectVO.pageVO.id + "/" + objectVO.id, objectVO );
		}

		private var soap : SOAP = SOAP.getInstance();

		public function get objectVO() : ObjectVO
		{
			return data as ObjectVO;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		public function getAttributes() : AsyncToken
		{
			var token : AsyncToken;

			token = soap.get_one_object( objectVO.pageVO.applicationVO.id, objectVO.id );
			token.recipientName = proxyName;

			return token;
		}
		
		public function getServerActions() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions( objectVO.pageVO.applicationVO.id, objectVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}

		private function addHandlers() : void
		{
			soap.get_one_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function removeHandlers() : void
		{
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
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

			switch ( operationName )
			{
				case "get_one_object":
				{
					var attributes : Array = generateObjectAttributes( result.Objects.Object.Attributes[ 0 ] );

					notification = new ProxyNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, attributes );
					notification.token = token;

					break;
				}
					
				case "get_server_actions":
				{
					var serverActions : Array = [];
					
					var serverActionsXML : XMLList = result.ServerActions.Container.( @ID == objectVO.id ).Action;
					
					var serverActionVO : ServerActionVO;
					var serverActionXML : XML;
					
					for each( serverActionXML in serverActionsXML )
					{
						serverActionVO = new ServerActionVO( serverActionXML.@Name, objectVO );
						serverActionVO.setID( serverActionXML.@ID );
						
						serverActionVO.script = serverActionXML[ 0 ];
						
						serverActions.push( serverActionVO );
					}
					
					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_GETTED, serverActions );
					
					break;
				}
			}

			if ( notification )
				facade.notifyObservers( notification );
		}
	}
}