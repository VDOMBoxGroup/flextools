package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.soap.Operation;
	import mx.rpc.soap.SOAPFault;
	
	import net.vdombox.ide.common.model.vo.ApplicationEventsVO;
	import net.vdombox.ide.common.model.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.model.vo.ApplicationVO;
	import net.vdombox.ide.common.model.vo.AttributeVO;
	import net.vdombox.ide.common.model.vo.ClientActionVO;
	import net.vdombox.ide.common.model.vo.EventVO;
	import net.vdombox.ide.common.model.vo.GlobalActionVO;
	import net.vdombox.ide.common.model.vo.LibraryVO;
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.common.model.vo.ServerActionVO;
	import net.vdombox.ide.common.model.vo.StructureObjectVO;
	import net.vdombox.ide.common.model.vo.TypeVO;
	import net.vdombox.ide.common.model.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.interfaces.IPageProxy;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.patterns.observer.ProxyNotification;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	/**
	 * ApplicationProxy is wrapper on VDOM Application.   
	 * Takes data from the server through the SOAP functions.
	 * 
	 * @see net.vdombox.ide.common.vo.ApplicationVO
	 * @see net.vdombox.ide.core.model.business.SOAP
	 * @see net.vdombox.ide.core.controller.requests.ApplicationProxyRequestCommand
	 * @see net.vdombox.ide.core.controller.responses.ApplicationProxyResponseCommand
	 * 
	 * @author Alexey Andreev
	 * 
	 * @flowerModelElementId _DDdTgEomEeC-JfVEe_-0Aw
	 */	
	public class ApplicationProxy extends Proxy
	{
		public static const NAME : String = "ApplicationProxy";
		
		public static var instances : Object = {};
		
		private static const CREATE_LIBRARY : String = "createLibrary";
		
		private static const GET_PAGE : String = "getPage";
		
		private static const GET_EVENTS : String = "getEvents";
		private static const SET_EVENTS : String = "setEvents";
		private static const UPDATE_LIBRARY : String = "updateLibrary";
		
		public function ApplicationProxy( applicationVO : ApplicationVO )
		{
			super( NAME + "/" + applicationVO.id, applicationVO );
			
			instances[ this.proxyName ] = "";
		}
		
		private var _pages : Array;
		
		private var _selectedPage : PageVO;
		
		private var serverProxy : ServerProxy;
		
		private var soap : SOAP = SOAP.getInstance();
		
		private var typesProxy : TypesProxy;
		
		public function get applicationVO() : ApplicationVO
		{
			return data as ApplicationVO;
		}
		
		public function changeApplicationInformation( applicationInformationVO : ApplicationInformationVO ) : AsyncToken
		{
			var applicationInformationXML : XML = applicationInformationVO.toXML();
			var token : AsyncToken;
			
			token = soap.set_application_info( applicationVO.id, applicationInformationXML );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function createLibrary( libraryVO : LibraryVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_library( applicationVO.id, libraryVO.name, libraryVO.script );
			
			token.recipientName = proxyName;
			token.requestFunctionName = CREATE_LIBRARY;
			
			return token;
		}
		
		public function createPage( typeVO : TypeVO, name : String = "", pageAttributesVO : VdomObjectAttributesVO = null ) : AsyncToken
		{
			var token : AsyncToken;
			
			var attributesXML : XML
			
			if ( pageAttributesVO && pageAttributesVO.attributes.length > 0 )
			{
				attributesXML =
					<Attributes/>;
				
				var attributeVO : AttributeVO;
				
				for each ( attributeVO in pageAttributesVO.attributes )
				{
					attributesXML.appendChild( attributeVO.toXML() );
				}
			}
			
			token = soap.create_object( applicationVO.id, "", typeVO.id, name, attributesXML ? attributesXML : "" );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function deleteLibrary( libraryVO : LibraryVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.remove_library( applicationVO.id, libraryVO.name );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function deletePage( pageVO : PageVO ) : AsyncToken
		{
			var token : AsyncToken;
			
			token = soap.delete_object( applicationVO.id, pageVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function deletePageAt( pageID : String ) : void
		{
		}
		
		public function getEvents( pageVO : PageVO ) : AsyncToken
		{
			var token : AsyncToken;
			//			token = soap.get_child_objects_tree( applicationVO.id, pageVO.id );
			
			token = soap.get_events_structure( applicationVO.id, pageVO.id );
			
			token.recipientName = proxyName;
			//			token.requestFunctionName = GET_EVENTS;
			token.pageVO = pageVO;
			
			return token;
		}
		
		public function getLibraries() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_libraries( applicationVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function getPageAt( pageID : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_one_object( applicationVO.id, pageID );
			
			token.recipientName = proxyName;
			token.requestFunctionName = GET_PAGE;
			
			return token;
		}
		
		public function getPageProxy( pageVO : PageVO ) : PageProxy
		{
			var pageProxy : PageProxy = facade.retrieveProxy( PageProxy.NAME + "/" + pageVO.applicationVO.id + "/" + pageVO.id ) as PageProxy;
			
			if ( !pageProxy )
			{
				pageProxy = new PageProxy( pageVO ) as PageProxy;
				facade.registerProxy( pageProxy );
			}
			
			return pageProxy;
		}
		
		public function getPageProxyAt( pageID : String ) : IPageProxy
		{
			return null;
		}
		
		public function getPages() : AsyncToken
		{
			var token : AsyncToken;
			
			token = soap.get_top_objects( applicationVO.id );
			
			token.recipientName = proxyName;
			return token;
		}
		
		public function getServerActions( typeAction : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions( applicationVO.id, typeAction );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function getStructure() : AsyncToken
		{
			var token : AsyncToken;
			
			token = soap.get_application_structure( applicationVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function get id() : String
		{
			return applicationVO.id;
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
		
		public function remoteCall( objectID : String, functionName : String, value : String ) : AsyncToken
		{
			var token : AsyncToken;
			
			token = soap.remote_method_call( applicationVO.id, objectID, functionName, value, "" );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		//click save button
		public function setEvents( applicationEventsVO : ApplicationEventsVO ) : AsyncToken
		{
			var token : AsyncToken;
			
			//			var serverActionsXML : XML = applicationEventsVO.getServerActionsXML();
			//
			//			token = soap.set_server_actions( applicationVO.id, applicationEventsVO.pageVO.id, serverActionsXML );
			//
			//			token.recipientName = proxyName;
			//			token.requestFunctionName = SET_EVENTS;
			//			token.applicationEventsVO = applicationEventsVO;
			
			//*****
			var e2vdom : XML = <E2vdom />;
			
			var eventsXML : XML = applicationEventsVO.getEventsXML();
			var clientActionsXML : XML = applicationEventsVO.getClientActionsXML();
			var serverActionsXML : XML = applicationEventsVO.getServerActionsXML();
			
			e2vdom.appendChild( eventsXML );
			e2vdom.appendChild( clientActionsXML );
			e2vdom.appendChild( serverActionsXML );
			
			
			token = soap.set_events_structure( applicationVO.id, applicationEventsVO.pageVO.id, e2vdom );
			//			token = soap.set_application_events( applicationVO.id, applicationEventsVO.pageVO.id, e2vdom );
			
			
			token.recipientName = proxyName;
			token.requestFunctionName = SET_EVENTS;
			token.applicationEventsVO = applicationEventsVO;
			//*****
			
			return token;
		}
		
		public function setStructure( strucrure : Array ) : AsyncToken
		{
			var token : AsyncToken;
			
			var structureXML : XML =
				<Structure/>
				;
			var structureObjectVO : StructureObjectVO;
			
			for each ( structureObjectVO in strucrure )
			{
				structureXML.appendChild( structureObjectVO.toXML() );
			}
			
			token = soap.set_application_structure( applicationVO.id, structureXML );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function updateLibrary( libraryVO : LibraryVO ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_library( applicationVO.id, libraryVO.name, libraryVO.script );
			
			token.recipientName = proxyName;
			token.requestFunctionName = UPDATE_LIBRARY;
			
			return token;
		}
		
		public function createCopy( sourceID : String ) : AsyncToken
		{
			
			var token : AsyncToken;
			
			var sourceInfo : Array = sourceID.split( " " );
			
			var sourceAppId : String = sourceInfo[1] as String;
			var sourceObjId : String = sourceInfo[2] as String;
			
			if ( applicationVO.id == sourceAppId )
					token = soap.copy_object(applicationVO.id, null, sourceObjId, null );
			else
					token = soap.copy_object(sourceAppId, null, sourceObjId, applicationVO.id );
			
			token.recipientName = proxyName;
			
			return token;
		}
		
		public function updateGlobal( globalActionVO : GlobalActionVO ) : AsyncToken
		{
			var token : AsyncToken;
			//token = soap.set_library( applicationVO.id, globalActionVO.name, globalActionVO.script );
			token = soap.set_server_action( applicationVO.id, globalActionVO.scriptsGroupName, globalActionVO.name, globalActionVO.script );
			
			token.recipientName = proxyName;
			token.requestFunctionName = UPDATE_LIBRARY;
			
			return token;
		}
		
		private function createPagesList( pages : XML ) : void
		{
			var pageVO : PageVO;
			var pageVOInd : Number = -1;
			
			var oldPages : Array = [];
			
			if (_pages)
				oldPages = _pages.slice();
			_pages = [];
			
			var pageID : String;
			var typeID : String;
			
			for each ( var page : XML in pages.* )
			{
				pageID = page.@ID[ 0 ];
				
				typeID = page.@Type[ 0 ];
				
				if ( !pageID || !typeID )
					continue;
				
				var typeVO : TypeVO = typesProxy.getType( typeID );
				
				pageVOInd = pageVOIndex(oldPages, pageID); 
				pageVO = pageVOInd >= 0 ? oldPages[pageVOInd] : new PageVO( applicationVO, typeVO );
				pageVO.setID( pageID );
				
				pageVO.setXMLDescription( page );
				
				_pages.push( pageVO );
			}
			
			_pages.sortOn("name", Array.CASEINSENSITIVE);
		}
		
		private function pageVOIndex(pagesVO : Array, pageID : String) : Number
		{
			var i : uint = 0;
			for each (var pageVO : PageVO in pagesVO)
			{
				if (pageVO.id == pageID)
					return i;
				
				i++;
			}
			
			return -1;
		}
		
		private function createStructure( sourceStructure : XMLList ) : Array
		{
			if ( sourceStructure.length() == 0 )
				return null;
			
			var resultStructure : Array = [];
			var structureObjectVO : StructureObjectVO;
			
			for each ( var structureObjectXML : XML in sourceStructure )
			{
				structureObjectVO = new StructureObjectVO( structureObjectXML.@ID )
				structureObjectVO.setDescription( structureObjectXML );
				
				resultStructure.push( structureObjectVO );
			}
			
			return resultStructure;
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
		
		private function generateApplicationEvents( applicationEventsXML : XML, pageVO : PageVO ) : ApplicationEventsVO
		{
			/*TODO: Писец! Дла того чтобы пролучить EventVO надо грузить все дерево объектов страницы!!! Т.к. в структуре action-event
			мля нет полного описания события. Ну и нахрена такая структура?*/
			
			var applicationEvents : ApplicationEventsVO = new ApplicationEventsVO( pageVO );
			
			var clientActions : Object = {};
			var serverActions : Object = {};
			
			var eventsXMLList : XMLList = applicationEventsXML.Events.Event;
			var clientActionsXMLList : XMLList = applicationEventsXML.ClientActions.Action;
			var serverActionsXMLList : XMLList = applicationEventsXML.ServerActions..Action;
			
			//			if ( serverActionsXMLList.length() > 0 )
			//				serverActionsXMLList = serverActionsXMLList.( @ID == pageVO.id ).Action;
			
			var clientActionVO : ClientActionVO;
			var serverActionVO : ServerActionVO;
			
			var objectXML : XML;
			var actionXML : XML;
			
			var objectID : String;
			
			for each ( actionXML in clientActionsXMLList )
			{
				clientActionVO = new ClientActionVO();
				clientActionVO.setProperties( actionXML );
				
				if ( clientActionVO.id )
				{
					if ( clientActionVO.objectID == pageVO.id )
					{
						clientActionVO.setObjectName( pageVO.name );
					}
					//					else
					//					{
					//						objectXML = pageStructureXML.descendants( "object" ).( @id == clientActionVO.objectID )[ 0 ];
					//
					//						if ( objectXML )
					//							clientActionVO.setObjectName( ""/*objectXML.@name*/ );
					//					}
					
					clientActions[ clientActionVO.id ] = clientActionVO;
					applicationEvents.clientActions.push( clientActionVO );
				}
			}
			
			for each ( actionXML in serverActionsXMLList )
			{
				serverActionVO = new ServerActionVO();
				serverActionVO.setProperties( actionXML );
				serverActionVO.setObjectName( pageVO.name );
				
				if ( serverActionVO.id )
				{
					serverActions[ serverActionVO.id ] = serverActionVO;
					applicationEvents.serverActions.push( serverActionVO );
				}
			}
			
			var eventXML : XML;
			var eventObject : Object;
			
			var eventName : String;
			var eventVO : EventVO;
			
			var typeID : String;
			var typeVO : TypeVO;
			
			var actionID : String;
			var objectName : String;
			
			for each ( eventXML in eventsXMLList )
			{
				objectID = eventXML.@ObjSrcID[ 0 ];
				objectName = "";
				if (eventXML.@ObjSrcName[ 0 ] != null)
					objectName = eventXML.@ObjSrcName[ 0 ];
				eventName = eventXML.@Name[ 0 ];
				
				
				if ( pageVO.id == objectID )
				{
					typeVO = pageVO.typeVO
					//objectName = pageVO.name;
				}
				else
				{
					//					objectXML = pageStructureXML.descendants( "object" ).( @id == objectID )[ 0 ];
					typeID = eventXML.@TypeID[ 0 ];
					typeVO = typesProxy.getType( typeID );
					//objectName = "" /*objectXML.@name*/;
				}
				
				if ( !typeVO )
					continue;
				
				eventVO = typeVO.getEventVOByName( eventName );
				
				if ( !eventVO )
					continue;
				
				eventVO = eventVO.copy();
				eventVO.setProperties( eventXML );
				eventVO.setObjectName( objectName );
				
				eventObject = { eventVO: eventVO, actions: [] };
				
				for each ( actionXML in eventXML.Action )
				{
					actionID = actionXML.@ID[ 0 ];
					
					if ( serverActions[ actionID ] )
					{
						eventObject.actions.push( serverActions[ actionID ] );
						continue;
					}
					else if ( clientActions[ actionID ] )
					{
						eventObject.actions.push( clientActions[ actionID ] );
						continue;
					}
				}
				
				applicationEvents.events.push( eventObject )
			}
			
			return applicationEvents;
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
		
		private function addHandlers() : void
		{
			soap.get_top_objects.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_top_objects.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.get_one_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.create_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.create_object.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			soap.delete_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.delete_object.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.get_application_structure.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_application_structure.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			soap.set_application_structure.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_application_structure.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.set_application_info.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_application_info.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.get_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_server_actions.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			soap.set_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_server_actions.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.set_library.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_library.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			soap.remove_library.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.remove_library.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.get_libraries.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_libraries.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.get_events_structure.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_events_structure.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			soap.set_events_structure.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_events_structure.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.remote_method_call.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.remote_method_call.addEventListener(  FaultEvent.FAULT, soap_faultHandler, false, 0, true );
			
			soap.copy_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true  );
			soap.copy_object.addEventListener( FaultEvent.FAULT, soap_faultHandler, false, 0, true  );
			
		}
		
		private function removeHandlers() : void
		{
			soap.get_top_objects.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_top_objects.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_one_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_one_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.delete_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.delete_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_application_structure.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_application_structure.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_application_structure.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_application_structure.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.set_application_info.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_application_info.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_server_actions.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.set_library.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_library.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.remove_library.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.remove_library.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_libraries.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_libraries.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_events_structure.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_events_structure.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			soap.set_events_structure.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_events_structure.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.remote_method_call.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.remote_method_call.removeEventListener(  FaultEvent.FAULT, soap_faultHandler );
			
			soap.copy_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.copy_object.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
		}
		
		private function soap_faultHandler( event : FaultEvent ) : void
		{
			
			var token : AsyncToken = event.token;
			
			if ( !token.hasOwnProperty( "recipientName" ) || token.recipientName != proxyName )
				return;
			
			var operation : Operation = event.target as Operation;
			
			if ( !operation )
				return;
			
			var operationName : String = operation.name;
			
			var fault : SOAPFault = event.fault as SOAPFault;
			
			switch ( operationName )
			{
				case "remote_method_call":
				{
					sendNotification( ApplicationFacade.APPLICATION_REMOTE_CALL_ERROR_GETTED, { applicationVO: applicationVO, error: fault.detail } );
					
					return;
				}
			}
			sendNotification( ApplicationFacade.WRITE_ERROR, event.fault.faultString );
			
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
			
			if ( result.hasOwnProperty( "Error" ) )
			{
				sendNotification( ApplicationFacade.WRITE_ERROR, result.Error.toString() );
				return;
			}
			
			var operationName : String = operation.name;
			
			var pageVO : PageVO;
			var pageID : String;
			
			var libraryVO : LibraryVO;
			var libraryXML : XML;
			
			var typeVO : TypeVO;
			
			
			
			switch ( operationName )
			{
				//				case "get_child_objects_tree":
				//					{
				//						if ( token.requestFunctionName == GET_EVENTS )
				//						{
				//							pageVO = token.pageVO;
				//
				//							token = soap.get_application_events( applicationVO.id, pageVO.id );
				//
				//							token.recipientName = proxyName;
				//							token.requestFunctionName = GET_EVENTS;
				//							token.pageVO = pageVO;
				//							token.pageStructure = generatePageStructure( result.Object[ 0 ] );
				//						}
				//
				//						break;
				//					}
				
				case "set_application_info":
				{
					var information : XML = result.Information[ 0 ];
					applicationVO.setInformation( information )
					sendNotification( ApplicationFacade.APPLICATION_INFORMATION_UPDATED, applicationVO );
					
					break;
				}
				case "get_top_objects":
				{
					createPagesList( result.Objects[ 0 ] );
					
					sendNotification( ApplicationFacade.APPLICATION_PAGES_GETTED, { applicationVO: applicationVO, pages: _pages.slice() } );
					
					sendNotification( ApplicationFacade.PAGE_CHECK_SELECTED, { pagesVO: _pages.slice() } );
					sendNotification( ApplicationFacade.PAGE_CHECK_INDEX, { pagesVO: _pages.slice() } );
					break;
				}
					
				case "get_application_structure":
				{
					var structure : Array = createStructure( result.Structure[ 0 ].* );
					
					sendNotification( ApplicationFacade.APPLICATION_STRUCTURE_GETTED, { applicationVO: applicationVO, structure: structure } );
					
					break;
				}
					
				case "set_application_structure":
				{
					sendNotification( ApplicationFacade.APPLICATION_STRUCTURE_SETTED, { applicationVO: applicationVO } );
					
					break;
				}
					
				case "get_server_actions":
				{
					
					/*var groupActionsName : String = result.ServerActions.Container;
					
					var serverActionVO : ServerActionVO;
					var serverActionXML : XML;
					
					for each ( serverActionXML in serverActionsXML )
					{
					serverActionVO = new ServerActionVO();
					
					serverActionVO.setID( serverActionXML.@ID[ 0 ] );
					
					serverActionVO.script = serverActionXML[ 0 ];
					
					serverActions.push( serverActionVO );
					}
					*/
					sendNotification( ApplicationFacade.APPLICATION_SERVER_ACTIONS_LIST_GETTED,
						{ applicationVO: applicationVO, serverActionsXML: result } );
					
					break;
				}
					
				case "get_one_object":
				{
					if ( token.requestFunctionName == GET_PAGE )
					{
						var objectXML : XML = result.Objects.Object[ 0 ];
						
						typeVO = typesProxy.getType( objectXML.@Type );
						
						pageVO = new PageVO( applicationVO, typeVO );
						pageVO.setID( objectXML.@ID );
						
						pageVO.setXMLDescription( objectXML );
						
						var notification : ProxyNotification;
						notification = new ProxyNotification( ApplicationFacade.APPLICATION_PAGE_GETTED, pageVO );
						notification.token = token;
						
						facade.notifyObservers( notification );
					}
					
					break;
				}
					
				case "set_server_actions":
				{
					//					if ( token.requestFunctionName == SET_EVENTS )
					//					{
					//						var applicationEventsVO : ApplicationEventsVO = token.applicationEventsVO;
					//
					//						var e2vdom : XML = <E2vdom />;
					//
					//						var eventsXML : XML = applicationEventsVO.getEventsXML();
					//						var clientActionsXML : XML = applicationEventsVO.getClientActionsXML();
					//
					//						e2vdom.appendChild( eventsXML );
					//						e2vdom.appendChild( clientActionsXML );
					//
					//						token = soap.set_application_events( applicationVO.id, applicationEventsVO.pageVO.id, e2vdom );
					//
					//						token.recipientName = proxyName;
					//						token.requestFunctionName = SET_EVENTS;
					//						token.applicationEventsVO = applicationEventsVO;
					//					}
					
					break;
				}
					
				case "set_library":
				{
					libraryXML = result.Library[ 0 ];
					
					libraryVO = new LibraryVO( libraryXML.@Name, applicationVO );
					libraryVO.script = libraryXML[ 0 ];
					
					if ( token.requestFunctionName == CREATE_LIBRARY )
						sendNotification( ApplicationFacade.APPLICATION_LIBRARY_CREATED, { applicationVO: applicationVO, libraryVO: libraryVO } );
					else if ( token.requestFunctionName == UPDATE_LIBRARY )
						sendNotification( ApplicationFacade.APPLICATION_LIBRARY_UPDATED, { applicationVO: applicationVO, libraryVO: libraryVO } );
					
					
					break;
				}
					
				case "remove_library":
				{
					libraryXML = result.Library[ 0 ];
					
					libraryVO = new LibraryVO( libraryXML.@Name, applicationVO );
					libraryVO.script = libraryXML[ 0 ];
					
					sendNotification( ApplicationFacade.APPLICATION_LIBRARY_DELETED, { applicationVO: applicationVO, libraryVO: libraryVO } );
					
					break;
				}
					
				case "get_libraries":
				{
					var libraries : Array = [];
					
					for each ( libraryXML in result.Libraries.Library )
					{
						libraryVO = new LibraryVO( libraryXML.@Name, applicationVO );
						libraryVO.script = libraryXML[ 0 ];
						
						libraries.push( libraryVO );
					}
					
					sendNotification( ApplicationFacade.APPLICATION_LIBRARIES_GETTED, { applicationVO: applicationVO, libraries: libraries } );
					
					break;
				}
					
					//				case "get_application_events":
					//					{
					//						var applicationEvents : Object = generateApplicationEvents( result.E2vdom[ 0 ], token.pageVO, token.pageStructure );
					//
					//						sendNotification( ApplicationFacade.APPLICATION_EVENTS_GETTED,
					//							{ applicationVO: applicationVO, applicationEvents: applicationEvents } );
					//						break;
					//					}
					
					//				case "set_application_events":
					//					{
					//						sendNotification( ApplicationFacade.APPLICATION_EVENTS_SETTED, { applicationVO: applicationVO } );
					//
					//						break;
					//					}
					
				case "create_object":
				{
					if (!_pages)
						_pages = [];
					
					var pageXML : XML = result.Object[ 0 ];
					
					pageID = pageXML.@ID[ 0 ];
					
					var typeID : String = pageXML.@Type[ 0 ];
					
					if ( !pageID || !typeID )
						return;
					
					typeVO = typesProxy.getType( typeID );
					
					pageVO = new PageVO( applicationVO, typeVO );
					pageVO.setID( pageID );
					
					pageVO.setXMLDescription( pageXML );
					
					_pages.push( pageVO );
					
					sendNotification( ApplicationFacade.APPLICATION_PAGE_CREATED, { applicationVO: applicationVO, pageVO: pageVO, pagesVO: _pages.slice() } );
					
					break;
				}
					
				case "delete_object":
				{
					pageID = result.Result[ 0 ].toString();
					
					var deletedPageVO : PageVO;
					var i : int;
					
					for ( i = 0; i < _pages.length; i++ )
					{
						if ( _pages[ i ].id == pageID )
						{
							deletedPageVO = _pages[ i ];
							_pages.splice( i, 1 );
							break;
						}
					}
					
					if ( deletedPageVO )
					{
						sendNotification( ApplicationFacade.APPLICATION_PAGE_DELETED, { applicationVO: applicationVO, pageVO: deletedPageVO, pagesVO: _pages.slice() } );
					}
					
					break;
				}
					
				case "remote_method_call":
				{
					sendNotification( ApplicationFacade.APPLICATION_REMOTE_CALL_GETTED, { applicationVO: applicationVO, result: result } );
					
					break;
				}
					
				case "get_events_structure":
				{
					var applicationEvents : ApplicationEventsVO = generateApplicationEvents( result.E2vdom[ 0 ], token.pageVO );
					
					sendNotification( ApplicationFacade.APPLICATION_EVENTS_GETTED,
						{ applicationVO: applicationVO, applicationEvents: applicationEvents } );
					
					break;
				}
					
				case "set_events_structure":
				{
					sendNotification( ApplicationFacade.APPLICATION_EVENTS_SETTED, { applicationVO: applicationVO } )
					
					break;
				}
					
				case "copy_object":
				{
					notification = new ProxyNotification( ApplicationFacade.APPLICATION_COPY_CREATED, applicationVO );
					notification.token = token;
					
					facade.notifyObservers( notification );
					
					break;
				}
			}
		}
	}
}