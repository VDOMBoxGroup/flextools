/*
   Class SelectFormItemMediator wrapper from SelectFormItemMediator
 */
package net.vdombox.object_editor.view.mediators
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.SelectFormItem;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class SelectFormItemMediator extends Mediator implements IMediator
	{
		public static const NAME			:String = "SelectFormItemMediator";				
		public static const CHOSE_WORD		:String = "choseWord";
		private var objectTypeVO:ObjectTypeVO;
		private var fildVO:String;
		
		public function SelectFormItemMediator( viewComponent:Object, objTypeVO:ObjectTypeVO, fVO:String ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;
			fildVO = fVO;
			view.fselectComboBox.addEventListener( Event.CHANGE, openListWords);
			var langsProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
			var arrCol:ArrayCollection = langsProxy.getWordsOnCarentLocal(objectTypeVO.languages);
			view.fselectComboBox.dataProvider = arrCol;
		}		
		
		public function openListWords( event:Event ) : void
		{		
			var selectData:String = getString( view.fselectComboBox.selectedItem.data );
			var word:Object = {};
			word["data"]   = selectData;
			word["fildVO"] = fildVO;
			
			//никто не перехватывает это сообщение!!!
//			facade.sendNotification( ApplicationFacade.CHANGE_SELECT_FORM_ITEM, word );
			//fildVO = getString( view.fselectComboBox.selectedItem.data );
			/*
			var functionName:String = "foo" + bar;
			if (this.hasOwnProperty(functionName))
				this[functionName]()*/
//			view.id;
			//[objectTypeVO.fildVO] = getString( view.fselectComboBox.selectedItem.data ); 
			//objectTypeVO.displayName = getString( view.fselectComboBox.selectedItem.data ); 
		}
		
		public function getString( id:String ) : String
		{
			return "#Lang("+id+")";
		}

		protected function get view():SelectFormItem
		{
			return viewComponent as SelectFormItem
		}
	}
}

