package net.vdombox.ide.modules.events.model
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.PageVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class MessageProxy extends Proxy implements IProxy
	{
		
		public static const NAME : String = "EventsMessageProxy";
		private var messageStackProxy : MessageStackProxy;
		
		public function MessageProxy()
		{
			super( NAME );
		}
		
		public function push( pageVO : PageVO, message : ProxyMessage ) : void
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				facade.registerProxy( new MessageStackProxy( pageVO ) );
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			messageStackProxy.push( message );
		}
		
		public function checkPush( pageVO : PageVO, message : ProxyMessage ) : void
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				facade.registerProxy( new MessageStackProxy( pageVO ) );
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			messageStackProxy.push( message );
		}
		
		private var renderers : Array;
		
		public function getUndo( pageVO : PageVO ) : ProxyMessage
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return null;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			return messageStackProxy.undo();
		}
		
		public function getRedo( pageVO : PageVO ) : ProxyMessage
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return null;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			return messageStackProxy.redo();
		}
		
		public function removeAll( pages : Object ) : void
		{
			for each( var pageVO : PageVO in pages )
			{
				if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
					continue;
			
				messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
				messageStackProxy.removeAll();
			}
		}
		
		
	}
}