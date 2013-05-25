package net.vdombox.ide.modules.wysiwyg.controller
{
	import mx.core.UIComponent;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererTransformedCommand extends SimpleCommand
	{
		private var rendererBase : RendererBase;

		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			var needForUpdateObject : Object = statesProxy.needForUpdate;

			var vdomObjectAttributesVO : VdomObjectAttributesVO = notification.getBody() as VdomObjectAttributesVO;

			if ( !vdomObjectAttributesVO )
				return;

			if ( getChangedAttributes( vdomObjectAttributesVO ) == 0 )
				return;

			var attributes : Vector.<AttributeVO> = vdomObjectAttributesVO.attributes;

			rendererBase = renderProxy.getRendererByVO( vdomObjectAttributesVO.vdomObjectVO );

			if ( !rendererBase )
				return;

			var hasAnotherAttributes : Boolean = false;
			var attributeVO : AttributeVO;

			for each ( attributeVO in attributes )
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
				rendererBase.lock( true );
				needForUpdateObject[ rendererBase ] = true;
			}

			sendNotification( Notifications.UPDATE_ATTRIBUTES, vdomObjectAttributesVO );
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

		private function getChangedAttributes( vdomObjectAttributesVO : VdomObjectAttributesVO ) : uint
		{
			var result : Array = [];

			var attributeVO : AttributeVO;
			for each ( attributeVO in vdomObjectAttributesVO.attributes )
			{
				if ( attributeVO.defaultValue !== attributeVO.value )
				{
					result.push( attributeVO );
				}
			}
			return result.length;
		}
	}
}
