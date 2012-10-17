package net.vdombox.ide.core.model
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.controller.requests.StatesProxyRequestCommand;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 * @flowerModelElementId _DExiIEomEeC-JfVEe_-0Aw
	 */
	public class StatesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "StatesProxy";

		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE		 : String = "selectedPage";
		public static const SELECTED_OBJECT		 : String = "selectedObject";
		
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanget";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanget";
		
		public static const ERROR : String = "error";
		public var attribute1:StatesProxyRequestCommand; //not used
		public var attribute2:StatesProxy;
		public var attribute3:StatesProxy;
		
		public function StatesProxy()
		{
			super( NAME, {} );
		}

		override public function onRemove() : void
		{
			cleanup();
		}
		
		public function get selectedApplication() : ApplicationVO
		{
			return data[ SELECTED_APPLICATION ];
		}

		public function set selectedApplication( value : ApplicationVO ) : void
		{
			data[ SELECTED_APPLICATION ] = value;
			data[ SELECTED_PAGE ] 		 = null;
			data[ SELECTED_OBJECT ]		 = null;
			
			var ppMessage : ProxyMessage = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.SELECTED_APPLICATION, value );
			
			facade.sendNotification(ApplicationFacade.STATES_PROXY_REQUEST, ppMessage);
		}

		public function get selectedPage() : PageVO
		{			
			return data[ SELECTED_PAGE ];
		}

		public function set selectedPage( value : PageVO ) : void
		{
			data[ SELECTED_PAGE ]   = value;
			data[ SELECTED_OBJECT ] = null;
			
			var ppMessage : ProxyMessage = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.SELECTED_PAGE, null );
			
			facade.sendNotification(ApplicationFacade.STATES_PROXY_REQUEST, ppMessage );
			//
		}

		public function get selectedObject() : ObjectVO
		{
			return data[ SELECTED_OBJECT ];
		}

		public function set selectedObject( value : ObjectVO ) : void
		{
			data[ SELECTED_OBJECT ] = value;
		}

		public function get error() : Object
		{
			return data[ ERROR ];
		}
		
		public function set error( value : Object ) : void
		{
			data[ ERROR ] = value;
		}
		
		public function cleanup() : void
		{
			data = {};
		}
	}
}