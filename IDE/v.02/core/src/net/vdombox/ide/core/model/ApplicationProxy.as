package net.vdombox.ide.core.model
{
	import mx.rpc.AsyncToken;
	import mx.rpc.soap.Operation;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
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
			addHandlers();
		}

		override public function onRemove() : void
		{
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
			var pageProxy : PageProxy = facade.retrieveProxy( PageProxy.NAME + "/" + pageVO.applicationID + "/" + pageVO.id ) as PageProxy;

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
		}

		private function removeHandlers() : void
		{
			soap.get_top_objects.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.create_object.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.get_application_structure.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
			soap.set_application_info.removeEventListener( SOAPEvent.RESULT, soap_resultHandler );
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

				var pageVO : PageVO = new PageVO( pageID, applicationVO.id, typeID );

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

					sendNotification( ApplicationFacade.PAGES_GETTED, { applicationVO: applicationVO, pages: _pages } );

					break;
				}

				case "get_application_structure":
				{
					var structure : Array = createStructure( result.Structure[ 0 ].* );

					sendNotification( ApplicationFacade.APPLICATION_STRUCTURE_GETTED, { applicationVO: applicationVO, structure: structure } );
					break;
				}

				case "create_object":
				{
					var pageXML : XML = result.Object[ 0 ];
					
					var pageID : String = pageXML.@ID[ 0 ];

					var typeID : String = pageXML.@Type[ 0 ];

					if ( !pageID || !typeID )
						return;

					var pageVO : PageVO = new PageVO( pageID, applicationVO.id, typeID );

					pageVO.setXMLDescription( pageXML );

					_pages.push( pageVO );

					sendNotification( ApplicationFacade.PAGE_CREATED, { applicationVO: applicationVO, pageVO: pageVO } );
					break;
				}
					
				case "delete_object":
				{
					
				}
			}
		}
	}
}