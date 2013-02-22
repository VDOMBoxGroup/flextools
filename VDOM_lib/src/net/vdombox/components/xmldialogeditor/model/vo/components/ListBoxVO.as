package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBoolVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeIntVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentDrop;
	
	public class ListBoxVO extends ComponentDrop
	{		
		protected var _width : AttributeIntVO;
		protected var _height : AttributeIntVO;
		protected var _multiple : AttributeBoolVO;
		
		public function ListBoxVO(value:XML)
		{
			super(value);
			
			name = "ListBox";
			
			if ( value && value.@width[0] )
				width = new AttributeIntVO( "width", value.@width );
			else
				width = new AttributeIntVO( "width", 0 );
			
			if ( value && value.@height[0] )
				height = new AttributeIntVO( "height", value.@height );
			else
				height = new AttributeIntVO( "height", 0 );
			
			if ( value && value.@multiple[0] && value.@multiple == "true" )
				multiple = new AttributeBoolVO( "multiple", true );
			else
				multiple = new AttributeBoolVO( "multiple", false );
			
		}
		
		public function get multiple():AttributeBoolVO
		{
			return _multiple;
		}

		public function set multiple(value:AttributeBoolVO):void
		{
			_multiple = value;
		}

		public function get height():AttributeIntVO
		{
			return _height;
		}

		public function set height(value:AttributeIntVO):void
		{
			_height = value;
		}

		public function get width():AttributeIntVO
		{
			return _width;
		}
		
		public function set width(value:AttributeIntVO):void
		{
			_width = value;
		}
		
		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( width );
			_attributes.addItem( height );
			_attributes.addItem( multiple );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( sort );
			_attributes.addItem( options );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <ListBox></ListBox>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@width = width.value;
			xml.@height = height.value;
			xml.@multiple = multiple.value;
			xml.@sort = sort.value;
			xml.@['class'] = className.value;
			
			var xml2 : XML = <Properties></Properties>;
			
			xml2.appendChild( options.toXML() );
			xml2.appendChild( <Property name="toolTip">{ toolTip.value }</Property> );
			
			xml.appendChild( xml2 );
			
			return xml;
		}

	}
}