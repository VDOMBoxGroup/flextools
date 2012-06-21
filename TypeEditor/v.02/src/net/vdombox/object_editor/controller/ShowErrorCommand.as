package net.vdombox.object_editor.controller
{
	import mx.controls.Alert;
	
	import net.vdombox.object_editor.model.vo.ErrorVO;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class ShowErrorCommand extends SimpleCommand
	{
		override public function execute( note:INotification  ) :void
		{
			var errorVO:ErrorVO = note.getBody() as ErrorVO;
			
			Alert.show(errorVO.detail, errorVO.string );
		}
	}
}