package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	import mx.rpc.soap.SOAPFault;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.vo.ErrorVO;
	import net.vdombox.ide.core.patterns.observer.ProxyNotification;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 * PageProxy is wrapper on VDOM Top Level Container(Page).   
	 * Takes data from the server through the SOAP functions.
	 * 
	 * @see net.vdombox.ide.common.vo.PageVO
	 * @see net.vdombox.ide.core.model.business.SOAP
	 * @see net.vdombox.ide.core.controller.requests.PageProxyRequestCommand
	 * @see net.vdombox.ide.core.controller.responses.PageProxyResponseCommand
	 * 
	 * @author Alexey Andreev
	 * 
	 * @flowerModelElementId _DD9p0EomEeC-JfVEe_-0Aw
	 */
	public class PageProxy extends Proxy
	{
		public static const NAME : String = "PageProxy";

		private static const GET_ATTRIBUTES : String = "getAttributes";
		private static const SET_ATTRIBUTES : String = "setAttributes";

		private static const GET_OBJECT : String = "getObject";
		private static const GET_OBJECTS : String = "getObjects";

		private static const GET_STRUCTURE : String = "getStructure";
		private static const GET_WYSIWYG : String = "getWYSIWYG";

		public static var instances : Object = {};

		public function PageProxy( pageVO : PageVO )
		{
			super( NAME + "/" + pageVO.applicationVO.id + "/" + pageVO.id, pageVO );

			instances[ this.proxyName ] = "";
		}

		private var soap : SOAP = SOAP.getInstance();

		private var typesProxy : TypesProxy;

		private var _objects : Array;

		public function get pageVO() : PageVO
		{
			return data as PageVO;
		}

		public function get id() : String
		{
			return null;
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

			delete instances[ proxyName ];
		}

		public function getStructure() : AsyncToken
		{
			var token : AsyncToken;

			token = soap.get_child_objects_tree( pageVO.applicationVO.id, pageVO.id );
			token.recipientName = proxyName;
			token.requestFunctionName = GET_STRUCTURE;

			return token;
		}

		public function getAttributes() : AsyncToken
		{
			var token : AsyncToken;

			token = soap.get_one_object( pageVO.applicationVO.id, pageVO.id );
			token.recipientName = proxyName;
			token.requestFunctionName = GET_ATTRIBUTES;

			return token;
		}

		/**
		 * 
		 * @param vdomObjectAttributesVO
		 * @return AsyncToken if exist changes in Attributes else return null
		 * 
		 */		
		public function setAttributes( vdomObjectAttributesVO : VdomObjectAttributesVO ) : AsyncToken
		{
			var token : AsyncToken;

			var attributes : Array = vdomObjectAttributesVO.getChangedAttributes();

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

			token = soap.set_attributes( pageVO.applicationVO.id, pageVO.id, attributesXML );
			token.recipientName = proxyName;
			token.requestFunctionName = SET_ATTRIBUTES;

			return token;
		}

		public function getObjects() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_child_objects( pageVO.applicationVO.id, pageVO.id );

			token.recipientName = proxyName;
			token.requestFunctionName = GET_OBJECTS;

			return token;
		}

		public function getServerActionsList() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions_list( pageVO.applicationVO.id, pageVO.id );

			token.recipientName = proxyName;

			return token;
		}
		
		public function getServerActions() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions( pageVO.applicationVO.id, pageVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		

		public function getServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_action( pageVO.applicationVO.id, pageVO.id, serverActionVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function setServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_server_action( pageVO.applicationVO.id, pageVO.id, serverActionVO.id, serverActionVO.script );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function createServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.create_server_action( pageVO.applicationVO.id, pageVO.id, serverActionVO.name, serverActionVO.script );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function renameServerAction( serverActionVO : ServerActionVO, newName : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.rename_server_action( pageVO.applicationVO.id, pageVO.id, serverActionVO.id, newName );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function deleteServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.delete_server_action( pageVO.applicationVO.id, pageVO.id, serverActionVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function setServerActions( serverActions : Array ) : AsyncToken
		{
			var token : AsyncToken;

			var language : String = "vscript";

			if ( pageVO.applicationVO.scriptingLanguage )
				language = pageVO.applicationVO.scriptingLanguage;

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

			token = soap.set_server_actions( pageVO.applicationVO.id, pageVO.id, serverActionsXML );

			token.recipientName = proxyName;
			token.serverActions = serverActions.slice();

			return token;
		}

		public function getWYSIWYG() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_child_objects_tree( pageVO.applicationVO.id, pageVO.id );

			token.recipientName = proxyName;
			token.requestFunctionName = GET_WYSIWYG;

			return token;
		}

		public function getXMLPresentation() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_object_script_presentation( pageVO.applicationVO.id, pageVO.id );

			token.recipientName = proxyName;

			return token;
		}

		public function setXMLPresentation( value : VdomObjectXMLPresentationVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.submit_object_script_presentation( pageVO.applicationVO.id, pageVO.id, value.xmlPresentation );

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
					<Attributes/>;

				for each ( attributeVO in attributes )
				{
					attributesXML.appendChild(
						<Attribute Name={attributeVO.name}>{attributeVO.value}</Attribute>
						);
				}
			}

			token = soap.create_object( pageVO.applicationVO.id, pageVO.id, typeVO.id, "", attributesXML );

			token.recipientName = proxyName;

			return token;
		}

		public function deleteObject( objectVO : ObjectVO ) : AsyncToken
		{
			var token : AsyncToken;

			token = soap.delete_object( pageVO.applicationVO.id, objectVO.id );

			token.recipientName = proxyName;
			token.objectVO = objectVO;

			return token;
		}

		public function deleteObjectAt( objectID : String ) : void
		{
		}

		public function getObjectAt( objectID : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_one_object( pageVO.applicationVO.id, objectID );

			token.recipientName = proxyName;
			token.requestFunctionName = GET_OBJECT;

			return token;
		}

		public function getObjectProxy( objectVO : ObjectVO ) : ObjectProxy
		{
			var objectProxy : ObjectProxy = facade.retrieveProxy( ObjectProxy.NAME + "/" + objectVO.pageVO.applicationVO.id + "/" +
				objectVO.pageVO.id + "/" + objectVO.id ) as ObjectProxy;

			if ( !objectProxy )
			{
				objectProxy = new ObjectProxy( objectVO ) as ObjectProxy;
				facade.registerProxy( objectProxy );
			}

			return objectProxy;
		}

		private function addHandlers() : void
		{
			soap.get_child_objects_tree.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.addEventListener(  FaultEvent.FAULT, soap_faultHandler);
			
			soap.get_server_actions_list.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.addEventListener( FaultEvent.FAULT, soap_resultHandler );
			
			soap.create_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.rename_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			
			soap.render_wysiwyg.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_object_script_presentation.addEventListener( SOAPEvent.RESULT, soap_resultHandler );

			soap.submit_object_script_presentation.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.submit_object_script_presentation.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.set_name.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_name.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.addEventListener( FaultEvent.FAULT, soap_faultHandler );
		}

		private function removeHandlers() : void
		{
			soap.set_attributes.removeEventListener(  FaultEvent.FAULT, soap_faultHandler);
			soap.get_child_objects_tree.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			
			soap.get_server_actions_list.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.removeEventListener( FaultEvent.FAULT, soap_resultHandler );
			
			soap.create_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.rename_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			
			soap.render_wysiwyg.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_object_script_presentation.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.submit_object_script_presentation.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			
			soap.set_name.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_name.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			
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

				var typeVO : TypeVO = typesProxy.getType( typeID );

				var objectVO : ObjectVO = new ObjectVO( pageVO, typeVO );
				objectVO.setID( objectID );

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
		
		public function setName(  ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_name( pageVO.applicationVO.id, pageVO.id, pageVO.name );
			
			token.recipientName = proxyName;
			
			return token;
			
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

			var vdomObjectAttributesVO : VdomObjectAttributesVO;
			var objectVO : ObjectVO;

			var xmlPresentation : String;
			var serverActions : Array = [];
			
			var serverActionsXMLList : XMLList 
			var serverActionVO : ServerActionVO;
			var serverActionXML : XML;


			switch ( operationName )
			{
				case "get_child_objects_tree":
				{

					var structure : XML = generatePageStructure( result.Object[ 0 ] );

					if ( token.requestFunctionName == GET_STRUCTURE )
					{
						notification = new ProxyNotification( ApplicationFacade.PAGE_STRUCTURE_GETTED, structure )
						notification.token = token;
					}
					else if ( token.requestFunctionName == GET_WYSIWYG )
					{
						token = soap.render_wysiwyg( pageVO.applicationVO.id, pageVO.id, "", 1 );

						token.structure =
							<structure>{structure}</structure>;
						token.recipientName = proxyName;
						token.requestFunctionName = GET_WYSIWYG;
					}

					break;
				}
					
				case "set_name":
				{
					pageVO.name = result.Object[ 0 ].@Name;
					notification = new ProxyNotification( ApplicationFacade.PAGE_NAME_SETTED, pageVO );
					notification.token = token;
					
					break;
				}

				case "get_child_objects":
				{
					createObjectsList( result.Objects[ 0 ] );
					notification = new ProxyNotification( ApplicationFacade.PAGE_OBJECTS_GETTED, _objects );
					notification.token = token;

					break;
				}

				case "get_server_actions_list":
				{
					serverActionsXMLList  = result.ServerActions.Action.( @ObjectID == pageVO.id );

					
					for each ( serverActionXML in serverActionsXMLList )
					{
						serverActionVO = new ServerActionVO();

						serverActionVO.setContainerID( pageVO.id );
						serverActionVO.setObjectID( serverActionXML.@ID[ 0 ] );

						serverActionVO.setProperties( serverActionXML );

						if ( serverActionVO.name != "onload" )
							serverActions.push( serverActionVO );
					}

					sendNotification( ApplicationFacade.PAGE_SERVER_ACTIONS_LIST_GETTED, { pageVO: pageVO, serverActions: serverActions } )

					break;
				}
					
				case "get_server_actions":
				{
					
					serverActionsXMLList = result.ServerActions.Container.( @ID == pageVO.id )[0].children();
					
					for each ( serverActionXML in serverActionsXMLList )
					{
						serverActionVO = new ServerActionVO();
						
						serverActionVO.setContainerID( pageVO.id );
						serverActionVO.setObjectID( serverActionXML.@ID[ 0 ] );
						
						serverActionVO.setProperties( serverActionXML )
						
						serverActionVO.script = serverActionXML.children();
						
						serverActions.push( serverActionVO );
					}
					
					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_GETTED, { objectVO: objectVO, serverActions: serverActions } );
					
					break;
				}

				case "get_server_action":
				{
					var iyt : int = 3;
					break;
				}
					
				
				case "set_server_actions":
				{
					
					sendNotification( ApplicationFacade.PAGE_SERVER_ACTION_CREATED , { pageVO: pageVO } );
					

					break;
				}
					
				case "create_server_action":
				{
					
					break;
				}
					
				case "rename_server_action":
				{
					
					break;
				}
					
				case "delete_server_action":
				{
					
					break;
				}
					
				case "get_one_object":
				{
					if ( token.requestFunctionName == GET_OBJECT )
					{
						var objectXML : XML = result.Objects.Object[ 0 ];

						var typeVO : TypeVO = typesProxy.getType( objectXML.@Type );

						objectVO = new ObjectVO( pageVO, typeVO );
						objectVO.setID( objectXML.@ID );

						objectVO.setXMLDescription( objectXML );

						notification = new ProxyNotification( ApplicationFacade.PAGE_OBJECT_GETTED, { pageVO: pageVO, objectVO: objectVO } );
						notification.token = token;
					}
					else if ( token.requestFunctionName == GET_ATTRIBUTES )
					{
						vdomObjectAttributesVO = new VdomObjectAttributesVO( pageVO );
						vdomObjectAttributesVO.setXMLDescription( result.Objects.Object[ 0 ] );

						notification =
							new ProxyNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED,
							{ pageVO: pageVO, vdomObjectAttributesVO: vdomObjectAttributesVO } );
						notification.token = token;
					}

					break;
				}

				case "set_attributes":
				{
					vdomObjectAttributesVO = new VdomObjectAttributesVO( pageVO );
					vdomObjectAttributesVO.setXMLDescription( result.Object[ 0 ] );

					notification =
						new ProxyNotification( ApplicationFacade.PAGE_ATTRIBUTES_SETTED,
						{ pageVO: pageVO, vdomObjectAttributesVO: vdomObjectAttributesVO } );
					notification.token = token;

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

					notification = new ProxyNotification( ApplicationFacade.PAGE_WYSIWYG_GETTED, { pageVO: pageVO, wysiwyg: wysiwyg } );
					notification.token = token;

					break;
				}

				case "create_object":
				{
					objectVO = new ObjectVO( pageVO, typesProxy.getType( result.Object.@Type ) );
					objectVO.setID( result.Object.@ID );
					objectVO.parentID = result.ParentId[ 0 ];
					objectVO.setXMLDescription( result.Object[ 0 ] );

					sendNotification( ApplicationFacade.PAGE_OBJECT_CREATED, { pageVO: pageVO, objectVO: objectVO } );

					break;
				}

				case "delete_object":
				{
					objectVO = token.objectVO;

					sendNotification( ApplicationFacade.PAGE_OBJECT_DELETED, { pageVO: pageVO, objectVO: objectVO } );

					break;
				}

				case "get_object_script_presentation":
				{
					try
					{
						xmlPresentation = result.Result[ 0 ].*.toXMLString();
					}
					catch ( error : Error )
					{
					}

					var vdomObjectXMLPresentationVO : VdomObjectXMLPresentationVO = new VdomObjectXMLPresentationVO( pageVO );
					vdomObjectXMLPresentationVO.xmlPresentation = xmlPresentation;

					sendNotification( ApplicationFacade.PAGE_XML_PRESENTATION_GETTED,
									  { pageVO: pageVO, vdomObjectXMLPresentationVO: vdomObjectXMLPresentationVO } );

					break;
				}

				case "submit_object_script_presentation":
				{
					sendNotification( ApplicationFacade.PAGE_XML_PRESENTATION_SETTED, { pageVO: pageVO } );

					break;
				}
			}

			if ( notification )
				facade.notifyObservers( notification );
		}

		private function soap_faultHandler( event : FaultEvent ) : void
		{
			var operation : Operation = event.target as Operation;

			if ( !operation )
				return;
			

			var operationName : String = operation.name;
			var errorVO : ErrorVO;
			
			var notification : ProxyNotification;
			var token : AsyncToken = event.token;
			var fault : SOAPFault = event.fault as SOAPFault;
			
			switch ( operationName )
			{
				case "submit_object_script_presentation":
				{
					errorVO = new ErrorVO();
					errorVO.code = event.fault.faultCode;
					errorVO.string = "XML not well-formed";

					sendNotification( ApplicationFacade.SERVER_ERROR, errorVO );

					break;
				}
					
				case "set_name":
				{
					var detailXML : XML = new XML(fault.detail);
					if (pageVO.id != detailXML.ObjectID)
						break;
					pageVO.name = detailXML.Name;
					notification = new ProxyNotification( ApplicationFacade.PAGE_NAME_SETTED, pageVO );
					notification.token = token;
					break;
				}

			}
			if ( notification )
				facade.notifyObservers( notification );
		}
	}
}