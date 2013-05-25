package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeDescriptionVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectListVO;

	public class AttributeItemVO
	{
		private var _group : uint;
		private var _name : String;
		private var _displayName : String;
		private var _objectVO : IVDOMObjectVO;
		private var _attributeVO : AttributeVO;
		private var _attributeDescriptionVO : AttributeDescriptionVO;
		private var _objectsList : Vector.<ObjectListVO>;
		private var _pageLinks : Vector.<ObjectListVO>;
		
		public function AttributeItemVO( group : uint, name : String, displayName : String, objectVO : IVDOMObjectVO,
										 attributeVO : AttributeVO, attributeDescriptionVO : AttributeDescriptionVO, 
										 objectsList : Vector.<ObjectListVO>, pageLinks : Vector.<ObjectListVO>)
		{
			_group = group;
			_name = name;
			_displayName = displayName;
			_objectVO = objectVO;
			_attributeVO = attributeVO;
			_attributeDescriptionVO = attributeDescriptionVO;
			_objectsList = objectsList;
			_pageLinks = pageLinks;
		}

		public function get group():uint
		{
			return _group;
		}
		
		public function set group(value:uint):void
		{
			_group = value;
		}

		public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}

		public function get displayName():String
		{
			return _displayName;
		}
		
		public function set displayName(value:String):void
		{
			_displayName = value;
		}

		public function get objectVO():IVDOMObjectVO
		{
			return _objectVO;
		}
		
		public function set objectVO(value:IVDOMObjectVO):void
		{
			_objectVO = value;
		}

		public function get attributeDescriptionVO():AttributeDescriptionVO
		{
			return _attributeDescriptionVO;
		}
		
		public function set attributeDescriptionVO(value:AttributeDescriptionVO):void
		{
			_attributeDescriptionVO = value;
		}

		public function get objectsList():Vector.<ObjectListVO>
		{
			return _objectsList;
		}
		
		public function set objectsList(value:Vector.<ObjectListVO>):void
		{
			_objectsList = value;
		}

		public function get pageLinks():Vector.<ObjectListVO>
		{
			return _pageLinks;
		}

		public function set pageLinks(value:Vector.<ObjectListVO>):void
		{
			_pageLinks = value;
		}

		public function get attributeVO():AttributeVO
		{
			return _attributeVO;
		}

		public function set attributeVO(value:AttributeVO):void
		{
			_attributeVO = value;
		}


	}
}