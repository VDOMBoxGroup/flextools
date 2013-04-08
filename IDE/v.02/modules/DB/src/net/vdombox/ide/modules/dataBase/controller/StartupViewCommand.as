package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.DataBase;
	import net.vdombox.ide.modules.dataBase.view.DataBaseJunctionMediator;
	import net.vdombox.ide.modules.dataBase.view.DataBaseMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupViewCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : DataBase = note.getBody() as DataBase;

			facade.registerMediator( new DataBaseJunctionMediator() );
			facade.registerMediator( new DataBaseMediator( application ) )
		}
	}
}
