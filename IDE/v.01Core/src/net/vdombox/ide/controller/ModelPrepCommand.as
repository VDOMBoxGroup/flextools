package net.vdombox.ide.controller
{
	import net.vdombox.ide.model.ApplicationProxy;
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.ModulesProxy;
	import net.vdombox.ide.model.ServerProxy;
	import net.vdombox.ide.model.SharedObjectProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ModelPrepCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new ServerProxy() );
			facade.registerProxy( new SharedObjectProxy() );
			facade.registerProxy( new LocaleProxy() );
			facade.registerProxy( new ModulesProxy() );
		}
	}
}