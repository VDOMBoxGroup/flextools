package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ObjectSelectedRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var objectVO : ObjectVO = notification.getBody() as ObjectVO;
			
			sendNotification( ApplicationFacade.SELECT_OBJECT, objectVO );
		}
	}
}