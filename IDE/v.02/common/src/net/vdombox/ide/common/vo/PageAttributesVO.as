package net.vdombox.ide.common.vo
{
	public class PageAttributesVO
	{
		public function PageAttributesVO( pageVO : PageVO )
		{
			_pageVO = pageVO;
			
			_attributes = [];
			_pageLinks = [];
			_objectsList = [];
		}

		private var _pageVO : PageVO;

		private var _attributes : Array;

		private var _pageLinks : Array;

		private var _objectsList : Array;

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}
		
		public function get attributes() : Array
		{
			return _attributes;
		}

		public function set attributes( value : Array ) : void
		{
			_attributes = value;
		}
		
		public function get pageLinks() : Array
		{
			return _pageLinks;
		}

		public function get objectsList() : Array
		{
			return _objectsList;
		}

		public function setXMLDescription( xmlDescription : XML ) : void
		{
			var attributesXML : XML = xmlDescription.Attributes[ 0 ];
			var pageLinksXML : XML = xmlDescription.Pagelink[ 0 ];
			var objectsListXML : XML = xmlDescription.Objectlist[ 0 ];

			if ( attributesXML && attributesXML.length() > 0 )
				processAttributes( attributesXML );

			if ( pageLinksXML && pageLinksXML.length() > 0 )
				processPageLink( pageLinksXML );

			if ( objectsListXML && objectsListXML.length() > 0 )
				processObjectList( objectsListXML );
		}
		
		
		
		public function getChangedAttributes() : Array
		{
			var result : Array = [];
			
			var attributeVO : AttributeVO;
			for each ( attributeVO in attributes )
			{
				if( attributeVO.defaultValue != attributeVO.value )
				{
					result.push( attributeVO );
				}
			}
			
			return result;
		}

		private function processAttributes( attributesXML : XML ) : void
		{
			var attributeVO : AttributeVO;

			for each ( var attributeXML : XML in attributesXML.* )
			{
				attributeVO = new AttributeVO( attributeXML.@Name, attributeXML[ 0 ] );
				_attributes.push( attributeVO );
			}
		}

		private function processPageLink( pageLinksXML : XML ) : void
		{
			var pageLinkVO : PageLinkVO;

			for each ( var pageLinkXML : XML in pageLinksXML.* )
			{
				pageLinkVO = new PageLinkVO();
				pageLinkVO.id = pageLinkXML.@ID;
				pageLinkVO.name = pageLinkXML.@Name;
				_pageLinks.push( pageLinkVO );
			}
		}

		private function processObjectList( objectsListXML : XML ) : void
		{
			var objectListVO : ObjectListVO;

			for each ( var objectListXML : XML in objectsListXML.* )
			{
				objectListVO = new ObjectListVO();
				objectListVO.id = objectsListXML.@ID;
				objectListVO.name = objectsListXML.@Name;
				_objectsList.push( objectListVO );
			}
		}
	}
}