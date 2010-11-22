package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.Sample;
	import net.vdombox.ide.modules.sample.view.SampleJunctionMediator;
	import net.vdombox.ide.modules.sample.view.SampleMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupViewCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Sample = note.getBody() as Sample;

//			регистраия посредника для механизма pipes
			facade.registerMediator( new SampleJunctionMediator() );
//			регистрация посредника для файла модуля Sample
			facade.registerMediator( new SampleMediator( application ) );
		}
	}
}