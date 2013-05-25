package net.vdombox.ide.modules.wysiwyg.model.business
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeDescriptionVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectListVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.AttributeItemVO;

	public class AttributeItemsManager
	{
		private var index : uint;
		private var attributeItems : Vector.<AttributeItemVO>;
		private static var instance : AttributeItemsManager;
		
		public function AttributeItemsManager()
		{
			if ( instance )
				throw new Error( "Singleton and can only be accessed through AttributeItemsManager.getInstance()" );
			
			index = 0;
			attributeItems = new Vector.<AttributeItemVO>();
		}
		
		public static function getInstance() : AttributeItemsManager
		{
			if ( !instance )
				instance = new AttributeItemsManager();
			
			return instance;
		}
		
		public function getAttributeItemVO(group : uint, name : String, displayName : String, objectVO : IVDOMObjectVO,
										   attributeVO : AttributeVO, attributeDescriptionVO : AttributeDescriptionVO, 
										   objectsList : Vector.<ObjectListVO>, pageLinks : Vector.<ObjectListVO>) : AttributeItemVO
		{
			var attributeItem : AttributeItemVO;
			
			if ( index >= attributeItems.length )
			{
				attributeItem = new AttributeItemVO(group, name, displayName, objectVO, attributeVO, attributeDescriptionVO, objectsList, pageLinks );
				attributeItems.push( attributeItem );
			}
			else
			{
				attributeItem = attributeItems[ index ];
				
				attributeItem.group = group;
				attributeItem.name = name;
				attributeItem.displayName = displayName;
				attributeItem.objectVO = objectVO;
				attributeItem.attributeVO = attributeVO;
				attributeItem.attributeDescriptionVO = attributeDescriptionVO;
				attributeItem.objectsList = objectsList;
				attributeItem.pageLinks = pageLinks;
			}
			
			index++;
			
			return attributeItem;
		}
		
		public function resetIndex() : void
		{
			index = 0;
		}
	}
}