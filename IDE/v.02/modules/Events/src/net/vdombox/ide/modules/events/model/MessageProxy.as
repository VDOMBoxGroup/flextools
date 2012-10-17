package net.vdombox.ide.modules.events.model
{
	import net.vdombox.ide.common.model._vo.ApplicationEventsVO;
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
		
		public function push( pageVO : PageVO, message : ApplicationEventsVO ) : void
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				facade.registerProxy( new MessageStackProxy( pageVO ) );
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			messageStackProxy.push( message );
		}
		
		
		
		private var renderers : Array;
		
		public function getUndo( pageVO : PageVO ) : ApplicationEventsVO
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return null;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			return messageStackProxy.undo();
		}
		
		public function getRedo( pageVO : PageVO ) : ApplicationEventsVO
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return null;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			return messageStackProxy.redo();
		}
		
		public function hasUndo( pageVO : PageVO ) : Boolean
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return false;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			return messageStackProxy.hasUndo;
		}
		
		public function hasRedo( pageVO : PageVO ) : Boolean
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return false;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			return messageStackProxy.hasRedo;
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