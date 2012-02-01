package net.vdombox.ide.modules.wysiwyg.controller
{
	import flash.geom.Point;

	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;

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

			if ( vdomObjectVO is PageVO )
				sendNotification( ApplicationFacade.CREATE_OBJECT, { pageVO: vdomObjectVO, attributes: attributes, typeVO: typeVO } );
			else
				sendNotification( ApplicationFacade.CREATE_OBJECT, { objectVO: vdomObjectVO, attributes: attributes, typeVO: typeVO } );
		}
	}
}
