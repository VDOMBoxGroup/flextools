package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.LogProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class DeleteObjectCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var pageVO : PageVO = body.pageVO as PageVO;

			var objectVO : ObjectVO;
			if ( body.hasOwnProperty( "objectVO" ) )
				objectVO = body.objectVO as ObjectVO;
			else if ( body.hasOwnProperty( "objectID" ) )
			{
				var objectID : String = body.objectID as String;
				objectVO = new ObjectVO( pageVO, null );
				objectVO.setID( objectID );
			}
			
			LogProxy.addLog( "DeleteObjectCommand" );

			sendNotification( Notifications.DELETE_OBJECT, { pageVO: pageVO, objectVO: objectVO } );
		}
	}
}
