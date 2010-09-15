package net.vdombox.ide.modules.wysiwyg.controller
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererTransformedCommand extends SimpleCommand
	{
		private var renderers : Array;
		
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			var needForUpdateObject : Object = sessionProxy.needForUpdate;

			var vdomObjectAttributesVO : VdomObjectAttributesVO = notification.getBody() as VdomObjectAttributesVO;
			
			if ( !vdomObjectAttributesVO )
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
					renderer.lock( true );
					needForUpdateObject[ renderer ] = true;
				}
			}

			sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, vdomObjectAttributesVO );
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