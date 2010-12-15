package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import mx.events.FlexEvent;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Attributes;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	import spark.events.IndexChangeEvent;

	public class AttributeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "AttributeMediator";
		private var objectTypeVO:ObjectTypeVO;

		public function AttributeMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showAttributes );
//			attributes.addEventListener( FlexEvent.HIDE, hideAttributes );
//			change="{changeLibrary(event)}"
		}

		private function changeAtribute(event:Event):void
		{ 
			var attributeVO:AttributeVO = view.attributesList.selectedItem.data as AttributeVO;
			view.fname.text 			= attributeVO.name;			

			view.defaultValue.text		= attributeVO.defaultValue;		
			view.visibleAtr.selected	= attributeVO.visible;	
/*			view.fDisplayName.text		= attributeVO.displayName;
			view.helpAtr.text 			= attributeVO.help;
			view.interfaceType.text 	= attributeVO.interfaceType;
			view.codeInterface.text 	= attributeVO.codeInterface;		
			view.colorgroup.text 		= attributeVO.colorgroup;		
			view.fErrMessage.text 		= attributeVO.errorValidationMessage;
			view.regExp.text 			= attributeVO.regularExpressionValidation;
			*/
		}

		private function showAttributes(event: FlexEvent): void
		{			
			view.attributesList.addEventListener(Event.CHANGE, changeAtribute);

			compliteAtributes();
			view.validateNow();
		}

		private  function hideAttributes(event: FlexEvent):void
		{
			view.attributesList.removeEventListener(Event.CHANGE, changeAtribute);
		}

		protected function compliteAtributes( ):void
		{			
			view.attributesList.dataProvider = objectTypeVO.attributes;
		}		

		protected function get view():Attributes
		{
			return viewComponent as Attributes;
		}
	}
}

