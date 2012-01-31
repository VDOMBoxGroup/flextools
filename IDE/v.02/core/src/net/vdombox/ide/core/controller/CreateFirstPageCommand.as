package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateFirstPageCommand extends SimpleCommand
	{ 
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy =  facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			var typeVO : TypeVO = typesProxy.getTypeVObyID("2330fe83-8cd6-4ed5-907d-11874e7ebcf4");
			var applicationVO : ApplicationVO = notification.getBody() as ApplicationVO;
			
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			var applicationProxy : ApplicationProxy;
			applicationProxy = serverProxy.getApplicationProxy( applicationVO );
			applicationProxy.createPage( typeVO );
		}
	}
}