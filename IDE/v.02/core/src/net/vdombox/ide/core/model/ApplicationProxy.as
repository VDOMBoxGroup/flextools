package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.soap.Operation;

	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.interfaces.IPageProxy;
	import net.vdombox.ide.core.model.business.SOAP;

	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ApplicationProxy extends Proxy
	{
		public static const NAME : String = "ApplicationProxy";

		public function ApplicationProxy( applicationVO : ApplicationVO )
		{
			super( NAME + "/" + applicationVO.id, applicationVO );
		}

		private var _selectedPage : PageVO;

		private var _pages : Array;

		private var soap : SOAP = SOAP.getInstance();

		private var typesProxy : TypesProxy;

		private var serverProxy : ServerProxy;

		public function get id() : String
		{
			return applicationVO.id;
		}

		public function get applicationVO() : ApplicationVO
		{
			return data as ApplicationVO;
		}

		public function get selectedPage() : PageVO
		{
			return _selectedPage;
		}

		public function get selectedPageID() : String
		{
			if ( _selectedPage )
				return _selectedPage.id;
			else
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
		}

		public function changeApplicationInformation( applicationInformationVO : ApplicationInformationVO ) : AsyncToken
		{
			var applicationInformationXML : XML = applicationInformationVO.toXML();
			var token : AsyncToken;

			token = soap.set_application_info( applicationVO.id, applicationInformationXML );

			token.recipientName = proxyName;

			return token;
		}

		public function getPages() : AsyncToken
		{
			var token : AsyncToken;

			token = soap.get_top_objects( applicationVO.id );

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

		public function getServerActions() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_server_actions( applicationVO.id, applicationVO.id );

			token.recipientName = proxyName;

			return token;
		}

		public function setLibrary( name : String, script : String ) : AsyncToken
		{
			var token : AsyncToken;
			token = soap.set_library( applicationVO.id, name, script );

			token.recipientName = proxyName;

			return token;
		}

		public function getLibraries() : AsyncToken
		{
			var token : AsyncToken;
			token = soap.get_libraries( applicationVO.id );

			token.recipientName = proxyName;

			return token;
		}

		public function createPage( typeVO : TypeVO ) : AsyncToken
		{
			var token : AsyncToken;

			token = soap.create_object( applicationVO.id, "", typeVO.id, "", "" );

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

		public function getPageAt( pageID : String ) : PageVO
		{
			return null;
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

		private function addHandlers() : void
		{
			soap.get_top_objects.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.create_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.delete_object.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_application_structure.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_application_info.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_server_actions.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.set_library.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
			soap.get_libraries.addEventListener( SOAPEvent.RESULT, soap_resultHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			soap.get_top_objects.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_application_structure.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_application_info.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_server_actions.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_library.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_libraries.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
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

		private function createPagesList( pages : XML ) : void
		{
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

				var pageVO : PageVO = new PageVO( pageID, applicationVO, typeVO );

				pageVO.setXMLDescription( page );

				_pages.push( pageVO );
			}
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

			var pageID : String;

			var libraryVO : LibraryVO;
			var libraryXML : XML;

			switch ( operationName )
			{
				case "set_application_info":
				{
					var information : XML = result.Information[ 0 ];
					applicationVO.setInformation( information )
					sendNotification( ApplicationFacade.APPLICATION_CHANGED, applicationVO );

					break;
				}
				case "get_top_objects":
				{
					createPagesList( result.Objects[ 0 ] );

					sendNotification( ApplicationFacade.APPLICATION_PAGES_GETTED, { applicationVO: applicationVO, pages: _pages.slice() } );

					break;
				}

				case "get_application_structure":
				{
					var structure : Array = createStructure( result.Structure[ 0 ].* );

					sendNotification( ApplicationFacade.APPLICATION_STRUCTURE_GETTED, { applicationVO: applicationVO, structure: structure } );

					break;
				}

				case "get_server_actions":
				{
					var serverActions : Array = [];

					var serverActionsXML : XMLList = result.ServerActions.Container.( @ID == applicationVO.id ).Action;

					var serverActionVO : ServerActionVO;
					var serverActionXML : XML;

					for each ( serverActionXML in serverActionsXML )
					{
						serverActionVO = new ServerActionVO( serverActionXML.@ID, applicationVO );
						serverActionVO.name = serverActionXML.@Name;
						serverActionVO.script = serverActionXML[ 0 ];

						serverActions.push( serverActionVO );
					}

					sendNotification( ApplicationFacade.APPLICATION_SERVER_ACTIONS_GETTED,
									  { applicationVO: applicationVO, serverActions: serverActions } );

					break;
				}

				case "set_library":
				{
					libraryXML = result.Library[ 0 ];

					libraryVO = new LibraryVO( libraryXML.@Name, applicationVO );
					libraryVO.script = libraryXML[ 0 ];

					sendNotification( ApplicationFacade.APPLICATION_LIBRARY_CREATED, { applicationVO: applicationVO, libraryVO: libraryVO } );

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

				case "create_object":
				{
					var pageXML : XML = result.Object[ 0 ];

					pageID = pageXML.@ID[ 0 ];

					var typeID : String = pageXML.@Type[ 0 ];

					if ( !pageID || !typeID )
						return;

					var typeVO : TypeVO = typesProxy.getType( typeID );

					var pageVO : PageVO = new PageVO( pageID, applicationVO, typeVO );

					pageVO.setXMLDescription( pageXML );

					_pages.push( pageVO );

					sendNotification( ApplicationFacade.APPLICATION_PAGE_CREATED, { applicationVO: applicationVO, pageVO: pageVO } );

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
						sendNotification( ApplicationFacade.APPLICATION_PAGE_DELETED, { applicationVO: applicationVO, pageVO: deletedPageVO } );
					}

					break;
				}
			}
		}
	}
}