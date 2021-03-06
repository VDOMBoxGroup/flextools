package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	import mx.rpc.soap.SOAPFault;
	
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.model._vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 * ObjectProxy is wrapper on VDOM Object.
	 * Takes data from the server through the SOAP functions.
	 *
	 * @see net.vdombox.ide.common.vo.ObjectVO
	 * @see net.vdombox.ide.core.model.business.SOAP
	 * @see net.vdombox.ide.core.controller.requests.ObjectProxyRequestCommand
	 * @see net.vdombox.ide.core.controller.responses.ObjectProxyResponseCommand
	 *
	 * @author Alexey Andreev
	 *
	 * @flowerModelElementId _DDvAUEomEeC-JfVEe_-0Aw
	 */
	public class ObjectProxy extends Proxy
	{
		public static const NAME : String = "ObjectProxy";

		private static const GET_ATTRIBUTES : String = "getAttributes";

		private static const SET_ATTRIBUTES : String = "setAttributes";

		private static const GET_WYSIWYG : String = "getWYSIWYG";

		private static const GET_CHECK : String = "getCheck";

		private static const GET_SCRIPT : String = "getScript";

		public static var instances : Object = {};

		public function ObjectProxy( objectVO : ObjectVO )
		{
			super( NAME + "/" + objectVO.pageVO.applicationVO.id + "/" + objectVO.pageVO.id + "/" + objectVO.id, objectVO );

			instances[ this.proxyName ] = "";
		}

		private function get soap() : SOAP
		{
			return SOAP.getInstance();
		}

		private var typesProxy : TypesProxy;

		private var serverProxy : ServerProxy;

		public function get objectVO() : ObjectVO
		{
			return data as ObjectVO;
		}

		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;

			serverProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			typesProxy = null;

			removeHandlers();

			delete instances[ proxyName ];
		}

		private var rmcXML : XML = new XML( "<Arguments><CallType>rmc</CallType></Arguments>" );

		public function remoteCall( functionName : String, value : String ) : AsyncToken
		{
			var token : AsyncToken;

			token = soap.remote_call( objectVO.pageVO.applicationVO.id, objectVO.id, functionName, rmcXML, value );

			token.recipientName = proxyName;

			return token;
		}

		public function getAttributes() : AsyncToken
		{
			var token : AsyncToken;

			trace( ( new Date() ).time );
			token = soap.get_one_object( objectVO.pageVO.applicationVO.id, objectVO.id );
			token.recipientName = proxyName;

			return token;
		}

		public function setAttributes( vdomObjectAttributesVO : VdomObjectAttributesVO ) : AsyncToken
		{
			var token : AsyncToken;

			var attributes : Array = vdomObjectAttributesVO.getChangedAttributes();

			if ( attributes.length == 0 )
			{
				sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_SETTED, { objectVO: vdomObjectAttributesVO.vdomObjectVO, vdomObjectAttributesVO: vdomObjectAttributesVO } );

				return token;
			}

			var attributesXML : XML = <Attributes/>;
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

		public function createCopy( sourceID : String ) : AsyncToken
		{
			var token : AsyncToken;
			//token = soap.copy_object(objectVO.pageVO.applicationVO.id, objectVO.id, sourceID );

			var sourceInfo : Array = sourceID.split( " " );

			var sourceAppId : String = sourceInfo[ 1 ] as String;
			var sourceObjId : String = sourceInfo[ 2 ] as String;

			if ( objectVO.pageVO.applicationVO.id == sourceAppId )
				token = soap.copy_object( objectVO.pageVO.applicationVO.id, objectVO.id, sourceObjId, null );
			else
				token = soap.copy_object( sourceAppId, objectVO.id, sourceObjId, objectVO.pageVO.applicationVO.id );


			token.recipientName = proxyName;

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

		public function setXMLPresentation( value : VdomObjectXMLPresentationVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.submit_object_script_presentation( objectVO.pageVO.applicationVO.id, objectVO.id, value.xmlPresentation );

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

		public function getServerActionsList() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions_list( objectVO.pageVO.applicationVO.id, objectVO.id );

			token.recipientName = proxyName;

			return token;
		}

		public function getServerAction( serverActionVO : ServerActionVO, check : Boolean ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_action( objectVO.pageVO.applicationVO.id, objectVO.id, serverActionVO.id );

			token.recipientName = proxyName;

			token.requestFunctionName = check ? GET_CHECK : GET_SCRIPT;

			return token;
		}

		public function setServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_server_action( objectVO.pageVO.applicationVO.id, objectVO.id, serverActionVO.id, serverActionVO.script );

			token.recipientName = proxyName;

			return token;
		}

		public function createServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.create_server_action( objectVO.pageVO.applicationVO.id, objectVO.id, serverActionVO.name, serverActionVO.script );

			token.recipientName = proxyName;

			return token;
		}

		public function renameServerAction( serverActionVO : ServerActionVO, newName : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.rename_server_action( objectVO.pageVO.applicationVO.id, objectVO.id, serverActionVO.id, newName );

			token.recipientName = proxyName;

			return token;
		}

		private var _serverActionVO : ServerActionVO;

		public function deleteServerAction( serverActionVO : ServerActionVO ) : AsyncToken
		{
			_serverActionVO = serverActionVO;

			var token : AsyncToken;
			token = soap.delete_server_action( objectVO.pageVO.applicationVO.id, objectVO.id, serverActionVO.id );

			token.recipientName = proxyName;

			return token;
		}

		public function setServerActions( serverActions : Array ) : AsyncToken
		{
			var token : AsyncToken;

			var language : String = "vscript";

			if ( objectVO.pageVO.applicationVO.scriptingLanguage )
				language = objectVO.pageVO.applicationVO.scriptingLanguage;

			var serverActionsXML : XML = <ServerActions/>;
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

		public function createObject( typeVO : TypeVO, attributes : Array, objectName : String ) : AsyncToken
		{
			var token : AsyncToken;

			var attributesXML : XML;
			var attributeVO : AttributeVO;

			if ( attributes.length > 0 )
			{
				attributesXML = <Attributes/>;

				for each ( attributeVO in attributes )
				{
					attributesXML.appendChild( <Attribute Name={attributeVO.name}>{attributeVO.value}</Attribute> );
				}
			}

			token = soap.create_object( objectVO.pageVO.applicationVO.id, objectVO.id, typeVO.id, objectName, attributesXML );

			token.recipientName = proxyName;

			return token;
		}

		private function addHandlers() : void
		{
			soap.get_one_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.get_server_actions_list.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions_list.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.get_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_action.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_action.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.create_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_server_action.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.delete_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_server_action.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.rename_server_action.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.rename_server_action.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.create_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_attributes.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.get_child_objects_tree.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects_tree.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.render_wysiwyg.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.render_wysiwyg.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.get_object_script_presentation.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_object_script_presentation.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.submit_object_script_presentation.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.submit_object_script_presentation.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.set_name.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_name.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.get_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.copy_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.copy_object.addEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.remote_call.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.remote_call.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );


		}

		private function removeHandlers() : void
		{
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.get_server_actions_list.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions_list.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.get_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_action.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_action.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.create_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_server_action.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.delete_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_server_action.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.rename_server_action.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.rename_server_action.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_attributes.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_attributes.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.get_child_objects_tree.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_child_objects_tree.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.render_wysiwyg.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.render_wysiwyg.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.get_object_script_presentation.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_object_script_presentation.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.submit_object_script_presentation.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.submit_object_script_presentation.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.set_name.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_name.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.copy_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.copy_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

			soap.remote_call.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.remote_call.removeEventListener( FaultEvent.FAULT, soap_faultHandler );

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
			var structure : XML = <object/>

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
			var structureObject : XML = <object/>;
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

		public function setName() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_name( objectVO.pageVO.applicationVO.id, objectVO.id, objectVO.name );

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

			var vdomObjectAttributesVO : VdomObjectAttributesVO;

			var xmlPresentation : String;

			var serverActions : Array = [];
			var serverActionsXMLList : XMLList;
			var serverActionVO : ServerActionVO;
			var serverActionXML : XML;

			if ( result.hasOwnProperty( "Error" ) )
			{
				sendNotification( ApplicationFacade.WRITE_ERROR, { text: result.Error.toString() } );
				if ( operationName == "remote_call" )
					sendNotification( ApplicationFacade.APPLICATION_REMOTE_CALL_ERROR_GETTED, { objectVO: objectVO, error: "" } );

				if ( operationName == "copy_object" )
					sendNotification( ApplicationFacade.ERROR_TO_PASTE, objectVO.pageVO.applicationVO );

				return;
			}


			switch ( operationName )
			{
				case "get_server_actions_list":
				{
					serverActionsXMLList = result.ServerActions.Action.( @ObjectID == objectVO.id );

					for each ( serverActionXML in serverActionsXMLList )
					{
						serverActionVO = new ServerActionVO();

						serverActionVO.setContainerID( objectVO.pageVO.id );
						serverActionVO.setObjectID( serverActionXML.@ID[ 0 ] );

						serverActionVO.setProperties( serverActionXML )
						serverActionVO.containerVO = objectVO;

						if ( serverActionVO.name != "onload" )
							serverActions.push( serverActionVO );
					}

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_LIST_GETTED, { objectVO: objectVO, serverActions: serverActions } );

					break;
				}

				case "get_server_action":
				{
					serverActionXML = result.*[ 0 ];

					serverActionVO = new ServerActionVO();
					serverActionVO.setContainerID( objectVO.id );
					serverActionVO.setObjectID( serverActionXML.@ID[ 0 ] );
					serverActionVO.setProperties( serverActionXML )
					serverActionVO.script = serverActionXML.children();
					serverActionVO.containerVO = objectVO;


					var check : Boolean = token.requestFunctionName == GET_CHECK ? true : false;

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTION_GETTED, { objectVO: objectVO, serverActionVO: serverActionVO, check: check } );

					break;
				}

				case "get_server_actions":
				{
					if ( result.ServerActions.Container )
					{
						var containerXML : XML = result.ServerActions.Container.( @ID == objectVO.id )[ 0 ]
						if ( containerXML )
							serverActionsXMLList = containerXML.children();
					}

					for each ( serverActionXML in serverActionsXMLList )
					{
						serverActionVO = new ServerActionVO();

						serverActionVO.setContainerID( objectVO.id );
						serverActionVO.setObjectID( serverActionXML.@ID[ 0 ] );

						serverActionVO.setProperties( serverActionXML )

						serverActionVO.script = serverActionXML.children();
						serverActionVO.containerVO = objectVO;

						serverActions.push( serverActionVO );
					}

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTIONS_GETTED, { objectVO: objectVO, serverActions: serverActions } );

					break;
				}

				case "set_server_actions":
				{

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTION_CREATED, { objectVO: objectVO, serverActions: serverActions } );

					break;
				}

				case "set_server_action":
				{
					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTION_SETTED, { objectVO: objectVO } );

					break;
				}

				case "rename_server_action":
				{
					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTION_RENAMED, { objectVO: objectVO, serverActionID: result.Action.@ID.toString(), newName: result.Action.@Name.toString() } );

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

				case "get_one_object":
				{
					trace( ( new Date() ).time );
					vdomObjectAttributesVO = new VdomObjectAttributesVO( objectVO );
					vdomObjectAttributesVO.setXMLDescription( result.Objects.Object[ 0 ] );
					objectVO.name = result.Objects.Object[ 0 ].@Name;

					sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, { objectVO: objectVO, vdomObjectAttributesVO: vdomObjectAttributesVO } );

					break;
				}

				case "set_attributes":
				{
					vdomObjectAttributesVO = new VdomObjectAttributesVO( objectVO );
					vdomObjectAttributesVO.setXMLDescription( result.Object[ 0 ] );

					sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_SETTED, { objectVO: objectVO, vdomObjectAttributesVO: vdomObjectAttributesVO } );

					break;
				}

				case "set_name":
				{
					objectVO.name = result.Object[ 0 ].@Name;

					sendNotification( ApplicationFacade.OBJECT_NAME_SETTED, objectVO );

					break;
				}

				case "get_child_objects_tree":
				{
					var structure : XML = generateObjectStructure( result.Object[ 0 ] );

					if ( token.requestFunctionName == GET_WYSIWYG )
					{
						token = soap.render_wysiwyg( objectVO.pageVO.applicationVO.id, objectVO.id, "", 1 );

						token.structure = <structure>{structure}</structure>;
						token.recipientName = proxyName;
						token.requestFunctionName = GET_WYSIWYG;
					}

					break;
				}

				case "render_wysiwyg":
				{
					var wysiwyg : XML = result.Result.children()[ 0 ];

					/*
					   if ( !wysiwyg )
					   wysiwyg = result.Result.table[ 0 ];
					 */

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

					sendNotification( ApplicationFacade.OBJECT_WYSIWYG_GETTED, { objectVO: objectVO, wysiwyg: wysiwyg } );

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

					var vdomObjectXMLPresentationVO : VdomObjectXMLPresentationVO = new VdomObjectXMLPresentationVO( objectVO );
					vdomObjectXMLPresentationVO.xmlPresentation = xmlPresentation;

					sendNotification( ApplicationFacade.PAGE_XML_PRESENTATION_GETTED, { objectVO: objectVO, vdomObjectXMLPresentationVO: vdomObjectXMLPresentationVO } );

					break;
				}

				case "submit_object_script_presentation":
				{
					sendNotification( ApplicationFacade.OBJECT_XML_PRESENTATION_SETTED, { objectVO: objectVO } );

					break;
				}

				case "copy_object":
				{
					var objectXML : XML = result.Object[ 0 ];

					var typeVO : TypeVO = typesProxy.getType( objectXML.@Type );

					var objVO : ObjectVO = new ObjectVO( objectVO.pageVO, typeVO );
					objVO.setID( objectXML.@ID );

					objVO.setXMLDescription( objectXML );

					sendNotification( ApplicationFacade.OBJECT_COPY_CREATED, { targetObject: objectVO, newObject: objVO } );

					break;
				}

				case "remote_call":
				{
					sendNotification( ApplicationFacade.OBJECT_REMOTE_CALL_GETTED, { objectVO: objectVO, result: result, serverVersion: serverProxy.authInfo.serverVersion } );

					break;
				}

				case "create_server_action":
				{
					serverActionVO = new ServerActionVO();

					serverActionVO.setContainerID( objectVO.id );

					serverActionVO.setProperties( result.Action[ 0 ] )

					serverActionVO.script = "";

					sendNotification( ApplicationFacade.OBJECT_SERVER_ACTION_CREATED, { objectVO: objectVO, serverActionVO: serverActionVO } );

					break;
				}

				case "delete_server_action":
				{
					sendNotification( ApplicationFacade.PAGE_SERVER_ACTION_DELETED, { objectVO: objectVO, serverActionVO: _serverActionVO } );

					break;
				}
			}
		}

		private function soap_faultHandler( event : FaultEvent ) : void
		{
			var token : AsyncToken = event.token;

			if ( !token.hasOwnProperty( "recipientName" ) || token.recipientName != proxyName )
				return;

			var operation : Operation = event.currentTarget as Operation;
			var fault : SOAPFault = event.fault as SOAPFault;

			if ( !operation || !fault )
				return;

			var operationName : String = operation.name;

			sendNotification( ApplicationFacade.WRITE_ERROR, { text: fault.faultString, detail: fault.detail } );

			switch ( operationName )
			{
				case "set_name":
				{
					var detailXML : XML = new XML( fault.detail );
					objectVO.name = detailXML.Name;

					sendNotification( ApplicationFacade.OBJECT_NAME_SETTED, objectVO );

					break;
				}

				case "remote_call":
				{
					sendNotification( ApplicationFacade.APPLICATION_REMOTE_CALL_ERROR_GETTED, { objectVO: objectVO, error: fault.detail } );

					return;
				}

				case "copy_object":
				{
					sendNotification( ApplicationFacade.ERROR_TO_PASTE, objectVO.pageVO.applicationVO );

					break;
				}
			}
		}
	}
}
