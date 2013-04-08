package net.vdombox.ide.modules.wysiwyg.model
{
	import mx.core.UIComponent;

	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class MessageProxy extends Proxy implements IProxy
	{

		public static const NAME : String = "MessageProxy";

		private var messageStackProxy : MessageStackProxy;

		private var message : ProxyMessage;

		private var renderProxy : RenderProxy;

		private var statesProxy : StatesProxy;

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

		private var rendererBase : RendererBase;

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
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var needForUpdateObject : Object = statesProxy.needForUpdate;

			var vdomObjectAttributesVO : VdomObjectAttributesVO = message.getBody() as VdomObjectAttributesVO;
			rendererBase = renderProxy.getRendererByVO( vdomObjectAttributesVO.vdomObjectVO );
			if ( !rendererBase )
				return;

			var hasAnotherAttributes : Boolean = false;
			var attributeVO : AttributeVO;

			for each ( attributeVO in vdomObjectAttributesVO.attributes )
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

			if ( hasAnotherAttributes )
			{
				rendererBase.lock( true );
				needForUpdateObject[ rendererBase ] = true;
			}
		}

		private function applyAttribute( attributeVO : AttributeVO ) : void
		{
			if ( attributeVO.name == "left" )
				rendererBase.x = int( attributeVO.value );
			else if ( attributeVO.name == "top" )
				rendererBase.y = int( attributeVO.value );
			else
				rendererBase[ attributeVO.name ] = int( attributeVO.value );
		}


	}
}
