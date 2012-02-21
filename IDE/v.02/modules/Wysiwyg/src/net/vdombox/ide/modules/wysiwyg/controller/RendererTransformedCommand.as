package net.vdombox.ide.modules.wysiwyg.controller
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererTransformedCommand extends SimpleCommand
	{
		private var renderers : Array;
		
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
		
			var attributes : Array = vdomObjectAttributesVO.attributes;

			renderers = renderProxy.getRenderersByVO( vdomObjectAttributesVO.vdomObjectVO );
			
			if( !renderers || renderers.length == 0 )
				return;
			
			var hasAnotherAttributes : Boolean = false;
			var attributeVO : AttributeVO;

			for each( attributeVO in attributes )
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
			
			sendNotification( Notifications.UPDATE_ATTRIBUTES, vdomObjectAttributesVO );
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
		
		private function getChangedAttributes( vdomObjectAttributesVO : VdomObjectAttributesVO ) : uint
		{
			var result : Array = [];
			
			var attributeVO : AttributeVO;
			for each ( attributeVO in vdomObjectAttributesVO.attributes )
			{
				if( attributeVO.defaultValue !== attributeVO.value )
				{
					result.push( attributeVO );
				}
			}
			return result.length;
		}
	}
}