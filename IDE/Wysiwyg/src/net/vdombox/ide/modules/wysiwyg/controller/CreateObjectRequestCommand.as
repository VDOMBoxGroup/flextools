package net.vdombox.ide.modules.wysiwyg.controller
{
	import flash.geom.Point;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var vdomObjectVO : IVDOMObjectVO = body.vdomObjectVO as IVDOMObjectVO;
			var typeVO : TypeVO = body.typeVO as TypeVO;
			var point : Point = body.point as Point;

			var attributes : Array;

			if ( !vdomObjectVO || !typeVO )
				return;

			if ( point )
			{
				attributes = [];

				attributes.push( new AttributeVO( "left", point.x.toString() ) );
				attributes.push( new AttributeVO( "top", point.y.toString() ) );
			}

			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			var rendererBase : RendererBase = renderProxy.getRendererByVO( vdomObjectVO );

			var objectName : String = "";

			if ( rendererBase )
			{
				var typeName : String = typeVO.name;
				var children : Array = rendererBase.renderVO.children;
				var leng : int = children ? children.length : 0;
				var findName : Boolean = false;
				var i : int;

				for ( i = 1; i <= leng; i++ )
				{
					findName = false;
					objectName = typeName + i.toString();

					for each ( var renderVO : RenderVO in children )
					{
						if ( renderVO.vdomObjectVO.name == objectName )
						{
							findName = true;
							break;
						}
					}

					if ( !findName )
						break;
				}

				objectName = typeName + i.toString();
			}

			if ( vdomObjectVO is PageVO )
				sendNotification( Notifications.CREATE_OBJECT, { pageVO: vdomObjectVO, attributes: attributes, typeVO: typeVO, name: objectName } );
			else
				sendNotification( Notifications.CREATE_OBJECT, { objectVO: vdomObjectVO, attributes: attributes, typeVO: typeVO, name: objectName } );
		}
	}
}
