package net.vdombox.ide.modules.wysiwyg.model
{
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class MessageProxy extends Proxy implements IProxy
	{
		
		public static const NAME : String = "MessageProxy";
		private var messageStackProxy : MessageStackProxy;
		private var message : ProxyMessage;
		private var renderProxy : RenderProxy;
		private var sessionProxy : SessionProxy;
		
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
		
		private var renderers : Array;
		
		public function getUndo( pageVO : PageVO ) : ProxyMessage
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return null;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			message = messageStackProxy.undo();
			
			if ( message && message.getBody() is VdomObjectAttributesVO )
			{
				setNeedForUpdate();
			}
			
			return message;
		}
		
		public function getRedo( pageVO : PageVO ) : ProxyMessage
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return null;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			message = messageStackProxy.redo();
			
			if ( message && message.getBody() is VdomObjectAttributesVO )
			{
				setNeedForUpdate();
			}
			
			return message;
		}
		
		public function removeAll( pageVO : PageVO ) : void
		{
			if ( !facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) )
				return;
			
			messageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + pageVO.id ) as MessageStackProxy;
			
			messageStackProxy.removeAll();
		}
		
		private function setNeedForUpdate() : void
		{
			renderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var needForUpdateObject : Object = sessionProxy.needForUpdate;
			
			var vdomObjectAttributesVO : VdomObjectAttributesVO = message.getBody() as VdomObjectAttributesVO;
			renderers = renderProxy.getRenderersByVO( vdomObjectAttributesVO.vdomObjectVO );
			if( !renderers || renderers.length == 0 )
				return;
			
			var hasAnotherAttributes : Boolean = false;
			var attributeVO : AttributeVO;
			
			for each( attributeVO in vdomObjectAttributesVO.attributes )
			{
				switch ( attributeVO.name )
				{
					case "width":
					{
						hasAnotherAttributes = true;
					}
						
					case "height":
					{
						hasAnotherAttributes = true;
					}
						
					case "top":
					{
					}
						
					case "left":
					{
						applyAttribute( attributeVO );
						
						break;
					}
						
					default:
					{
						hasAnotherAttributes = true;
					}
				}
			}
			
			var renderer : IRenderer;
			
			if ( hasAnotherAttributes )
			{
				for each( renderer in renderers )
				{
					if ( renderer )
					{
						renderer.lock( true );
						needForUpdateObject[ renderer ] = true;
					}
				}
			}
		}
		
		private function applyAttribute( attributeVO : AttributeVO ) : void
		{
			var renderer : UIComponent;
			
			for each ( renderer in renderers )
			{
				if( attributeVO.name == "left" )
					renderer.x = int( attributeVO.value );
				else if( attributeVO.name == "top" )
					renderer.y = int( attributeVO.value );
				else
					renderer[ attributeVO.name ] = int( attributeVO.value );
			}
		}
		
		
	}
}