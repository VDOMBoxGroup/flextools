package net.vdombox.ide.core.model
{
	
	import mx.rpc.soap.Operation;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.interfaces.IApplicationProxy;
	import net.vdombox.ide.core.interfaces.IPageProxy;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ApplicationProxy extends Proxy implements IApplicationProxy
	{
		public static const NAME : String = "ApplicationProxy";

		public function ApplicationProxy( applicationVO : ApplicationVO )
		{
			super( NAME + "/" + applicationVO.id, applicationVO );
		}

		private var _selectedPage : PageVO;

		private var soap : SOAP = SOAP.getInstance();

		private var serverProxy : ServerProxy;
		
		public function get id() : String
		{
			return applicationVO.id;
		}

		public function get application() : ApplicationVO
		{
			return applicationVO;
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
			addEventListeners();
		}
		
		public function load( applicationID : String ) : void
		{
			var dummy : * = ""; // FIXME remove dummy
		}
		
		public function changeApplicationInformation( applicationInformationVO : ApplicationInformationVO ) : void
		{
			var applicationInformationXML : XML = applicationInformationVO.toXML();
			
			soap.set_application_info( applicationVO.id, applicationInformationXML );
			soap.set_application_info.addEventListener( SOAPEvent.RESULT, soap_resultHandler );
		}
		
		public function createPage( pageID : String ) : PageVO
		{
			return null;
		}

		public function deletePage( pageVO : PageVO ) : void
		{
		}

		public function deletePageAt( pageID : String ) : void
		{
		}

		public function getPageAt( pageID : String ) : PageVO
		{
			return null;
		}

		public function getPageProxie( pageVO : PageVO ) : IPageProxy
		{
			return null;
		}

		public function getPageProxieAt( pageID : String ) : IPageProxy
		{
			return null;
		}
		
		private function get applicationVO() : ApplicationVO
		{
			return data as ApplicationVO;
		}
		
		private function addEventListeners() : void
		{

		}
		
		private function soap_resultHandler( event : SOAPEvent ) : void
		{
			var operation : Operation = event.currentTarget as Operation;
			var result : XML = event.result[ 0 ] as XML;
			
			if( !operation || !result )
				return;
			
			var operationName : String = operation.name;
			
			switch ( operationName )
			{
				case "set_application_info" :
				{
					var information : XML = result.Information[ 0 ];
					applicationVO.setInformation( information )
					sendNotification( ApplicationFacade.APPLICATION_CHANGED, applicationVO );
					
					break;
				}
			}
		}
	}
}