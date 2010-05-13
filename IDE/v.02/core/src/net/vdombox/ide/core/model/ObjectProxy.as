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

		private static const GET_WYSIWYG : String = "getWYSIWYG";

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

		public function setAttributes( objectAttributesVO : ObjectAttributesVO ) : AsyncToken
		{
			var token : AsyncToken;

			var attributes : Array = objectAttributesVO.getChangedAttributes();

			if ( attributes.length == 0 )
			{
				facade.notifyObservers( new ProxyNotification( ApplicationFacade.OBJECT_ATTRIBUTES_SETTED,
															   { objectVO: objectAttributesVO.objectVO, objectAttributesVO: objectAttributesVO } ) );

				return token;
			}

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

		public function getWYSIWYG() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_child_objects_tree( objectVO.pageVO.applicationVO.id, objectVO.id );

			token.recipientName = proxyName;
			token.requestFunctionName = GET_WYSIWYG;

			return token;
		}

		public function getXMLPresentation() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_object_script_presentation( objectVO.pageVO.applicationVO.id, objectVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function setXMLPresentation( value : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.submit_object_script_presentation( objectVO.pageVO.applicationVO.id, objectVO.id, value );
			
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

		public function setServerActions( serverActions : Array ) : AsyncToken
		{
			var token : AsyncToken;
			
			var language : String = "vscript";
			
			if ( objectVO.pageVO.applicationVO.scriptingLanguage )
				language = objectVO.pageVO.applicationVO.scriptingLanguage;
			
			var serverActionsXML : XML =
				<ServerActions/>
				;
			var serverActionVO : ServerActionVO;
			
			for each ( serverActionVO in serverActions )
			{
				if ( !serverActionVO.language )
					serverActionVO.language = language;
				
				serverActionsXML.appendChild( serverActionVO.toXML() );
			}
			
			token = soap.set_server_actions( objectVO.pageVO.applicationVO.id, objectVO.id, serverActionsXML );
			
			token.recipientName = proxyName;
			token.serverActions = serverActions.slice();
			
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
			soap.set_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects_tree.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.render_wysiwyg.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_object_script_presentation.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.submit_object_script_presentation.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}

		private function removeHandlers() : void
		{
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects_tree.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.render_wysiwyg.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_object_script_presentation.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.submit_object_script_presentation.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
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

		private function generateObjectStructure( rawObject : XML ) : XML
		{
			var structure : XML =
				<object/>

			var rawChildren : XMLList = rawObject.Objects.Object;

			structure.@id = rawObject.@ID;
			structure.@name = rawObject.@Name;
			structure.@typeID = rawObject.@Type;

			if ( rawChildren.length() == 0 )
				return structure;

			var child : XML;
			var rawChild : XML

			for each ( rawChild in rawChildren )
			{
				child = createStructureObject( rawChild );

				structure.appendChild( child );
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

			if ( !token.hasOwnProperty( "recipientName" ) || token.recipientName != proxyName )
				return;

			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;

			if ( !operation || !result )
				return;

			var operationName : String = operation.name;
			var notification : ProxyNotification;

			var objectAttributesVO : ObjectAttributesVO;
			
			var xmlPresentation : String;

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
						serverActionVO = new ServerActionVO();
						
						serverActionVO.setContainerID( objectVO.pageVO.id );
						serverActionVO.setObjectID( serverActionXML.@ID[ 0 ] );
						
						serverActionVO.setProperties( serverActionXML )

						serverActions.push( serverActionVO );
					}

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_GETTED, { objectVO: objectVO, serverActions : serverActions } );

					break;
				}

				case "set_server_actions":
				{
					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_SETTED, { objectVO: objectVO, serverActions : token.serverActions } )
					
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

				case "get_child_objects_tree":
				{
					var structure : XML = generateObjectStructure( result.Object[ 0 ] );

					if ( token.requestFunctionName == GET_WYSIWYG )
					{
						token = soap.render_wysiwyg( objectVO.pageVO.applicationVO.id, objectVO.id, "", 1 );

						token.structure =
							<structure>{structure}</structure>
							;
						token.recipientName = proxyName;
						token.requestFunctionName = GET_WYSIWYG;
					}

					break;
				}

				case "render_wysiwyg":
				{
					var wysiwyg : XML = result.Result.container[ 0 ];

					var tempList : XMLList = result.Result.descendants( "*" );
					var tempElement : XML;
					var structureList : XMLList = token.structure.descendants( "*" );
					var id : String;
					var typeID : String;

					for each ( tempElement in tempList )
					{
						id = tempElement.@id;
						if ( id == "" )
							continue;

						typeID = structureList.( @id == id ).@typeID;

						if ( typeID != "" )
							tempElement.@typeID = typeID;
					}

					notification = new ProxyNotification( ApplicationFacade.OBJECT_WYSIWYG_GETTED, { objectVO: objectVO, wysiwyg: wysiwyg } );
					notification.token = token;

					break;
				}
					
				case "get_object_script_presentation":
				{
					try
					{
						xmlPresentation = result.Result[ 0 ].*.toString();
					}
					catch ( erroe : Error )
					{
					}
					
					sendNotification( ApplicationFacade.OBJECT_XML_PRESENTATION_GETTED, { objectVO: objectVO, xmlPresentation: xmlPresentation } );
					
					break;
				}
					
				case "submit_object_script_presentation":
				{
					sendNotification( ApplicationFacade.OBJECT_XML_PRESENTATION_SETTED, { objectVO: objectVO, xmlPresentation: xmlPresentation } );
					
					break;
				}
			}

			if ( notification )
				facade.notifyObservers( notification );
		}
	}
}