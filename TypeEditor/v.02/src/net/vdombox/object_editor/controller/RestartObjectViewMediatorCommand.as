package net.vdombox.object_editor.controller
{
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;


	public class RestartObjectViewMediatorCommand extends SimpleCommand 
	{
		override public function execute( note:INotification ) :void
		{
			var objTypeVO:ObjectTypeVO = note.getBody()["ObjTypeVO"];
			var objID:String = objTypeVO.id;
			objTypeVO = null;
			facade.removeMediator(note.getBody()["MediatorName"]);
			
			facade.sendNotification( ApplicationFacade.OPEN_OBJECT, note.getBody()["Item"] );					
		}
	}
}