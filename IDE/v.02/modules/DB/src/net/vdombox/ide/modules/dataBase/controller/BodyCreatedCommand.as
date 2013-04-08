package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.dataBase.view.DataTablesTreeMediator;
	import net.vdombox.ide.modules.dataBase.view.ExternalManagerMediator;
	import net.vdombox.ide.modules.dataBase.view.WorkAreaMediator;
	import net.vdombox.ide.modules.dataBase.view.components.Body;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

			facade.registerMediator( new DataTablesTreeMediator( body.dataTablesTree ) );
			facade.registerMediator( new WorkAreaMediator( body.workArea ) );
			facade.registerMediator( new ExternalManagerMediator() );
		}
	}
}
